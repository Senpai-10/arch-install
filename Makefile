exe_name=arch-installer

build: clean
	cargo build --release --verbose
	cp ./target/release/${exe_name} ./${exe_name}-testing

clean:
	cargo clean

upload:
	git add "${exe_name}-testing"
	git commit -m "commit ${exe_name}-testing for testing"
	git push