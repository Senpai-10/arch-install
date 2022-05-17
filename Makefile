# TODO: build: use pyinstaller to create a bin file (name: installer)
# and move the bin file to the root of this dir, run ./installer --part-1
# 

all: clean build

build:
	./install_build_requirements.sh
	@pyinstaller src/main.py --onefile -n installer
	mv dist/installer .

clean:
	rm -rf .mypy_cache build dist `find . -type d -name __pycache__` installer.spec