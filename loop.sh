
# ===== General =====
# Test API : adiLibGetErrorString(EERROR Code, char* ErrorString, size_t Length);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Error_String_Message

# Test API : adiLibInit(EBOARD_TYPE BoardType);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section adiLibInit

# Test API : adiLibGetSystemInfo(SystemInfo* SysInfo);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SYS_Info


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
sudo sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section User_LED


# SA3X does not support High Current LED
# ===== HighCurrent_LED =====
# Test API : adiHcoGetPort(uint64_t* PortValue);
# Test API : adiHcoGetPin(uint8_t BitId, bool* Value);
# Test API : adiHcoSetPort(uint64_t PortValue);
# Test API : adiHcoSetPin(uint8_t BitId, bool Value);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED


# ===== DIO =====
# Test API : adiDoSetLampBlink(uint64_t BitMask, uint16_t Period, uint16_t DutyCycle);
# Test API : adiDoGetLampBlink(uint8_t BitId, uint16_t* Period, uint16_t* DutyCycle);
# Test API : adiDoGetPin(uint8_t BitId, bool* Value);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPO_LED


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
sudo sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPO_LED_Drive

# Test API : adiDiGetPort(uint64_t* PortValue);
# Test API : adiDiGetPin(uint8_t BitId, bool* Value);
# Test API : adiDiSetDebounceFilter(uint64_t BitMask, uint16_t DebounceValue);
# Test API : adiDiGetDebounceFilter(uint8_t BitId, uint16_t* DebounceValue);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPI_Button

# Test API : adiDipSwitchMainboardGetPort(uint64_t* PortValue);
# Test API : adiDipSwitchMainboardGetPin(uint8_t BitId, bool* Value);
# Test API : adiDipSwitchBackplaneGetPort(uint64_t* PortValue); // BACC_DIPSWITCH
# Test API : adiDipSwitchBackplaneGetPin(uint8_t BitId, bool* Value);
# Test API : adiBaccFsGetPort(uint64_t* PortValue); // BACC_FS1_FS2 // For BACC only
# Test API : adiBaccFsGetPin(uint8_t BitId, bool* Value); // For BACC only
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPI_User_DIP_SW


# ===== EEPROM =====
# Test API : adiEepromRead(uint8_t Index, uint32_t Address, uint8_t* Buffer, size_t Length);
# Test API : adiEepromWrite(uint8_t Index, uint32_t Address, const uint8_t* Buffer, size_t Length);
# Test API : adiEepromGetSize(uint8_t Index, uint32_t* Size);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section EEPROM_Auto
# Can assign which eeprom to test
#sudo sudo ./idll-test.exe --EMEM_TYPE EMEM_EEPROM1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section EEPROM_Auto
#sudo sudo ./idll-test.exe --EMEM_TYPE EMEM_EEPROM2 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section EEPROM_Auto
#sudo sudo ./idll-test.exe --EMEM_TYPE EMEM_EEPROM3 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section EEPROM_Auto


# ===== Ext I2C=====
# Please make sure the slave address of EEPROM on the external I2C is 0x50.
# Test API : adiI2cExec(uint8_t Address, const uint8_t* OutBuffer, size_t OutBufLen, uint8_t* InBuffer, size_t* InBufLen);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section ExtI2C


# ===== Ext SPI =====
# Test API : adiSpiInit(ESPI_BUS Bus, uint8_t Mode);
# Test API : adiSpiExec(ESPI_BUS Bus, uint8_t* OutBuffer, size_t OutBufLen, uint8_t* InBuffer, size_t InBufLen);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Ext_SPI_RDID_REMS


# ===== Crypto =====
# Test API : adiCryptoGetSerial(char* Buffer, size_t Length);
# Test API : adiCryptoSendCmd(uint8_t Address, uint8_t Command, uint8_t* Buffer, size_t* DataLen, size_t BufferLen);
# Test API : adiCryptoAesSetMode(ECRYPTO_AES_MODE mode);
# Test API : adiCryptoAesGetMode(ECRYPTO_AES_MODE mode);
# Test API : adiCryptoAesSetKey(const uint8_t* Buffer, size_t Length);
# Test API : adiCryptoAesGetKey(uint8_t* Buffer, size_t Length);
# Test API : adiCryptoAesEncode(const uint8_t* InBuffer, uint8_t* OutBuffer, size_t InOutBufLen);
# Test API : adiCryptoAesDecode(const uint8_t* InBuffer, uint8_t* OutBuffer, size_t InOutBufLen);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Crypto
#sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Crypto_SHA
#sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Crypto_AES


# ===== FPGA FW SHA256 verify =====
# Test API : adiLibGetFirmwareSHA256(char* Sha256String);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X "Scenario: adiLibGetFirmwareSHA256"


# ===== Mard Meter =====
# Test API : adiHardMeterOutSetPort(uint64_t PortValue);
# Test API : adiHardMeterOutSetPin(uint8_t BitId, bool Value);
# Test API : adiHardMeterSenseGetPort(uint64_t* PortValue);
# Test API : adiHardMeterSenseGetPin(uint8_t BitId, bool* Value);
# Desc     : If not have 8 hard meters, assign --PORT_VAL as which pins your hard meter(s) connect to. (from 0x01~0xFF). Format: --PORT_VAL <decimal/hex number>
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HardMeter
#sudo sudo ./idll-test.exe --PORT_VAL 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HardMeter


# Test API : adiHardMeterDetectionPort(uint64_t* Status)
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HardMeter_Detection_ByPort


# Test API : adiHardMeterDetectionPin(uint8_t BitId, bool* Status)
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe --HM_PIN_ID 0x0 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HardMeter_Detection_ByPin


# ===== SecMeter =====
# Test API : adiSecShowCounterValue(uint8_t CounterId);
# Test API : adiSecIncrementCounterValue(uint8_t CounterId, uint16_t IncrementValue);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SecMeter

# Test API : adiSecSelfTest(ESEC_ERROR* errorCode);
# Test API : adiSecRequestStatus(uint8_t *statusByte);
# Test API : adiSecRequestMarketType(uint8_t *marketType);
# Test API : adiSecRequestVersion(char* textBuffer, size_t textBufLen);
# Test API : adiSecRequestFingerPrint(uint32_t *fingerPrint);]
# Test API : adiSecRequestLastError(ESEC_ERROR* errorCode);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SecMeter_New

# Test API : adiSecShowBitPattern(uint8_t* pattern, size_t patternSize);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SecMeter_BitPattern

# Test API : adiSecSetNumCounters(uint8_t numCounters);
# Test API : adiSecCycleCounterDisplay(bool startOrStop);
# sec-counter-num : The counter of channel in cycle display, it must be >= 1 and <= 31 (show counter text(1s) + counter value(3s) three times for each channel)
# sec-reserve-time : The resvered time in ms for the secmeter to show the cycle display (3 * 4000 * sec-counter-num + 1000 by dedault)
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#sudo sudo ./idll-test.exe --sec-counter-num 3 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SecMeter_Cycle


# ===== PIC =====
# Test API : adiLibGetSystemInfo(SystemInfo* SysInfo);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_Firmware_Version

# Add "-s" will display success test case message ==
# Test API : adiRtcCalibrate(int8_t Value);
# Test API : adiRtcGetTime(Time* Time);
# Test API : adiRtcSetTime(const Time* Time);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe --pic-time 2019/04/13/01/02/03 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_RTC

# Move PIC_RTC(without assigned date time) after PIC_RTC(WITH assigned date time) to prevent Day Light Saving problem with different 'time zone'.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_RTC
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_RTC_GETCLOCK

# Test API : adi1wireSearchAllDevices(uint8_t* DevicesCount);
# Test API : adi1wireGetUniqueId(uint8_t Index, char* Buffer, size_t Length);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_1Wire_IDs

# Test API : adi1wireEepromRead(uint8_t Index, uint32_t Address, uint8_t* Buffer, size_t Length);
# Test API : adi1wireEepromWrite(uint8_t Index, uint32_t Address, const uint8_t* Buffer,size_t Length);
# Test API : adi1wireEepromGetSize(uint8_t Index, uint32_t* Size);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_1Wire_EEPROM_Same_Pattern_0xA5
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_1Wire_EEPROM_Random_Pattern

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
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_GetPICEvent_and_CheckPICBatteryVoltage

# [CALLBACK][PIC][UNITTEST] will run all callback of pic unit test
# PIC Callback Add, duplicate add, remove every intrusion pin and event.
# PIC Callback Event queue full.
# Test API : adiEnableQueueFullEvent(void (*CallbackFunction)(uint8_t eventCount));
# Test API : adiDisableQueueFullEvent(void);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Callback_PIC_Intrusion_Auto [CALLBACK][PIC][UNITTEST]
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Callback_PIC_EventQueueFull_Auto [CALLBACK][PIC][UNITTEST]
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Callback_PIC_WDTimeout_Auto [CALLBACK][PIC][UNITTEST]
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Callback_PIC_RtcAlarm_Auto [CALLBACK][PIC][UNITTEST]
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Callback_PIC_BatWarn_Auto [CALLBACK][PIC][UNITTEST]
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Callback_PIC_BatLow_Auto [CALLBACK][PIC][UNITTEST]

# RD Test
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X [AUTO][UNITTEST]

# RD Test
# Assign --pic-fw parameter to verify
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# sudo sudo ./idll-test.exe --pic-fw 110  -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_Firmware_Version


# ===== PIC Alarm (& configuration) auto =====
# Test API : adiEnableRtcAlarmEvent(const Time* alarmTime, void (*CallbackFunction)(const Event wdEvent));
# Test API : adiDisableRtcAlarmEvent(void);
# Test API : adiRtcGetAlarm(Time* alarmTime);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_RTC_ALARM_auto [PIC][RTC][ALARM][UNITTEST][AUTO]
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_RTC_ALARM_CONF_auto [PIC][RTC][ALARM][UNITTEST][AUTO]


# ===== adiWatchdogSetSystemRestart & adiWatchdogGetSystemRestart  =====
# Test API : adiEnableWatchdogTimeoutEvent(void (*CallbackFunction)(const Event wdEvent));
# Test API : adiDisableWatchdogTimeoutEvent(void); 
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X "Scenario: adiWatchdogSetSystemRestart" -s


# ===== SRAM =====
# Test API : adiSramGetSize(uint32_t* Size);
# Test API : adiSramRead(uint32_t Address, uint8_t* Buffer, size_t Length);
# Test API : adiSramWrite(uint32_t Address, const uint8_t* Buffer, size_t Length);
# Test API : adiSramGetBankInformation( uint32_t *Number, uint32_t *Size);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SRAM_Capacity
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SRAM_Same_Pattern_0xA5
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SRAM_Random_Pattern
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SRAM_Performance


# ===== SRAM =====
# Test API : adiSramSetCallback(ESRAM_CALLBACK_TYPE CallbackType, void ( *CallbackFunction )( AsyncSramData* ));
# Test API : adiSramAsyncWriteWithVerify( uint32_t SRAMAddress, uint32_t SRAMAccessLength, uint8_t *MainMemoryAddress );
# Test API : adiSramAsyncBankCopy( uint32_t Address, uint32_t Length, uint32_t SourceBank, uint32_t DestinationBank);
# Test API : adiSramAsyncBankCompare( uint32_t SourceBank, uint32_t DestinationBank, uint32_t Address, uint32_t Length);
# Test API : adiSramAsyncCalculateCRC32( uint32_t StartAddress, uint32_t Length);
# Test API : adiSramGetBankInformation( uint32_t *Number, uint32_t *Size);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section ASYNC_SRAM


# ===== SRAM =====
# Test API : adiSramWriteWithVerify( uint32_t SRAMAddress, uint32_t SRAMAccessLength, uint8_t *MainMemoryAddress, uint32_t *ErrorAddress );
# Test API : adiSramBankCopy( uint32_t Address, uint32_t Length, uint32_t SourceBank, uint32_t DestinationBank);
# Test API : adiSramBankCompare( uint32_t SourceBank, uint32_t DestinationBank, uint32_t Address, uint32_t Length, uint32_t *ErrorAddress);
# Test API : adiSramCalculateCRC32( uint32_t StartAddress, uint32_t Length, uint32_t *CRC32);
# Test API : adiSramGetBankInformation( uint32_t *Number, uint32_t *Size);
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SYNC_SRAM


# ===== 4xGPIO (only for SA3X) =====
# Test API : adiGpioSetPort(uint64_t PortValue)
# Test API : adiGpioGetPort(uint64_t* PortValue)
# Depend on FPGA configuration, the GPO pin number maybe from 0 to 8. The possible GPIO_PORT_VAL range is from 0x0 to 0xFF.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe --GPIO_PORT_VAL 0xF -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SA3X_4xGPIO_by_Port

# Test API : adiGpioGetPin(uint8_t BitId, bool* Value)
# Test API : adiGpioSetPin(uint8_t BitId, bool Value)
# Depend on FPGA configuration, the GPO pin number maybe from 0 to 8. The possible value range is from 0x0 to 0xFF.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sudo sudo ./idll-test.exe --GPIO_PIN_ID 0x0 --GPIO_PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SA3X_4xGPIO_by_Pin