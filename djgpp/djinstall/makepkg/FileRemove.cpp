#include "PkgBuilder.hpp"

const std::vector<std::regex> PkgBuilder::remove_instr = {
    std::regex("bin/c\\+\\+\\.exe"),
    std::regex("bin/djgpp-.*?\\.exe"),
    std::regex("adainclude/s-stratt__xdr\\.adb"),
    std::regex("info/dir"),
    std::regex("libphobos/"),
    std::regex("gcc/d/"),
    std::regex("gcc/config/arm/"),
    std::regex("gcc/m2"),
    std::regex("/g\\+\\+-mapper-server\\.exe")
};
