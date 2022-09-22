exe_name=arch-installer

build: clean
	cargo build --release --verbose
	cp ./target/release/${exe_name} ./${exe_name}-testing

clean:
	cargo clean