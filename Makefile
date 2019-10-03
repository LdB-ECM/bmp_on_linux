# If cross compiling from windows use native GNU-Make 4.2.1
# https://sourceforge.net/projects/ezwinports/files/
# download "make-4.2.1-without-guile-w32-bin.zip" and set it on the enviroment path
# There is no need to install cygwin or any of that sort of rubbish

ifeq ($(OS), Windows_NT)
	#WINDOWS USE THESE DEFINITIONS
	RM = -del /q
	SLASH = \\
else
	#LINUX USE THESE DEFINITIONS
	RM = -rm -f
	SLASH = /
endif 

TARGET = tuffchem.cmd


Pi3-64: CFLAGS = -Wall -O3 -mcpu=cortex-a53+fp+simd  -std=c11 -mstrict-align -fno-tree-loop-vectorize -fno-tree-slp-vectorize -Wno-nonnull-compare
Pi3-64: ARMGNU = D:/gcc-linaro-7.4.1-2019.02-i686-mingw32_aarch64-elf/bin/aarch64-elf

Pi3: CFLAGS = -Wall -O3 -mcpu=cortex-a53 -mfpu=neon-vfpv4 -mfloat-abi=hard  -std=c11 -mno-unaligned-access -fno-tree-loop-vectorize -fno-tree-slp-vectorize -Wno-nonnull-compare
Pi3: ARMGNU = D:/GCC/gcc-arm-none-eabi-8/bin/arm-none-eabi

Pi2: CFLAGS = -Wall -O3 -mcpu=cortex-a7 -mfpu=neon -mfloat-abi=hard -std=c11 -mno-unaligned-access -fno-tree-loop-vectorize -fno-tree-slp-vectorize -Wno-nonnull-compare
Pi2: ARMGNU = D:/GCC/gcc-arm-none-eabi-8/bin/arm-none-eabi

Pi1: CFLAGS = -Wall -O3 -mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard -std=c11 -mno-unaligned-access -fno-tree-loop-vectorize -fno-tree-slp-vectorize -Wno-nonnull-compare
Pi1: ARMGNU = D:/SysGCC/raspberry/bin/arm-linux-gnueabihf

# The directory in which source files are stored.
SOURCE = ${CURDIR}
BUILD = build

INCLUDE = -I$(SOURCE) -I$(SOURCE)/Fonts


# The name of the assembler listing file to generate.
LIST = kernel.list

# The name of the map file to generate.
MAP = kernel.map

# The names of all object files that must be generated. Deduced from the 
# assembly code files in source.
CFILES = $(wildcard $(SOURCE)/*.c) $(wildcard $(SOURCE)/Fonts/*.c)
COBJS := $(patsubst %.c,$(BUILD)/%.o, $(notdir $(CFILES)))


Pi3-64: $(TARGET)
.PHONY: Pi3-64

Pi3: $(TARGET)
.PHONY: Pi3

Pi2: $(TARGET)
.PHONY: Pi2

Pi1: $(TARGET)
.PHONY: Pi1

all: Pi3-64 Pi3 Pi2 Pi1

$(COBJS): $(CFILES)
	$(ARMGNU)-gcc -MMD -MP $(INCLUDE) $(CFLAGS) $(filter %/$(patsubst %.o,%.c,$(notdir $@)), $(CFILES)) -c -o $@

$(TARGET): $(COBJS) 
	$(ARMGNU)-gcc $(CFLAGS) $(COBJS) -o bmplinux.cmd -lc -lm -lgcc -lpthread

# Control silent mode  .... we want silent in clean
.SILENT: clean

# cleanup temp files
clean:
	$(RM) $(BUILD)$(SLASH)*.o 
	$(RM) $(BUILD)$(SLASH)*.d 
	echo CLEAN COMPLETED
.PHONY: clean

