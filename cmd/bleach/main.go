package main

import (
	"fmt"
	"os"

	"bleach/internal/tui/dashboard"
	"bleach/internal/tui/menu"
	"bleach/internal/ops"
	"bleach/internal/tui/styles"
	
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type appsState int
const (
	stateDashboard appsState = iota
	stateRunning
)

const Version = "v1.0.0"

type model struct {
	width     int
	height    int
	state     appsState
	
	dashboard dashboard.Model
	menu      menu.Model
	
	outputLog string 
}

func initialModel() model {
	return model{
		dashboard: dashboard.NewModel(),
		menu:      menu.NewModel(),
		outputLog: fmt.Sprintf("Ready (v%s). Select an action.", Version),
	}
}

func (m model) Init() tea.Cmd {
	return tea.Batch(m.dashboard.Init(), m.menu.Init())
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmds []tea.Cmd

	switch msg := msg.(type) {
	case tea.KeyMsg:
		if msg.String() == "q" || msg.String() == "ctrl+c" {
			return m, tea.Quit
		}
		// If running, ignore keys or allow cancel?
		if m.state == stateRunning {
			return m, nil 
		}

	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		
		// Resize Dashboard
		var dCmd tea.Cmd
		m.dashboard, dCmd = m.dashboard.Update(msg)
		cmds = append(cmds, dCmd)
		
		// Resize Menu (Bottom Left)
		// Logic: Menu gets half width? or full width bottom?
		// Design said: Bottom Left = Menu, Bottom Right = Output.
		// Let's pass half width to menu.
		halfWidth := (m.width / 2) - 4
		m.menu.Width = halfWidth
		m.menu, _ = m.menu.Update(msg) // just to update width
		
	case ops.OpResultMsg:
		m.state = stateDashboard
		if msg.Err != nil {
			m.outputLog = fmt.Sprintf("Error: %v\n%s", msg.Err, msg.Output)
		} else {
			m.outputLog = fmt.Sprintf("Success:\n%s", msg.Output)
		}
		// Clear selection
		m.menu.Selected = nil
	}
	
	// Route messages to components
	// Dashboard always updates (ticks)
	var dCmd tea.Cmd
	m.dashboard, dCmd = m.dashboard.Update(msg)
	cmds = append(cmds, dCmd)

	// Menu updates only if not running
	if m.state == stateDashboard {
		newMenu, mCmd := m.menu.Update(msg)
		m.menu = newMenu
		cmds = append(cmds, mCmd)
		
		// Check selection
		if m.menu.Selected != nil {
			// Trigger Action
			switch m.menu.Selected.Title {
			case "Exit":
				return m, tea.Quit
			case "System Cleanup":
				m.state = stateRunning
				m.outputLog = "Running System Cleanup... (Password may be required in terminal if not cached)"
				cmds = append(cmds, ops.RunCleanupCmd())
			case "System Updates":
				m.state = stateRunning
				m.outputLog = "Running System Updates..."
				cmds = append(cmds, ops.RunUpdateCmd())
			case "Maintenance":
				m.state = stateRunning
				m.outputLog = "Running Maintenance..."
				cmds = append(cmds, ops.RunMaintenanceCmd())
			case "View Logs":
				m.outputLog = "Log viewing not implemented yet."
				m.menu.Selected = nil
			}
		}
	}

	return m, tea.Batch(cmds...)
}

func (m model) View() string {
	if m.width == 0 {
		return "Initializing..."
	}
	
	// 1. Dashboard (Top)
	topView := m.dashboard.View()
	
	// 2. Bottom Area
	// Left: Menu
	menuView := m.menu.View()
	
	// Right: Output Log
	// Calculate width for right box
	rWidth := m.width - m.menu.Width - 6 // margin
	outputView := styles.Panel.Width(rWidth).Height(6).Render(
		lipgloss.JoinVertical(lipgloss.Left, 
			styles.Label.Render("OUTPUT"), 
			styles.Value.Render(truncate(m.outputLog, 200)), // simple truncate
		),
	)
	
	bottomView := lipgloss.JoinHorizontal(lipgloss.Top, menuView, outputView)
	
	return lipgloss.JoinVertical(lipgloss.Left, topView, bottomView)
}

func truncate(s string, max int) string {
	if len(s) > max {
		return s[:max] + "..."
	}
	return s
}

func main() {
	// Enable mouse? tea.WithMouseCellMotion()
	p := tea.NewProgram(initialModel(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Error: %v", err)
		os.Exit(1)
	}
}
