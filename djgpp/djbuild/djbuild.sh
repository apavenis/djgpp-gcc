#! /bin/sh

ConfigureGCC () {
	./djconfig.sh;
}

BootstrapGCC () {
	if ./djmake.sh bootstrap ; then
		true
	else
		false
	fi
}

InstallTMP () {
	./djinsttmp.sh
}


MakePackages () {
	cd $TOP/../install.gcc 
	perl ./makepkg.pl
	cd $TOP
}


TOP=`pwd`

cd $TOP
echo "Configuring GCC ..."
ConfigureGCC >djconfig.log 2>&1 || exit 1;

cd $TOP
echo "Bootstrapping GCC ..."
BootstrapGCC >bootstrap.log 2>&1 || exit 1

cd $TOP
echo "Installing GCC in temporary directory ..."
InstallTMP >insttmp.log 2>&1 || exit 1

cd $TOP
echo "Creating binary packages ..."
MakePackages >makepkg.log 2>&1 || exit 1
