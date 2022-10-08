default:
	just -l -u

run:
	zig build run
	
# Run tests in watch  mode. Requires watchexec to be installed.
test:
	watchexec -c -e zig zig build test