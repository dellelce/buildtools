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

mainBanner()
{
  cat << EOF

ID is       ${id}
Source is   ${src}
Build is    ${build}
Log file is ${logfile}

EOF
}

# run configure step
build_configure()
{
  export start_conf="$(date +%s)"
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
}

msg_configure()
{
  echo
  echo "elapsed configure: ${elapsed_conf}"
  echo "==== end configure ===="
}

# run configure step
build_make()
{
  echo work in progress
}

msg_make()
{
  echo
  echo "elapsed make: ${elapsed_make}"
  echo "==== end make ===="
}

# run configure step
build_makeinstall()
{
  echo work in progress
}

msg_makeinstall()
{
  echo
  echo "elapsed make install: ${elapsed_makei}"
  echo "==== end make install ===="
}

### ENV ###

export rc=0

# build profile
buildFile="$1"
[ ! -f "$buildFile" ] &&
{
  # this should go and be replaced by an error message or by some defaults
  prefix="/home/antonio/src/web/mediawiki/mwpython/root"
  src="$PWD/bison-2.7.1"
  build="build_2255_200613"
  id="confbuild_bison"
} ||
{
  . "${buildFile}"
  [ -z "${prefix}" -o -z "${src}" -o -z "${build}" -o -z "${id}" ] && fail "invalid profile"
  [ ! -d "${src}" ] && failed "invalid source"
}

#
logsdir="$PWD/logs"
logfile="${logsdir}/log.${id}.$(now).txt"

### MAIN ###

mainBanner

[ ! -d "$logsdir" ] &&
{
  echo "logs directory missing"
  mkdir -p "$logsdir"
}

{
  #only if debugging: set -x

  [ -z "$CFLAGS" ] && { export CFLAGS="-I$prefix/include"; } || { export CFLAGS="$CFLAGS -I$prefix/include"; }
  [ -z "$CXXFLAGS" ] && { export CXXFLAGS="-I$prefix/include"; } || { export CXXFLAGS="$CXXFLAGS -I$prefix/include"; } 
  [ -z "$LDFLAGS" ] && { export LDFLAGS="-L$prefix/lib"; } || { export LDFLAGS="$LDFLAGS -L$prefix/lib"; } 
  
  cd "$build"
 
  export start_conf="$(date +%s)" 
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

  msg_configure
  
  export start_make="$(date +%s)" 
  [ "$rc" -eq 0 ] && {  make  2>&1; } || { exit "$rc"; } 
  rc=$?
  export end_make="$(date +%s)" 

  msg_make
  
  export start_makei="$(date +%s)" 
  [ "$rc" -eq 0 ] && make  install 2>&1
  rc=$?
  export end_makei="$(date +%s)" 
  msg_makeinstall
} 2>&1 |  tee "${logfile}"

exit $rc

### EOF ###
