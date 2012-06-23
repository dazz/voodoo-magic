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

AddArg 'v' 'detailed=true'
AddArg 'verbose' 'detailed=true'
AddArg 'more' 'detailed=true'

ExpandVariables() {
    local text="${*:-$(cat)}"
    echo "$text" |\
        sed "s/\$PROGRAM/$PROGRAM/g" |\
        sed "s/\$PRODUCT/$PRODUCT/g" |\
        sed "s/\$WORKFLOW/$WORKFLOW/g"
}

PrintDescription() {
    local description="$1/description"
    if [[ -f "$description" ]]; then
        cat "$description" | ExpandVariables
    else
        Print "No description found: $1"
    fi
}

PrintUsage() {
    local usage="$1/usage"
    if [[ -f "$usage" ]]; then
        cat "$usage" | ExpandVariables
    else
        Print "No usage information found: $1"
    fi
}

PrintDetails() {
    local details="$1/details"
    if [[ -f "$details" ]]; then
        cat "$details" | ExpandVariables
    else
        Print "No details available: $1"
    fi
}

