DEPS = libalpm libconfig

debug: format check build

build:
	@gcc `pkg-config --cflags $(DEPS)` -o pacwall -g -Werror -Wall *.c \
		`pkg-config --libs $(DEPS)`

check:
	@cppcheck --suppress=missingIncludeSystem --template=gcc \
	          --quiet --platform=unix64 --enable=all *.c

format:
	@astyle --formatted --project *.c *.h

graph:
	@cinclude2dot | xdot -
