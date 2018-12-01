# Name
name		:= twopage
debug		:= 1

# Use packages
libsfx_packages := LZ4 

# Derived data files
derived_files	:= Data/first.png.palette Data/first.png.tiles Data/first.png.map
derived_files	+= Data/first.png.tiles.lz4 Data/first.png.map.lz4
derived_files	+= Data/second.png.palette Data/second.png.tiles Data/second.png.map
derived_files	+= Data/second.png.tiles.lz4 Data/second.png.map.lz4

# Include libSFX.make
libsfx_dir	:= ../..
include $(libsfx_dir)/libSFX.make
