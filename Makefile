$?AVMPLUS_MASTER:=$(abspath avmplus)
$?UNAME:=$(shell uname -s)
$?TARGET:=
# $?TARGET:=i686-linux
$?DEBUG:=
$?DEBUGGER:=
$?EXE_EXT:=

$?GCC_WARNINGS_IGNORING:=-Wno-unused-function -Wno-unused-local-typedefs -Wno-maybe-uninitialized -Wno-narrowing -Wno-sizeof-pointer-memaccess -Wno-unused-variable -Wno-unused-but-set-variable
#-Wno-deprecated-declartions

ifdef NUMBER_OF_PROCESSORS
	$?THREADS=$(NUMBER_OF_PROCESSORS)
else
	$?THREADS=2
endif

ifneq (,$(findstring CYGWIN,$(UNAME)))
	$?BUILD:=build.cygwin
	$?LDFLAGS:=-static-libgcc -static-libstdc++
	$?EXE_EXT:=.exe
else ifneq (,$(findstring MINGW,$(UNAME)))
	$?BUILD:=build.mingw32
	$?EXE_EXT:=.exe
	$?LDFLAGS:=
else ifneq (,$(findstring Darwin,$(UNAME)))
	$?BUILD:=build.darwin
	$?EXE_EXT:=
	$?LDFLAGS:=
	$?GCC_WARNINGS_IGNORING:=-Wno-deprecated
	$?THREADS=$(shell sysctl -n hw.ncpu)
else
	$?BUILD:=build
	$?EXE_EXT:=
	$?LDFLAGS:=
endif

TARGET_FLAGS=
ifneq (,$(TARGET))
	TARGET_FLAGS=--target=$(TARGET)
endif

DEBUG_FLAGS=
ifneq (,$(DEBUG))
	DEBUG_FLAGS=--enable-debug 
endif

ifneq (,$(DEBUGGER))
	DEBUG_FLAGS+=--enable-debugger 
endif

tr: build
	cp -rf $(BUILD)/shell/avmshell$(EXE_EXT) avmshell$(EXE_EXT)

trd:
	make build BUILD=$(BUILD)-debugger DEBUGGER=1
	cp -rf $(BUILD)-debugger/shell/avmshell$(EXE_EXT) avmshell-debugger$(EXE_EXT)

trdd:
	make build BUILD=$(BUILD)-debug DEBUGGER=1 DEBUG=1
	cp -rf $(BUILD)-debug/shell/avmshell$(EXE_EXT) avmshell-debug$(EXE_EXT)

build:
	mkdir -p $(BUILD)
	cd $(BUILD) && CC=gcc CXX=g++ AR=ar \
		CFLAGS="-m32 $(GCC_WARNINGS_IGNORING)" \
		CXXFLAGS="-m32 $(GCC_WARNINGS_IGNORING)" \
		LDFLAGS="$(LDFLAGS)" $(AVMPLUS_MASTER)/configure.py \
		--enable-telemetry --enable-telemetry-sampler --enable-jit \
		--enable-shell --enable-alchemy-posix $(TARGET_FLAGS) $(DEBUG_FLAGS)
	cd $(BUILD) && make -j$(THREADS)

