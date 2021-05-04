COMPILABLE_MODULES ?= $(dir $(wildcard */*/Makefile))

compile: $(COMPILABLE_MODULES)

$(COMPILABLE_MODULES): %: .PHONY
	$(MAKE) -C $@

.PHONY:
