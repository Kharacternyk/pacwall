DEPS = libalpm libconfig

CFLAGS ?= -g -Werror -Wall
CFLAGS += $(shell pkg-config --cflags $(DEPS))
LDLIBS += $(shell pkg-config --libs-only-l $(DEPS))
LDFLAGS += $(shell pkg-config --libs-only-other $(DEPS))

pacwall: pacwall.o generate.o opts.o
