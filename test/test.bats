#!/usr/bin/env bats

setup() {
	load 'test_helper/bats-support/load'
	load 'test_helper/bats-assert/load'
	PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
	PATH="$PROJECT_ROOT/bin:$PATH"
	TMP="$(mktemp -d)"
	cd "$TMP"
}

teardown() {
	rm -rf "$TMP"
}

assert_files() {
	run ls
	assert_success
	assert_output "$(for f in "$@"; do echo "$f"; done)"
}

@test "can rotate single file" {
	touch target
	assert_files "target"
	rotate target
	assert_files "target.1"
	rotate target
	rotate target
	rotate target
	rotate target
	rotate target
	assert_files "target.6"
	rotate target
	assert_files "target.7"
	rotate target
	assert_files "target.7"
}

@test "can rotate multiple files" {
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

@test "blows up on faulty parameters" {
	run rotate --what --the
	assert_failure
	run rotate a b c
	assert_failure
	run rotate -a
	assert_failure
}

@test "can compress rotated files" {
	echo 0 > target
	rotate --zstd target
	assert_files "target.1"
	echo 1 > target
	rotate --zstd target
	assert_files "target.1" "target.2.zst"
	[ "$(zstd -d < target.2.zst)" = 0 ]
	echo 2 > target
	rotate --zstd target
	assert_files "target.1" "target.2.zst" "target.3.zst"
	[ "$(zstd -d < target.3.zst)" = 0 ]
	[ "$(zstd -d < target.2.zst)" = 1 ]
}

@test "can upgrade uncompressed files" {
	echo 0 > target
	echo 1 > target.1
	echo 2 > target.2
	rotate --zstd target
	assert_files "target.1" "target.2.zst" "target.3.zst"
}

@test "does not replace compressed files with uncompressed files" {
	echo ok | zstd > target.1.zst
	echo not ok > target.1
	rotate --zstd target
	assert_files "target.1" "target.2.zst"
	[ "$(zstd -d < target.2.zst)" = "ok" ]
	[ "$(cat target.1)" = "not ok" ]

	echo new > target
	rotate --zstd target
	assert_files "target.1" "target.2.zst" "target.3.zst"
	[ "$(zstd -d < target.3.zst)" = "ok" ]
	[ "$(zstd -d < target.2.zst)" = "not ok" ]
	[ "$(cat target.1)" = "new" ]
}

@test "can be quiet" {
	touch target
	run rotate target
	assert_success
	assert_output ''
}

@test "can be verbose" {
	touch target
	run rotate -v target
	assert_success
	assert_output 'target -> target.1'
}

# vim: set ft=sh :
