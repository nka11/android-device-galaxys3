#!/bin/bash

# Copyright (C) 2010 The Android Open Source Project
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

DEVICE=galaxys3
COMMON=c1-common
MANUFACTURER=samsung

if [[ -z "${ANDROIDFS_DIR}" && -d ../../../backup-${DEVICE}/system ]]; then
    ANDROIDFS_DIR=../../../backup-${DEVICE}
fi

if [[ -z "${ANDROIDFS_DIR}" ]]; then
    echo Pulling files from device
    DEVICE_BUILD_ID=`adb shell cat /system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\n\r'`
else
    echo Pulling files from ${ANDROIDFS_DIR}
    DEVICE_BUILD_ID=`cat ${ANDROIDFS_DIR}/system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\n\r'`
fi

case "$DEVICE_BUILD_ID" in
"IMM76D.I9300XXBLG1")
  FIRMWARE=XXBLG1 ;;
"IMM76D.I9300BUBLG3")
  FIRMWARE=BUBLG3 ;;
"IMM76D.I9300XXBLH3")
  FIRMWARE=XXBLH3 ;;
"Omega v9.1 - XXBLG1")
  FIRMWARE=XXBLG1 ;;

*)
  echo Your device has unknown firmware $DEVICE_BUILD_ID >&2
  echo >&2
  echo Supported firmware: >&2
  echo XXBLG1 >&2
  echo XXBLH3 >&2
  echo BUBLG3 >&2
  exit 1 ;;
esac

if [[ ! -d ../../../backup-${DEVICE}/system  && -z "${ANDROIDFS_DIR}" ]]; then
    echo Backing up system partition to backup-${DEVICE}
    mkdir -p ../../../backup-${DEVICE} &&
    adb pull /system ../../../backup-${DEVICE}/system
fi

BASE_PROPRIETARY_COMMON_DIR=vendor/$MANUFACTURER/$COMMON/proprietary
PROPRIETARY_DEVICE_DIR=../../../vendor/$MANUFACTURER/$DEVICE/proprietary
PROPRIETARY_COMMON_DIR=../../../$BASE_PROPRIETARY_COMMON_DIR

mkdir -p $PROPRIETARY_DEVICE_DIR

for NAME in audio cameradata egl firmware hw keychars wifi media
do
    mkdir -p $PROPRIETARY_COMMON_DIR/$NAME
done

# galaxys3


# c1-common
(cat << EOF) | sed s/__DEVICE__/$DEVICE/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > ../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk
# Copyright (C) 2010 The Android Open Source Project
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

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES := \\

# All the blobs necessary for galaxys2 devices
PRODUCT_COPY_FILES += \\

EOF

COMMON_BLOBS_LIST=../../../vendor/$MANUFACTURER/$COMMON/c1-vendor-blobs.mk

(cat << EOF) | sed s/__COMMON__/$COMMON/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > $COMMON_BLOBS_LIST
# Copyright (C) 2010 The Android Open Source Project
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

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES := device/sample/etc/apns-full-conf.xml:system/etc/apns-conf.xml

# All the blobs necessary for galaxys3 devices
PRODUCT_COPY_FILES += \\
EOF

# copy_file
# pull file from the device and adds the file to the list of blobs
#
# $1 = src name
# $2 = dst name
# $3 = directory path on device
# $4 = directory name in $PROPRIETARY_COMMON_DIR
copy_file()
{
    echo Pulling \"$1\"
    if [[ -z "${ANDROIDFS_DIR}" ]]; then
        adb pull /$3/$1 $PROPRIETARY_COMMON_DIR/$4/$2
    else
           # Hint: Uncomment the next line to populate a fresh ANDROIDFS_DIR
           #       (TODO: Make this a command-line option or something.)
           # adb pull /$3/$1 ${ANDROIDFS_DIR}/$3/$1
        cp ${ANDROIDFS_DIR}/$3/$1 $PROPRIETARY_COMMON_DIR/$4/$2
    fi

    if [[ -f $PROPRIETARY_COMMON_DIR/$4/$2 ]]; then
        echo   $BASE_PROPRIETARY_COMMON_DIR/$4/$2:$3/$2 \\ >> $COMMON_BLOBS_LIST
    else
        echo Failed to pull $1. Giving up.
        exit -1
    fi
}

# copy_files
# pulls a list of files from the device and adds the files to the list of blobs
#
# $1 = list of files
# $2 = directory path on device
# $3 = directory name in $PROPRIETARY_COMMON_DIR
copy_files()
{
    for NAME in $1
    do
        copy_file "$NAME" "$NAME" "$2" "$3"
    done
}

# copy_local_files
# puts files in this directory on the list of blobs to install
#
# $1 = list of files
# $2 = directory path on device
# $3 = local directory path
copy_local_files()
{
    for NAME in $1
    do
        echo Adding \"$NAME\"
        echo device/$MANUFACTURER/$DEVICE/$3/$NAME:$2/$NAME \\ >> $COMMON_BLOBS_LIST
    done
}
# Dropped from the list cause not findable on device (Omega ROM) 
#	libs5pjpeg.so
COMMON_LIBS="
	libakm.so
	libddc.so
	libcec.so
	libedid.so
	libext2_blkid.so
	libext2_com_err.so
	libext2_e2p.so
	libext2fs.so
	libext2_uuid.so
	libfimc.so
	libfimg.so
	libhdmi.so
	libion.so
	libhdmiclient.so
	libkeyutils.so
	libMali.so
	libril.so
	libsec_devenc.so
	libsec_ecryptfs.so
	libsecfips.so
	libsec_km.so
	libsecril-client.so
	libsec-ril.so
	libsurfaceflinger.so
	libTVOut.so
	libtvoutservice.so
	libtvoutinterface.so
	libdirencryption.so
	libUMP.so
	"

copy_files "$COMMON_LIBS" "system/lib" ""

if [[ -z "${ANDROIDFS_DIR}" ]]; then
   HCDNAME=`basename \`adb shell ls /system/bin/*.hcd\` | tr -d '\r'`
else
   HCDNAME=`basename ${ANDROIDFS_DIR}/system/bin/*.hcd`
fi
COMMON_BINS="
	playlpm
	immvibed
	lpmkey
	rild
	mediaserver
	servicemanager
	surfaceflinger
	vold
	netd
	debuggerd
	icd
	ddexe
	smdexe
	dttexe
	diagexe
	connfwexe
	npsmobex
	brcm_poke_helper
	app_process
	bcm4334.hcd
	bcm4334_murata.hcd
	bcm4334_semco.hcd
	samsungpowersoundplay
	bootanimation
	samsungani
	dhcpcd
	wpa_supplicant
	dbus-daemon
	mfgloader
	wlandutservice
	macloader
	logwrapper
	bluetoothd
	"
copy_files "$COMMON_BINS" "system/bin" ""

COMMON_CAMERADATA="
	datapattern_420sp.yuv
	datapattern_front_420sp.yuv
	"
copy_files "$COMMON_CAMERADATA" "system/cameradata" "cameradata"

COMMON_EGL="
	egl.cfg
	libEGL_mali.so
	libGLESv1_CM_mali.so
	libGLESv2_mali.so
	"
copy_files "$COMMON_EGL" "system/lib/egl" "egl"

if [ $FIRMWARE = "XXBLG1" ] || [ $FIRMWARE = "XXBLH3" ] || [ $FIRMWARE = "BUBLG3" ];
then
COMMON_FIRMWARE="
	RS_M9MO.bin
	"
fi

copy_files "$COMMON_FIRMWARE" "system/etc/firmware" "firmware"
copy_files "libpn544_fw.so" "system/vendor/firmware" "firmware"

COMMON_HW="
	audio.a2dp.default.so
	audio_policy.default.so
	audio.primary.default.so
	audio.primary.smdk4x12.so
	audio.primary.goldfish.so
	camera.smdk4x12.so
	gps.exynos4.so
	gralloc.smdk4x12.so
	lights.exynos4.so
	sensors.smdk4x12.so
	nfc.smdk4x12.so
	"
copy_files "$COMMON_HW" "system/lib/hw" "hw"

COMMON_IDC="
	melfas_ts.idc
	qwerty2.idc
	sec_touchscreen.idc
	mxt224_ts_input.idc
	qwerty.idc
	"
copy_local_files "$COMMON_IDC" "system/usr/idc" "idc"

COMMON_KEYCHARS="
	Generic.kcm
	qwerty.kcm
	qwerty2.kcm
	Virtual.kcm
	"
copy_files "$COMMON_KEYCHARS" "system/usr/keychars" "keychars"

COMMON_WIFI="
	bcmdhd_apsta.bin_b1
	bcmdhd_apsta.bin_b2
	bcmdhd_mfg.bin_b0
	bcmdhd_mfg.bin_b1
	bcmdhd_mfg.bin_b2
	bcmdhd_p2p.bin_b0
	bcmdhd_p2p.bin_b1
	bcmdhd_p2p.bin_b2
	bcmdhd_sta.bin_b0
	bcmdhd_sta.bin_b1
	bcmdhd_sta.bin_b2
	nvram_mfg.txt
	nvram_net.txt
	nvram_net.txt_murata
	nvram_net.txt_murata_b2
	nvram_net.txt_semcosh
	wpa_supplicant.conf
	"
copy_files "$COMMON_WIFI" "system/etc/wifi" "wifi"

# Found in gs2 but not found in device :
# libasound.so
# libaudiohw.so
# libmediayamaha.so => libmedia.so
# libmediayamahaservice.so => libmediaplayerservice.so
# libsamsungAcousticeq.so 
# lib_Samsung_Acoustic_Module_Llite.so
# liblvvefs.so
COMMON_AUDIO="
	libsamsungSoundbooster.so
	libsoundalive.so
	lib_SoundAlive_for_ICS_V01012.so
	libSoundAlive_VSP_ver311a.so
	libsoundspeed.so
	libmedia.so
	libmediaplayerservice.so
	lib_Samsung_Resampler.so
	lib_Samsung_SB_AM_for_ICS_v03005.so
	"
copy_files "$COMMON_AUDIO" "system/lib" "audio"

COMMON_AUDIO_CONFIG="
	LVVEFS_Rx_Configuration.txt
	LVVEFS_Tx_Configuration.txt
	Rx_ControlParams_BLUETOOTH_HEADSET.txt
	Rx_ControlParams_EARPIECE_WIDEBAND.txt
	Rx_ControlParams_SPEAKER_WIDEBAND.txt
	Rx_ControlParams_WIRED_HEADPHONE_WIDEBAND.txt
	Rx_ControlParams_WIRED_HEADSET_WIDEBAND.txt
	Tx_ControlParams_BLUETOOTH_HEADSET.txt
	Tx_ControlParams_EARPIECE_WIDEBAND.txt
	Tx_ControlParams_SPEAKER_WIDEBAND.txt
	Tx_ControlParams_WIRED_HEADPHONE_WIDEBAND.txt
	Tx_ControlParams_WIRED_HEADSET_WIDEBAND.txt
	"
copy_files "$COMMON_AUDIO_CONFIG" "system/etc/audio" "audio"
#copy_files "asound.conf" "system/etc" "audio"
#copy_files "alsa.conf" "system/usr/share/alsa" "audio"

COMMON_MEDIA="
	battery_batteryerror.qmg
	battery_charging_45.qmg
	battery_charging_85.qmg
	battery_charging_100.qmg
	battery_charging_50.qmg
	battery_charging_90.qmg
	battery_charging_10.qmg
	battery_charging_55.qmg
	battery_charging_95.qmg
	battery_charging_15.qmg
	battery_charging_5.qmg
	battery_error.qmg
	battery_charging_20.qmg
	battery_charging_60.qmg
	bootsamsungloop.qmg
	battery_charging_25.qmg
	battery_charging_65.qmg
	bootsamsung.qmg
	battery_charging_30.qmg
	battery_charging_70.qmg
	chargingwarning.qmg
	battery_charging_35.qmg
	battery_charging_75.qmg
	Disconnected.qmg
	battery_charging_40.qmg
	battery_charging_80.qmg
"
copy_files "$COMMON_MEDIA" "system/media" "media"

./setup-makefiles.sh
