package menu

import (
	"fmt"
	"bleach/internal/tui/styles"
	tea "github.com/charmbracelet/bubbletea"
)

type Item struct {
	Title string
	Permission string // specific permission or module name
}

type Model struct {
	Items    []Item
	Cursor   int
	Selected *Item
	Width    int
}

func NewModel() Model {
	return Model{
		Items: []Item{
			{Title: "System Cleanup"},
			{Title: "System Updates"},
			{Title: "Maintenance"},
			{Title: "View Logs"},
			{Title: "Exit"},
		},
		Cursor: 0,
	}
}

func (m Model) Init() tea.Cmd {
	return nil
}

func (m Model) Update(msg tea.Msg) (Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "up", "k":
			if m.Cursor > 0 {
				m.Cursor--
			}
		case "down", "j":
			if m.Cursor < len(m.Items)-1 {
				m.Cursor++
			}
		case "enter":
			// Select the item
			selected := m.Items[m.Cursor]
			m.Selected = &selected
			// We return a command or let parent handle the selection state check
		}
	case tea.WindowSizeMsg:
		m.Width = msg.Width
	}
	return m, nil
}

func (m Model) View() string {
	var s string
	
	// Title
	s += styles.Label.Render("  :: ACTIONS ::") + "\n"

	for i, item := range m.Items {
		cursor := "  " // 2 spaces
		title := item.Title
		
		if m.Cursor == i {
			cursor = "> " // arrow
			title = styles.Label.Render(title) // Highlighted
		} else {
			title = styles.Value.Render(title)
		}
		
		s += fmt.Sprintf("%s%s\n", cursor, title)
	}

	return styles.Panel.Width(m.Width).Render(s)
}
