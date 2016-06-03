#! /usr/bin/perl

use strict;
use File::Basename;
use File::Copy;

my $src_dir = GuessSourceDir();
my $ver = FindGccVer();

my $ver_s1 = GenVerDJ($ver);
my $ver_s2 = $ver; $ver_s2 =~ s/\.//g;

my $fd;


my $build_dir = GuessBuildDir();
my $doc_dir = "gnudocs/gcc-$ver_s1";
mkdir "gnudocs";
mkdir "gnudocs/gcc-$ver_s1";
mkdir "manifest";

die "Failed to build DVI docs.\n" unless (system ("make -C $build_dir dvi") == 0);
die "Failed to build PDF docs.\n" unless (system ("make -C $build_dir pdf") == 0);

open $fd, "find $build_dir -name '*.dvi' |" or die "Error invoking command fine: $!\n";
while(<$fd>)
{
    chomp;
    my $from = $_;
    my $dest_dvi = "gnudocs/gcc-$ver_s1/".basename($_);
    $dest_dvi =~ m/^(.*\.)dvi$/;
    my $dest_ps = $1."ps";
    copy $from, $dest_dvi or die "Copy failed: $!\n";
    system "dvips -o $dest_ps $from";
}
close $fd;

unlink "$doc_dir/install.dvi";
unlink "$doc_dir/install.ps";

open $fd, "find $build_dir -name '*.pdf' |" or die "Error invoking command fine: $!\n";
while(<$fd>)
{
    chomp;
    my $from = $_;
    my $dest_pdf = "gnudocs/gcc-$ver_s1/".basename($_);
    copy $from, $dest_pdf or die "Copy failed: $!\n";
}
close $fd;

system 'cp -v $(find '.$build_dir.' -name libquadmath-vers.texi)'." $src_dir/libquadmath/";

BuildHtml ("$src_dir/gcc/fortran/gfortran.texi", "gfortran.html", "gcc/doc/include gcc/fortran", "gcc");
BuildHtml ("$src_dir/gcc/fortran/gfc-internals.texi", "gfc-internals.html", "gcc/doc/include gcc/fortran", "gcc");
BuildHtml ("$src_dir/gcc/doc/cpp.texi", "cpp.html", "gcc/doc/include gcc/fortran", "gcc");
BuildHtml ("$src_dir/gcc/doc/gcc.texi", "gcc.html", "gcc/doc/include gcc/fortran", "gcc");
BuildHtml ("$src_dir/gcc/doc/install.texi", "gccinstall.html", "gcc/doc/include gcc/fortran", "gcc");
BuildHtml ("$src_dir/gcc/doc/gccint.texi", "gccint.html", "gcc/doc/include gcc/fortran", "gcc");
BuildHtml ("$src_dir/gcc/doc/cppinternals.texi", "cppinternals.html", "gcc/doc/include gcc/fortran", "gcc");
BuildHtml ("$src_dir/libiberty/libiberty.texi", "libiberty.html", "libiberty", "libiberty");
BuildHtml ("$src_dir/libquadmath/libquadmath.texi", "libquadmath.html", "libquadmath gcc/doc/include", "libquadmath");
BuildHtml ("$src_dir/gcc/ada/gnat-style.texi", "gnat-style.html", "gcc/doc/include gcc/ada", "gcc/ada");
BuildHtml ("$src_dir/gcc/ada/gnat_rm.texi", "gnat_rm.html", "gcc/doc/include gcc/ada", "gcc/ada");
BuildHtml ("$src_dir/gcc/ada/gnat_ugn.texi", "gnat_ugn.html", "gcc/doc/include gcc/ada", "gcc/ada");

my $gcc_mft;
my $gfor_mft;
my $gnat_mft;

open $gcc_mft, ">manifest/gcc".$ver_s2."d.mft";
open $gfor_mft, ">manifest/gfor".$ver_s2."d.mft";
open $gnat_mft, ">manifest/ada".$ver_s2."d.mft";

WriteVerFile("gcc", "C");
WriteVerFile("gfor", "GNU Fortran");
WriteVerFile("ada", "Ada");

my @files = (glob("manifest/*d.*"), glob("$doc_dir/*"), "manifest/gcc$ver_s2"."d.mft",
    "manifest/gfor$ver_s2"."d.mft", "manifest/ada$ver_s2"."d.mft");
foreach (sort @files) {
    my $nm = basename($_);
    if ($nm =~ m/^gfor/ || $nm =~ m/gfc-internals/)
    {
	print $gfor_mft "$_\n"; 
    }
    elsif ($nm =~ m/^gnat/ || $nm =~ m/^ada/)
    {
	print $gnat_mft "$_\n";
    }
    else
    {
	print $gcc_mft "$_\n";
    }
}
close $gcc_mft;
close $gfor_mft;
close $gnat_mft;

CreateZipArchive ("gcc");
CreateZipArchive ("gfor");
CreateZipArchive ("ada");

sub CreateZipArchive
{
    my ($n) = @_;
    my $zname = "$n$ver_s2"."d.zip";
    my $mname = "manifest/$n$ver_s2"."d.mft";
    print "Creating $zname:\n";
    system "zip -9@ $zname <$mname";
}
   
sub WriteVerFile()
{
    my ($sn, $n) = @_;
    my $fb = "$sn$ver_s2"."d";
    my $fd;
    open $fd, ">manifest/$fb.ver";
    print $fd "$fb.zip: GCC $ver: $n compiler documentation (DVI, PDF, PS, HTML)";
}

sub BuildHtml()
{
    my ($src_name, $dest_name, $inc_list, $cdir, $tmp) = @_;
    my $cmd = "makeinfo --no-split --html ";
    my $doc_dir = "gnudocs/gcc-".GenVerDJ($ver);
    print "INC=:$inc_list:\n";
    my @inc_dirs = split /\s+/, $inc_list;
    foreach (@inc_dirs)
    {
	$cmd .= "-I $src_dir/$_ ";
    }
    $cmd .= "-I $build_dir/gcc ";
    $cmd .= "-o $doc_dir/$_[1] $src_dir/$_[0]";
    print "Running: $cmd\n";
    system "$cmd";
}

sub GenVerDJ()
{
    my $tmp = $_[0];
    $tmp =~ s/\./_/;
    $tmp =~ s/\.//g;
    $tmp =~ s/_/./;
    return $tmp;
}

sub GuessBuildDir()
{
    if ( -f "../build.gcc/Makefile" )
    {
	return "../build.gcc";
    }
    elsif ( -f "../../djcross/Makefile" )
    {
	return "../../djcross";
    }
    else
    {
	die "Build directory is not found.\n";
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
                print "File $x/$y not found - skipping directory $x\n";
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
    my $ver;
    my $ver = FileContents("$src_dir/gcc/BASE-VER");
    my $dev_phase = FileContents("$src_dir/gcc/DEV-PHASE");
    if (!($dev_phase =~ m/^\s*$/))
    {
        my $date_stamp = FileContents("$src_dir/gcc/DATESTAMP");
        $ver = "${ver}_${date_stamp}"; 
    }
    
    return $ver;
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
