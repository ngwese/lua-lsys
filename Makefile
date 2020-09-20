# lua-lsys
#
# Targets:
#   test            run tests

TEST_DIR := $(shell pwd)/test
TEST_WRAPPER ?=

test:
	$(TEST_WRAPPER) lua5.3 $(TEST_DIR)/lsys_value_test.lua --verbose
	$(TEST_WRAPPER) lua5.3 $(TEST_DIR)/lsys_selector_test.lua --verbose
	$(TEST_WRAPPER) lua5.3 $(TEST_DIR)/lsys_test.lua --verbose

.PHONY: test
