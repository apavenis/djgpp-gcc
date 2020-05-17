#pragma once

#include <filesystem>
#include <regex>
#include <set>
#include <string>
#include <vector>

class ManifestInfo
{
public:
    ManifestInfo();
    ManifestInfo(const std::vector<std::string>& rules);

    bool check_file(const std::filesystem::path& p);
    const std::set<std::filesystem::path>& get() const { return files; }
    void write(const std::filesystem::path& p) const;

private:
    std::vector<std::regex> rules;
    std::set<std::filesystem::path> files;
};
