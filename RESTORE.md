# MacBook 12" 2017 — Restore from Btrfs Snapshots

This guide covers restoring the Arch Linux TUI Magic setup on the MacBook 12" (MacBook10,1) from the btrfs snapshots stored on the Pi 5.

## What's Backed Up

All backups are on **Pi 5** at `/home/justin/macbook-snapshots/`:

| File | Contents |
|------|----------|
| `root_2026-02-14_tui-magic-v2.btrfs` | Root filesystem (/) — all system configs, packages, services |
| `home_2026-02-14_tui-magic-v2.btrfs` | Home directory (/home) — user configs, dotfiles, tmux, ranger |
| `boot-backup-2026-02-14.tar.gz` | /boot partition — **custom kernel 6.19**, initramfs, bootloader |
| `fstab-backup.txt` | Filesystem table |
| `blkid-backup.txt` | Partition UUIDs |
| `partition-table.txt` | Disk partition layout |

> **IMPORTANT**: The custom kernel 6.19 is NOT in the Arch repos. It was compiled from source. The boot backup contains the compiled kernel and initramfs. Without it, the system won't boot.

## Partition Layout

```
/dev/nvme0n1p1  EFI (Apple)     — DO NOT TOUCH (macOS boot)
/dev/nvme0n1p2  APFS            — DO NOT TOUCH (macOS)
/dev/nvme0n1p3  NTFS (BOOTCAMP) — Can be wiped if not needed
/dev/nvme0n1p4  FAT32  /boot    — Arch bootloader + kernel 6.19
/dev/nvme0n1p5  btrfs  /        — Arch root (@), home (@home), swap (@swap)
```

**Btrfs subvolume layout on nvme0n1p5:**
```
@       → mounted at /
@home   → mounted at /home
@swap   → mounted at /swap
```

---

## Restore Procedure

### Option A: Restore subvolumes (same disk, partitions intact)

Use this if the partition table is still intact and you just want to roll back.

#### 1. Boot from Arch ISO USB

Download the latest Arch ISO, write to USB:
```bash
# From any machine:
dd if=archlinux.iso of=/dev/sdX bs=4M status=progress
```

Boot the MacBook from USB (hold Option key at startup, select EFI Boot).

#### 2. Connect to WiFi
```bash
iwctl
station wlan0 connect heero
# enter password
exit
```

#### 3. Mount the btrfs partition
```bash
mount /dev/nvme0n1p5 /mnt
```

#### 4. Copy snapshots from Pi 5
```bash
# Get the snapshot files from the Pi
scp justin@192.168.6.6:/home/justin/macbook-snapshots/root_2026-02-14_tui-magic-v2.btrfs /tmp/
scp justin@192.168.6.6:/home/justin/macbook-snapshots/home_2026-02-14_tui-magic-v2.btrfs /tmp/
scp justin@192.168.6.6:/home/justin/macbook-snapshots/boot-backup-2026-02-14.tar.gz /tmp/
```

#### 5. Replace root and home subvolumes
```bash
# Delete the broken/old subvolumes
btrfs subvolume delete /mnt/@
btrfs subvolume delete /mnt/@home

# Receive the snapshots (creates read-only subvolumes)
btrfs receive /mnt/ < /tmp/root_2026-02-14_tui-magic-v2.btrfs
btrfs receive /mnt/ < /tmp/home_2026-02-14_tui-magic-v2.btrfs

# The snapshots are read-only — create writable copies
btrfs subvolume snapshot /mnt/@_snapshot_2026-02-14_tui-magic-v2 /mnt/@
btrfs subvolume snapshot /mnt/@home_snapshot_2026-02-14_tui-magic-v2 /mnt/@home

# Clean up the read-only intermediates
btrfs subvolume delete /mnt/@_snapshot_2026-02-14_tui-magic-v2
btrfs subvolume delete /mnt/@home_snapshot_2026-02-14_tui-magic-v2
```

#### 6. Restore /boot (kernel 6.19)
```bash
mount /dev/nvme0n1p4 /mnt/@/boot
# Clear old boot contents
rm -rf /mnt/@/boot/*
# Restore the backup
tar xzf /tmp/boot-backup-2026-02-14.tar.gz -C /mnt/@/
```

#### 7. Unmount and reboot
```bash
umount /mnt/@/boot
umount /mnt
reboot
```

Remove the USB drive. The system should boot into the fully configured TUI Magic environment.

---

### Option B: Fresh install + restore (new disk or wiped partitions)

Use this if the partition table is gone and you need to recreate everything.

#### 1. Boot from Arch ISO USB (same as above)

#### 2. Connect to WiFi (same as above)

#### 3. Partition the disk

Reference the backed-up partition table. If preserving macOS:
```bash
# Use gdisk/fdisk to create:
# p4: ~4GB FAT32 for /boot
# p5: remaining space for btrfs

# Example (adjust sizes to match your needs):
fdisk /dev/nvme0n1
# Create partition 4: type EFI System, ~4G
# Create partition 5: type Linux filesystem, rest of disk
```

Format:
```bash
mkfs.fat -F32 /dev/nvme0n1p4
mkfs.btrfs /dev/nvme0n1p5
```

#### 4. Create btrfs subvolume structure
```bash
mount /dev/nvme0n1p5 /mnt

# Create the swap subvolume (not in the snapshot)
btrfs subvolume create /mnt/@swap
```

#### 5. Restore root and home from snapshots
```bash
# Copy from Pi 5
scp justin@192.168.6.6:/home/justin/macbook-snapshots/root_2026-02-14_tui-magic-v2.btrfs /tmp/
scp justin@192.168.6.6:/home/justin/macbook-snapshots/home_2026-02-14_tui-magic-v2.btrfs /tmp/
scp justin@192.168.6.6:/home/justin/macbook-snapshots/boot-backup-2026-02-14.tar.gz /tmp/

# Receive snapshots
btrfs receive /mnt/ < /tmp/root_2026-02-14_tui-magic-v2.btrfs
btrfs receive /mnt/ < /tmp/home_2026-02-14_tui-magic-v2.btrfs

# Create writable subvolumes from snapshots
btrfs subvolume snapshot /mnt/@_snapshot_2026-02-14_tui-magic-v2 /mnt/@
btrfs subvolume snapshot /mnt/@home_snapshot_2026-02-14_tui-magic-v2 /mnt/@home

# Delete read-only intermediates
btrfs subvolume delete /mnt/@_snapshot_2026-02-14_tui-magic-v2
btrfs subvolume delete /mnt/@home_snapshot_2026-02-14_tui-magic-v2
```

#### 6. Restore /boot
```bash
mkdir -p /mnt/@/boot
mount /dev/nvme0n1p4 /mnt/@/boot
tar xzf /tmp/boot-backup-2026-02-14.tar.gz -C /mnt/@/
```

#### 7. Fix fstab UUIDs (if partition UUIDs changed)

If you recreated partitions, the UUIDs will be different:
```bash
# Check new UUIDs
blkid /dev/nvme0n1p4 /dev/nvme0n1p5

# Edit fstab to match new UUIDs
nano /mnt/@/etc/fstab
# Replace the old UUID values with the new ones from blkid
```

#### 8. Install bootloader (if EFI entries were lost)
```bash
# Mount the restored system
mount -o subvol=@ /dev/nvme0n1p5 /mnt
mount -o subvol=@home /dev/nvme0n1p5 /mnt/home
mount /dev/nvme0n1p4 /mnt/boot

# Chroot in
arch-chroot /mnt

# Reinstall systemd-boot
bootctl install

# Verify boot entry exists
cat /boot/loader/entries/linux-619.conf
# Should show:
#   title   Arch Linux (6.19.0)
#   linux   /vmlinuz-linux-619
#   initrd  /initramfs-linux-619.img
#   options root=PARTUUID=... rw rootfstype=btrfs subvol=@

# If PARTUUID changed, update the boot entry:
# blkid -s PARTUUID /dev/nvme0n1p5
# Edit /boot/loader/entries/linux-619.conf with new PARTUUID

exit
umount -R /mnt
reboot
```

---

## Post-Restore Checklist

After booting into the restored system:

- [ ] Login as `justin`
- [ ] MOTD displays with system info
- [ ] Tmux auto-starts
- [ ] `Ctrl-a m` — Matrix screensaver works
- [ ] `Ctrl-a b` — btop works
- [ ] F1/F2 — display brightness
- [ ] F5/F6 — keyboard backlight
- [ ] F10 — mute toggle
- [ ] F11/F12 — volume with beep
- [ ] WiFi connects (`nmtui` or `nmcli con up heero`)
- [ ] Status bar shows DISP/VOL/KBD/W:heero/CPU/RAM/BAT

## Re-compiling Kernel 6.19 (if boot backup is lost)

If you lose the boot backup and need to rebuild the kernel:

```bash
# Install build dependencies
sudo pacman -S base-devel bc libelf pahole cpio perl python

# Get kernel source
cd /tmp
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.19.tar.xz
tar xf linux-6.19.tar.xz
cd linux-6.19

# Copy the running config (if available) or use Arch default
zcat /proc/config.gz > .config 2>/dev/null || curl -o .config <config-url>

# Build
make olddefconfig
make -j$(nproc)
sudo make modules_install

# Install
sudo cp arch/x86/boot/bzImage /boot/vmlinuz-linux-619
sudo mkinitcpio -k 6.19.0 -g /boot/initramfs-linux-619.img
```

The kernel config used for this build is also on the Pi at:
`/home/justin/kernel-619-config`

---

## Notes

- The btrfs snapshots are **stream format** (.btrfs files), not mountable images. Use `btrfs receive` to restore them.
- The /boot backup is a tar.gz of the entire /boot FAT32 partition contents including the EFI directory, systemd-boot, and kernel.
- WiFi password for `heero`: stored in `/etc/NetworkManager/system-connections/` (inside the root snapshot).
- The `macbook-fnkeys.service` and `acpid` will auto-start after restore.
