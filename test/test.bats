#!/usr/bin/env bats

setup() {
	load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
	PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
	PATH="$PROJECT_ROOT/bin:$PATH"
	TMP="$(mktemp -d)"
}

teardown() {
	rm -rf "$TMP"
}

@test "can rotate single file" {
	cd "$TMP"
	touch target
	run ls
	assert_output "target"
	rotate target
	run ls
	assert_output "target.1"
	rotate target
	rotate target
	rotate target
	rotate target
	rotate target
	run ls
	assert_output "target.6"
	rotate target
	run ls
	assert_output "target.7"
	rotate target
	run ls
	assert_output "target.7"
}

@test "can rotate multiple files" {
	cd "$TMP"
	echo 0 > target
	echo 1 > target.1
	echo 2 > target.2
	echo 3 > target.3
	echo 4 > target.4
	echo 5 > target.5
	echo 6 > target.6
	echo 7 > target.7
	rotate target
	[ ! -f target ]
	[ "$(cat target.1)" = 0 ]
	[ "$(cat target.7)" = 6 ]
}

# vim: set ft=sh :
