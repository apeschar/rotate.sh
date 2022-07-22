all : submodules
.PHONY : all

submodules : test/bats/.git test/test_helper/bats-support/.git test/test_helper/bats-assert/.git
.PHONY : submodules

test : submodules
	test/bats/bin/bats test
.PHONY : test

watch : submodules
	git ls-files | entr -c $(MAKE) -s test
.PHONY : watch

%/.git :
	git submodule update --init $*
