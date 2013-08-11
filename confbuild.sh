#!/bin/bash
#
# File:         build_phc.sh
# Created:      1623 020613
# Description:  description for build_phc.sh
#

### FUNCTIONS ###

now () 
{ 
    export now=$(date +%H%M_%d%m%y);
    echo $now
}

fail()
{
  echo "$*"
  exit 1
}

### ENV ###


buildFile="$1"
[ ! -f "$buildFile" ] &&
{
  prefix="/home/antonio/src/web/mediawiki/mwpython/root"
  src="$PWD/bison-2.7.1"
  build="build_2255_200613"
  id="confbuild_bison"
} ||
{
  . "${buildFile}"
  [ -z "${prefix}" -o -z "${src}" -o -z "${build}" -o -z "${id}" ] && fail "invalid profile"
}

logsdir="$PWD/logs"
logfile="${logsdir}/log.${id}.$(now).txt"


### MAIN ###
cat << EOF

ID is       ${id}
Source is   ${src}
Build is    ${build}
Log file is ${logfile}

EOF

[ ! -d "logs" ] &&
{
  echo "logs directory missing"
  mkdir logs
}

{
  set -x
  export CFLAGS="-I$prefix/include"
  export CXXFLAGS="-I$prefix/include"
  export LDFLAGS="-L$prefix/lib"
  
  cd "$build"
  
  [ -z "$configure_args" ] &&
  {
     $src/configure   \
		--prefix=$prefix      \
		2>&1
     rc=$?
  } ||
  {
     $src/configure   \
		--prefix=$prefix      \
		${configure_args}
		2>&1
     rc=$?
  }
  
  set +x
  echo "==== end configure ===="
  
  [ "$rc" -ne 0 ] && make  2>&1
  
  rc=$?
  [ "$rc" -ne 0 ] && make  install 2>&1
} 2>&1 |  tee "${logfile}"


### EOF ###
