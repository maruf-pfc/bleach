package ops

import (
	"os/exec"
)

// Msg for completion
type OpDoneMsg struct{ Err error }

// CmdCheckSudo prompts for sudo password (caches credential)
func CmdCheckSudo() *exec.Cmd {
	return exec.Command("sudo", "-v")
}

// CmdCleanupAPT returns the command structure
func CmdCleanupAPT() *exec.Cmd {
	return exec.Command("bash", "-c", "sudo apt-get autoremove -y && sudo apt-get autoclean -y && sudo apt-get clean")
}

func CmdUpdateSystem() *exec.Cmd {
	return exec.Command("bash", "-c", "sudo apt-get update && sudo apt-get upgrade -y")
}

// CmdMaintenance returns the command structure
func CmdMaintenance() *exec.Cmd {
	return exec.Command("bash", "-c", "sudo fstrim -av && sudo journalctl --vacuum-time=3d")
}

func CmdTrash() *exec.Cmd {
	return exec.Command("bash", "-c", "rm -rf ~/.local/share/Trash/*")
}

func CmdCache() *exec.Cmd {
	return exec.Command("bash", "-c", "rm -rf ~/.cache/thumbnails/*")
}

func CmdFixLocks() *exec.Cmd {
	cmd := `
	sudo killall apt apt-get 2>/dev/null || true
	sudo rm -f /var/lib/apt/lists/lock
	sudo rm -f /var/cache/apt/archives/lock
	sudo rm -f /var/lib/dpkg/lock*
	sudo dpkg --configure -a
	`
	return exec.Command("bash", "-c", cmd)
}

// --- Developer & Deep Cleanup Ops ---

func CmdCleanDocker() *exec.Cmd {
	return exec.Command("bash", "-c", "docker system prune -f 2>/dev/null || true")
}

func CmdCleanNode() *exec.Cmd {
	return exec.Command("bash", "-c", "npm cache clean --force 2>/dev/null; pnpm store prune 2>/dev/null || true")
}

// CmdCleanPython removes cache but respects git/safety
func CmdCleanPython() *exec.Cmd {
	cmd := `
	rm -rf ~/.cache/pip ~/.cache/pypoetry ~/.cache/virtualenv 2>/dev/null
	find "$HOME/projects" "$HOME/code" "$HOME/dev" \
		-path "*/.git" -prune -o \
		-type d -name "__pycache__" \
		-exec rm -rf {} + 2>/dev/null || true
	`
	return exec.Command("bash", "-c", cmd)
}

func CmdCleanIDEs() *exec.Cmd {
	cmd := `
	rm -rf ~/.config/Code/Cache ~/.config/Code/CachedData 2>/dev/null
	rm -rf ~/.cache/JetBrains 2>/dev/null
	`
	return exec.Command("bash", "-c", cmd)
}

func CmdDeepSystemClean() *exec.Cmd {
	// Combines APT, Logs, Snap, Flatpak, Temp, SSD
	cmd := `
	echo "Cleaning APT..."
	sudo apt-get autoremove -y && sudo apt-get autoclean -y && sudo apt-get clean
	
	echo "Cleaning System Logs..."
	sudo journalctl --vacuum-size=100M
	
	echo "Cleaning Snap/Flatpak..."
	sudo rm -rf /var/lib/snapd/cache/* 2>/dev/null
	flatpak uninstall --unused -y 2>/dev/null
	
	echo "Cleaning Temp & Trimming SSD..."
	sudo rm -rf /tmp/*
	sudo fstrim -av
	`
	return exec.Command("bash", "-c", cmd)
}

func CmdFullClean() *exec.Cmd {
	cmd := `
	# 1. System
	sudo apt-get autoremove -y && sudo apt-get autoclean -y
	sudo journalctl --vacuum-size=100M
	sudo rm -rf /var/lib/snapd/cache/* 2>/dev/null
	flatpak uninstall --unused -y 2>/dev/null
	sudo rm -rf /tmp/*
	sudo fstrim -av

	# 2. Docker
	docker system prune -f 2>/dev/null || true
	
	# 3. Node/JS
	npm cache clean --force 2>/dev/null || true
	pnpm store prune 2>/dev/null || true
	rm -rf ~/node_modules 2>/dev/null
	
	# 4. Python
	rm -rf ~/.cache/pip ~/.cache/pypoetry 2>/dev/null
	
	# 5. IDEs
	rm -rf ~/.config/Code/Cache 2>/dev/null
	rm -rf ~/.cache/JetBrains 2>/dev/null
	`
	return exec.Command("bash", "-c", cmd)
}


