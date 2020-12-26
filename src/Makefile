DEPS = libalpm libconfig

CFLAGS ?= -g -Wall
CFLAGS += $(shell pkg-config --cflags $(DEPS))
LDLIBS += $(shell pkg-config --libs-only-l $(DEPS))
LDFLAGS += $(shell pkg-config --libs-only-other $(DEPS))

pacwall: pacwall.o generate.o opts.o
pacwall.o: generate.h opts.h util.h
opts.o: opts.h util.h
generate.o: generate.h opts.h util.h
