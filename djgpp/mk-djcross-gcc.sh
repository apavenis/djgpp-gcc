#! /bin/sh

gcc_src_ext=bz2
gmp_version=5.0.5
mpfr_version=3.1.1
mpc_version=1.0
autoconf_version=2.64
automake_version=1.11.1

target=i586-pc-msdosdjgpp

test -f ../gcc/BASE-VER || exit 1

basever=$(cat ../gcc/BASE-VER)
datestamp=$(cat ../gcc/DATESTAMP)
devphase=$(cat ../gcc/DEV-PHASE)

upstream=master
dj_branch=gcc_4_8_djgpp
djn_branch=gcc_4_8_djgpp_native

sver2=$(echo $basever | sed -e 's:\.:_:2g' | sed 's:_.*$::')

case "x$devphase" in
    x)
        ver1=${basever}
        ver2=${basever}
        snapshot_spec=""
        source_name=gcc-$(echo $basever | sed -e 's:\.::2g')
        ;;
    *)
        ver1=${basever}_${datestamp}
        ver2=${basever}-${datestamp}
        snapshot_spec="%define snapshot $datestamp"
        source_name=gcc-${sver2}-${datestamp}
        ;;
esac

dest=djcross-gcc-$ver1
rm -rf $dest

mkdir -p $dest
cp -prv cross-native $dest/
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

    files=$( cd ../gcc && git diff --stat origin/$orig_branch origin/$new_branch | grep -v files\ changed | awk '{print $1}')

    new_files=
    for file in $files; do
        case $file in
            djgpp/*)
                echo "Skipped file  : $file"
                ;;

            *)
                dir=$patch_dir/$(dirname $file)
                mkdir -p $dir
                if git cat-file -e $orig_branch:../$file 2>/dev/null ; then
                    ( cd ../gcc && git diff origin/$orig_branch origin/$new_branch ../$file ) >$patch_dir/$file.patch
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
    djcross-gcc.spec.in >$dest/djcross-gcc-$sver2.spec

echo "#"
echo "# Generating unpack-gcc.sh"
echo "#"

sed -e "s/@__GCCVER__@/$ver2/g" \
    unpack-gcc.sh.in >$dest/unpack-gcc.sh

chmod +x $dest/unpack-gcc.sh

echo "#"
echo "# Creating djcross-gcc archive"
echo "#"

tar cjvf ${dest}.tar.bz2 ${dest}
