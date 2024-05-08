#! /bin/sh

gcc_src_ext=xz
gmp_version=6.2.1
mpfr_version=4.1.0
mpc_version=1.2.1
autoconf_version=2.69
automake_version=1.15.1

target=i586-pc-msdosdjgpp

test -f ../gcc/BASE-VER || exit 1

basever=$(cat ../gcc/BASE-VER)
datestamp=$(cat ../gcc/DATESTAMP)
devphase=$(cat ../gcc/DEV-PHASE)

gcc_major=$(echo $basever | sed -e 's:\..*$::')

case $basever in
    [1-9][0-9].[1-9].[0-9])
        upstream=tags/releases/gcc-$basever
        dj_branch=tags/djgpp/gcc-$basever
        djn_branch=tags/djgpp/native/gcc-$basever
        ;;

    [1-9][0-9].0.[1-9])
        upstream=releases/gcc-${gcc_major}
        dj_branch=djgpp/gcc-${gcc_major}
        djn_branch=djgpp/native/gcc-${gcc_major}
        ;;

    [1-9][0-9].0.0)
        upstream=master
        dj_branch=djgpp/master
        djn_branch=djgpp/native/master
        test -z "$devphase" && devphase=prerelease
        ;;
    *)
        echo Unsupported version $basever
        exit 1
esac

for ref in $upstream $dj_branch $djn_branch; do
    if ! git log -1 $ref 2>/dev/null >/dev/null ; then
        echo "$ref not found"
        exit 1
    fi
done

sver2=$(echo $basever | sed -e 's:\.:_:2g' | sed 's:_.*$::')

case "x$gcc_src_ext" in
    xgz) archiver=gzip ;;
    xbz2) archiver=bzip2 ;;
    xxz) archiver="xz -T 0" ;;
    *) echo "Unknown archive extension $gcc_src_ext"; exit 1; ;;
esac

case "x$devphase" in
    xprerelease)
        ver1=${basever}_${datestamp}
        ver2=${basever}-${datestamp}
        snapshot_spec="%define snapshot $datestamp"
        source_name=${basever}-${datestamp}
        ;;

    x)
        ver1=${basever}
        ver2=${basever}
        snapshot_spec=""
        source_name=${basever}
        ;;
    *)
        ver1=${basever}_${datestamp}
        ver2=${basever}-${datestamp}
        snapshot_spec="%define snapshot $datestamp"
        source_name=${basever}-${datestamp}
        ;;
esac

# Extract minimal set of changes required for building cross-compiler for DJGPP target
rm -f djgpp-changes-minimal.diff
for file in $(git -C .. diff --name-only $upstream $dj_branch); do
   case $file in
       djgpp* | readme.DJGPP | ChangeLog.DJGPP)
           ;;
       *)
           ( git -C .. diff -u $upstream $dj_branch -- $file ) >>djgpp-changes-minimal.diff
           ;;
   esac
done

dest=djcross-gcc-$ver1
rm -rf $dest

mkdir -p $dest
mkdir -p $dest/cross-native
sed -e "s/@SRCDIR@/$source_name/g" \
    cross-native/build-cross-native.sh.in \
    >$dest/cross-native/build-cross-native.sh
chmod +x $dest/cross-native/*.sh

mkdir -p $dest/diffs/source
mkdir -p $dest/diffs2/build.gcc
cp -pv djbuild/* $dest/diffs2/build.gcc/
chmod +x $dest/diffs2/build.gcc/*.sh
mkdir -p $dest/diffs2/install.gcc
cp -prv djinstall/* $dest/diffs2/install.gcc/
chmod +x $dest/diffs2/install.gcc/*.pl

CreatePatchDir()
{
    orig_branch=$1
    new_branch=$2
    patch_dir=$3

    echo "#"
    echo "# Writting diffs to the directory $patch_dir"
    echo "#"

    set -x
    files=$( git -C .. diff --stat --name-only $orig_branch $new_branch )

    new_files=
    for file in $files; do
        case $file in
            djgpp/*)
                echo "Skipped file  : $file"
                ;;

            *)
                dir=$patch_dir/$(dirname $file)
                mkdir -p $dir
                if git cat-file -e $orig_branch:$file 2>/dev/null ; then
                    ( git -C .. diff $orig_branch $new_branch -- $file ) >$patch_dir/$file.diff
                    echo "Existing file : " $file
                else
                    new_files="$new_files $file"
                    echo "New file      : " $file
                fi
                ;;
            esac
    done

    for file in $new_files; do
        dir=$patch_dir/$(dirname $file)
        mkdir -p $dir
        git cat-file -p $new_branch:$file >$patch_dir/$file
    done
    set +x
}

CreatePatchDir $upstream $dj_branch $dest/diffs/source
CreatePatchDir $dj_branch $djn_branch $dest/diffs2/source

echo "#"
echo "# Generating SPECS file"
echo "#"

sed -e "s/@__GCCVER__@/$basever/g" \
    -e "s/@__GCC_SRC_EXT__@/$gcc_src_ext/g" \
    -e "s/@__SNAPSHOT_SPEC__@/$snapshot_spec/g" \
    -e "s/@__GCC_SOURCE_NAME__@/$source_name/g" \
    -e "s/@__RPMVER__@/$ver1/g" \
    -e "s/@__GMP_VERSION__@/$gmp_version/g" \
    -e "s/@__MPFR_VERSION__@/$mpfr_version/g" \
    -e "s/@__MPC_VERSION__@/$mpc_version/g" \
    -e "s/@__AUTOCONF_VERSION__@/$autoconf_version/g" \
    -e "s/@__AUTOMAKE_VERSION__@/$automake_version/g" \
    -e "s/@__TARGET__@/$target/g" \
    -e "s/@__GCC_SRC_EXT__@/$gcc_src_ext/g" \
    djcross-gcc.spec.in >$dest/djcross-gcc-$sver2.spec

echo "#"
echo "# Generating unpack-gcc.sh"
echo "#"

sed -e "s/@__GCCVER__@/$ver2/g" \
    unpack-gcc.sh.in >$dest/unpack-gcc.sh

chmod +x $dest/unpack-gcc.sh

mkdir -p ext

ext_files="
    gmp-$gmp_version.tar.bz2
    mpfr-$mpfr_version.tar.bz2
    mpc-$mpc_version.tar.gz
    autoconf-$autoconf_version.tar.gz
    automake-$automake_version.tar.gz";

for file in $ext_files ; do
    case $file in
        gmp*) url=http://ftp.gnu.org/gnu/gmp/gmp-${gmp_version}.tar.bz2 ;;
        mpfr*) url=http://ftp.gnu.org/gnu/mpfr/mpfr-${mpfr_version}.tar.bz2 ;;
        mpc*) url=https://ftp.gnu.org/gnu/mpc/mpc-${mpc_version}.tar.gz ;;
        autoconf*) url=http://ftp.gnu.org/gnu/autoconf/autoconf-${autoconf_version}.tar.gz ;;
        automake*) url=http://ftp.gnu.org/gnu/automake/automake-${automake_version}.tar.gz ;;
        *) exit 1 ;;
    esac

    if [ -f ext/$file ] ; then
        file_ok=false
        case $file in
            *.gz) gzip -t ext/$file >/dev/null 2>&1 && file_ok=true ;;
            *.bz2) bzip2 -t ext/$file >/dev/null 2>&1 && file_ok=true ;;
            *.xz) xz -t ext/$file >/dev/null 2>&1 && file_ok=true ;;
        esac

        if ! $file_ok ; then
            rm -f ext/$file
        fi
    fi

    if ! [ -f ext/$file ] ; then
        echo "Downloading $url"
        curl --output ext/$file $url
    fi
done

ls -l $(find djcross-gcc-$ver1 -name '*.diff')

rm -rf rpm
mkdir -p rpm/SOURCES rpm/BUILD rpm/SPECS rpm/SRPMS rpm/RPMS

tar cjf rpm/SOURCES/${dest}.tar.bz2 ${dest}

git -C .. archive --format=tar --prefix=gcc-${source_name}/ ${upstream} | $archiver -9vv >rpm/SOURCES/gcc-${source_name}.tar.${gcc_src_ext}

for file in $ext_files ; do cp -v ext/$file rpm/SOURCES; done

rpmbuild --bs --define "_topdir $(pwd)/rpm" --bs $dest/djcross-gcc-$sver2.spec
mv -v rpm/SRPMS/djcross-gcc-$ver1-*ap.src.rpm ./ && rm -rf rpm


