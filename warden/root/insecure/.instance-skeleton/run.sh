#!/bin/bash

# Change to directory that holds this script
self=$(readlink -f ${0})
cd $(dirname ${self})

# Run script with PWD=root. Bash closes stdin for processes that is moves to
# the background so we need to pass the script via a temporary file.
cd root
tmp=$(mktemp --tmpdir=. -d)
cat ${1:-/dev/null} > ${tmp}/stdin
env -i bash < ${tmp}/stdin 1> ${tmp}/stdout 2> ${tmp}/stderr &
cd ..

# Store PID of this process while subshell runs
child_pid=${!}
parent_pid=${$}
touch pids/${parent_pid}
wait ${child_pid} 2> /dev/null
child_exit_status=${?}
rm pids/${parent_pid}
echo ${child_exit_status} ${tmp}
