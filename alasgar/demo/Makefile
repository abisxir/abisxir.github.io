all: clean
	nim c -d:emscripten main.nim && python prepare.py
linux: clean
	nim c -d:release -r main.nim
fighter: clean
	nim c -r fighter.nim
wfc: clean
	nim c -r wfc.nim
island: clean
	nim c -r island.nim	
clean:
	rm -rf wfc
	rm -rf build
	rm -rf main
	rm -rf fighter
	rm -rf island
