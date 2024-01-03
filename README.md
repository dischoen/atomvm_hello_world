# atomvm_hello_world
initial steps to get going on ESP32S3 with AtomVM 0.6.0
Based on the hello_world example project of atomvm.

## USB serial devices

On my machine (Dell laptop with Ubuntu 22 LTS) two serial devices
are created when I connect the ESP32S3:
- /dev/ttyACM0
- /dev/ttyACM1

After playing around a bit, the following usage of the ports works best for me:
- use ACM0 for erasing and uploading firmware and projects
- use ACM1 to communicate with the board at runtime (e.g. picocom)

The other way around also worked, but uploading is much slower and
the communication with the terminal program crashes during uploads.

## First errors

After erasing and loading AtomVM, this was the first thing that I
saw:

```
invalid header: 0xffffffff
invalid header: 0xffffffff
invalid header: 0xffffffff
```

This happens when the device has been erased or when crappy firmware has been uploaded.
Or if something has been uploaded at the wrong address.

After erasing and uploading AtomVM to address 0x1000, this is what I saw:

```
ESP-ROM:esp32s3-20210327
Build:Mar 27 2021
rst:0x7 (TG0WDT_SYS_RST),boot:0x8 (SPI_FAST_FLASH_BOOT)
Saved PC:0x40043ac8
SPIWP:0xee
mode:DIO, clock div:1
load:0x3fce3818,len:0x13a0
load:0x206f7420,len:0x69726576
Invalid image block, can't boot.
ets_main.c 329 
```

These are more or less the same as in this ticket:

https://github.com/espressif/esp-idf/issues/7821

## Comparison with MicroPython

To find out if there was an error with my board, I tried to install
MicroPython from
https://micropython.org/download/ESP32_GENERIC_S3/

> esptool.py --chip esp32s3 --port /dev/ttyACM0 erase_flash
>
> From then on program the firmware starting at address 0:
>
> esptool.py --chip esp32s3 --port /dev/ttyACM0 write_flash -z 0 board-20210902-v1.17.bin

This worked fine.

The big difference here is that MicroPython is to be installed at address 0.

## Solution (at least for me)

You might have guessed it: I just had to change the upload address to 0.
Happy coding!

### Run the project

The Makefile expects these files in the directory images:
- AtomVM-esp32s3-v0.6.0-alpha.2.img
- ESP32_GENERIC_S3-20231227-v1.22.0.bin (optional)

They are available at
https://github.com/atomvm/AtomVM/releases
https://micropython.org/download/ESP32_GENERIC_S3/

Then you can do:

```
make erase
make load
make deploy
```

And thanks to @atomvm for this fantastic project!
