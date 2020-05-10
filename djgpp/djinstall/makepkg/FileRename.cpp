#include "PkgBuilder.hpp"

const std::vector<std::pair<std::filesystem::path, std::filesystem::path> > PkgBuilder::file_rename_instr = {
    {"lib/libsupc++.la", "libsupcxx.la"},
    {"lib/libsupc++.a", "libsupcxx.a"},
    {"lib/libstdcxx.a-gdb.py", "libstdcxx_a-gdb-py"},
    {"lib/libstdc++fs.a", "libstdcfs.a"},
    {"lib/libstdc++fs.la", "libstdcfs.la"},
    {"bin/g++.exe", "gpp.exe"},
    {"share/man/man1/g++.1", "gpp.1"},
    {"lib/gcc/djgpp/10/adainclude/standard.ads.h", "standard_ads.h"}
};

