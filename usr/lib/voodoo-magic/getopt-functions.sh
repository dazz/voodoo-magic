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

AddArg() {
    local arg="$1"; shift
    local cmd="$*"
    local raw="${arg/:/}"
    local argsdir="$WF_TEMP_DIR/args"
    mkdir -p "$argsdir"

    if (( ${#raw} == 1 )); then
        local tmpvar=WF_ARG_$raw
    else
        local tmpvar=WF_LONG_$raw
    fi
    declare -g $tmpvar="$argsdir/$arg"

    echo "$cmd" > "${!tmpvar}"
}

ParseWorkflowArgs() {
    local args=""
    local long=""
    declare -a a_args=()
    declare -a a_long=()

    for var in "${!WF_ARG_@}"; do
        args+="${!var##*/}"
        a_args+=( "${var/WF_ARG_/}" )
    done
    for var in "${!WF_LONG_@}"; do
        long+=",${!var##*/}"
        a_long+=( "${var/WF_LONG_/}" )
    done

    OPTS="$(getopt -n $PROGRAM -o "$args" -l "${long:1}" -- "$@")"
    StopIfError "Unknown argument in workflow: $WORKFLOW"

    eval set -- "$OPTS"
    until [[ "$1" == '--' ]]; do
        if IsInArray "${1/-/}" ${a_args[@]}; then
            wf_arg="WF_ARG_${1/-/}"
            source "${!wf_arg}"
            [[ ${!wf_arg: -1} == ':' ]] && shift
        elif IsInArray "${1/--/}" ${a_long[@]}; then
            wf_long="WF_LONG_${1/--/}"
            source "${!wf_long}"
            [[ ${!wf_long: -1} == ':' ]] && shift
        elif [[ "$1" == '--' ]]; then
            shift
            break
        elif [[ "$1" == '-'* ]]; then
            Error "Unknown option in workflow: $WORKFLOW"
        else
            break
        fi
        shift
    done
    shift
    
    # keep the remaining args for the workflows to use
    ARGS=( $@ )
}

