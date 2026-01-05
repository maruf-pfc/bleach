package sys

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
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
	Distro   string
	PkgCount string
	Procs    uint64
	Threads  string
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
		Distro:   fmt.Sprintf("%s %s", h.Platform, h.PlatformVersion),
		PkgCount: getPkgCount(),
		Procs:    h.Procs,
		Threads:  getThreadCount(),
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
	info.CPU = GetCPUPercent()

	return info
}

func getPkgCount() string {
	// Try apt/dpkg first
	out, err := exec.Command("sh", "-c", "dpkg -l | grep ^ii | wc -l").Output()
	if err == nil {
		return strings.TrimSpace(string(out)) + " (dpkg)"
	}
	// Try rpm
	out, err = exec.Command("sh", "-c", "rpm -qa | wc -l").Output()
	if err == nil {
		return strings.TrimSpace(string(out)) + " (rpm)"
	}
	return "?"
}

func getThreadCount() string {
	out, err := exec.Command("sh", "-c", "ps -eLf | wc -l").Output()
	if err == nil {
		return strings.TrimSpace(string(out))
	}
	return "?"
}

func GetCPUPercent() float64 {
	p, _ := cpu.Percent(100*time.Millisecond, false)
	if len(p) > 0 {
		return p[0]
	}
	return 0
}

func formatUptime(seconds uint64) string {
	d := time.Duration(seconds) * time.Second
	return d.Round(time.Minute).String()
}
