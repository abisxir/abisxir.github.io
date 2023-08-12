all: clean
	nim c -d:emscripten main.nim && /usr/bin/python3 prepare.py
clean:
	rm -rf build
