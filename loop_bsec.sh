#!/bin/bash

# A U T O   T E S T   C A S E S :

# ===== General =====
# Test API : adiLibGetErrorString(EERROR Code, char* ErrorString, size_t Length);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section Error_String_Message


# Test API : adiLibInit(EBOARD_TYPE BoardType);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section adiLibInit


# Test API : adiLibGetSystemInfo(SystemInfo* SysInfo);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SYS_Info


# ===== User LED =====
# Test API : adiUserLedBackplaneGetPort(uint64_t* PortValue); // BACC_USERLED or LEC1_MCP_USERLED
# Test API : adiUserLedBackplaneGetPin(uint8_t BitId, bool* Value);
# Test API : adiUserLedBackplaneSetPort(uint64_t PortValue);
# Test API : adiUserLedBackplaneSetPin(uint8_t BitId, bool Value);
# Test API : adiUserLedMainboardGetPort(uint64_t* PortValue); // BSEC_USERLED or LEC1_MCU_USERLED
# Test API : adiUserLedMainboardGetPin(uint8_t BitId, bool* Value);
# Test API : adiUserLedMainboardSetPort(uint64_t PortValue);
# Test API : adiUserLedMainboardSetPin(uint8_t BitId, bool Value);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED


# ===== HighCurrent_LED =====
# Test API : adiHcoGetPort(uint64_t* PortValue);
# Test API : adiHcoGetPin(uint8_t BitId, bool* Value);
# Test API : adiHcoSetPort(uint64_t PortValue);
# Test API : adiHcoSetPin(uint8_t BitId, bool Value);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section HighCurrent_LED
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section HighCurrent_LED


# ===== DIO =====
# Test API : adiDoSetLampBlink(uint64_t BitMask, uint16_t Period, uint16_t DutyCycle); // not support yet in 3.x
# Test API : adiDoGetLampBlink(uint8_t BitId, uint16_t* Period, uint16_t* DutyCycle); // not support yet in 3.x
# Test API : adiDoGetPort(uint64_t* PortValue);
# Test API : adiDoGetPin(uint8_t BitId, bool* Value);
# Test API : adiDoSetPort(uint64_t PortValue);
# Test API : adiDoSetPin(uint8_t BitId, bool Value);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED

# Test API : adiDiGetPort(uint64_t* PortValue);
# Test API : adiDiGetPin(uint8_t BitId, bool* Value);
# Test API : adiDiSetDebounceFilter(uint64_t BitMask, uint16_t DebounceValue); // not support yet in 3.x
# Test API : adiDiGetDebounceFilter(uint8_t BitId, uint16_t* DebounceValue); // not support yet in 3.x
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPI_Button

# Test API : adiDipSwitchBackplaneGetPort(uint64_t* PortValue); // BACC_DIPSWITCH
# Test API : adiDipSwitchBackplaneGetPin(uint8_t BitId, bool* Value);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPI_User_DIP_SW

# Test API : adiDipSwitchMainboardGetPort(uint64_t* PortValue); // need to be added
# Test API : adiDipSwitchMainboardGetPin(uint8_t BitId, bool* Value); // need to be added
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPI_Mainboard_DIP_SW

# Test API : adiBaccFsGetPort(uint64_t* PortValue); // BACC_FS1_FS2 // For BACC only // need to be added
# Test API : adiBaccFsGetPin(uint8_t BitId, bool* Value); // For BACC only // need to be added
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPI_BACC_FS

# ===== LED PCA9626 Driver =====
# Test API : adiLedSetBrightness(uint32_t BitMask, uint8_t Brightness)
# Test API : adiLedGetBrightness(uint8_t LedId, uint8_t* Brightness)
# Test API : adiLedSetBlink(uint8_t Blink, uint8_t DutyCycle)
# Test API : adiLedGetBlink(uint8_t* Blink, uint8_t* DutyCycle)
# Test API : adiLedSetPort(uint64_t PortValue)
# Test API : adiLedGetPort(uint64_t *PortValue)
# Test API : adiLedSetPin(uint8_t BitId, bool Value)
# Test API : adiLedGetPin(uint8_t BitId, bool *Value)
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive


# ===== EEPROM =====
# Test API : adiEepromRead(uint8_t Index, uint32_t Address, uint8_t* Buffer, size_t Length);
# Test API : adiEepromWrite(uint8_t Index, uint32_t Address, const uint8_t* Buffer, size_t Length);
# Test API : adiEepromGetSize(uint8_t Index, uint32_t* Size);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section EEPROM_Auto


# ===== Ext I2C =====
# Test API : adiI2cExec(uint8_t Address, const uint8_t* OutBuffer, size_t OutBufLen, uint8_t* InBuffer, size_t* InBufLen);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe --LOOP 1 --SLAVE_ADDR 0x51 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section ExtI2C


# ===== Ext SPI =====
# Test API : adiSpiInit(ESPI_BUS Bus, uint8_t Mode);
# Test API : adiSpiExec(ESPI_BUS Bus, uint8_t* OutBuffer, size_t OutBufLen, uint8_t* InBuffer, size_t InBufLen);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe --LOOP 2 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section Ext_SPI_RDID_REMS


# ===== Crypto =====
# Test API : adiCryptoGetSerial(char* Buffer, size_t Length);
# Test API : adiCryptoSendCmd(uint8_t Address, uint8_t Command, uint8_t* Buffer, size_t* DataLen, size_t BufferLen);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo ./idll-test.exe --LOOP 2 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section Crypto
#sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section Crypto_SHA


# ===== Hard Meter =====
# Test API : adiHardMeterOutGetPort(uint64_t* PortValue); // not support yet in 3.x
# Test API : adiHardMeterOutGetPin(uint8_t BitId, bool* Value); // not support yet in 3.x
# Test API : adiHardMeterOutSetPort(uint64_t PortValue); // not support yet in 3.x
# Test API : adiHardMeterOutSetPin(uint8_t BitId, bool Value); // not support yet in 3.x
# Test API : adiDoSetPort(uint64_t PortValue);
# Test API : adiHardMeterSenseGetPort(uint64_t* PortValue);
# The test HardMeter_BACC_SetPort expects the (max 8) hardmeters connected to Hardmeter Pin 0-7 and Out Pin 24-31!
# To test all 8 hardmeters set PORT_VAL to 255 (0xFF)
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo ./idll-test.exe --PORT_VAL 255 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section HardMeter_BACC_SetPort


# ===== SecMeter =====
# Test API : adiSecShowCounterValue(uint8_t CounterId);
# Test API : adiSecIncrementCounterValue(uint8_t CounterId, uint16_t IncrementValue);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe --LOOP 2 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter


# ===== PIC =====
# Test API : adiLibGetSystemInfo(SystemInfo* SysInfo);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section PIC_Firmware_Version
#sudo ./idll-test.exe --pic-fw 261  -- --EBOARD_TYPE EBOARD_ADi_SA3X --section PIC_Firmware_Version

# Add "-s" will display success test case message ==
# Test API : adiRtcCalibrate(int8_t Value);
# Test API : adiRtcGetTime(Time* Time);
# Test API : adiRtcSetTime(const Time* Time);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe --pic-time 2019/04/13/01/02/03 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section PIC_RTC

# Move PIC_RTC(without assigned date time) after PIC_RTC(WITH assigned date time) to prevent Day Light Saving problem with different 'time zone'.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section PIC_RTC_GETCLOCK
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section PIC_RTC

# Test API : adi1wireSearchAllDevices(uint8_t* DevicesCount);
# Test API : adi1wireGetUniqueId(uint8_t Index, char* Buffer, size_t Length);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section PIC_1Wire_IDs

# Test API : adi1wireEepromRead(uint8_t Index, uint32_t Address, uint8_t* Buffer, size_t Length);
# Test API : adi1wireEepromWrite(uint8_t Index, uint32_t Address, const uint8_t* Buffer,size_t Length);
# Test API : adi1wireEepromGetSize(uint8_t Index, uint32_t* Size);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section PIC_1Wire_EEPROM_Same_Pattern_0xA5
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section PIC_1Wire_EEPROM_Random_Pattern

# Test API : adiBatGenerateEvent(void);
# Test API : adiBatSetWarningVoltage(const Batteries* Voltages);
# Test API : adiBatGetWarningVoltage(Batteries* Voltages);
# Test API : adiBatSetLowVoltage(const Batteries* Voltages);
# Test API : adiBatGetLowVoltage(Batteries* Voltages);
# Test API : adiBatGetVoltages(Batteries* Batteries);
# Test API : adiEnableBatteryWarnEvent(uint8_t interval, uint16_t pinMask, void (*CallbackFunction)(const Event PicEvent, uint16_t triggeredPinMask));
# Test API : adiDisableBatteryWarnEvent(uint16_t pinMask);
# Test API : adiEnableBatteryLowEvent(uint8_t interval, uint16_t pinMask, void (*CallbackFunction)(const Event PicEvent, uint16_t triggeredPinMask));
# Test API : adiDisableBatteryLowEvent(uint16_t pinMask);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section PIC_GetPICEvent_and_CheckPICBatteryVoltage


# ===== SRAM =====
# Test API : adiSramGetSize(uint32_t* Size);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SRAM_Capacity

# Test API : adiSramRead(uint32_t Address, uint8_t* Buffer, size_t Length);
# Test API : adiSramWrite(uint32_t Address, const uint8_t* Buffer, size_t Length);
# Test API : adiSramGetBankInformation( uint32_t *Number, uint32_t *Size);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SRAM_Same_Pattern_0xA5
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SRAM_Random_Pattern
sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SRAM_Performance