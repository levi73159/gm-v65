include common/tools.mk

ROM_NAME=program

SRC_FOLDER=src
INCLUDE_FOLDER=include
BUILD_FOLDER=build
TEMP_FOLDER=$(BUILD_FOLDER)/$(ROM_NAME)

C_SOURCES=$(wildcard $(SRC_FOLDER)/*.c)
ASM_SOURCES=$(wildcard $(SRC_FOLDER)/*.s)
FIRMWARE_CFG=memory.cfg

ROM_TYPE=AT28C256
ROM_FILE=$(BUILD_FOLDER)/$(ROM_NAME).bin
MAP_FILE=$(TEMP_FOLDER)/$(ROM_NAME).map

GENERATED_ASM_FILES=$(C_SOURCES:$(SRC_FOLDER)/%.c=$(TEMP_FOLDER)/%.s)
ASM_OBJECTS=$(ASM_SOURCES:$(SRC_FOLDER)/%.s=$(TEMP_FOLDER)/%.o) \
            $(GENERATED_ASM_FILES:$(TEMP_FOLDER)/%.s=$(TEMP_FOLDER)/%.o)

LIBRARIES=common/none.lib

# Compile C sources to assembly
$(TEMP_FOLDER)/%.o: $(SRC_FOLDER)/%.c
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(TEMP_FOLDER)
	$(CC65_BINARY) $(CC65_FLAGS) -o $(@:.o=.s) -I $(INCLUDE_FOLDER) $<
	$(CA65_BINARY) $(CA65_FLAGS) -o $@ -l $(@:.o=.lst) $(@:.o=.s)

$(TEMP_FOLDER)/%.o: $(SRC_FOLDER)/%.s
	$(CA65_BINARY) $(CA65_FLAGS) -I $(INCLUDE_FOLDER) -o $@ -l $(@:.o=.lst) $<

# Link ROM image
$(ROM_FILE): $(ASM_OBJECTS) $(FIRMWARE_CFG)
	@$(MKDIR_BINARY) $(MKDIR_FLAGS) $(BUILD_FOLDER)
	$(LD65_BINARY) $(LD65_FLAGS) -C $(FIRMWARE_CFG) -o $@ -m $(MAP_FILE) $(ASM_OBJECTS) $(LIBRARIES)

# Default target
all: $(ROM_FILE)

# Build and install on EEPROM
install: $(ROM_FILE)
	minipro -p $(ROM_TYPE) -w $(ROM_FILE) -u

# Build and dump output
test: $(ROM_FILE)
	$(HEXDUMP_BINARY) $(HEXDUMP_FLAGS) $<
	$(MD5_BINARY) $<

.PRECIOUS: $(TMP_FOLDER)/%.s
