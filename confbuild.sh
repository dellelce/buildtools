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

  [ -z "$CFLAGS" ] && { export CFLAGS="-I$prefix/include"; } || { export CFLAGS="$CFLAGS -I$prefix/include"; }

  [ -z "$CXXFLAGS" ] && { export CXXFLAGS="-I$prefix/include"; } || { export CXXFLAGS="$CXXFLAGS -I$prefix/include"; } 

  [ -z "$LDFLAGS" ] && { export LDFLAGS="-L$prefix/lib"; } || { export LDFLAGS="$LDFLAGS -L$prefix/lib"; } 
  
  cd "$build"
 
  export start_conf="$(date +%s)" 
  export rc=0
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
		${configure_args}     \
		2>&1
     rc=$?
  }
  export end_conf="$(date +%s)" 
  let elapsed_conf="(( $end_conf - $start_conf ))"
  
  echo
  echo "elapsed configure: ${elapsed_conf}"
  echo "==== end configure ===="

  export start_make="$(date +%s)" 
  [ "$rc" -eq 0 ] && {  make  2>&1; } || { exit "$rc"; } 
  rc=$?
  export end_make="$(date +%s)" 
  echo
  echo "elapsed make: ${elapsed_make}"
  echo "==== end make ===="
  
  export start_makei="$(date +%s)" 
  [ "$rc" -eq 0 ] && make  install 2>&1
  rc=$?
  export end_makei="$(date +%s)" 
  echo
  echo "elapsed make install: ${elapsed_makei}"
  echo "==== end make install ===="
} 2>&1 |  tee "${logfile}"

exit $rc

### EOF ###
