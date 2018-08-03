TARGET = sparsebundlefs

# Note: Doesn't work for paths with spaces in them
SRC_DIR=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
vpath %.cpp $(SRC_DIR)

PKG_CONFIG = pkg-config
override CFLAGS += -std=c++11 -Wall -pedantic -O2 -g

GCC_4_2_OR_HIGHER := $(shell expr `$(CXX) -dumpversion | sed 's/\.//g'` \>= 420)
ifeq "$(GCC_4_2_OR_HIGHER)" "1"
    CFLAGS += -march=native
endif

DEFINES = -DFUSE_USE_VERSION=26

ifeq ($(shell uname), Darwin)
	# Pick up OSXFUSE, even with pkg-config from MacPorts
	PKG_CONFIG := PKG_CONFIG_PATH=/usr/local/lib/pkgconfig $(PKG_CONFIG)
else ifeq ($(shell uname), Linux)
	LFLAGS += -Wl,-rpath=$(shell $(PKG_CONFIG) fuse --variable=libdir)
endif

FUSE_FLAGS := $(shell $(PKG_CONFIG) fuse --cflags --libs)

$(TARGET): sparsebundlefs.cpp
	$(CXX) $< -o $@ $(CFLAGS) $(FUSE_FLAGS) $(LFLAGS) $(DEFINES)

first: $(TARGET)

clean:
	rm -f $(TARGET)
	rm -Rf $(TARGET).dSYM

linux-gcc: linux-gcc-32 linux-gcc-64

linux-gcc-%:
	@docker-compose run -T --rm $@

all: first linux-gcc
