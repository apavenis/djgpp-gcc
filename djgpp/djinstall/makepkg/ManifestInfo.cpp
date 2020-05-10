#include "ManifestInfo.hpp"
#include <algorithm>
#include <fstream>
#include <iostream>

ManifestInfo::ManifestInfo()
{
}

ManifestInfo::ManifestInfo(const std::vector<std::string>& rules)
{
    std::transform(
        rules.begin(),
        rules.end(),
        std::back_inserter(this->rules),
        [](const std::string& r) { return std::regex(r, std::regex::icase); });
}

bool ManifestInfo::check_file(const std::filesystem::path& p)
{
    const std::string fn = p.string();
    for (const std::regex& r : rules) {
        if (std::regex_search(fn, r)) {
            files.insert(p);
            return true;
        }
    }
    return false;
}

void ManifestInfo::write(const std::filesystem::path& p) const
{
    try {
        std::ofstream mft;
        mft.exceptions(std::ios::failbit|std::ios::badbit);
        mft.open(p.string().c_str());
        for (const auto& p : files) {
            mft << p.string() << std::endl;
        }
    } catch (const std::exception& e) {
        throw std::runtime_error("Failed to write " + p.string() + ": " + e.what());
    }
}
