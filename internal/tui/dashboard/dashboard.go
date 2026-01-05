package dashboard

import (
	"fmt"
	"strings"
	"time"

	"bleach/internal/sys"
	"bleach/internal/tui/styles"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type Model struct {
	Width   int
	Height  int
	SysInfo sys.SystemInfo
}

func NewModel() Model {
	return Model{
		SysInfo: sys.GetSystemInfo(),
	}
}

func (m Model) Init() tea.Cmd {
	// Start the ticker immediately
	return tickCommand()
}

type TickMsg time.Time

func tickCommand() tea.Cmd {
	return tea.Tick(time.Second, func(t time.Time) tea.Msg {
		return TickMsg(t)
	})
}

func (m Model) Update(msg tea.Msg) (Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.Width = msg.Width
		m.Height = msg.Height
	case TickMsg:
		// Refresh System Info
		m.SysInfo = sys.GetSystemInfo()
		return m, tickCommand()
	}
	return m, nil
}

func (m Model) View() string {
	if m.Width == 0 {
		return ""
	}

	// Calculate Panel Widths
	// We want roughly 50/50 split on large screens
	// Use styles.Panel (with borders)
	// Available width = m.Width - 2 (outer margin/border if any)
	
	halfWidth := (m.Width / 2) - 4 // minus borders/padding

	leftPanel := m.renderLeftPanel(halfWidth)
	rightPanel := m.renderRightPanel(halfWidth)

	if m.Width > 90 {
		// Side-by-Side
		return lipgloss.JoinHorizontal(lipgloss.Top, leftPanel, rightPanel)
	}
	
	// Stacked
	return lipgloss.JoinVertical(lipgloss.Left, leftPanel, rightPanel)
}

func (m Model) renderLeftPanel(width int) string {
	// Logo
	logo := styles.Logo.Render(`
 ____  _each
| __ )| | ___  __ _  ___| |__
|  _ \| |/ _ \/ _` + "`" + ` |/ __| '_ \
| |_) | |  __/ (_| | (__| | | |
|____/|_|\___|\__,_|\___|_| |_|`)

	// Info
	info := fmt.Sprintf("\n\nHost:   %s\nKernel: %s\nUptime: %s\nShell:  %s",
		m.SysInfo.Hostname,
		m.SysInfo.Kernel,
		m.SysInfo.Uptime,
		m.SysInfo.Shell,
	)

	return styles.Panel.Width(width).Render(
		lipgloss.JoinHorizontal(lipgloss.Top, logo, styles.Value.Render(info)),
	)
}

func (m Model) renderRightPanel(width int) string {
	// Placeholders for bars (Will use bubbles/progress later)
	// For now simple text bars
	
	cpuBar := m.makeProgressBar("CPU ", m.SysInfo.CPU, width-10)
	ramBar := m.makeProgressBar("RAM ", m.SysInfo.RAM.Percent, width-10)
	diskBar := m.makeProgressBar("DFT ", m.SysInfo.Disk.Percent, width-10) // DFT = Disk / Root

	return styles.Panel.Width(width).Render(
		lipgloss.JoinVertical(lipgloss.Left, cpuBar, "", ramBar, "", diskBar),
	)
}

func (m Model) makeProgressBar(label string, percent float64, width int) string {
	// Simple manual bar for now
	// [|||||     ]
	barWidth := width - 15
	if barWidth < 5 { barWidth = 5 }
	
	numBars := int((percent / 100) * float64(barWidth))
	if numBars > barWidth { numBars = barWidth }
	
	filled := strings.Repeat("|", numBars)
	empty := strings.Repeat(" ", barWidth-numBars)
	
	return fmt.Sprintf("%s [%s] %.1f%%", label, filled+empty, percent)
}
