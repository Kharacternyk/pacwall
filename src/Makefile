DEPS = libalpm libconfig

CFLAGS ?= -g -Werror -Wall
CFLAGS += $(shell pkg-config --cflags $(DEPS))
CFLAGS += $(shell pkg-config --libs $(DEPS))

debug: format check build

build:
	$(CC) $(CFLAGS) -o pacwall *.c

check:
	@cppcheck --suppress=missingIncludeSystem --template=gcc \
	          --quiet --platform=unix64 --enable=all *.c

format:
	@astyle --formatted --project *.c *.h
