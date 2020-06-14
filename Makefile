CC=clang
CCFLAGS=--target=wasm32-unknown-unknown-wasm --optimize=3 -nostdlib
LDFLAGS=-Wl,--export-all -Wl,--no-entry -Wl,--allow-undefined

WASM2WAT=/opt/wabt/bin/wasm2wat

.PHONY: all

all: example1.wat

example1.wat: example1.wasm
	$(WASM2WAT) example1.wasm -o example1.wat

example1.wasm: example1.c memory-allocation.c
	$(CC) example1.c memory-allocation.c $(CCFLAGS) $(LDFLAGS) --output example1.wasm

clean:
	rm -f example1.wasm
	rm -f example1.wat
