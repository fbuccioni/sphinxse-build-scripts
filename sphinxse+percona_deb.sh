#!/bin/bash

percona_ver="5.6"
dir="percona+sphinxse/debsrc"

echo "
Installing necessary packages to build
--------------------------------------
"
apt-get install build-essential
apt-get install build-dep percona-server-server-$percona_ver

echo -e "\n
Getting deb package sources
---------------------------
"

[ ! -d $dir ] && mkdir -v $dir

cd $dir
apt-get source "percona-server-server-${percona_ver}" "sphinxsearch"

sphinxsearch_sys_source_dir="$( \
	ls -lah --sort=time -c \
	| grep '^d' \
	| awk '{print $9}' \
	| grep "^sphinxsearch" \
	| head -n 1 \
)"
percona_sys_source_dir="$( \
	ls -lah --sort=time -c \
	| grep '^d' \
	| awk '{print $9}' \
	| grep "^percona-server-${percona_ver}" \
	| head -n 1 \
)"

sphinxse_dir="${percona_sys_source_dir}/storage/sphinx"

[ -d "${sphinxse_dir}" ] && rm -rf ${sphinxse_dir}

cp -Rpv ${sphinxsearch_sys_source_dir}/mysqlse ${sphinxse_dir}

cd ${percona_sys_source_dir} 
BUILD/autorun.sh
sed -ie 's/-DWITH_PAM=ON/-DWITH_PAM=ON -DWITH_SPHINX=ON/g' "debian/rules"


echo -e "\n
Done!!!
-------

Now you have to do the following commands:

  cd ${dir}/${percona_sys_source_dir}
  debuild -us -uc -rfakeroot
"
