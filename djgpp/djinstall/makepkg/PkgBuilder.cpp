#include "PkgBuilder.hpp"
#include <algorithm>
#include <cassert>
#include <iostream>
#include <fstream>
#include <filesystem>
#include <functional>
#include <map>
#include <regex>
#include <set>
#include <sstream>
#include <stdexcept>
#include <vector>
#include "ManifestInfo.hpp"

namespace fs = std::filesystem;

namespace {
    fs::path sfn_convert(const fs::path& src)
    {
        fs::path result;
        for (const fs::path& part : src) {
            std::string w;
            const std::string s = part.string();
            std::transform(s.begin(), s.end(), std::back_inserter(w), [](char c) { return c == '+' ? 'x' : c; });
            result /= w;
        }
        return result;
    }

    std::string do_replace(
        const std::string& src,
        const std::vector<std::pair<std::string, std::string> >& substitutions)
    {
        std::string a = src;
        for (const auto& item : substitutions) {
            std::ostringstream tmp;
            std::size_t pos;
            while ((pos = a.find(item.first)) != std::string::npos) {
                tmp << a.substr(0, pos) << item.second;
                a = a.substr(pos + item.first.length());
            }
            tmp << a;
            a = tmp.str();
        }
        return a;
    }

    std::string read_file(const fs::path& fn)
    {
        try {
            std::string content;
            std::ifstream input;
            input.exceptions(std::ios::failbit|std::ios::badbit);
            input.open(fn.string().c_str());
            std::copy(std::istreambuf_iterator<char>(input.rdbuf()), std::istreambuf_iterator<char>(), std::back_inserter(content));
            std::size_t pos = content.find_last_not_of(" \t\r\n");
            return pos == std::string::npos ? content : content.substr(0, pos + 1);
        } catch (const std::exception& e) {
            throw std::runtime_error("Failed to read " + fn.string() + ": " + e.what());
        }
    }

    void write_file(const fs::path& fn, const std::string& content)
    {
        fs::create_directories(fn.parent_path());

        try {
            std::ofstream output;
            output.exceptions(std::ios::failbit|std::ios::badbit);
            output.open(fn.string().c_str());
            output << content;
        } catch (const std::exception& e) {
            throw std::runtime_error("Failed to write " + fn.string() + ": " + e.what());
        }
    }
}

PkgBuilder::PkgBuilder(const fs::path& src_search, const fs::path& inst_dir)
    : r_sfn("^([\\w\\d-]+)(\\.[\\w\\d-]+|)$")
    , gcc_src_dir(find_source_dir(src_search))
    , base_ver(read_file(gcc_src_dir / "gcc" / "BASE-VER"))
    , date_stamp(read_file(gcc_src_dir / "gcc" / "DATESTAMP"))
    , inst_dir(inst_dir)
{
    parse_version();
    std::cout << "Source directory   : " << gcc_src_dir << std::endl;
    std::cout << "Base version       : " << base_ver << std::endl;
    std::cout << "Doc dir            : " << get_doc_dir() << std::endl;
}

PkgBuilder::~PkgBuilder()
{
}

void PkgBuilder::run()
{
    copy_docs();
    remap_cpp_headers(cpp_rename);
    remap_c_headers(c_inc_rename);
    rename_files(file_rename_instr);
    remove_files(remove_instr);
    convert_man_pages();
    sfn_check("../install.gcc");
    create_mft();
}

fs::path PkgBuilder::find_source_dir(const fs::path& base_dir)
{
    std::set<fs::path> results;

    for (const fs::path& p : fs::recursive_directory_iterator(base_dir)) {
        const std::string exp = base_dir.string() + "/gcc-";
        if (fs::is_directory(p) and (p.string().substr(0, exp.length()) == exp)) {
            if (fs::is_regular_file(p / "gcc" / "BASE-VER")
                and fs::is_regular_file(p / "gcc" / "DATESTAMP")
                and fs::is_regular_file(p / "gcc" / "gcc.c")
                and fs::is_regular_file(p / "gcc" / "DEV-PHASE")
                )
            {
                results.insert(p);
            }
        }
    };
    switch (results.size()) {
    case 0: throw std::runtime_error("Source directory not found");
    case 1: return fs::absolute(*results.begin());
    default: throw std::runtime_error("More than one source directory found");
    }
}

fs::path PkgBuilder::get_doc_dir()
{
    fs::path p = inst_dir / "gnu"
        / ("gcc-" + major + "." + minor + revision + (include_datestamp ? "_" + date_stamp : std::string()));
    return p;
}

void PkgBuilder::parse_version()
{
    std::smatch m;
    if (std::regex_match(base_ver, m, std::regex("^(\\d+)\\.(\\d+)\\.(\\d+)$"))) {
        const std::string dev_phase = read_file(gcc_src_dir / "gcc" / "DEV-PHASE");
        major = m[1].str();
        minor = m[2].str();
        revision = m[3].str();
        include_datestamp = (dev_phase != "") or (m[3].str() != "0");
    } else {
        throw std::runtime_error("Failed to parse base version '" + base_ver + "'");
    }
}

fs::path PkgBuilder::make_relative(const fs::path& path, const fs::path& base_path)
{
    std::function<fs::path(const fs::path&, const fs::path&)>
        impl = [&impl] (const fs::path& curr, const fs::path& exp) {
                   if (curr.has_parent_path()) {
                       fs::path parent = curr.parent_path();
                       if (parent == exp) {
                           return curr.filename();
                       } else {
                           return impl(parent, exp) / curr.filename();
                       }
                   } else {
                       throw std::runtime_error("Failed to make relative path");
                   }
               };

    return impl(fs::absolute(path), fs::absolute(base_path));
}

void PkgBuilder::copy_docs()
{
    const fs::path doc_dir = get_doc_dir();
    for (const fs::path& p : fs::recursive_directory_iterator(gcc_src_dir)) {
        if (fs::is_regular_file(p)) {
            const std::string fn = p.filename().string();
            if (false
                or (fn.substr(0, 6) == "README")
                or (fn.substr(0, 4) == "NEWS")
                or (fn.substr(0, 7) == "COPYING")
                or (fn.substr(0, 6) == "readme")
                )
            {
                const fs::path p_rel = make_relative(p, gcc_src_dir);
                const fs::path from = gcc_src_dir / p_rel;
                const fs::path to = doc_dir / sfn_convert(p_rel);
                fs::create_directories(to.parent_path());
                std::cout << "COPY: " << from << " -> " << to << std::endl;
                assert(fs::exists(from));
                fs::copy_file(from, to, fs::copy_options::overwrite_existing);
            }
        }
    }
}

void PkgBuilder::remap_cpp_headers(const std::map<fs::path, fs::path>& rename_instr)
{
    remap_headers(
        "C++ headers",
        inst_dir / "include" / "cxx" / major,
        rename_instr);
}

void PkgBuilder::remap_c_headers(const std::map<fs::path, fs::path>& rename_instr)
{
    remap_headers(
        "C headers",
        inst_dir / "lib" / "gcc" / "djgpp" / major / "include",
        rename_instr);
}

void PkgBuilder::remap_headers(
    const std::string& name,
    const fs::path& header_dir,
    const std::map<fs::path, fs::path>& rename_map_c)
{
    std::map<fs::path, fs::path> rename_map = rename_map_c;
    for (const fs::path& p : fs::recursive_directory_iterator(header_dir)) {
        if (not fs::is_regular_file(p)) {
            continue;
        }

        const fs::path orig_rel = make_relative(p, header_dir).string();
        auto it = rename_map.find(orig_rel);
        if (it != rename_map.end()) {
            const fs::path new_rel = orig_rel.parent_path() / it->second;
            std::cout << "RENAME (" << name << "): " << orig_rel << " --> " << new_rel << std::endl;
            fs::rename((header_dir / orig_rel), (header_dir / new_rel));
            write_header_gcc(header_dir, orig_rel, new_rel);
            rename_map.erase(it);
        }
    }

    if (not rename_map.empty()) {
        bool found_unused = false;
        for (const auto& item : rename_map) {
            const fs::path p = item.first.parent_path() / item.second;
            if (not fs::exists(header_dir / p)) {
                if (not found_unused) {
                    std::cout << std::endl;
                    std::cout << "Unused rename requests for " << name << ':' << std::endl;
                    found_unused = true;
                }
                std::cout << "     " << item.first << " -> " << item.second << std::endl;
            }
        }
    }

    sfn_check(header_dir);
}

void PkgBuilder::write_header_gcc(const fs::path& header_dir, const fs::path& orig_rel, const fs::path& new_rel)
{
    const fs::path fn = header_dir / "header.gcc";
    try {
        std::ofstream output;
        output.exceptions(std::ios::failbit|std::ios::badbit);
        output.open(fn.string().c_str(), std::ios::app | std::ios::out);
        output << orig_rel.string() << ' ' << new_rel.string() << std::endl;
    } catch (const std::exception& e) {
        throw std::runtime_error("Failed to write " + fn.string() + ": " + e.what());
    }

    const fs::path part = *orig_rel.begin();
    const fs::path next = header_dir / part;
    if (fs::is_directory(next)) {
        write_header_gcc(
            next,
            make_relative(header_dir / orig_rel, next),
            make_relative(header_dir / new_rel, next));
    }
}

void PkgBuilder::rename_files(const std::vector<std::pair<fs::path, fs::path> >& rename_instr)
{
    for (const auto& item : rename_instr) {
        const fs::path& orig_rel = item.first;
        if (not orig_rel.has_parent_path() or item.second.has_parent_path()) {
            std::ostringstream err;
            err << "Invalid file rename item " << orig_rel << " --> " << item.second;
            throw std::runtime_error(err.str());
        }

        const fs::path new_rel = orig_rel.parent_path() / item.second;
        if (fs::exists(inst_dir / orig_rel)) {
            std::cout << "RENAME: " << orig_rel << " --> " << new_rel << std::endl;
            fs::rename(inst_dir / orig_rel, inst_dir / new_rel);
        } else if (not fs::exists(inst_dir / new_rel)) {
            std::cout << "RENAME: neither " << orig_rel << " nor " << new_rel
                      << " is found" << std::endl;
        }
    }
}

void PkgBuilder::remove_files(const std::vector<std::regex> remove_instr)
{
    for (const fs::path& p : fs::recursive_directory_iterator(inst_dir)) {
        if (fs::is_regular_file(p)) {
            const std::string fn = p.string();
            for (const auto& r : remove_instr) {
                if (std::regex_search(fn, r)) {
                    std::cout << "REMOVE: " << make_relative(p, inst_dir) << std::endl;
                    fs::remove(p);
                }
            }
        }
    }
}

void PkgBuilder::create_mft()
{
    ManifestInfo m_ignore(mft_ignore);
    ManifestInfo m_ada(mft_ada);
    ManifestInfo m_for(mft_for);
    ManifestInfo m_gpp(mft_gpp);
    ManifestInfo m_objc(mft_objc);
    ManifestInfo m_gcc(mft_gcc);

    std::map<std::string, ManifestInfo*> m = {
        { "", &m_ignore },
        { "ada", &m_ada },
        { "gfor", &m_for },
        { "gpp", &m_gpp },
        { "objc", &m_objc },
        { "gcc", &m_gcc }
    };

    fs::create_directories(inst_dir / "manifest");

    const std::string mft_suffix = major + minor + revision
        + (include_datestamp ? "_" + date_stamp : "");


    const auto mft_path = [&](const std::string& n , const std::string& ext) {
                              return inst_dir / "manifest" / (n + mft_suffix + "b." + ext);
                          };

    for (const auto& item : m) {
        if (item.first != "") {
            const fs::path p_ver = mft_path(item.first, "ver");
            const fs::path p_mft = mft_path(item.first, "mft");
            const fs::path p_dsi = inst_dir / "dsmsrc" / (item.first + "b.dsi");
            const fs::path p_dsm = mft_path(item.first, "dsm");

            write_ver(item.first, p_ver);
            write_dsm(p_dsi, p_dsm);
            // Dummy write to get into file list
            item.second->write(p_mft);
        }
    }

    for (const fs::path& p : fs::recursive_directory_iterator(inst_dir)) {
        if (fs::is_regular_file(p)) {
            bool found = false;
            const fs::path pr = make_relative(p, inst_dir);
            for (const auto& x : m) {
                found |= x.second->check_file(pr);
            }
            if (not found) {
                std::cout << "SKIPPED: " << pr << std::endl;
            }
        }
    }

    for (const auto& item : m) {
        if (item.first != "") {
            const fs::path p_mft = mft_path(item.first, "mft");
            item.second->write(p_mft);
        }
    }
}

void PkgBuilder::write_ver(const std::string& name, const fs::path& p) const
{
    std::ostringstream ver;
    ver << p.filename().replace_extension(".zip") << ": GNU Compiler Collection: ";
    if (name == "gcc") {
        ver << "C compiler";
    } else if (name == "gpp") {
        ver << "C++ compiler";
    } else if (name == "gfor") {
        ver << "Fortran compiler";
    } else if (name == "ada") {
        ver << "Ada compiler ";
    } else if (name == "objc") {
        ver << "Objective-C and Objective C++ compilers";
    } else {
        throw std::runtime_error("PkgBuilder::write_ver: invalid first parameter: " + name);
    }
    ver << " (Version " << major << '.' << minor << '.' << revision;
    if (include_datestamp) {
        ver << '_' << date_stamp;
    }
    ver << ')';

    write_file(p, ver.str());
}

void PkgBuilder::write_dsm(const std::filesystem::path& p_dsi, const std::filesystem::path& p_dsm) const
{
    std::string content =
        do_replace(
            read_file(p_dsi) + "\n",
            {
                {"@arcv@", major + minor + revision }
                , {"@version@", major + "." + minor + "." + revision }
                , {"@version_status@", include_datestamp ? "_" + date_stamp : std::string() }
                , {"@porter@", "Andris Pavenis"}
                , {"@e_mail@", "andris.pavenis@iki.fi"}
                , {"@djreq@", "2.0.5"}
            });

    write_file(p_dsm, content);
}

void PkgBuilder::sfn_check(const fs::path& dir)
{
    int num_err = 0;
    std::map<std::string, std::set<std::string> > summary;
    for (const fs::path& p : fs::recursive_directory_iterator(dir)) {
        if (fs::is_regular_file(p)) {
            const fs::path rel_path = make_relative(p, dir);
            std::string sfn_name;
            bool ok = true;
            for (const auto& x : rel_path) {
                std::smatch s;
                const std::string part = x.string();
                if (std::regex_match(part, s, r_sfn)) {
                    const std::string curr = s[1].str().substr(0, 8) + s[2].str().substr(0, 4);
                    if (sfn_name != "") {
                        sfn_name += "/";
                    }
                    sfn_name += curr;
                } else {
                    std::cout << "Filename '" << rel_path.string() << "' is invalid for MS-DOS" << std::endl;
                    num_err++;
                    ok = false;
                }
            }
            if (ok) {
                summary[sfn_name].insert(rel_path);
            }
        }
    }

    for (const auto& item : summary) {
        if (item.second.size() > 1) {
            std::cout << "Following filenames resolves to " << item.first
                      << " on DOS without LFN suppoort" << std::endl;
            for (const auto& name : item.second) {
                std::cout << "       " << name << std::endl;
            }
            num_err++;
        }
    }
    if (num_err) {
        throw std::runtime_error("DOS SFN conflicts detected in " + dir.string());
    }
}

void PkgBuilder::convert_man_pages()
{
    std::regex r_man("man(\\d)/(.*?\\.\\d)");
    const fs::path man_dir = inst_dir / "share" / "man";
    for (const fs::path& p : fs::recursive_directory_iterator(man_dir)) {
        fs::path pr = make_relative(p, man_dir);
        std::string fn = pr.string();
        std::smatch s;
        if (fs::is_regular_file(p) and std::regex_match(fn, s, r_man)) {
            const fs::path catn = man_dir / ("cat" + s[1].str()) / s[2].str();
            fs::create_directories(catn.parent_path());
            const std::string cmd = "groff -man -Tascii " + p.string() + " >" + catn.string();
            int ret = system(cmd.c_str());
            if (ret != 0) {
                throw std::runtime_error("Return code " + std::to_string(ret)
                    + " from '" + cmd + "'");
            }
        }
    }
}

