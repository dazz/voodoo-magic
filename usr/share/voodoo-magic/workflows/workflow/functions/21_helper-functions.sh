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

ListHelpers() {
    echo
    echo 'Available helpers:'
    echo '=================='
    egrep -ore '.*\(\) \{' "$LIB_DIR" |\
        cut -d: -f2 |\
        sed 's#^\([^(]\+\).*#\1#' |\
        sed '/^[\t| ]/d' |\
        egrep '^[A-Z]' |\
        grep -v "Workflow" |\
        sort
}

ShowHelper() {
    # ToDo: use sed to accomplish this
    filename="$(egrep -ore "^$1\(\) \{" "$LIB_DIR" | cut -d: -f1)"
    local output=false
    echo $filename

    if [[ -f "$filename" ]]; then
        echo
        while read line; do
            if $output; then
                echo "$line"
                [[ "${line}" == "}" ]] && echo && return
            elif [[ "$line" == "$1()"* ]]; then
                output=true
                echo "$line"
            fi
        done < "$filename"
    fi
}

