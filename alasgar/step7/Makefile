clean:
	rm -rf build
all: clean
	nim c -d:emscripten main.nim && python prepare.py
