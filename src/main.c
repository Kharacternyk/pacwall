#include "generate.h"
#include "display.h"

int main(int argc, char **argv) {
    generate_graph("/tmp/pacwall.gv");
    display_graph("/tmp/pacwall.gv", "/tmp/pacwall.png");
}
