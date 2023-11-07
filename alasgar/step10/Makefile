all: clean
	nim c -d:emscripten main.nim && /usr/bin/python3 prepare.py
clean:
	rm -rf build
demo:
	ffmpeg -i ~/Downloads/demo.webm -plays 0 -vf "setpts=PTS-STARTPTS, hqdn3d=1.5:1.5:6:6"  demo.apng
	rm -rf demo.png
	rm -rf ~/Downloads/demo.webm
	apngopt -z2 demo.apng demo.png
	rm -rf demo.apng