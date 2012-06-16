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

Install() {
    IFS=$'\n' directories=( $(
        find "$BASEDIR" ! -regex '.*/\..*' -type d -printf '%P\n'
    ) )
    IFS=$'\n' files=( $(
        find "$BASEDIR" ! -regex '.*/\..*' -type f -printf '%P\n'
    ) )

    # save directory tree for a possible uninstall
    filename="$WORKFLOW_DIR/$WORKFLOW/conf/install.dirs"
    echo "IFS=\$'\\n' INSTALL_DIRS=(" > "$filename"
    for dir in "${directories[@]}"; do
        echo "$dir" >> "$filename"
    done
    echo ")" >> "$filename"

    # install to /
    for file in "${files[@]}"; do
        install -D "$BASEDIR/$file" /
    done
}

