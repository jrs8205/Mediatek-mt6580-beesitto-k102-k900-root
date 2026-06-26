# BEESITTO K102 / K900 Tablet Root & Optimization Guide

This repository contains the files and scripts to root and optimize cheap Chinese tablets based on the **MediaTek MT6580** chipset running **Android 7.0 (Nougat)** (often fake-reporting as Android 9.0 in Settings/CPU-Z).

By applying these modifications, you will:
1. **Gain Root Access** via Magisk (v30.7+).
2. **Remove Bloatware & Spyware/Trackers** (AutoDialer, Baidu, fake Antutu/CPU-Z benchmarks, MTKLogger, and aggressive DuraSpeed task killers).
3. **Block Ads Systemlessly** using StevenBlack's hosts file.
4. **Boost Performance** by tuning the CPU governor (interactive), I/O scheduler (deadline), zRAM swappiness, Low Memory Killer thresholds, and Dalvik VM limits.
5. **Restore Flash Storage Speed** by automatically running `fstrim` on boot.

---

## 📱 Supported Device Specifications

* **Product Model:** BEESITTO K102 / K900 (and similar MT6580 generic tablets)
* **Chipset:** MediaTek MT6580 (Quad-Core Cortex-A7)
* **RAM:** 1.5 GB
* **Storage:** 16 GB / 32 GB eMMC
* **OS:** Android 7.0 Nougat (Fake-reporting as Android 9.0)
* **Kernel Version:** 3.18.35

---

## 📦 Repository Structure

* `boot-stock.img` - The original unmodified factory boot image.
* `magisk_patched.img` - The stock boot image pre-patched with Magisk v30.7 (ready to flash).
* `logo-stock.img` - The original unmodified boot logo partition backup.
* `hosts` - StevenBlack's unified ad-blocking hosts file.
* `optimizations.sh` - Performance kernel-tweaking startup shell script.
* `optimize_tablet.bat` - Automation script for Windows PCs to deploy files and clean bloatware.

---

## 🚀 Step 1: Flashing the Patched Boot Image (Root)

To write the pre-patched boot image to your tablet, you can use **MTKClient** (recommended since it bypasses locked bootloaders in BROM mode) or standard **Fastboot** if your bootloader is already unlocked.

### Option A: Via MTKClient (BROM Mode)
1. Turn off your tablet completely.
2. Install MTKClient and its drivers on your computer.
3. Open a command prompt/terminal in your MTKClient folder and run:
   ```bash
   python mtk.py w boot magisk_patched.img --noreconnect
   ```
4. Connect the tablet to your computer via USB. MTKClient will detect the device in BROM mode and write the image.
5. Once complete, unplug and power on the tablet. Open the **Magisk** app to verify root access.

### Option B: Via Fastboot
If your bootloader is unlocked:
1. Reboot the tablet into fastboot mode (`adb reboot bootloader`).
2. Run:
   ```bash
   fastboot flash boot magisk_patched.img
   fastboot reboot
   ```

---

## 🛠️ Step 2: Running the Optimization Script

Once the tablet is rooted and booted:
1. Connect the tablet to your computer via USB and ensure **USB Debugging** (ADB) is enabled in Developer Options.
2. Open the Magisk app on the tablet, go to Settings, and ensure that root access is pre-granted to shell commands or you respond to the prompt.
3. Double-click and run `optimize_tablet.bat` on your Windows PC.
4. The script will automatically:
   * Disable known spyware, trackers, MTK debug loggers, and aggressive background killers.
   * Configure the CPU governor to scale up faster under load and react to storage input/output (I/O).
   * Optimize zRAM swappiness and Low Memory Killer limits to prevent background web browser tabs from closing.
   * Set the disk I/O scheduler to `deadline` and increase the read-ahead buffer to 512KB.
   * Enable hardware GPU rendering and Dalvik VM heap optimizations.
   * Install the systemless adblocker.
5. Reboot the tablet when prompted.

---

## 🛑 List of Removed Bloatware & Spyware

The script uninstalls the following pre-installed packages for `user 0`:
* `com.example` (AutoDialer / adware)
* `com.baidu.map.location` (Baidu background location tracker)
* `com.antutu.ABenchMark` (Pre-installed spoofed benchmark app)
* `com.cpuid.cpu_z` (Pre-installed spoofed CPU-Z app showing fake specifications)
* `com.mediatek.mtklogger` (Heavy logging tool that consumes CPU and writes gigabytes of debug logs to storage)
* `com.mediatek.duraspeed` (Aggressive process killer that causes background services/notifications to drop and WiFi to disconnect)

---

## 🌍 Installing Apps & Modern Web Browsing

Since the tablet runs Android 7.0, the stock Google Play Store is often outdated and fails to download newer updates.
1. Download and install **Aurora Store** (an open-source client for the Google Play Store).
2. Open Aurora Store's settings and change the **Installation Method** to **Root**.
3. Download and install updates for **Google Play Services** and **Android System WebView** (version 117+ is compatible with Android 7.0).
4. Use modern, lightweight browsers such as **Kiwi Browser** or **Firefox Lite** for the best tab-management experience.
