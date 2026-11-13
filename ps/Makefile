BUILD_DIR ?= build
PREFIX ?= $(HOME)/.local

.DEFAULT_GOAL := build
.PHONY: configure build run check install clean

configure:
	cmake -S . -B "$(BUILD_DIR)" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$(PREFIX)"

build: configure
	cmake --build "$(BUILD_DIR)" --parallel

run: build
	"$(BUILD_DIR)/app/mps" serve

check: build
	"$(BUILD_DIR)/app/mps" --help

install: build
	cmake --install "$(BUILD_DIR)"

clean:
	cmake --build "$(BUILD_DIR)" --target clean
