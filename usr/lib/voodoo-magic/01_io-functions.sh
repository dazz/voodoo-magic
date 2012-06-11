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

# provide a precise timestamp when running in debug mode
if $DEBUG || $DEBUG_SCRIPTS; then
    Timestamp() {
        date +"%Y-%m%d %H:%M:%S.%N"
    }
else
    Timestamp() {
        date +"%Y-%m%d %H:%M:%S"
    }
fi

Error() {
    # if fist arg is an int, use it as exit-code
    if [ $1 -eq $1 ] 2>/dev/null; then
        EXIT_CODE=$1
        shift
    else
        EXIT_CODE=1
    fi
    VERBOSE=1
    LogPrint "Error: $*"
    kill -USR1 $MASTER_PID 
}

StopIfError() {
    (( $? != 0 )) && Error "$@"
}

BugError() {
    if (( $1 == $1 )); then
        EXIT_CODE=$1
    else
        EXIT_CODE=1
    fi
    Error "Bug Bug Bug! " "$@" "
    Please report this as a bug to the authors of $PRODUCT"
}

BugIfError() {
    (( $? != 0 )) && BugError "$@"
}

Debug() {
    $DEBUG && Log "$@" && return
}

Print() {
    echo -e "$*" >&7 && return
}

PrintIfError() {
    (( $? != 0 )) && Print "$@"
}

Log() {
    if [[ -n $1 ]]; then
        echo "$(Timestamp) $*"
    else
        echo "$(Timestamp) $(cat)"
    fi >&2
}

LogIfError() {
    (( $? != 0 )) && Log "$@"
}

LogPrint() {
    Log "$@"
    Print "$@"
}

LogPrintIfError() {
    (( $? != 0 )) && LogPrint "$@"
}

