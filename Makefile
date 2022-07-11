exe_name=installer

build: clean
	cargo build --release
	cp ./target/release/${exe_name} .

clean:
	cargo clean