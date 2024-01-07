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

ifeq ($(origin CHIP), undefined)
	CHIP    := esp32s3
endif
ifeq ($(origin FW_OFFSET), undefined)
	FW_OFFSET := 0x0
endif
PYIMAGE := images/ESP32_GENERIC_S3-20231227-v1.22.0.bin

erase:
	esptool.py --chip $(CHIP) --port $(PORT) --baud 115200 erase_flash

load:
	esptool.py --chip $(CHIP) --port $(PORT) --baud 115200 \
		--before default_reset --after hard_reset write_flash \
		-u --flash_mode dio --flash_freq 40m --flash_size detect $(FW_OFFSET) \
		$(IMG)

load-python: erase
	esptool.py --chip $(CHIP) --port $(PORT) write_flash -z 0 $(PYIMAGE)

build:
	rebar3 atomvm packbeam
deploy: build
	rebar3 atomvm esp32_flash --port $(PORT) --chip $(CHIP)

com:
	picocom --baud 115200 $(COMPORT)

ESP32-S3: erase load deploy com

ESP32-WROOM-32: CHIP=auto
ESP32-WROOM-32: PORT=/dev/ttyUSB0
ESP32-WROOM-32: IMG=images/AtomVM-esp32-v0.6.0-alpha.2.img
ESP32-WROOM-32: COMPORT=/dev/ttyUSB0
ESP32-WROOM-32: FW_OFFSET=0x1000
ESP32-WROOM-32: erase load deploy com

ESP8266MOD: CHIP=auto
ESP8266MOD: PORT=/dev/ttyUSB0
ESP8266MOD: IMG=images/AtomVM-esp32-v0.6.0-alpha.2.img
ESP8266MOD: COMPORT=/dev/ttyUSB0
ESP8266MOD: FW_OFFSET=0x1000
ESP8266MOD: erase load deploy com

# perform BOOTSEL manually before, my laptop is too slow
RPICO: 
	rebar3 atomvm pico_flash -p /media/$(USER)/RPI-RP2/


checkesptool:
ifeq ($(shell which esptool.py),)
	pip3 install esptool
endif
ifneq ($(shell which pip3 | grep .asdf),)
	asdf reshim
endif
