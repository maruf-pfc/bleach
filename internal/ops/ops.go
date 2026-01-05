package ops

import (
	"os/exec"
	"time"
	
	tea "github.com/charmbracelet/bubbletea"
)

// OpResultMsg wraps the result of an operation
type OpResultMsg struct {
	Output string
	Err    error
}

// RunCleanupCmd returns a tea.Cmd that executes the cleanup
func RunCleanupCmd() tea.Cmd {
	return func() tea.Msg {
		// Simulate work or run real command
		// Real: exec.Command("sudo", "apt", "autoremove", "-y").Output()
		// For safety in this demo, strict real commands:
		
		cmd := exec.Command("bash", "-c", "sudo apt-get autoremove -y && sudo apt-get clean")
		out, err := cmd.CombinedOutput()
		
		return OpResultMsg{Output: string(out), Err: err}
	}
}

// RunUpdateCmd
func RunUpdateCmd() tea.Cmd {
	return func() tea.Msg {
		cmd := exec.Command("bash", "-c", "sudo apt-get update")
		out, err := cmd.CombinedOutput()
		return OpResultMsg{Output: string(out), Err: err}
	}
}

// Emulate a maintenance task
func RunMaintenanceCmd() tea.Cmd {
	return func() tea.Msg {
		time.Sleep(2 * time.Second)
		return OpResultMsg{Output: "Maintenance routines executed successfully (Logs rotated).", Err: nil}
	}
}
