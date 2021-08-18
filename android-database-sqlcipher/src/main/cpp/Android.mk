LOCAL_PATH := $(call my-dir)
MY_PATH := $(LOCAL_PATH)
include $(CLEAR_VARS)
LOCAL_PATH := $(MY_PATH)

C_SRC_ROOT := $(LOCAL_PATH)/../external/android-sqlite-evplus-ndk-driver-free

LOCAL_CFLAGS +=  $(SQLCIPHER_CFLAGS) $(SQLCIPHER_OTHER_CFLAGS)
LOCAL_C_INCLUDES += $(LOCAL_PATH)
LOCAL_LDLIBS := -llog
LOCAL_LDFLAGS += -L$(ANDROID_NATIVE_ROOT_DIR)/$(TARGET_ARCH_ABI) -fuse-ld=bfd
LOCAL_STATIC_LIBRARIES += static-libcrypto
LOCAL_MODULE    := sqlc-evplus-ndk-driver
# includes the SQLite amalgamation etc:
LOCAL_SRC_FILES := $(C_SRC_ROOT)/native/sqlc_all.c
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../external/libb64-core
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../external/sqlite3-base64
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../external/sqlite3-regexp-cached

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := static-libcrypto
LOCAL_EXPORT_C_INCLUDES := $(OPENSSL_DIR)/include
LOCAL_SRC_FILES := $(ANDROID_NATIVE_ROOT_DIR)/$(TARGET_ARCH_ABI)/libcrypto.a
include $(PREBUILT_STATIC_LIBRARY)
