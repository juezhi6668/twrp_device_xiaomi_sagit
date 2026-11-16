#
# Copyright 2022 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# BoardConfig.mk for Xiaomi Mi 6 (sagit) - OrangeFox Recovery
# Target branch: fox_14.1 (OrangeFox R12.x / Android 14 base)
#
# Ported from the TWRP 12.1 tree:
#   https://github.com/xiaomi-msm8998-devs/twrp_device_xiaomi_sagit (branch: new)
#
# NOTE: this file must NOT contain FOX_* variables. OrangeFox build vars
#       are shell exports and live in vendorsetup.sh.

DEVICE_PATH := device/xiaomi/sagit

BUILD_BROKEN_USES_BUILD_COPY_HEADERS := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_MISSING_REQUIRED_MODULES := true

# For building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a73

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a73

# Crypto
BOARD_USES_QCOM_FBE_DECRYPTION := true
PLATFORM_VERSION := 99.87.36
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := 2099-12-31

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := msm8998
TARGET_NO_BOOTLOADER := true

# Kernel
# We use a prebuilt kernel (prebuilt/Image.gz-dtb). This is why
# OF_FORCE_PREBUILT_KERNEL=1 is exported in vendorsetup.sh.
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz-dtb

BOARD_KERNEL_CMDLINE := androidboot.console=ttyMSM0 androidboot.hardware=qcom
BOARD_KERNEL_CMDLINE += user_debug=31 msm_rtb.filter=0x37 ehci-hcd.park=3
BOARD_KERNEL_CMDLINE += service_locator.enable=1
BOARD_KERNEL_CMDLINE += swiotlb=2048
BOARD_KERNEL_CMDLINE += androidboot.usbcontroller=a800000.dwc3
BOARD_KERNEL_CMDLINE += androidboot.configfs=true
BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive

# Platform
TARGET_BOARD_PLATFORM := msm8998

# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144 # (BOARD_KERNEL_PAGESIZE * 64)

BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_CACHEIMAGE_PARTITION_SIZE := 402653184
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 5368709120
BOARD_USERDATAIMAGE_PARTITION_SIZE := 120426835968
BOARD_VENDORIMAGE_PARTITION_SIZE := 872415232
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USES_MKE2FS := true

# Workaround for error copying vendor files to recovery ramdisk
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor

# Recovery
BOARD_HAS_LARGE_FILESYSTEM := true
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab

# Additional binaries & libraries needed for recovery
#
# NOTE (fox_14.1): the vibrator NDK HAL is no longer shipped as
# 'android.hardware.vibrator-ndk_platform' in Android 14. If you want haptic
# feedback, port the AIDL vibrator HAL and add it back here - otherwise the
# build aborts with "module not found".
# TARGET_RECOVERY_DEVICE_MODULES += android.hardware.vibrator-ndk_platform

TARGET_RECOVERY_DEVICE_MODULES += \
    libion \
    vendor.display.config@1.0 \
    vendor.display.config@2.0

RECOVERY_LIBRARY_SOURCE_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libion.so \
    $(TARGET_OUT_SYSTEM_EXT_SHARED_LIBRARIES)/vendor.display.config@1.0.so \
    $(TARGET_OUT_SYSTEM_EXT_SHARED_LIBRARIES)/vendor.display.config@2.0.so

# TWRP / OrangeFox specific build flags
BOARD_HAS_NO_REAL_SDCARD := true
RECOVERY_SDCARD_ON_DATA := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TW_BRIGHTNESS_PATH := /sys/class/leds/lcd-backlight/brightness
TW_DEFAULT_BRIGHTNESS := 2047
TW_MAX_BRIGHTNESS := 4095
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_EXCLUDE_APEX := true
TW_EXTRA_LANGUAGES := true
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_FB2PNG := true
TW_INCLUDE_NTFS_3G := true
TW_INPUT_BLACKLIST := hbtp_vm
TW_SCREEN_BLANK_ON_BOOT := true
TW_THEME := portrait_hdpi
TW_CUSTOM_CPU_TEMP_PATH := /sys/devices/virtual/thermal/thermal_zone5/temp
TW_DEVICE_VERSION := fox-sagit
TW_FRAMERATE := 60
# Android 14 recovery defaults to the AIDL health HAL; msm8998 only has the
# legacy sysfs battery interface, so keep the legacy path enabled.
TW_USE_LEGACY_BATTERY_SERVICES := true

# The recovery partition on sagit is only 64 MiB. If the image ever exceeds
# it, enable LZMA compression in vendorsetup.sh (OF_USE_LZMA_COMPRESSION=1)
# or trim features (TW_EXTRA_LANGUAGES, TW_INCLUDE_NTFS_3G).

# Debug build support (logcat inside recovery)
CUSTOM_BUILD_DEBUG := false
ifeq ($(CUSTOM_BUILD_DEBUG),true)
    TWRP_INCLUDE_LOGCAT := true
    TARGET_USES_LOGD := true
    TARGET_RECOVERY_DEVICE_MODULES += debuggerd
    RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/debuggerd
    TARGET_RECOVERY_DEVICE_MODULES += strace
    RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/strace
endif
