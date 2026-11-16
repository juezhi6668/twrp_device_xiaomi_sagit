#!/usr/bin/env bash
#
# Pull the proprietary files that cannot be committed to this repository:
#
#   prebuilt/Image.gz-dtb                        - kernel + dtb (required)
#   recovery/root/system/bin/qseecomd            - Qualcomm TEE daemon
#   recovery/root/vendor/lib64/*                 - keymaster / gatekeeper / TEE blobs
#   recovery/root/system/etc/event-log-tags      - only needed when logcat is enabled
#
# They are taken from the upstream TWRP device tree, which ships them as
# prebuilts. Run this once before building (the CI workflow does it for you).
#
# Usage:
#   bash scripts/fetch_blobs.sh [path-to-device-tree]
#
set -euo pipefail

DEVICE_TREE="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
REF_REPO="${REF_REPO:-https://github.com/xiaomi-msm8998-devs/twrp_device_xiaomi_sagit.git}"
REF_BRANCH="${REF_BRANCH:-new}"

if [ ! -f "$DEVICE_TREE/BoardConfig.mk" ]; then
    echo "!! $DEVICE_TREE does not look like the sagit device tree" >&2
    exit 1
fi

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

echo "==> Fetching reference tree (${REF_BRANCH}) for proprietary blobs"
git clone --depth=1 -b "$REF_BRANCH" "$REF_REPO" "$TMP_DIR/ref"

copy_file() {
    local rel="$1"
    local required="${2:-optional}"
    if [ -e "$TMP_DIR/ref/$rel" ]; then
        mkdir -p "$DEVICE_TREE/$(dirname "$rel")"
        cp -a "$TMP_DIR/ref/$rel" "$DEVICE_TREE/$rel"
        echo "    + $rel"
    else
        echo "    ! not found in reference tree: $rel"
        if [ "$required" = "required" ]; then
            echo "!! $rel is required to build - aborting" >&2
            exit 1
        fi
    fi
}

copy_dir() {
    local rel="$1"
    if [ -d "$TMP_DIR/ref/$rel" ]; then
        mkdir -p "$DEVICE_TREE/$rel"
        cp -a "$TMP_DIR/ref/$rel/." "$DEVICE_TREE/$rel/"
        echo "    + $rel/ ($(find "$DEVICE_TREE/$rel" -type f | wc -l) files)"
    else
        echo "    ! not found in reference tree: $rel"
    fi
}

echo "==> Copying kernel"
copy_file "prebuilt/Image.gz-dtb" required

echo "==> Copying TEE / crypto blobs"
copy_file "recovery/root/system/bin/qseecomd"
copy_dir  "recovery/root/vendor/lib64"

echo "==> Copying optional logd tag map"
copy_file "recovery/root/system/etc/event-log-tags"

echo
echo "==> Done. Kernel:"
ls -lh "$DEVICE_TREE/prebuilt/Image.gz-dtb"
