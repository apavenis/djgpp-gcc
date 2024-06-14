#include "PkgBuilder.hpp"

const std::map<std::filesystem::path, std::filesystem::path> PkgBuilder::c_inc_rename = {
    {"avx512bf16intrin.h", "avx512bf16intrin.h1"},
    {"avx512bf16vlintrin.h", "avx512bf16vlintrin.h2"},
    {"avx512ifmavlintrin.h", "avx512ifmavlintrin.h2"},
    {"avx512vbmi2vlintrin.h", "avx512vbmi2vlintrin.h3"},
    {"avx512vbmiintrin.h", "avx512vbmiintrin.h4"},
    {"avx512vbmivlintrin.h", "avx512vbmivlintrin.h2"},
    {"avx512vldqintrin.h", "avx512vldqintrin.h2"},
    {"avx512vlintrin.h", "avx512vlintrin.h3"},
    {"avx512fp16intrin.h","avx512fp16intrin.h1"},
    {"avx512fp16vlintrin.h","avx512fp16vlintrin.h2"},
    {"avx512vnnivlintrin.h", "avx512vnnivlintrin.h2"},
    {"avx512vp2intersectintrin.h", "avx512vp2intersectintrin.h2"},
    {"avx512vp2intersectvlintrin.h", "avx512vp2intersectvlintrin.h3"},
    {"avx512vpopcntdqintrin.h", "avx512vpopcntdqintrin.h4"},
    {"avx512vpopcntdqvlintrin.h", "avx512vpopcntdqvlintrin.h5"},
    {"avx512bitalgintrin.h", "avx512bitalgintrin.h2"},
    {"avx512bitalgvlintrin.h", "avx512bitalgvlintrin.h3"},
    {"avxvnniint16intrin.h", "avxvnniint16intrin.h2"},
    {"avxvnniint8intrin.h", "avxvnniint8intrin.h3"},
    {"avxvnniintrin.h", "avxvnniintrin.h4"},
    {"quadmath_weak.h", "quadmath.h2"}
};
