all: clean
	nim c -d:emscripten main.nim && /usr/bin/python3 prepare.py
clean:
	rm -rf build
demo:
	rm -rf /tmp/convert
	mkdir /tmp/convert
	ffmpeg -i ~/Downloads/demo.webm /tmp/convert/frame%04d.png
	apngasm -d 17 -o /tmp/convert/demo.png /tmp/convert/frame*.png
	cp /tmp/convert/demo.png ./demo.png
	rm -rf /tmp/convert
	rm -rf ~/Downloads/demo.webm