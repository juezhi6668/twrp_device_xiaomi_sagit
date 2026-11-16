#
# Copyright 2017 The Android Open Source Project
# Copyright (C) 2021-2026 The OrangeFox Recovery Project
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

# Release name
PRODUCT_RELEASE_NAME := sagit

# Inherit from sagit device
$(call inherit-product, device/xiaomi/sagit/device.mk)

# Inherit the recovery product configuration.
# NOTE: vendor/twrp is the TWRP minimal-manifest project. The OrangeFox sync
# script patches it so that this makefile pulls in the OrangeFox recovery
# makefiles. This is the path official OrangeFox device trees inherit.
$(call inherit-product, vendor/twrp/config/common.mk)

# Optional OrangeFox-only product settings for this device
$(call inherit-product-if-exists, device/xiaomi/sagit/fox_sagit.mk)

PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.keystore=msm8998 \
    ro.hardware.gatekeeper=msm8998

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := sagit
PRODUCT_NAME := twrp_sagit
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := MI 6
PRODUCT_MANUFACTURER := Xiaomi
