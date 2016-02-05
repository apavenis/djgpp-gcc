#! /usr/bin/perl

use File::Basename;


my $srcdir = GuessSourceDir();
my ($base_ver, $gcc_ver) = FindGccVer();
my $e_mail = "Andris Pavenis <andris.pavenis\@iki.fi>";

#my $strip = "upx --brute";
my $strip = "strip";

my $gcc_ver_s1 = del2dot($gcc_ver);
my $base_ver_s1 = del2dot($base_ver);
my $gcc_ver_s2 = del_all_dot($gcc_ver);
my $gcc_ver_s2a = $gcc_ver_s2; $gcc_ver_s2a =~ s/-.*$//;
my $gcc_ver_s1a = $gcc_ver_s1; $gcc_ver_s1a =~ s/-.*$//;
my $docdir = "gnu/gcc-$gcc_ver_s1";

my $djver = getdjver();
my ($djver_desc, $djreq);

my $fver_find = "$gcc_ver";
$fver_find =~ s/\./\\./g;
print "fver_find=$fver_find\n";

my @cpp_rename = (
"bits/c++0x_warning.h:cxx0x_warning.hxx",
"bits/c++14_warning.h:cxx14_warning.hxx",
"bits/exception_defines.h:_excptdef.h",
"bits/exception_ptr.h:_excptptr.h",
"bits/hashtable.h:_hashtbl.h",
"bits/hashtable_policy.h:_hshtpol.h",
"bits/locale_facets.h:locfacets.h",
"bits/locale_facets_nonio.h:locfcnio.h",
"bits/locale_facets.tcc:locfacets.tcc",
"bits/locale_facets_nonio.tcc:locfacnio.tcc",
"bits/locale_conv.h:locale_conv.h2",
"bits/shared_ptr_base.h:shared_ptr_base.h1",
"bits/regex_compiler.h:_regcomp.h",
"bits/regex_constants.h:_regconst.h",
"bits/shared_ptr_atomic.h:shared_ptr_atomic.h2",
"bits/stl_algo.h:stlalgo.h",
"bits/stl_algobase.h:stlalgobase.h",
"bits/stl_iterator.h:stl_iterator.h",
"bits/stl_iterator_base_funcs.h:stl_itbf.h",
"bits/stl_iterator_base_types.h:stl_itbt.h",
"bits/stl_multimap.h:stl_mmap.h",
"bits/stl_multiset.h:stl_mset.h",
"bits/unordered_map.h:_unordmap.h1",
"bits/unordered_set.h:_unordset.h1",
"bits/valarray_after.h:varr_after.h",
"bits/valarray_array.h:varr_array.h",
"bits/valarray_before.h:varr_before.h",

"debug/unordered_map:unordmap",
"debug/unordered_set:unordset",
"debug/safe_unordered_base.h:safe_unordered_base.h01",
"debug/safe_unordered_container.h:safe_unordered_container.h02",

"djgpp/bits/c++allocator.h:cxxallocator.h",
"djgpp/bits/c++config.h:cxxconfig.h",
"djgpp/bits/c++io.h:cxxio.h",
"djgpp/bits/c++locale.h:cxxlocale.h",
"djgpp/bits/extc++.h:extcxx.h",
"djgpp/bits/stdc++.h:stdcxx.h",
"djgpp/bits/stdtr1c++.h:stdtr1cxx.h",

"ext/pb_ds/detail/binomial_heap_base_/binomial_heap_base_.hpp:_bheapbase.hpp",
"ext/pb_ds/detail/binomial_heap_base_/constructors_destructor_fn_imps.hpp:_cdfnimps.hpp",
"ext/pb_ds/detail/binomial_heap_base_/debug_fn_imps.hpp:_dfnimps.hpp",
"ext/pb_ds/detail/cc_hash_table_map_/constructor_destructor_fn_imps.hpp:_cdfn_imps.hpp",
"ext/pb_ds/detail/cc_hash_table_map_/constructor_destructor_no_store_hash_fn_imps.hpp:cdnshfn_imps.hpp",
"ext/pb_ds/detail/cc_hash_table_map_/constructor_destructor_store_hash_fn_imps.hpp:cdsh_fn_imps.hpp",
"ext/pb_ds/detail/gp_hash_table_map_/constructor_destructor_fn_imps.hpp:cdfn_imps.hpp",
"ext/pb_ds/detail/gp_hash_table_map_/constructor_destructor_no_store_hash_fn_imps.hpp:cdnsh_fn_imps.hpp",
"ext/pb_ds/detail/gp_hash_table_map_/constructor_destructor_store_hash_fn_imps.hpp:cdsh_fn_imps.hpp",
"ext/pb_ds/detail/hash_fn/direct_mask_range_hashing_imp.hpp:dmarhashing_imp.hpp",
"ext/pb_ds/detail/hash_fn/direct_mod_range_hashing_imp.hpp:dmdrhashing_imp.hpp",
"ext/pb_ds/detail/hash_fn/sample_range_hashing.hpp:sr_hashing.hpp",
"ext/pb_ds/detail/hash_fn/sample_ranged_hash_fn.hpp:sr_hash_fn.hpp",
"ext/pb_ds/detail/hash_fn/sample_ranged_probe_fn.hpp:sr_probe_fn.hpp",
"ext/pb_ds/detail/resize_policy/hash_load_check_resize_trigger_imp.hpp:hlcrt_imp.hpp",
"ext/pb_ds/detail/resize_policy/hash_load_check_resize_trigger_size_base.hpp:hlcrt_size_base.hpp",
"ext/pb_ds/detail/resize_policy/sample_resize_policy.hpp:sr_policy.hpp",
"ext/pb_ds/detail/resize_policy/sample_resize_trigger.hpp:sr_trigger.hpp",
"ext/pb_ds/detail/trie_policy/sample_trie_node_update.hpp:stn_update.hpp",
"ext/pb_ds/detail/pat_trie_/pat_trie_.hpp:pat_trie.h01",
"ext/pb_ds/detail/pat_trie_/pat_trie_base.hpp:pat_trie.h02",
"ext/vstring_fwd.h:vstr_fwd.h",
"ext/vstring_util.h:vstr_util.h",

"parallel/for_each_selectors.h:foreachselector.h",
"parallel/omp_loop_static.h:omploopstatic.h",
"parallel/multiway_mergesort.h:multiway_mergesort.h2",

"profile/impl/profiler.h:_profiler.h",
"profile/impl/profiler_algos.h:_profalgos.h",
"profile/impl/profiler_container_size.h:_profcts.h1",
"profile/impl/profiler_hash_func.h:_profhf.h1",
"profile/impl/profiler_hashtable_size.h:_profhts.h1",
"profile/impl/profiler_list_to_slist.h:_profltsl.h1",
"profile/impl/profiler_list_to_vector.h:_profltv.h1",
"profile/impl/profiler_map_to_unordered_map.h:_profmtum.h1",
"profile/impl/profiler_node.h:_profnode.h1",
"profile/impl/profiler_state.h:_profstate.h1",
"profile/impl/profiler_trace.h:_proftrace.h1",
"profile/impl/profiler_vector_size.h:_profvs.h1",
"profile/impl/profiler_vector_to_list.h:_profvtl.h1",
"profile/unordered_map:_unordmap",
"profile/unordered_set:_unordset",

"tr1/unordered_map.h:_unordmap.h1",
"tr1/unordered_set.h:_unordset.h1",
"tr1/unordered_map:unordmap",
"tr1/unordered_set:unordset",
"tr1/hashtable_policy.h:hashtable_policy.h1",

"unordered_map:unordmap",
"unordered_set:unordset",
"unordered_map:unordmap",
"unordered_set:unordset",

"experimental/unordered_map:unordmap",
"experimental/unordered_set:unordset",
);

my @c_inc_rename = (
"avx512ifmavlintrin.h:avx512ifmavlintrin.h2",
"avx512vbmivlintrin.h:avx512vbmivlintrin.h2",
"avx512vldqintrin.h:avx512vldqintrin.h2",
"avx512vlintrin.h:avx512vlintrin.h3"
);

my @rename_list = (
"lib/libsupc++.la:##/libsupcxx.la",
"lib/libsupc++.a:##/libsupcxx.a",
"lib/libstdcxx.a-gdb.py:##/libstdcxx_a-gdb-py",
"bin/g++.exe:##/gpp.exe",
"bin/c++.exe:",
"bin/djgpp-g++.exe:",
"bin/djgpp-gcc.exe:",
"bin/djgpp-gcc-4.10:",
"bin/djgpp-c++.exe:",
"info/dir:",
"share/man/man1/g++.1:##/gpp.1"
);

my @docfiles = (
"COPYING", "COPYING3", "COPYING.LIB", "NEWS", "README",
"fixincludes/README-fixinc", "fixincludes/README",
"gcc/COPYING", "gcc/COPYING3", "gcc/ONEWS", "gcc/onews",
"gcc/cp/NEWS",
"libobjc/README", "libobjc/THREADS",
"libstdc++-v3/README",
);


copy_docs();
cxx_rename_proc(@cpp_rename);
objc_rename_proc();
c_inc_rename_proc(@c_inc_rename);
move_man_pages_if_needed();
rename_files_proc(@rename_list);
mkdir "gnu";
mkdir "gnu/gcc-$gcc_ver_s1";
convert_man_pages();
update_dsm();
update_readme_djgpp();
mk_manifest();
build_zip_archives();

sub create_dir_if_needed
{
    my $dname = $_[0];
    if ( ! -d $dname )
    {
        if ($dname =~ m:^(.*)/([^/]*)$:)
        {
            my $d1 = $1;
            create_dir_if_needed ($d1);
        }

        mkdir $dname or
            die "Failed to create directory $dname: $!\n";
    }
}



sub copy_docs
{
    if (0) # Not implemented. Should edit HTML files for this to work
    {
        my $fd;
        open ($fd, "find $srcdir/libstdc++-v3/docs/html -type f -a -not -name Makefile |")
            or die "Failed : $!\n";
        while (<$fd>)
        {
            chomp;
            $srcfile = $_;
            s/^.*\/html\///;
            my $n1 = $_;
            my $n2 = "$docdir/libstdcxx/html/$n1";
            my $n2xd = $n2;  $n2xd =~ s/\/[^\/]*$//;
            print "$n1 $n2 $n2xd\n";
            ;
            create_dir_if_needed $n2xd;
            system ("cp -v $srcfile $n2");
        }
    }

    foreach my $file (@docfiles)
    {
        my $dest = $file; $dest =~ s:\+\+:xx:g;
        my $dir = "$docdir/$dest"; $dir =~ s:/[^/]*$::;
        create_dir_if_needed $dir;
        system ("cp -v $srcdir/$file $docdir/$dest");
    }
}


sub cxx_rename_proc
{
    my %header_gcc;
    my $v = $base_ver_s1;
    $v =~ s/-.*$//;
    my $cxx_inc_dir = "include/cxx/$v";
    foreach (@_)
    {
        m/^([^:]*):([^:]*)$/;
        my $orig_path = $1;
        my $new_name = $2;
        my $dir_name = dirname($orig_path);
        my $orig_name = basename($orig_path);

        $dir_name = $dir_name eq "." ? "" : "$dir_name/";

        my $n1 = "$cxx_inc_dir/$dir_name$orig_name";
        my $n2 = "$cxx_inc_dir/$dir_name$new_name";

        if ( -f $n1 )
        {
            #print "Rename: $n1 ==>$n2\n";
            if (! rename ($n1, $n2))
            {
                #print "Rename: $n1 ==>$n2: $!\n";
            }
        }
        elsif ( -f $n2 )
        {
            #print "New file: $n2 already exists\n";
        }
        else
        {
            print "Neither $n1 nor $n2 found\n";
            next;
        }

        my $d1 = "";
        my $d2 = $dir_name;
        if (! /^djgpp\//)
        {
            $header_gcc{"header.gcc"} = $header_gcc{"header.gcc"} .
                "$d2$orig_name $d2$new_name\n";
            #print "Write: $d2$orig_name $d2$new_name >>header.gcc\n";
        }
        do
        {
            if ($d2 =~ m/^([^\/]*)\/(.*)$/)
            {
                $d1 = $d1 eq "" ? $1 : "$d1/$1";
                $d2 = $2;
            }
            else
            {
                $d1 = $d1 eq "" ? $d2 : "$d1/$d2";
                $d2 = "";
            }
            $header_gcc{"$d1/header.gcc"} = $header_gcc{"$d1/header.gcc"} .
                "$d2$orig_name $d2$new_name\n";
            #print "Write: $d2$orig_name $d2$new_name >>$d1/header.gcc\n";
        } while ($d2 ne "");
    }

    foreach (sort keys %header_gcc)
    {
        my $file = $_;
        my $contents = $header_gcc{$file};
        #print "\n###### $file\n\n$contents\n\n";
        my $fd;
        if (open $fd, ">$cxx_inc_dir/$file")
        {
            print $fd $contents;
            close $fd;
        }
        else
        {
            print "Failed to write file $file\n";
        }
    }
}

sub objc_rename_proc
{
    my %header_gcc;
    my $v = $base_ver_s1;
    $v =~ s/-.*$//;
    my $cxx_inc_dir = "lib/gcc/djgpp/$v/include";

    my @objc_rename =
      (
       "quadmath_weak.h:quadmath_weak.h1"
      );

    foreach (@objc_rename)
    {
        m/^([^:]*):([^:]*)$/;
        my $orig_path = $1;
        my $new_name = $2;
        my $dir_name = dirname($orig_path);
        my $orig_name = basename($orig_path);

        $dir_name = $dir_name eq "." ? "" : "$dir_name/";

        my $n1 = "$cxx_inc_dir/$dir_name$orig_name";
        my $n2 = "$cxx_inc_dir/$dir_name$new_name";

        if ( -f $n1 )
        {
            print "Rename: $n1 ==>$n2\n";
            if (! rename ($n1, $n2))
            {
                print "Rename: $n1 ==>$n2: $!\n";
            }
        }
        elsif ( -f $n2 )
        {
            #print "New file: $n2 already exists\n";
        }
        else
        {
            print "Neither $n1 nor $n2 found\n";
            next;
        }

        my $d1 = "";
        my $d2 = $dir_name;
        if (! /^djgpp\//)
        {
            $header_gcc{"header.gcc"} = $header_gcc{"header.gcc"} .
                "$d2$orig_name $d2$new_name\n";
            #print "Write: $d2$orig_name $d2$new_name >>header.gcc\n";
        }
        do
        {
            if ($d2 =~ m/^([^\/]*)\/(.*)$/)
            {
                $d1 = $d1 eq "" ? $1 : "$d1/$1";
                $d2 = $2;
            }
            else
            {
                $d1 = $d1 eq "" ? $d2 : "$d1/$d2";
                $d2 = "";
            }
            $header_gcc{"$d1/header.gcc"} = $header_gcc{"$d1/header.gcc"} .
                "$d2$orig_name $d2$new_name\n";
            #print "Write: $d2$orig_name $d2$new_name >>$d1/header.gcc\n";
        } while ($d2 ne "");
    }

    foreach (sort keys %header_gcc)
    {
        my $file = $_;
        my $contents = $header_gcc{$file};
        #print "\n###### $file\n\n$contents\n\n";
        my $fd;
        if (open $fd, ">$cxx_inc_dir/$file")
        {
            print $fd $contents;
            close $fd;
        }
        else
        {
            print "Failed to write file $file\n";
        }
    }
}

sub c_inc_rename_proc
{
    my %header_gcc;
    my $v = $base_ver_s1;
    $v =~ s/-.*$//;
    my $c_inc_dir = "lib/gcc/djgpp/$v/include";
    foreach (@_)
    {
        m/^([^:]*):([^:]*)$/;
        my $orig_path = $1;
        my $new_name = $2;
        my $dir_name = dirname($orig_path);
        my $orig_name = basename($orig_path);

        $dir_name = $dir_name eq "." ? "" : "$dir_name/";

        my $n1 = "$c_inc_dir/$dir_name$orig_name";
        my $n2 = "$c_inc_dir/$dir_name$new_name";

        if ( -f $n1 )
        {
            #print "Rename: $n1 ==>$n2\n";
            if (! rename ($n1, $n2))
            {
                #print "Rename: $n1 ==>$n2: $!\n";
            }
        }
        elsif ( -f $n2 )
        {
            #print "New file: $n2 already exists\n";
        }
        else
        {
            print "Neither $n1 nor $n2 found\n";
            next;
        }

        my $d1 = "";
        my $d2 = $dir_name;
        if (! /^djgpp\//)
        {
            $header_gcc{"header.gcc"} = $header_gcc{"header.gcc"} .
                "$d2$orig_name $d2$new_name\n";
            #print "Write: $d2/$orig_name $d2/$new_name >>header.gcc\n";
        }
        do
        {
            if ($d2 =~ m/^([^\/]*)\/(.*)$/)
            {
                $d1 = $d1 eq "" ? $1 : "$d1/$1";
                $d2 = $2;
            }
            else
            {
                $d1 = $d1 eq "" ? $d2 : "$d1/$d2";
                $d2 = "";
            }
            my $d2a = $d2 ne "" ? "$d2/" : "";
            $header_gcc{"$d1/header.gcc"} = $header_gcc{"$d1/header.gcc"} .
                "$d2a$orig_name $d2a$new_name\n";
            #print "Write: $d2a$orig_name $d2a$new_name >>$d1/header.gcc\n";
        } while ($d2 ne "");
    }

    foreach (sort keys %header_gcc)
    {
        my $file = $_;
        my $contents = $header_gcc{$file};
        #print "\n###### $file\n\n$contents\n\n";
        my $fd;
        if (open $fd, ">$c_inc_dir/$file")
        {
            print $fd $contents;
            close $fd;
        }
        else
        {
            print "Failed to write file $file\n";
        }
    }
}

sub rename_files_proc
{
    my $v = $base_ver_s1;
    $v =~ s/-.*$//;
    foreach (@_)
    {
        if (! m/^([^:]*):([^:]*)$/)
        {
            print "Wrong line: $_\n";
            next:
        }

        my $old_path = $1;
        my $new_name = $2;
        $old_path =~ m#^(.*)/([^/]*)$# or next;

        my $dir = $1;
        my $old_name = $2;

        if ($new_name eq "")
        {
            if ( -f "$dir/$old_name" )
            {
                #print "Delete: $dir/$old_name\n";
                unlink ("$dir/$old_name") or
                   print "Delete failed: $!\n";
            }
            else
            {
                #print "File $dir/$old_name not found\n";
            }
        }
        else
        {
            $new_name =~ s:\#gcc_lib\#:lib/gcc/djgpp/$base_ver_s1:;
            $new_name =~ s:\#\#:$dir/:;
            if ( -f "$dir/$old_name" )
            {
                print "Rename/move: $dir/$old_name ==> $new_name\n";
                rename ("$dir/$old_name", "$new_name") or die "$dir/$old_name ==> $new_name: $!\n";
                #print "\n";
            }
            elsif ( -f $new_name )
            {
                #print "Renamed file $new_name found\n";
            }
            else
            {
                die "-- Neither $dir/$old_name nor $new_name found\n";
            }
        }
    }
}


sub del_all_dot
{
    my $x = $_[0];
    $x =~ s/\.//g;
    return $x;
}

sub del2dot
{
    my $x = $_[0];
    $x =~ s/\./_/;
    $x =~ s/\.//g;
    $x =~ s/_/./;
    return $x;
}

sub getdjver
{
    my $fd;
    my $major;
    my $minor;
    my $fname = "/dev/env/DJDIR/include/sys/version.h";
    open $fd, "<$fname" or die "Failed to open $fname: $!\n";
    while (<$fd>)
    {
        if (m/#define\s+__DJGPP__\s+([0-9]+)/)
        {
            $major = $1;
        }

        if (m/#define\s+__DJGPP_MINOR__\s+([0-9]+)/)
        {
            $minor = $1;
        }
    }
    close $fd;

    if ($major eq "2" && ($minor ge "3")) 
    {
        if ($minor == 3)
        {
            # Not actually supported: left in however
            $djver_desc = "2.03 Patchlevel 2";
            $djreq = $djver_desc;
        }
        elsif ($minor == 4)
        {
            # Also obsolete: left in howev er
            $djver_desc = "2.04 Beta 1 or above";
            $djreq = ">= 2.04 Beta 1";
        }
        elsif ($minor > 5)
        {
            # Fix for DJGPP v2.1X later (perhaps not very soon)
            $djver_dec = "2.0$minor";
            $djreq = ">=2.0$minor";
        }
        return sprintf("%d.%02d", $major, $minor);
    }
    return "";
}




sub update_readme_djgpp
{
    create_dir_if_needed $docdir;

    my $djdev="djdev$djver"; $djdev=~s/\.//g;
    my ($fdin, $fdout);
    open $fdin, "<$srcdir/readme.DJGPP" or
        die "Failed to open $srcdir/readme.DJGPP: $!\n";
    open $fdout, ">gnu/gcc-${gcc_ver_s1}/readme.DJGPP" or
        die "Failed to create file $srcdir/readme.DJGPP: $!\n";
    while (<$fdin>)
    {
        s/\@GCCVER\@/$gcc_ver/g;
        s/\@GCCVER2\@/$gcc_ver_s1/g;
        s/\@GCCVER3\@/$gcc_ver_s2a/g;
        s/\@DJVER\@/$djver_desc/g;
        s/\@DJDEV\@/$djdev/g;
        s/\@CONTACT\@/$e_mail/g;
        print $fdout $_;
    }
    close $fdin;
    close $fdout;
}

sub move_man_pages_if_needed
{
    if ( ! -d "share/man" )
      {
          if ( -d "man" )
          {
            print "Rename man ==> share/man\n";
            rename("man", "share/man");
          }
      }
}

sub convert_man_pages
{
    my @manpages = (glob("share/man/man1/*"), glob("share/man/man7/*"));
    foreach my $src (@manpages)
    {
        my $dest = $src; $dest =~ s:/man([1-9])/:/cat\1/:;
        my $dir = $dest; $dir =~ s:/[^/]*$::;
        create_dir_if_needed $dir;
        die "Failure\n" if $dest eq $src;
        system ("groff -man -Tascii $src >$dest");
    }
}


sub update_dsm
{
    create_dir_if_needed "manifest";

    foreach my $dsi (glob "dsmsrc/*.dsi")
    {
        $dsi =~ s/^dsmsrc\///;
        my $dsm = $dsi;
        $dsm =~ s/b\.dsi/${gcc_ver_s2a}b/;
        my ($fdin, $fdout);
        open $fdin, "<dsmsrc/$dsi" or
            die "Failed to open file dsmsrc/$dsi: $!\n";
        open $fdout, ">manifest/$dsm.dsm" or
            die "Failed to create file manifest/$dsm: $!\n";
        while (<$fdin>)
        {
            my $desc;
            s/\@version\@/$gcc_ver/g;
            s/\@arcv\@/$gcc_ver_s2a/g;
            s/\@version_status\@//g;
            s/\@djreq\@/$djreq/g;
            if (m/^short-description:\s+(.*)$/)
            {
                my $fdver;
                $desc = "$dsm.zip: $1 (Version $gcc_ver)";
                open $fdver, ">manifest/$dsm.ver";
                print $fdver $desc;
                close $fdver;
                open $fdver, ">manifest/$dsm.mft";
                close $fdver;
            }
            print $fdout $_;
        }
    }
}



sub mk_manifest
{
    my @ignore = (
        '/adainclude/s-stratt-xdr.adb',
	'dsmsrc/(?:ada|gcc|gfor|gpp|objc)b\.dsi$',
        'share/info/dir$',
        'share/man/man(?:1|7)/',
        'bin/djgpp-gcc-',
        'bin/djgpp-gfortran\.exe$'
        );

    my @cxxfiles = (
        'bin/gpp\.exe', '^include/cxx/', '/cc1plus\.exe',
        '/libstdcxx', '/libsupcxx', 'manifest/gpp',
        '/cat1/gpp', '/cp/news'
    );

    my @gforfiles = (
        'bin/gfortran\.exe', 'info/gfortran.info',
        '/libgf', '/f951\.exe', 'manifest/gfor',
        '/finclude/ieee_',
	'/libcaf_single.(?:a|la)',
        '/cat1/gfortran'
    );

    my @adafiles = (
        'bin/gnat.*\.exe', 'bin/gprmake\.exe', 'info/gnat',
        '/adainclude/', '/adalib/', '/gnat1\.exe',
        'manifest/ada'
    );

    my @gccfiles = (
        'bin/gcc\.exe', 'bin/cpp\.exe', 'bin/gcov\.exe', 'bin/gccbug',
        'bin/gcc-(?:ar|nm|ranlib)\.exe', 'bin/gcov-tool\.exe',
        'include/ssp/', 'info/(?:cpp|gcc|libquadmath)', '/djgpp\.ver$',
        '/include/(?:am|bm|em|m|nm|pm|sm|tm|xm)mintrin',
        '/include/(?:cpuid|float|iso646|mm_malloc|mm3dnow|mmintcommon)\.h$',
        '/include/(?:avx|imm|wmm|x86|bmi|tbm|pku|clzero)intrin\.h$',
        '/include/(?:avx2|bmi2|f16c|fma|lzcnt)intrin.\h$',
        '/include/std(?:align|noreturn)\.h$',
        '/include/quadmath(?:|_weak).h',
        '/include/(?:stdarg|stdatomic|stdbool|stddef|stdfix|tgmath|unwind|varargs)\.h$',
        '/include/header.gcc$',
        '/include-fixed/(?:limits|syslimits|wchar)\.h$',
        '/include-fixed/readme$',
        '/include/(?:abm|fma4|ia32|lwp|popcnt|xop|xtest|mwaitx)intrin.h$',
	'/include/(?:adx|fxsr|prfchw|rdseed|rtm|xsave|xsaveopt)intrin.h$',
        '/include/(?:clflushopt|clwb|pcommit|xsavec|xsaves|)intrin.(?:h|h2|h3)$',
        '/include/cross-stdarg.h$',
        '/include/stdint(?:|-gcc).h$',
        '/include/avx512[^\.]*.(?:h|h2|h3)$',
        '/include/shaintrin\.h$',
        '/install-tools/', '/libgcc\.a', '/libgcov\.a', '/libssp*',
        '/libquadmath.(?:la|a)',
        '/cc1\.exe',
        '/lto1\.exe',
        '/collect2\.exe',
        '/lto-wrapper\.exe',
        'manifest/gcc',
        'readme.djgpp', '/cat1/(?:cpp|gcc|gcov)', '/cat7/',
        '/bugs', '/copying', '/faq', '/news', '/readme', '/gcc/onews',
        'share/locale/',
        '/bugs\.html', 'faq\.html'
    );

    my @objcfiles = (
        'libobjc\.', '/include/objc/', '/cc1obj.*\.exe',
        'manifest/objc', '/libobjc/(readme|threads)', '/objc/readme'
    );

    my $fd;
    my %status;
    my (@mft_ignored, @mft_gcc, @mft_gpp, @mft_gfor, @mft_objc, @mft_ada);
    open ($fd, "find . -type f |") or die "Failed to get filelist:$!\n";

    my $NF=0;
    while (<$fd>)
    {
        chomp;
	s:^\./::;
        next if (! m/\//);

        if ($_ =~ m|/$fver_find/|)
        {
            my $old_name = $_;
            my $new_name = $_;
            $new_name =~ s|/$fver_find/|/$gcc_ver_s1/|g;
            print "WARNING: GCC full version detected - renaming:\n";
            print "   $old_name ==> $new_name\n";
            my $dir = dirname($new_name);
            system("mkdir -pv $dir");
            rename($old_name, $new_name);
            $_ = $new_name;
        }

        $status{$_} = "unknown";
        $NF++;
    }
    close $fd;
    print "$NF files totally\n";
    my @files = sort keys %status;

    foreach my $file (@files)
    {
        if ($file =~ m/\.exe$/)
        {
            system ("$strip $file");
            if ($file =~ m/(?:cc1|cc1obj|cc1objplus|cc1plus|f951|gnat1)\.exe$/)
            {
                system ("stubedit $file minstack=2048K");
            }
        }
        elsif ($file =~ m/\.a$/)
        {
            system ("strip -g $file");
        }
    }

    foreach my $file (@files)
    {
        next if ($status{$file} ne "unknown");
        foreach my $expr (@ignore)
        {
            if ($file =~ $expr)
            {
                $status{$file} = "ignore";
                print "Ignore $file\n";
            }
        }
    }

    foreach my $file (@files)
    {
        next if ($status{$file} ne "unknown");
        foreach (@cxxfiles)
        {
            if (lc($file) =~ $_)
            {
                $status{$file} = "gpp";
                push @mft_gpp, $file;
                last;
            }
        }
    }


    foreach my $file (@files)
    {
        next if ($status{$file} ne "unknown");
        foreach (@adafiles)
        {
            if (lc($file) =~ $_)
            {
                $status{$file} = "ada";
                push @mft_ada, $file;
                last;
            }
        }
    }

    foreach my $file (@files)
    {
        next if ($status{$file} ne "unknown");
        foreach (@gforfiles)
        {
            if (lc($file) =~ $_)
            {
                $status{$file} = "gfor";
                push @mft_gfor, $file;
                last;
            }
        }
    }

    foreach my $file (@files)
    {
        next if ($status{$file} ne "unknown");
        foreach (@objcfiles)
        {
            if (lc($file) =~ $_)
            {
                $status{$file} = "objc";
                push @mft_objc, $file;
                last;
            }
        }
    }

    foreach my $file (@files)
    {
        next if ($status{$file} ne "unknown");
        foreach (@gccfiles)
        {
            if (lc($file) =~ $_)
            {
                $status{$file} = "gcc";
                push @mft_gcc, $file;
                last;
            }
        }
    }

    my $fd_mft;
    open ($fd_mft, ">manifest/gcc${gcc_ver_s2a}b.mft") or
        die "Failed to create file manifest/gcc${$gcc_ver_s2a}b.mft: $!\n";
    foreach my $file (@mft_gcc)
    {
        print $fd_mft "$file\n";
    }
    close $fd_mft;

    if ( -f "bin/gnat.exe")
    {
        open ($fd_mft, ">manifest/ada${gcc_ver_s2a}b.mft") or
            die "Failed to create file manifest/ada${$gcc_ver_s2a}b.mft: $!\n";
        foreach my $file (@mft_ada)
        {
            print $fd_mft "$file\n";
        }
        close $fd_mft;
    }
    else
    {
        unlink("manifest/ada${gcc_ver_s2a}b.mft");
    }

    open ($fd_mft, ">manifest/gfor${gcc_ver_s2a}b.mft") or
        die "Failed to create file manifest/gfor${$gcc_ver_s2a}b.mft: $!\n";
    foreach my $file (@mft_gfor)
    {
        print $fd_mft "$file\n";
    }
    close $fd_mft;

    open ($fd_mft, ">manifest/gpp${gcc_ver_s2a}b.mft") or
        die "Failed to create file manifest/gpp${$gcc_ver_s2a}b.mft: $!\n";
    foreach my $file (@mft_gpp)
    {
        print $fd_mft "$file\n";
    }
    close $fd_mft;

    open ($fd_mft, ">manifest/objc${gcc_ver_s2a}b.mft") or
        die "Failed to create file manifest/objc{$gcc_ver_s2a}b.mft: $!\n";
    foreach my $file (@mft_objc)
    {
        print $fd_mft "$file\n";
    }
    close $fd_mft;


    open ($fd_mft, ">skipped.mft") or
        die "Failed to create file skipped.mft: $!\n";
    foreach my $file (@files)
    {
        if ($status{$file} eq "unknown")
        {
            print $fd_mft "$file\n";
        }
    }
    close $fd_mft;
}




sub build_zip_archives
{
    foreach my $mft (glob "manifest/*.mft")
    {
        my $zip = $mft;
        $zip =~ s:\.mft:.zip:;
        $zip =~ s:^.*/::;
        print "Creating $zip\n";
        system ("zip -9\@ $zip <$mft");
    }
}

sub GuessSourceDir
{
    my @fchk = ('gcc/BASE-VER', 'gcc/DATESTAMP', 'gcc/gcc.c', 'gcc/DEV-PHASE');
    my $cnt = 0;
    my $dn;
    my @dl = glob("../gcc*");
    foreach my $x (@dl)
    {
        my $ok = 1;
        if (! -d $x)
        {
            next;
        }

        foreach my $y (@fchk)
        {
            if (! -f "$x/$y")
            {
                #print "File $x/$y not found - skipping directory $x\n";
                $ok = 0;
            }
        }

        if ($ok == 1)
        {
            $cnt++;
            $dn = $x;
        }

    }

    if ($cnt == 0)
    {
        die "ERROR: No GCC source directory found";
    }
    elsif ($cnt > 1)
    {
        die "ERROR: More than 1 GCC source directory found\n";
    }

    return $dn;
}

sub FindGccVer
{
    my ($base_ver, $ver);
    my $base_ver = FileContents("$srcdir/gcc/BASE-VER");
    my $dev_phase = FileContents("$srcdir/gcc/DEV-PHASE");
    if (!($dev_phase =~ m/^\s*$/))
    {
        my $date_stamp = FileContents("$srcdir/gcc/DATESTAMP");
        $ver = "${base_ver}_${date_stamp}";
    }
    else
    {
        $ver = $base_ver;
    }

    return ($base_ver, $ver);
}

# Read a file and returns contents as the scalar
sub FileContents
{
    my $fd;
    my $fn = $_[0];
    open $fd, $fn or die "Failed to open $fn: $!";
    my $content = <$fd>;
    close $fd;
    chomp($content);
    return $content;
}
