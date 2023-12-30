function user_config__sdk_config() {
	EXTRA_IMAGE_SUFFIXES+=("-sdk")                  # global array
	display_alert "SDK custom image" "enabled for ${BOARD}" "info"
}
