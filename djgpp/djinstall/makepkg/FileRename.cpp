#include "PkgBuilder.hpp"

const std::vector<std::pair<std::filesystem::path, std::filesystem::path> > PkgBuilder::file_rename_instr = {
    {"lib/libsupc++.la", "libsupcxx.la"},
    {"lib/libsupc++.a", "libsupcxx.a"},
    {"lib/libstdcxx.a-gdb.py", "libstdcxx_a-gdb-py"},
    {"lib/libstdc++exp.a", "libstdcexp.a"},
    {"lib/libstdc++exp.la", "libstdcexp.la"},
    {"libexec/gcc/djgpp/12/g++-mapper-server.exe", "gxx-mapper-server.exe"},
    {"bin/g++.exe", "gpp.exe"},
    {"share/man/man1/g++.1", "gpp.1"}
};

