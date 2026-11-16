#
#	This file is part of the OrangeFox Recovery Project
# 	Copyright (C) 2021-2026 The OrangeFox Recovery Project
#
#	OrangeFox is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	any later version.
#
#	OrangeFox is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
# 	This software is released under GPL version 3 or any later version.
#	See <http://www.gnu.org/licenses/>.
#
# 	Please maintain this if you use this script or any part of it
#
# OrangeFox build variables for Xiaomi Mi 6 (sagit)
# These MUST live in a shell script - FOX_* / OF_* variables are ignored
# (or break the build) when placed in a .mk file.
#
FDEVICE="sagit"

fox_get_target_device() {
  if echo "$BASH_SOURCE" | grep -q "/$FDEVICE/"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif set | grep BASH_ARGV | grep -w \"$FDEVICE\"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif echo "${BASH_SOURCE[0]}" | grep -q "/$FDEVICE/"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif echo "$0" | grep -q "$FDEVICE"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  fi
}

if [ -z "$1" -a -z "$FOX_BUILD_DEVICE" ]; then
   fox_get_target_device
fi

if [ "$1" = "$FDEVICE" -o "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then

	# --- Device identity -------------------------------------------------
	export FOX_BUILD_DEVICE="$FDEVICE"
	export LC_ALL="C"
	export ALLOW_MISSING_DEPENDENCIES=true

	# --- Language --------------------------------------------------------
	# zh_CN by default; change to "en" if you prefer English
	export TW_DEFAULT_LANGUAGE="zh_CN"

	# --- Kernel ----------------------------------------------------------
	# sagit builds with a prebuilt Image.gz-dtb. Without this flag the build
	# aborts with "NO KERNEL CONFIG".
	export OF_FORCE_PREBUILT_KERNEL=1

	# --- Crypto ----------------------------------------------------------
	# The keymaster HAL shipped in recovery/root/vendor/lib64 is 3.0.
	# Declaring it avoids the recovery hanging on the splash logo when a
	# device is encrypted.
	export OF_DEFAULT_KEYMASTER_VERSION=3.0

	# --- MIUI ------------------------------------------------------------
	# sagit is an A-only MIUI device: patch AVB2.0 so that booting into MIUI
	# does not overwrite OrangeFox with the stock recovery.
	export OF_PATCH_AVB20=1

	# --- Shell / utilities ----------------------------------------------
	# Keep this list SHORT: the recovery partition is only 64 MiB.
	export FOX_USE_BASH_SHELL=1
	export FOX_ASH_IS_BASH=1
	export FOX_USE_TAR_BINARY=1
	export FOX_USE_XZ_UTILS=1
	export FOX_USE_DATE_BINARY=1

	# AromaFM is not used on this device - drop it to save space
	export FOX_DELETE_AROMAFM=1

	# --- Versioning ------------------------------------------------------
	# Appended to the internal OrangeFox version, e.g. "R12.0_1"
	export FOX_MAINTAINER_PATCH_VERSION=1

	# --- Size fallbacks (uncomment if the image exceeds 64 MiB) ----------
	# export OF_USE_LZMA_COMPRESSION=1
	# export FOX_DRASTIC_SIZE_REDUCTION=1
else
	if [ -z "$FOX_BUILD_DEVICE" -a -z "$BASH_SOURCE" ]; then
		echo "I: This script requires bash. Not processing the $FDEVICE $(basename $0)"
	fi
fi
#
