$?AVMPLUS_MASTER:=$(abspath avmplus)
$?UNAME:=$(shell uname -s)

$?GCC_WARNINGS_IGNORING:=-Wno-unused-function -Wno-unused-local-typedefs -Wno-maybe-uninitialized -Wno-narrowing -Wno-sizeof-pointer-memaccess -Wno-unused-variable -Wno-unused-but-set-variable -Wno-deprecated-declartions

ifdef NUMBER_OF_PROCESSORS
	$?THREADS=$(NUMBER_OF_PROCESSORS)
else
	$?THREADS=2
endif

ifneq (,$(findstring CYGWIN,$(UNAME)))
	$?BUILD:=build.cygwin
else ifneq (,$(findstring MINGW,$(UNAME)))
	$?BUILD:=build.mingw32
else
	$?BUILD:=build
endif

tr:
	mkdir -p $(BUILD)
	cd $(BUILD) && CC=gcc CXX=g++ AR=ar CFLAGS="-m32 $(GCC_WARNINGS_IGNORING)" CXXFLAGS="-m32 $(GCC_WARNINGS_IGNORING)" LDFLAGS= $(AVMPLUS_MASTER)/configure.py \
		--enable-shell --enable-alchemy-posix --target=i686-linux
	cd $(BUILD) && make
