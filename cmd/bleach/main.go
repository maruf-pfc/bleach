package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"

	"bleach/internal/tui/dashboard"
	"bleach/internal/tui/menu"
	"bleach/internal/ops"
	"bleach/internal/tui/styles"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

const Version = "v1.0.1"

type appState int
const (
	stateIdle appState = iota
	stateAuth
	stateStreaming
)

type lineMsg string
type streamDoneMsg struct{ err error }
type authResultMsg struct{ err error }

var activeScanner *bufio.Scanner

type model struct {
	width, height int
	state         appState
	
	dashboard dashboard.Model
	menu      menu.Model
	
	logs      []string
	pendingOp *exec.Cmd
}

func initialModel() model {
	return model{
		dashboard: dashboard.NewModel(),
		menu:      menu.NewModel(),
		state:     stateIdle,
		logs:      []string{fmt.Sprintf("Ready (%s). Select an action.", Version)},
	}
}

func (m model) Init() tea.Cmd {
	return tea.Batch(m.dashboard.Init(), m.menu.Init())
}

func nextLine() tea.Cmd {
	return func() tea.Msg {
		if activeScanner != nil && activeScanner.Scan() {
			return lineMsg(activeScanner.Text())
		}
		return nil
	}
}

func waitCmd(cmd *exec.Cmd) tea.Cmd {
	return func() tea.Msg {
		err := cmd.Wait()
		return streamDoneMsg{err}
	}
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmds []tea.Cmd

	switch msg := msg.(type) {
	
	case tea.KeyMsg:
		if m.state == stateStreaming {
			if msg.String() == "ctrl+c" { return m, tea.Quit }
			return m, nil
		}
		switch msg.String() {
		case "q", "ctrl+c": return m, tea.Quit
		case "enter":
			if m.menu.Selected != nil {
				return m.handleMenuSelect(m.menu.Selected.Title)
			}
		}

	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		var cmd tea.Cmd
		m.dashboard, cmd = m.dashboard.Update(msg)
		cmds = append(cmds, cmd)
		m.menu.Width = (m.width / 2) - 4
		m.menu, cmd = m.menu.Update(msg)
		cmds = append(cmds, cmd)

	// Auth Finished
	case authResultMsg:
		if msg.err != nil {
			m.logs = append(m.logs, "Authentication failed.")
			m.state = stateIdle
			m.pendingOp = nil
			return m, nil
		}
		
		m.logs = []string{"Authentication successful.", "Starting operation..."}
		m.state = stateStreaming
		
		cmd := m.pendingOp
		stdout, _ := cmd.StdoutPipe()
		stderr, _ := cmd.StderrPipe()
		
		if err := cmd.Start(); err != nil {
			m.logs = append(m.logs, fmt.Sprintf("Error: %v", err))
			m.state = stateIdle
			return m, nil
		}

		activeScanner = bufio.NewScanner(io.MultiReader(stdout, stderr))
		return m, tea.Batch(nextLine(), waitCmd(cmd))

	// Stream Line
	case lineMsg:
		m.logs = append(m.logs, string(msg))
		maxLines := 20
		if len(m.logs) > maxLines {
			m.logs = m.logs[len(m.logs)-maxLines:]
		}
		return m, nextLine()

	// Stream Done
	case streamDoneMsg:
		activeScanner = nil
		m.state = stateIdle
		if msg.err != nil {
			m.logs = append(m.logs, fmt.Sprintf("Failed: %v", msg.err))
		} else {
			m.logs = append(m.logs, "Done.")
		}
		return m, nil
	}

	// Update Components
	if m.state == stateIdle {
		var cmd tea.Cmd
		m.dashboard, cmd = m.dashboard.Update(msg)
		cmds = append(cmds, cmd)
		m.menu, cmd = m.menu.Update(msg)
		cmds = append(cmds, cmd)
	}

	return m, tea.Batch(cmds...)
}

func (m model) handleMenuSelect(title string) (tea.Model, tea.Cmd) {
	var op *exec.Cmd
	switch title {
	case "Exit": return m, tea.Quit
	case "View Logs": 
		m.logs = append(m.logs, "Log viewing not implemented yet.")
		return m, nil
	case "Quick Clean (System)": op = ops.CmdDeepSystemClean()
	case "Deep Clean (Dev + Sys)": 
		op = ops.CmdFullClean()
	case "System Updates": op = ops.CmdUpdateSystem()
	case "Maintenance": op = ops.CmdMaintenance()
	}

	if op != nil {
		m.pendingOp = op
		m.state = stateAuth
		return m, tea.ExecProcess(ops.CmdCheckSudo(), func(err error) tea.Msg {
			return authResultMsg{err}
		})
	}
	return m, nil
}

func (m model) View() string {
	if m.width == 0 { return "Loading..." }
	
	m.dashboard.Width = m.width
	topView := m.dashboard.View()
	topHeight := lipgloss.Height(topView)
	
	mainHeight := m.height - topHeight - 3
	if mainHeight < 5 { mainHeight = 5 }
	
	sidebarWidth := 28
	m.menu.Width = sidebarWidth - 4
	
	// Ensure menu doesn't blow up vertical space
	menuContent := m.menu.View() // just lines
	
	menuView := styles.Panel.Width(sidebarWidth - 2).Height(mainHeight - 2).Render(
		lipgloss.JoinVertical(lipgloss.Left,
			styles.Label.Render("MENU"),
			menuContent,
		),
	)
	
	logWidth := m.width - sidebarWidth - 4
	if logWidth < 20 { logWidth = 20 }
	
	logContent := strings.Join(m.logs, "\n")
	
	statusView := styles.Panel.Width(logWidth).Height(mainHeight - 2).Render(
		lipgloss.JoinVertical(lipgloss.Left, 
			styles.Label.Render("STATUS / LOGS"), 
			styles.Value.Width(logWidth-2).Render(logContent), 
		),
	)
	
	bottomView := lipgloss.JoinHorizontal(lipgloss.Top, menuView, statusView)
	
	return lipgloss.JoinVertical(lipgloss.Left, topView, bottomView)
}

func main() {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Error: %v", err)
		os.Exit(1)
	}
}
