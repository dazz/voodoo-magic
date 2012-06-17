#!/bin/bash
#
# Voodoo-Magic
#
#    Voodoo-Magic is free software; you can redistribute it and/or modify it
#    under the terms of the GNU General Public License as published by the Free
#    Software Foundation; either version 2 of the License, or (at your option)
#    any later version.
#
#    Voodoo-Magic is distributed in the hope that it will be useful, but
#    WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#    or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#    for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with Voodoo-Magic; if not, write to the Free Software Foundation,
#    Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

EXIT_TASKS=( ) # Array for exit tasks

AddExitTask() {
    EXIT_TASKS=( "$*" "${EXIT_TASKS[@]}" )
    Debug "Added $* as exit task"
}

QuietAddExitTask() {
    EXIT_TASKS=( "$*" "${EXIT_TASKS[@]}" )
}

RemoveExitTask() {
    local removed=false
    for (( c=0 ; c<${#EXIT_TASKS[@]} ; c++ )); do
        if [[ ${EXIT_TASKS[c]} == "$*" ]]; then
            unset 'EXIT_TASKS[c]'
            removed=true
            Debug "Removed $* from the list of exit tasks"
        fi
    done   
    $removed
    StopIfError "Couldn't remove exit task $*."
}

DoExitTasks(){
    Log "Running exit tasks."
    for task in "${EXIT_TASKS[@]}"; do
        Debug "Exit task '$task'"
        eval "$task"
    done
}

builtin trap DoExitTasks 0              # trap for exit tasks
exec 7>&1                               # duplicate STD_IN to fd7 for Print()
QuietAddExitTask "exec 7>&-"

# USR1 is used to abort on errors. we store the PID of the master file, so an
# error in any child process can kill the master process.
MASTER_PID=$$
builtin trap "echo 'Aborting due to an error, check $LOGFILE for details' >&7; kill $MASTER_PID" USR1

function trap () { # make sure nobody else can use trap
    BugError "Forbidden to use trap '$@'. Use AddExitTask instead"
}

# check if any of the binaries/aliases exist
has_binary() {
    for bin in $@; do
        if type $bin &>/dev/null; then
            return 0
        fi
    done
    return 1
}

get_path() {
    type -p $1 2>&8
}

exec 8>/dev/null
QuietAddExitTask "exec 8>&-"

