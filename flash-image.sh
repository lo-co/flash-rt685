#!/bin/bash

echo "blhost: Starting flash process..."
echo "blhost: Attempting to read flash..."
echo ""

# If we can read the memory, it has been configured...
response=$(blhost -p /dev/ttyACM0 -j -- read-memory 0x8000000 1)

status=$(echo "$response" | jq -r '.status.value')

# The following was taken as a mixture from the UM11147 and some forum posts.
# The chapter in the user manual is 41.1.3.1

# ISP pins on the RT685 EVK are set for serial UART and are 1,1,1.
# Default values from UM11159 are 1,0,1

if [ "$status" != 0 ]; then

    echo "blhost: Configuring memory..."

# Option 0 configuration - flash config parameter
# This option is based off of what you might get from the secure provisioning
# tool.  The value is for simplified FlexSPI NOR for a Macronix Octal SDR flash
# device with the default settings.
# For these settings:
#  Query pads           = 1
#  Cmd pads             = 8
#  Quad mode setting    = Not configured
#  Misc mode            = Stand SPI mode
#  Max frequency        = 133
#  Has option1          = yes

    blhost -p /dev/ttyACM0 -j -- fill-memory 0x1c000 0x4 0xC1503057 word

# Not sure if this is needed here or if we can wait until after 0xe1c004 
# is filled
    blhost -p /dev/ttyACM0 -j -- configure-memory 0x09 0x1c000

# Option 1 configuration - flash config block (FCB)
# I tried to use 0xf000000f but this seemed to fail every time...
# the value 0x20000000 is taken from the secure provisioning tool
# For this value, use the following settings:
#   Flash connection        = Single port B
#   Drive Strength          = 0
#   DQS pinmux group        = 0
#   Enable second pinmux    = 0
#   Status override         = 0
#   Dummy cycles            = 0
    blhost -p /dev/ttyACM0 -j -- fill-memory 0x1c004 0x4 0x20000000
#    blhost -p /dev/ttyACM0 -j -- fill-memory 0x1c004 0x4 0xf000000f

#    blhost -p /dev/ttyACM0 -j -- configure-memory 0x09 0x1c004
    blhost -p /dev/ttyACM0 -j -- configure-memory 0x09 0x1c000

# mem id 0x09 is not needed here.
else
    echo "blhost: Memory already configured..."
fi

echo ""
echo "blhost: Erasing memory on flash..."
echo ""
blhost -p /dev/ttyACM0 -j -- flash-erase-region 0x08000000 0x10000 9

echo ""
echo "blhost: Writing image to 0x8001000..."
echo ""

# For FlexSPI boot media, the offset for the image is 0x1000 according to Table 1000 in the UM
response=$(blhost -p /dev/ttyACM0 -j -- write-memory 0x8001000 /home/mrichardson/nxp-rt-685-test/evkmimxrt685_hello_world/armgcc/debug/hello_world.bin)

status=$(echo "$response" | jq -r '.status.value')

if [ "$status" -eq 0 ];then
    echo "blhost: Flash successful.  Reboot now..."
fi

# RESPONSE:
# Ping responded in 1 attempt(s)
# Inject command 'write-memory'
# Preparing to send 27320 (0x6ab8) bytes to the target.
# Successful generic response to command 'write-memory'
# (1/1)100% Completed!
# Successful generic response to command 'write-memory'
# Response status = 0 (0x0) Success.
# Wrote 27320 of 27320 bytes.

