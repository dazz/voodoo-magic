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

# if workflow is passed as an argument, echo description of workflow
if [[ -n $1 ]]; then
    Source "$SHARE_DIR/workflows/$1/workflow_$1"
    local description=WORKFLOW_$1_DESCRIPTION
    local usage=WORKFLOW_$1_USAGE
    echo "Help for $1:"
    echo "${!description}"
    echo
    echo "${!usage}"
    echo
else
    echo "$usage_information"
    echo "
    Available commands:
    $(
        find "$SHARE_DIR/workflows/" -mindepth 1 -maxdepth 1 \
            -type d -printf '\t%f\n'
    )
    "
fi

