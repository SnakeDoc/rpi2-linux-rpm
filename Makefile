#########
# Makefile for rpi2-linux-rpm
#########

#########
# Declarations
#########
cur-dir := $(shell pwd)
cache-dir := $(cur-dir)/.cache
tools-cache := $(cache-dir)/tools
tools-dir := $(cur-dir)/tools
tools-archive := rpi2-cross-tools-current.tar.gz
tools-url := http://build.vanomaly.net/job/rpi-cross-tools/ws/archives/$(tools-archive)
source-cache := $(cache-dir)/source


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
	mkdir -p $(cache-dir)/{tools,source}

###
# Installs tools
get-tools:
ifeq ("$(wildcard $(tools-dir))","$(tools-dir)")
	@echo
	@echo Existing tools found
	@echo Try running: make clean-tools
	@echo
else
	mkdir $(tools-dir)
ifneq ("$(wildcard $(tools-cache)/$(tools-archive))","$(tools-cache)/$(tools-archive)")
	@echo Tools not cached. Downloading...
	wget --read-timeout=20 --output-document=$(tools-cache)/$(tools-archive) $(tools-url)
else
	@echo Cached tools detected. Using...
endif
	@echo Installing tools...
	mkdir $(tools-dir)/temp
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

