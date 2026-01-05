package sys

import (
	"os"
	"time"

	"github.com/shirou/gopsutil/v3/cpu"
	"github.com/shirou/gopsutil/v3/disk"
	"github.com/shirou/gopsutil/v3/host"
	"github.com/shirou/gopsutil/v3/mem"
)

type SystemInfo struct {
	Hostname string
	Kernel   string
	Uptime   string
	Shell    string
	CPU      float64
	RAM      ResourceUsage
	Disk     ResourceUsage
}

type ResourceUsage struct {
	Used    uint64
	Total   uint64
	Percent float64
}

func GetSystemInfo() SystemInfo {
	h, _ := host.Info()
	
	info := SystemInfo{
		Hostname: h.Hostname,
		Kernel:   h.KernelVersion,
		Uptime:   formatUptime(h.Uptime),
		Shell:    os.Getenv("SHELL"),
	}
	
	// Memory
	v, _ := mem.VirtualMemory()
	info.RAM = ResourceUsage{
		Used:    v.Used,
		Total:   v.Total,
		Percent: v.UsedPercent,
	}

	// Disk (Root)
	d, _ := disk.Usage("/")
	info.Disk = ResourceUsage{
		Used:    d.Used,
		Total:   d.Total,
		Percent: d.UsedPercent,
	}

	// CPU
	// We use the helper to get non-blocking or cached CPU
	info.CPU = GetCPUPercent()

	return info
}

func GetCPUPercent() float64 {
	// We use a short interval. For a TUI loop, 100ms is okay-ish but might block UI slightly.
	// ideally we run this in a goroutine/tea.Cmd but for now this is simple.
	// Better: Use TotalPercent with 0 interval (instant) if we calculated delta ourselves, 
	// but gopsutil needs interval for delta.
	// Let's rely on the simplified View update loop time diff or just block 100ms.
	// actually, tea.Tick handles the scheduling, but this call WILL block the Update loop for 100ms.
	// To fix this proper, we'd need a separate Msg for "CPUUpdate".
	// For MVP, blocking 100ms every 1s is acceptable.
	p, _ := cpu.Percent(100*time.Millisecond, false)
	if len(p) > 0 {
		return p[0]
	}
	return 0
}

func formatUptime(seconds uint64) string {
	d := time.Duration(seconds) * time.Second
	// formatting logic...
	return d.String() // simplistic
}
