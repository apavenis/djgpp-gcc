#pragma once

#include <algorithm>
#include <cassert>
#include <filesystem>
#include <functional>
#include <map>
#include <regex>
#include <vector>

class PkgBuilder
{
public:
    PkgBuilder(
        const std::filesystem::path& src_search,
        const std::filesystem::path& inst_dir);

    virtual ~PkgBuilder();

    void run();

private:
    void copy_docs();

    void remap_cpp_headers(
        const std::map<std::filesystem::path, std::filesystem::path>& rename_instr);

    void remap_c_headers(
        const std::map<std::filesystem::path, std::filesystem::path>& rename_instr);

    void rename_files(
        const std::vector<std::pair<std::filesystem::path, std::filesystem::path> >& rename_instr);

    void remove_files(const std::vector<std::regex> remove_instr);

    void create_mft();

    void write_ver(const std::string& name, const std::filesystem::path& p) const;

    void write_dsm(const std::filesystem::path& p_dsi, const std::filesystem::path& p_dsm) const;

    void sfn_check(const std::filesystem::path& dir);

    std::filesystem::path find_source_dir(const std::filesystem::path& base_dir);

    std::filesystem::path get_doc_dir();

    void parse_version();

    std::filesystem::path make_relative(
        const std::filesystem::path& path,
        const std::filesystem::path& base_path);

    void remap_headers(
        const std::string& name,
        const std::filesystem::path& header_dir,
        const std::map<std::filesystem::path, std::filesystem::path>& rename_instr);

    void convert_man_pages();

    void write_header_gcc(const std::filesystem::path& header_dir, const std::filesystem::path& orig_rel, const std::filesystem::path& new_rel);

private:
    const std::regex r_sfn;
    const std::filesystem::path gcc_src_dir;
    const std::string base_ver;
    const std::string date_stamp;
    std::string major;
    std::string minor;
    std::string revision;
    bool include_datestamp;
    std::filesystem::path inst_dir;

private:
    static const std::map<std::filesystem::path, std::filesystem::path> cpp_rename;
    static const std::map<std::filesystem::path, std::filesystem::path> c_inc_rename;
    static const std::vector<std::pair<std::filesystem::path, std::filesystem::path> > file_rename_instr;
    static const std::vector<std::regex> remove_instr;

    static const std::vector<std::string> mft_ignore;
    static const std::vector<std::string> mft_gpp;
    static const std::vector<std::string> mft_for;
    static const std::vector<std::string> mft_objc;
    static const std::vector<std::string> mft_ada;
    static const std::vector<std::string> mft_gcc;
};
