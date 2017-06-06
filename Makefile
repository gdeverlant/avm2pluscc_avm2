$?AVMPLUS_MASTER:=$(abspath avmplus)
$?UNAME:=$(shell uname -s)
$?TARGET:=
# $?TARGET:=i686-linux
$?DEBUG:=

$?GCC_WARNINGS_IGNORING:=-Wno-unused-function -Wno-unused-local-typedefs -Wno-maybe-uninitialized -Wno-narrowing -Wno-sizeof-pointer-memaccess -Wno-unused-variable -Wno-unused-but-set-variable -Wno-deprecated-declartions

ifdef NUMBER_OF_PROCESSORS
	$?THREADS=$(NUMBER_OF_PROCESSORS)
else
	$?THREADS=2
endif

ifneq (,$(findstring CYGWIN,$(UNAME)))
	$?BUILD:=build.cygwin
	$?LDFLAGS:=-static-libgcc -static-libstdc++
else ifneq (,$(findstring MINGW,$(UNAME)))
	$?BUILD:=build.mingw32
	$?LDFLAGS:=
else
	$?BUILD:=build
	$?LDFLAGS:=
endif

TARGET_FLAGS=
ifneq (,$(TARGET))
	TARGET_FLAGS=--target=$(TARGET)
endif

DEBUG_FLAGS=
ifneq (,$(DEBUG))
	DEBUG_FLAGS=--enable-debugger
endif

tr:
	mkdir -p $(BUILD)
	cd $(BUILD) && CC=gcc CXX=g++ AR=ar \
		CFLAGS="-m32 $(GCC_WARNINGS_IGNORING)" \
		CXXFLAGS="-m32 $(GCC_WARNINGS_IGNORING)" \
		LDFLAGS="$(LDFLAGS)" $(AVMPLUS_MASTER)/configure.py \
		--enable-telemetry --enable-telemetry-sampler --enable-jit \
		--enable-shell --enable-alchemy-posix $(TARGET_FLAGS) $(DEBUG_FLAGS)
	cd $(BUILD) && make -j$(THREADS)
