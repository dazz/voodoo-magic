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

LoadLayoutFile() {
    Log "Seeking layout-file..."
    if [[ ! -f "$layout_file" ]]; then
        Log "Layout-file not found."
        return 1
    else
        Log "Parsing layout-file..."
        Source "$WF_CONFIG_DIR/install.dirs"
        DebugIfError "Warning: layout-file returned non-zero exit-code."
        return 0
    fi
}

UninstallFiles() {
    LogPrint "Uninstalling files..."
    for f in "${INSTALL_FILES[@]}"; do
        if [[ ! -f "$f" ]]; then
            Debug "File has vanished: $f"
        else
            Log "Removing file: $f"
            rm "$v" -f "$f"
            StopIfError "Can not remove file: $f"
        fi
    done
}

UninstallDirectories() {
    LogPrint "Uninstalling empty directories"
    for d in "${INSTALL_DIRS[@]}"; do
        if [[ ! -d "$d" ]]; then
            Debug "Directory has vanished: $d"
            continue
        elif ! ls -A "$d"/* >&8; then
            LogPrint "Skipping not empty directory: $d"
            continue
        else
            Log "Removing directory: $d"
            rm "$v" -rf "$d"
            StopIfError "Can not remove directory: $d"
        fi
    done
}

RemoveLayoutFile() {
    Log "Removing layout-file"
    if [[ -f "$layout_file" ]]; then
        rm "$v" -f "$layout_file"
        StopIfError "Can not remove layout-file"
    else
        Log "Layout-file vanished."
    fi
}

