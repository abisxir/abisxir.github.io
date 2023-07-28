all: clean
	nim c -d:emscripten main.nim && python prepare.py
clean:
	rm -rf build
