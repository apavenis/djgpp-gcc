#include "PkgBuilder.hpp"

const std::vector<std::string> PkgBuilder::mft_gpp = {
    "/cat1/gpp",
    "/cc1plus\\.exe$",
    "/cp/news",
    "^lib/libstdcfs\\.(?:la|a)$",
    "/libstdcxx",
    "/libsupcxx",
    "^bin/gpp\\.exe$",
    "^include/cxx/",
    "^manifest/gpp",
};

const std::vector<std::string> PkgBuilder::mft_for = {
    "^bin/gfortran\\.exe$",
    "info/gfortran\\.info$",
    "/libgf",
    "/f951\\.exe",
    "^manifest/gfor",
    "/finclude/ieee_",
    "/libcaf_single\\.(?:a|la)",
    "/include/iso_fortran_binding\\.h",
    "/cat1/gfortran"
};

const std::vector<std::string> PkgBuilder::mft_objc = {
    "libobjc\\.",
    "/include/objc/",
    "/cc1obj[^.]*\\.exe",
    "manifest/objc",
    "/libobjc/(readme|threads)",
    "/objc/readme"
};

const std::vector<std::string> PkgBuilder::mft_ada = {
    "bin/gnat[^.]*\\.exe",
    "bin/gprmake\\.exe",
    "info/gnat",
    "/adainclude/",
    "/adalib/",
    "/gnat1\\.exe",
    "manifest/ada",
    "/ada_target_properties"
};

const std::vector<std::string> PkgBuilder::mft_gcc = {
    "/bugs",
    "/bugs\\.html",
    "/cat1/(?:cpp|gcc|gcov|lto-dump)",
    "/cat7/",
    "/cc1\\.exe",
    "/collect2\\.exe",
    "/copying",
    "/djgpp\\.ver$",
    "/faq",
    "/gcc/onews",
    "/include-fixed/(?:limits|syslimits)\\.h$",
    "/include-fixed/readme$",
    "/include/[^.]*?intrin\\.h(?:|[0-9])$",
    "/include/cet\\.h$",
    "/include/cpuid\\.h$",
    "/include/cross-stdarg\\.h$",
    "/include/float\\.h$",
    "/include/gcov\\.h$",
    "/include/header\\.gcc",
    "/include/iso646\\.h$",
    "/include/mm(?:_malloc|3dnow)\\.h$",
    "/include/quadmath*?\\.h(?:|[0-9])$",
    "/include/std[^.]*?\\.h$",
    "/include/tgmath\\.h$",
    "/include/unwind\\.h$",
    "/include/varargs\\.h$",
    "/install-tools/",
    "/libgcc\\.a",
    "/libgcov\\.a",
    "/libquadmath\\.(?:la|a)",
    "/libssp",
    "[0-9]+/lto[^.]*\\.exe",
    "/lto1\\.exe",
    "/news",
    "/readme",
    "bin/cpp\\.exe",
    "bin/gcc-(?:ar|nm|ranlib)\\.exe",
    "bin/gcc\\.exe",
    "bin/gccbug",
    "bin/gcov-dump\\.exe",
    "bin/gcov-tool\\.exe",
    "bin/gcov\\.exe",
    "bin/lto-dump",
    "faq\\.html",
    "/include/ssp/.*?.h$",
    "info/(?:cpp|gcc|libquadmath)",
    "manifest/gcc",
    "readme.djgpp",
    "share/locale/",
};

const std::vector<std::string> PkgBuilder::mft_ignore = {
    "/adainclude/s-stratt__xdr\\.adb",
    "dsmsrc/(?:ada|gcc|gfor|gpp|objc)b\\.dsi$",
    "share/info/dir$",
    "share/man/man[1-9]/",
    "bin/djgpp-gcc-",
    "bin/djgpp-gfortran\\.exe$",
    "^.*?.pl",
    "^.*?.sh",
    "/gcc/config/",
    "/gcc/d/",
    "/maintainer-scripts/",
    "/libphobos/",
    "/libbacktrace/",
    "/libffi/",
    "/contrib/reg",
    "/contrib/vim-gcc-dev",
    "/libhsail/"
};
