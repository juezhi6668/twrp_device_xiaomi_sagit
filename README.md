# OrangeFox Recovery device tree — Xiaomi Mi 6 (sagit)

Device tree for building **OrangeFox Recovery R12.x** (branch `fox_14.1`, Android 14
base) for the Xiaomi Mi 6 — codename `sagit`, Qualcomm MSM8998 / Snapdragon 835.

Ported from the TWRP 12.1 tree at
[`xiaomi-msm8998-devs/twrp_device_xiaomi_sagit`](https://github.com/xiaomi-msm8998-devs/twrp_device_xiaomi_sagit)
(branch `new`).

---

## Version note (read this first)

OrangeFox version numbers are **not** the Android version:

| OrangeFox release | Source branch | Android base |
|---|---|---|
| R11.x | `fox_11.0` | Android 11 |
| R11.x (later) | `fox_12.1` | Android 12.1 |
| **R12.x** | **`fox_14.1`** | **Android 14** |
| — | `fox_16.0` | Android 16 |

So "橙狐12 / OrangeFox R12.0" = `fox_14.1` = Android 14 build system. That is what
this tree targets.

⚠️ Upstream marks `fox_14.1` as experimental, and the OrangeFox wiki recommends
`fox_12.1` for devices that did **not** ship with Android 14. sagit shipped with
Android 7.1, so `fox_14.1` is the harder path. The CI workflow takes the branch as
an input — if 14.1 does not build, switch the dropdown to `12.1` and try again
before changing any file.

---

## Repository layout

```
.
├── AndroidProducts.mk          # product entry point
├── BoardConfig.mk              # board / partition / kernel / recovery flags
├── Android.mk                  # BOARD_RECOVERY_IMAGE_PREPARE prop hack
├── Android.bp                  # soong namespace
├── device.mk                   # packages, HALs, copy rules
├── twrp_sagit.mk               # PRODUCT_* definition (lunch target: twrp_sagit-eng)
├── fox_sagit.mk                # optional OrangeFox-only product settings
├── system.prop                 # USB controller props
├── vendorsetup.sh              # FOX_* / OF_* build variables (NOT .mk!)
├── recovery/root/
│   ├── init.recovery.qcom.rc
│   ├── init.recovery.usb.rc
│   ├── system/etc/recovery.fstab
│   ├── system/etc/twrp.fstab
│   ├── system/etc/vintf/manifest.xml
│   ├── vendor/etc/ueventd.qcom.rc
│   └── vendor/etc/vintf/manifest.xml
├── scripts/fetch_blobs.sh      # pulls prebuilt kernel + TEE blobs
└── .github/workflows/build.yml # CI
```

### Why `twrp_sagit` and not `fox_sagit`

OrangeFox keeps the TWRP naming for the product: the lunch target is
`twrp_sagit-eng`, and `twrp_sagit.mk` inherits `vendor/twrp/config/common.mk`.
The OrangeFox sync script patches `vendor/twrp` so that this pulls in the
OrangeFox recovery makefiles. This matches official OrangeFox device trees
(see `OrangeFox/device/vayu`).

`fox_sagit.mk` is **not** a second product — it is an optional settings fragment
inherited via `inherit-product-if-exists`, exactly like `fox_vayu.mk` upstream.

---

## Building with GitHub Actions

1. Push this repository to GitHub (default branch `main`).
2. **Actions → Build OrangeFox Recovery (sagit) → Run workflow**.
3. Pick `fox_branch` (`14.1` recommended for R12.x) and run.

The workflow:

| Step | What it does |
|---|---|
| Free disk space | removes .NET / Android SDK / GHC / CodeQL → ~25 GB back |
| Install deps | build-essential, flex, bison, python3, `repo` launcher |
| Sync | `git clone https://gitlab.com/OrangeFox/sync.git` then `./orangefox_sync.sh --branch 14.1 --path /home/runner/fox` |
| Place tree | rsync this repo → `$SRC/device/xiaomi/sagit` |
| Blobs | `scripts/fetch_blobs.sh` (prebuilt kernel + vendor libs) |
| Build | `lunch twrp_sagit-eng` → `mka adbd recoveryimage` |
| Upload | `OrangeFox-*.img`, `build.log`, `sync.log` as artifacts |

Expect **1.5–3 hours** for `14.1` (the sync alone is ~85 GB of git objects).
Artifacts are kept 14 days. Pushing a tag (`git tag v1 && git push --tags`) also
creates a GitHub Release with the image attached.

---

## Building locally

```bash
# 1. Sync OrangeFox 14.1 (needs ~85 GB free, a lot of RAM, and hours)
git clone https://gitlab.com/OrangeFox/sync.git
cd sync
./orangefox_sync.sh --branch 14.1 --path "$HOME/fox"

# 2. Place this device tree
cd "$HOME/fox"
mkdir -p device/xiaomi
git clone <this-repo> device/xiaomi/sagit

# 3. Pull the prebuilt kernel + vendor blobs
bash device/xiaomi/sagit/scripts/fetch_blobs.sh device/xiaomi/sagit

# 4. Build
source build/envsetup.sh
lunch twrp_sagit-eng
mka adbd recoveryimage
```

Output: `out/target/product/sagit/OrangeFox-unofficial-sagit.img`

Flash it:

```bash
fastboot flash recovery OrangeFox-unofficial-sagit.img
```

---

## About the proprietary blobs

`prebuilt/Image.gz-dtb`, `recovery/root/system/bin/qseecomd` and
`recovery/root/vendor/lib64/*` are Qualcomm/Xiaomi binaries. They are **not**
committed here (see `.gitignore`) — `scripts/fetch_blobs.sh` copies them from the
upstream TWRP tree at build time.

Override the source if you prefer your own copy:

```bash
REF_REPO=https://github.com/you/your_tree.git REF_BRANCH=my-branch \
  bash scripts/fetch_blobs.sh device/xiaomi/sagit
```

---

## Cross-checked against the LineageOS 21 tree (4.4 kernel)

Reference: [`android_device_xiaomi_msm8998-common`](https://github.com/xiaomi-msm8998-devs/android_device_xiaomi_msm8998-common)
@ branch **`lineage-21.0`** (Android 14, 4.4 kernel — matching sagit's stock kernel).

The ROM tree is not a recovery tree, but it is authoritative for hardware facts.

**What was taken from it**

| Item | Finding | Action |
|---|---|---|
| `rootdir/etc/fstab.qcom` | partition layout confirmed: system on `system`, vendor on **`cust`**, dsp/firmware_mnt/bt_firmware all under `/vendor/` | our `recovery.fstab` already matches |
| Keymaster / gatekeeper | `keymaster@3.0-impl` + `gatekeeper@1.0-impl` | confirms `OF_DEFAULT_KEYMASTER_VERSION=3.0` |
| Health HAL | only **HIDL** `health@2.1` (+ `health-service.qti`), no AIDL health | `TW_USE_LEGACY_BATTERY_SERVICES := true` is correct |
| Kernel cmdline | adds `loop.max_part=7` | added to `BOARD_KERNEL_CMDLINE` |
| `task_profiles.json` | copied from `system/core/libprocessgroup/profiles/task_profiles_28.json` | CI copies it automatically |
| Kernel source | `TARGET_KERNEL_SOURCE := kernel/xiaomi/msm8998`, `TARGET_KERNEL_CONFIG := vendor/xiaomi/mi8998_defconfig` | use these if you switch to building the kernel from source |

**What was deliberately NOT taken**

- `BOARD_VNDK_VERSION := current`, `PRODUCT_FULL_TREBLE_OVERRIDE`, `BOARD_USES_QCOM_HARDWARE`,
  `TARGET_USES_GRALLOC1` / `HWC2` / `ION` — whole-ROM concerns, irrelevant to a
  recovery ramdisk.
- `sepolicy/` — recovery runs with `androidboot.selinux=permissive`. Only needed if
  you ever want an enforcing recovery.
- `overlay/`, `rro_overlays/`, `gps/`, `camera/`, `wifi/` — not part of recovery.
- `/mnt/vendor/persist` + `BOARD_ROOT_EXTRA_SYMLINKS` — LineageOS moves persist
  under `/mnt/vendor/`; TWRP expects `/persist`, so the TWRP layout was kept.
- `quota,reservedsize=128M` on `/data` — LineageOS formats userdata with ext4 quota.
  TWRP uses different `mke2fs` flags, so adding these risks a broken format.
  Worth revisiting only if a ROM-side quota check ever complains.

## Known issues and how to work around them

**Image too large for the 64 MiB recovery partition.** The workflow prints the
size and fails the step if it exceeds `BOARD_RECOVERYIMAGE_PARTITION_SIZE`.
Fix by enabling in `vendorsetup.sh`:

```sh
export OF_USE_LZMA_COMPRESSION=1
# or, as a last resort (must come last):
export FOX_DRASTIC_SIZE_REDUCTION=1
```

…or trim features in `BoardConfig.mk` (`TW_EXTRA_LANGUAGES`, `TW_INCLUDE_NTFS_3G`).

**Decryption does not work / recovery hangs on the splash logo.** msm8998 uses
keymaster 3.0; `OF_DEFAULT_KEYMASTER_VERSION=3.0` is already exported. Check that
`recovery/root/vendor/lib64/hw/keystore.msm8998.so` and `qseecomd` were actually
fetched. FBE on Android 14 with a 2017 kernel is the most fragile part of this port.

**Logcat inside recovery does nothing.** On `fox_14.1`, logcat needs
`recovery/root/system/etc/task_profiles.json`. The CI workflow copies it from
`system/core/libprocessgroup/profiles/task_profiles_28.json` in the synced tree;
for local builds do the same, or copy one out of any Android 14 ROM. Also build
with `CUSTOM_BUILD_DEBUG := true` in `BoardConfig.mk` so logd is actually
included.

**`module not found: android.hardware.vibrator-ndk_platform`.** Android 14 no
longer ships the vibrator NDK HAL. It is commented out in `BoardConfig.mk`; port
the AIDL vibrator HAL if you want haptics.

**`NO KERNEL CONFIG` error.** `OF_FORCE_PREBUILT_KERNEL=1` in `vendorsetup.sh`
handles it. If it still appears, make sure `prebuilt/Image.gz-dtb` exists.

**Build errors about `vendor.display.config@1.0`.** Those libs come from the
synced tree. If they are missing, drop the two `vendor.display.config` lines from
`TARGET_RECOVERY_DEVICE_MODULES` / `RECOVERY_LIBRARY_SOURCE_FILES` in
`BoardConfig.mk` and re-check that the display still comes up.

**MIUI overwrites OrangeFox with the stock recovery.** `OF_PATCH_AVB20=1` is
exported for this reason. If it still happens, flash Magisk or disable
`/system/bin/install-recovery.sh` on the ROM side.

---

## Credits

- Device tree origin: [xiaomi-msm8998-devs](https://github.com/xiaomi-msm8998-devs) (Nanhumly et al.)
- Kernel: [Nanhumly-Staging/android_kernel_xiaomi_msm8998](https://github.com/Nanhumly-Staging/android_kernel_xiaomi_msm8998)
- [Team Win Recovery Project](https://github.com/minimal-manifest-twrp)
- [OrangeFox Recovery Project](https://gitlab.com/OrangeFox)

## License

Device tree configuration files: Apache-2.0 (as inherited from the upstream
tree). `vendorsetup.sh` follows the OrangeFox GPL-3.0 convention.
