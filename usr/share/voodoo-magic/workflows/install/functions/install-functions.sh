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

SaveLayoutFile() {
    # save file tree to be available when uninstalling
    filename="$WORKFLOW_DIR/$WORKFLOW/conf/install.dirs"
    LogPrint "Saving file and directory structure to: $filename"

    IFS=$'\n' files=( $(
        find "$BASEDIR" ! -regex '.*/\..*' -type f -printf '/%P\n' |\
            grep -v "^/$"
    ) )
    IFS=$'\n' directories=( $(
        find "$BASEDIR" ! -regex '.*/\..*' -type d -printf '/%P\n' |\
            grep "$PROGRAM" |\
            grep -v "^/$"
    ) )
    (
        cat <<-EOF
# directories to be removed when uninstalling
IFS=\$'\\n' INSTALL_FILES=( $(
                for f in "${files[@]}"; do
                    echo "$f"
                done
            )
        )

EOF
    ) > "$filename"
    (
        cat <<-EOF
IFS=\$'\\n' INSTALL_DIRS=( $(
                for d in "${directories[@]}"; do
                    echo "$d"
                done
            )
        )

EOF
    ) >> "$filename"
}

Install() {
    # array for file list
    IFS=$'\n' files=( $(
        find "$BASEDIR" ! -regex '.*/\..*' -type f -printf '%P\n'
    ) )

    # install file list to /
    LogPrint "Installing files..."
    for file in "${files[@]}"; do
        install -D "$BASEDIR/$file" /"$file"
    done
    LogPrint "Done"
}

