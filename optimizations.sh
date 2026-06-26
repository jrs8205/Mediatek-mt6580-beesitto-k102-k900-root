#!/system/bin/sh
# Wait for system boot to settle down
sleep 20

# -------------------------------------------------------------
# 1. CPU governor tuning (interactive)
# -------------------------------------------------------------
# Since cpu1-cpu7 cpufreq files symlink to cpu0, setting cpu0 is sufficient,
# but we write to the global paths to ensure it applies system-wide.
if [ -d "/sys/devices/system/cpu/cpufreq/interactive" ]; then
  # Make CPU ramp up faster when load is >= 80% (default is usually 90% or 99%)
  echo 80 > /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
  # Target loads: more aggressive ramp-up
  echo "80 1300000:90" > /sys/devices/system/cpu/cpufreq/interactive/target_loads
  # Enable I/O wait awareness: CPU will clock up when loading files/web assets
  echo 1 > /sys/devices/system/cpu/cpufreq/interactive/io_is_busy
  # Sample load more frequently (10ms instead of 20ms) for faster response
  echo 10000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
  # Allow downscaling faster when idle (20ms instead of 80ms) to save battery
  echo 20000 > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
fi

# -------------------------------------------------------------
# 2. Disk I/O & eMMC optimizations
# -------------------------------------------------------------
# Set IO scheduler to deadline (lower overhead than cfq on flash)
# and increase read-ahead to 512KB (improves sequential reading)
for block_dev in /sys/block/mmcblk*; do
  if [ -f "$block_dev/queue/scheduler" ]; then
    echo deadline > "$block_dev/queue/scheduler"
  fi
  if [ -f "$block_dev/queue/read_ahead_kb" ]; then
    echo 512 > "$block_dev/queue/read_ahead_kb"
  fi
done

# Run fstrim to discard unused blocks and restore flash performance
vdc fstrim dotrim

# -------------------------------------------------------------
# 3. Virtual Memory & zRAM tweaks
# -------------------------------------------------------------
# Increase swappiness to 100 to utilize zRAM more aggressively
sysctl -w vm.swappiness=100
# Reclaim cached directories/inodes at standard rate
sysctl -w vm.vfs_cache_pressure=100
# Start flushing dirty pages to swap/zram earlier to prevent sudden spikes
sysctl -w vm.dirty_background_ratio=5
sysctl -w vm.dirty_ratio=15
# Maintain a bit more extra free pages for allocations
sysctl -w vm.extra_free_kbytes=16384

# -------------------------------------------------------------
# 4. Low Memory Killer (LMK) optimization
# -------------------------------------------------------------
# Slightly relax minfree thresholds to allow more background processes/tabs
# to stay in memory before being terminated by the OS.
# Old: 18432,23040,27648,32256,36864,46080 (72MB, 90MB, 108MB, 126MB, 144MB, 180MB)
# New: 12288,15360,18432,21504,24576,30720 (48MB, 60MB, 72MB, 84MB, 96MB, 120MB)
if [ -f "/sys/module/lowmemorykiller/parameters/minfree" ]; then
  echo "12288,15360,18432,21504,24576,30720" > /sys/module/lowmemorykiller/parameters/minfree
fi

# -------------------------------------------------------------
# 5. System Properties & Rendering tweaks
# -------------------------------------------------------------
# Force hardware GPU rendering for UI & 2D canvas
resetprop debug.sf.hw 1
resetprop debug.egl.hw 1
resetprop video.accelerate.hw 1
resetprop debug.performance.tuning 1
# Disable screen dithering (minor GPU load reduction)
resetprop persist.sys.use_dithering 0
# Allow purging cached assets from memory quicker under pressure
resetprop persist.sys.purgeable_assets 1
# Increase touch/scroll event polling rate for smoother response
resetprop windowsmgr.max_events_per_sec 150
# Limit max background apps to prevent memory exhaustion
resetprop ro.config.max_starting_bg 8
resetprop ro.sys.fw.bg_apps_limit 8

# Dalvik VM tuning for 1.5GB RAM
# Increase heapgrowthlimit slightly (from 128m to 192m) for heavy apps/web pages,
# and adjust heap size and starting allocation.
resetprop dalvik.vm.heapgrowthlimit 192m
resetprop dalvik.vm.heapsize 384m
resetprop dalvik.vm.heapstartsize 8m

# Disable MTK logger if not already disabled
resetprop persist.sys.mtklog.no_ui 1
resetprop persist.sys.mtklog.filter 0
