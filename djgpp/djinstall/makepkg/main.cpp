#include <locale>
#include "PkgBuilder.hpp"

int main(int argc, char** argv)
{
    const char* src_search = argc > 1 ? argv[1] : "..";
    const char* inst_dir = argc > 2 ? argv[2] : ".";
    PkgBuilder builder(src_search, inst_dir);
    builder.run();
    return 0;
}
