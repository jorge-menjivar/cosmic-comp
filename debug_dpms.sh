#!/bin/bash

# Debug script for COSMIC monitor wake issues
# Run this when you experience the issue

echo "=== COSMIC Monitor Debug Information ===" > cosmic_monitor_debug.log
echo "Date: $(date)" >> cosmic_monitor_debug.log
echo "" >> cosmic_monitor_debug.log

# Check DRM connectors
echo "=== DRM Connector Status ===" >> cosmic_monitor_debug.log
for conn in /sys/class/drm/card*/card*-*/status; do
    if [ -f "$conn" ]; then
        echo "$conn: $(cat $conn)" >> cosmic_monitor_debug.log
    fi
done
echo "" >> cosmic_monitor_debug.log

# Check DPMS status
echo "=== DPMS Status ===" >> cosmic_monitor_debug.log
for conn in /sys/class/drm/card*/card*-*/dpms; do
    if [ -f "$conn" ]; then
        echo "$conn: $(cat $conn 2>/dev/null || echo 'N/A')" >> cosmic_monitor_debug.log
    fi
done
echo "" >> cosmic_monitor_debug.log

# Get kernel logs related to DRM
echo "=== Recent DRM Kernel Messages ===" >> cosmic_monitor_debug.log
sudo dmesg | grep -E "drm|DPMS|connector|display" | tail -50 >> cosmic_monitor_debug.log
echo "" >> cosmic_monitor_debug.log

# Get display configuration
echo "=== Current Display Configuration ===" >> cosmic_monitor_debug.log
if command -v cosmic-randr &> /dev/null; then
    cosmic-randr >> cosmic_monitor_debug.log 2>&1
else
    echo "cosmic-randr not found" >> cosmic_monitor_debug.log
fi
echo "" >> cosmic_monitor_debug.log

# Check for GPU info
echo "=== GPU Information ===" >> cosmic_monitor_debug.log
lspci -vnn | grep -E "VGA|Display|3D" >> cosmic_monitor_debug.log
echo "" >> cosmic_monitor_debug.log

# Get systemd journal for cosmic-comp
echo "=== Recent cosmic-comp logs ===" >> cosmic_monitor_debug.log
journalctl --user -u cosmic-comp -n 100 --no-pager >> cosmic_monitor_debug.log 2>&1

echo "Debug information saved to cosmic_monitor_debug.log"
echo ""
echo "To monitor in real-time, run:"
echo "  sudo dmesg -w | grep -E 'drm|DPMS|connector'"