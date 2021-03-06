############################################################################### 
#
#  The MIT License
#  Copyright (c) 2016 MXCHIP Inc.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy 
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights 
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is furnished
#  to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
#  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
############################################################################### 

NAME := Board_EML3047

WLAN_CHIP            	:= NONE
WLAN_CHIP_REVISION   	:= NONE
WLAN_CHIP_FAMILY     	:= NONE
WLAN_CHIP_FIRMWARE_VER  := NONE

MODULE              	:= EML3047

BUS := EML3047

NO_WIFI_FIRMWARE        := YES     

# # Extra build target in mico_standard_targets.mk, include bootloader, and copy output file to eclipse debug file (copy_output_for_eclipse)
#EXTRA_TARGET_MAKEFILES +=  mico-os/board/EML3047/mico_standard_targets_for_stm32l0xx.mk

EXTRA_TARGET_MAKEFILES +=  $(MAKEFILES_PATH)/mico_standard_targets.mk


# Global includes
GLOBAL_INCLUDES  := .

# Source files
$(NAME)_SOURCES := mico_board.c

# Global defines
GLOBAL_DEFINES += STM32L071xx

GLOBAL_LDFLAGS := -L $(MICO_OS_PATH)/board/EML3047

# Components
$(NAME)_COMPONENTS := drivers/spi_flash \
                      drivers/keypad/gpio_button
                     
################################# mbed sources ############################################################

# Add mbed support, add mbed target definitions here
MBED_SUPPORT 	        := 1
MBED_DEVICES            := ANALOGIN I2C I2CSLAVE I2C_ASYNCH INTERRUPTIN LOWPOWERTIMER PORTIN PORTINOUT PORTOUT PWMOUT RTC SERIAL SERIAL_FC SERIAL_ASYNCH SLEEP SPI SPISLAVE SPI_ASYNCH STDIO_MESSAGES
MBED_TARGETS            := STM STM32L0

GLOBAL_DEFINES          += INITIAL_SP=(0x20005000UL)
GLOBAL_DEFINES          += OS_TASKCNT=14
GLOBAL_DEFINES          += OS_MAINSTKSIZE=256
GLOBAL_DEFINES          += OS_CLOCK=32000000
GLOBAL_DEFINES          += OS_ROBINTOUT=1
                           
GLOBAL_DEFINES += TRANSACTION_QUEUE_SIZE_SPI=2 USB_STM_HAL USBHOST_OTHER MXCHIP_LIBRARY

# Source files
$(NAME)_SOURCES += mbed/PeripheralPins.c \
                   mbed/device/system_stm32l0xx.c \
                   mbed/device/cmsis_nvic.c
                   
                   
# Global includes
GLOBAL_INCLUDES  += mbed mbed/device

################################# LINK_SCRIPT ############################################################

ifeq ($(APP),bootloader)
####################################################################################
# Building bootloader
####################################################################################

DEFAULT_LINK_SCRIPT += mbed/device/TOOLCHAIN_$(TOOLCHAIN_NAME_MBED)/STM32L071xB_BL_FLASH$(LINK_SCRIPT_SUFFIX)
GLOBAL_DEFINES      += VECT_TAB_OFFSET=0x0

$(NAME)_SOURCES += mbed/device/TOOLCHAIN_GCC_ARM/startup_stm32l071xx.S

else
ifneq ($(filter spi_flash_write, $(APP)),)
####################################################################################
# Building spi_flash_write
####################################################################################

DEFAULT_LINK_SCRIPT += mbed/device/TOOLCHAIN_$(TOOLCHAIN_NAME_MBED)/STM32L071xB_PROG$(LINK_SCRIPT_SUFFIX)
GLOBAL_DEFINES      += __JTAG_FLASH_WRITER_DATA_BUFFER_SIZE__=9920 \
                       SECTOR_SIZE=1024 \
                       MICO_DISABLE_STDIO \
                       VECT_TAB_SRAM \
                       VECT_TAB_OFFSET=0x2800
                       
$(NAME)_SOURCES += mbed/device/TOOLCHAIN_GCC_ARM/startup_stm32l071xx_flash_prog.S

else
####################################################################################
# Building standard application to run with bootloader
####################################################################################

PRE_APP_BUILDS      += bootloader
DEFAULT_LINK_SCRIPT := mbed/device/TOOLCHAIN_$(TOOLCHAIN_NAME_MBED)/STM32L071xB_APP_FLASH$(LINK_SCRIPT_SUFFIX)
ifneq ($(VECT_TAB_OFFSET_APP),)
GLOBAL_DEFINES      += VECT_TAB_OFFSET=$(VECT_TAB_OFFSET_APP)
else
GLOBAL_DEFINES      += VECT_TAB_OFFSET=0x8000
endif

$(NAME)_SOURCES += mbed/device/TOOLCHAIN_GCC_ARM/startup_stm32l071xx.S
GLOBAL_LDFLAGS += $$(CLIB_LDFLAGS_NANO)


endif # APP=spi_flash_write
endif # APP=bootloader


