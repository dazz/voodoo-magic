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

Error() {
    # Helper for simulating an exception. Use this to define that an error
    # in your workflow has occurred. This function writes all logs down to disk
    # and runs all exit tasks before printing the error, a description, as well
    # as some useful debug information to stdout. If the first argument of the
    # function call is an integer, the framework will use this as the final
    # exit-code, otherwise the exit-code is set to 1.
    # example: Error "42 Can not do FOO because auf BAR."

    # if fist arg is an int, use it as exit-code
    if [ $1 -eq $1 ] 2>/dev/null; then
        EXIT_CODE=$1
        shift
    else
        EXIT_CODE=1
    fi
    VERBOSE=1
    LogPrint "Error: $*"
    LogPrint "See '$PROGRAM help $WORKFLOW' for usage information."
    Print
    kill -USR1 $MASTER_PID 
}

StopIfError() {
    # Helper to raise exception if the last executed statement returned a non-
    # zero exit-code.
    # example: StopIfError "42 Can not do FOO because auf BAR."
    (( $? != 0 )) && Error "$@"
}

BugError() {
    # Helper for raising a bug exception. A bug exception complements a regular
    # Error exception, except that it tells the use that the problem seems to be
    # caused by a possible bug and that this should be reported to the authors.
    # example: BugError "23 Can not detect disclayout"
    if (( $1 == $1 )); then
        EXIT_CODE=$1
    else
        EXIT_CODE=1
    fi
    Error "Bug Bug Bug! " "$@" "
    Please report this as a bug to the authors of $PRODUCT"
}

BugIfError() {
    # Helper to raise a bug exception if the last executed statement returned a
    # non-zero exit-code.
    # example: BugIfError "23 Can not detect network configuration"
    (( $? != 0 )) && BugError "$@"
}

Debug() {
    # Helper for writing debug-messages into the logs. You can use this in your
    # workflow to log any information you feel does not belong into a regular
    # runtime log.  Debug-Messages will only reach the log if the framework is
    # running in debug-mode, e.g. with the '-d' shell parameter.
    # example: Debug "42 mounting iso on loopback device"
    $DEBUG && Log "$@" && return
}

DebugIfError() {
    # Helper for writing debug messages into the logs, but only if the last
    # executed statement returned a non-zero exit-code.
    # example: DebugIfError "23 file has vanished before deleting."
    (( $? != 0 )) && Debug "$@"
}

Print() {
    # Helper for reliably echoing to stdout. Sometimes within the framework
    # simple echo statements might not work because of sub-shelling. Using this
    # helper provides a work-around to these problems.
    # example: Print "Hello World!"
    echo -e "$*" >&7 && return
}

PrintIfError() {
    # Helper for echoing to stdout if the last executed statement returned a
    # non-zero exit-code.
    # example: PrintIfError "You really need to set this config variable first."
    (( $? != 0 )) && Print "$@"
}

Log() {
    # Helper for echoing into the logfile. Messages can either be piped into the
    # helper or passed as shell arguments.
    # example: Log "Mounting iso into loopback device"
    #          grep -r /foo/bar | Log
    local message="${1:-$(cat)}"
    echo "$(Timestamp) $message" >&2
    $VERBOSE && Print "$message"
}

LogIfError() {
    # Helper for echoing into the logfile, but only if the last executed statement
    # returned a non-zero exit-code.
    # example: LogIfError "This question does not lead to the answer 42."
    (( $? != 0 )) && Log "$@"
}

LogPrint() {
    # Wrapper for echoing to stdout, as well as to the logfile.
    # example: LogPrint "The answer is 42."
    Log "$@"
    $VERBOSE || Print "$@"
}

LogPrintIfError() {
    # Helper for calling the LogPrint wrapper, but only if the last executed
    # statement returned a non-zero exit-code.
    # example: LogPrintIfError "You are still not asking the right question."
    (( $? != 0 )) && LogPrint "$@"
}

