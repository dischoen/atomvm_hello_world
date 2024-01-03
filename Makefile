# PORT is for flashing
# COMPORT is stdio
ifeq ($(origin PORT), undefined)
	PORT := /dev/ttyACM0
endif
ifeq ($(origin COMPORT), undefined)
	COMPORT := /dev/ttyACM1
endif

ifeq ($(origin IMG), undefined)
	IMG := images/AtomVM-esp32s3-v0.6.0-alpha.2.img
endif

CHIP    := esp32s3
PYIMAGE := images/ESP32_GENERIC_S3-20231227-v1.22.0.bin

erase:
	esptool.py --chip $(CHIP) --port $(PORT) --baud 115200 erase_flash

load:
	esptool.py --chip $(CHIP) --port $(PORT) --baud 115200 \
		--before default_reset --after hard_reset write_flash \
		-u --flash_mode dio --flash_freq 40m --flash_size detect 0x0 \
		$(IMG)

load-python: erase
	esptool.py --chip $(CHIP) --port $(PORT) write_flash -z 0 $(PYIMAGE)

build:
	rebar3 atomvm packbeam
deploy: build
	rebar3 atomvm esp32_flash --port $(PORT) --chip $(CHIP)

com:
	picocom --baud 115200 $(COMPORT)
