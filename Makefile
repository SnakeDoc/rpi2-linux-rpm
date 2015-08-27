#########
# Makefile for rpi2-linux-rpm
#########

#########
# Declarations
#########
cur-dir        := $(shell pwd)

cache-dir      := $(cur-dir)/.cache

tools-cache    := $(cache-dir)/tools
tools-archive  := rpi2-cross-tools-current.tar.gz
tools-dir      := $(cur-dir)/tools
tools-url      := http://build.vanomaly.net/job/rpi-cross-tools/ws/archives/$(tools-archive)

source-cache   := $(cache-dir)/source
source-archive := linux
source-dir     := $(cur-dir)/$(source-archive)
source-url     := https://github.com/raspberrypi/$(source-archive)

linux-version  := rpi-4.1.y

#########
# Default target
#########
all: release

release: init get-tools get-source make-rpm	

#########
# Helpers
#########

###
# Sets up necessary directories, etc...
init:
	mkdir --parents $(cache-dir)/{tools,source}

###
# Installs tools
get-tools:
ifeq ("$(wildcard $(tools-dir))","$(tools-dir)")
	@echo
	@echo Existing tools found
	@echo Try running: make clean-tools
	@echo
else
ifneq ("$(wildcard $(tools-cache)/$(tools-archive))","$(tools-cache)/$(tools-archive)")
	@echo Tools not cached. Downloading...
	wget --read-timeout=20 --output-document=$(tools-cache)/$(tools-archive) $(tools-url)
else
	@echo Cached tools detected. Using...
endif
	@echo Installing tools...
	mkdir --parents $(tools-dir)/temp
	cp $(tools-cache)/$(tools-archive) $(tools-dir)/temp
	cd $(tools-dir)/temp && \
	tar --gzip --extract --verbose --file $(tools-archive) && \
	./install.sh $(tools-dir) && \
	rm --preserve-root --recursive --force $(tools-dir)/temp
	@echo Tools installed
endif

###
# Installs linux source
get-source:
ifeq ("$(wildcard $(source-dir))","$(source-dir)")
	rm --preserve-root --recursive --force $(source-dir)
endif
	mkdir --parents $(source-dir)
ifneq ("$(wildcard $(source-cache)/$(source-archive))","$(source-cache)/$(source-archive)")
	@echo Source not cached. Downloading...
	cd $(source-cache) && git clone $(source-url) --branch $(linux-version) --depth=1 --progress
else
	@echo Cached source detected. Using...
endif
	@echo Cleaning source...
	cd $(source-cache)/$(source-archive) && \
		$(MAKE) mrproper && git reset --hard $(linux-version) && \
			git checkout $(linux-version) && git reset --hard $(linux-version) && $(MAKE) mrproper
	cd $(source-cache) && cp --recursive $(source-archive)/* $(source-dir)/
	sync
	@# paranoid much?
	cd $(source-dir) && $(MAKE) mrproper

###
# Builds the rpm package
make-rpm:
	

#########
# Cleaning routines
#########

###
# Cleans the tools directory
clean-tools:
	chmod --recursive 777 $(tools-dir) 2> /dev/null || true
	rm --preserve-root --recursive --force $(tools-dir)

###
# Cleans the source directory
clean-source:
	rm --preserve-root --recursive --force $(source-dir)
###
# Cleans the rpm build directory
clean-rpm:
	
###
# Cleans the .cache directory
clean-cache:
	rm --preserve-root --recursive --force $(cache-dir)

###
# Cleans all work directories
clean-all: clean-rpm clean-source clean-tools clean-cache

###
# Alias for: make clean-all
clean: clean-all

