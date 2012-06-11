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

OPTS="$(getopt -n $PROGRAM -o "t:p:x:" -l "exclude" -- "$@")"
StopIfError "Unknown argument in workflow: $WORKFLOW"

eval set -- "$OPTS"
while true; do
    case "$1" in
        (-t) target=$2; shift;;
        (-p) product=$2; shift;;
        (-x) EXCLUDE_WORKFLOWS+="$2"; shift;;
        (--) shift; break;;
        (-*) Error "Unrecognized option '$option' in workflow: $WORKFLOW";;
        (*) break;;
    esac
    shift
done

[[ -n "$target" ]]
StopIfError "No target specified. Please see $PROGRAM help."

# set some default behaviours
program="$(basename "$target")"
product="${product:-$program}"

# bail out if targetdir exists and is not empty
if [[ -d "$target" ]]; then
    ! ls -A "$target"/* >&8
    StopIfError "Target directory exists and is not empty"
fi

