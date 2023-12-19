This is a simple script using the boot loader host tool (blhost) from NXP to flash the RT685 via UART ISP.  

Program uses `jq` as well as `blhost` to parse the JSON data returned by `blhost` with the `-j` switch.  `jq` can be acquired on linux via the command

```
sudo apt install jq
```

## Documents
* UM11159 - user manual for the RT685 eval kit
* UM11147 - user manual for the RT685 chip
* MCUBLHOSTUG - MCU blhost user guide
