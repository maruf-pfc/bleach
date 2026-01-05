package styles

import "github.com/charmbracelet/lipgloss"

var (
	// Bleach Theme Colors
	ColorPrimary   = lipgloss.Color("#7D56F4") // Purple
	ColorSecondary = lipgloss.Color("#35F537") // Acid Green (or similar)
	ColorAccent    = lipgloss.Color("#FAFAFA") // White/Bright
	ColorMuted     = lipgloss.Color("#626262") // Grey
	
	// Base Styles
	Base = lipgloss.NewStyle().Foreground(ColorAccent)

	// Panel Styles
	Panel = lipgloss.NewStyle().
		Border(lipgloss.RoundedBorder()).
		BorderForeground(ColorPrimary).
		Padding(1, 1)

	// Text Styles
	Label = lipgloss.NewStyle().
		Bold(true).
		Foreground(ColorPrimary)

	Value = lipgloss.NewStyle().
		Foreground(ColorAccent)
		
	// Logo Style
	Logo = lipgloss.NewStyle().
		Bold(true).
		Foreground(ColorPrimary)
)
