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

tempdir="${WORKSPACE:-/tmp/$PROGRAM}"
workdir="${workdir:-$tempdir/work}"

CreateWorkSpace() {
    LogPrint "Creating workspace..."

    # create directories
    [[ -d "$workdir" ]] && rm -rf "$workdir"
    mkdir -p "$workdir"

    # don't remove $tempdir when finished when in debug mode
    $DEBUG && return

    AddExitTask "rm -rf $tempdir"
}

CloneStructureIntoWorkSpace() {
    LogPrint "Cloning directory structure into workspace..."

    pushd "$BASEDIR" >&8
    
    # collect filelist in array
    IFS=$'\n' DIRECTORYSTRUCTURE=( $(
        find . \( ! -regex '.*/\..*' \) | sed 's#\./##'
    ) )

    # move directory structure
    for f in "${DIRECTORYSTRUCTURE[@]}"; do
        if [[ -d "$f" ]]; then
            # if directory
            dir="$workdir/$(ReplaceProgramNameInPath "$f")"
            Debug "Creating directory: $dir"
            mkdir -p "$dir"
        else
            # if file
            filename="$workdir/$(ReplaceProgramNameInPath "$f")"
            Debug "Copying file: $f  =>  $filename"
            cp -a "$f" "$filename"
            Debug "Replacing vendor information in: $filename"
            ReplaceVendorInformationInFile "$filename"
        fi
    done

    # remove logs
    ExcludeFromWorkSpace "$workdir/var/log/$program"/*.log
    ExcludeFromWorkSpace "$workdir/var/log/$program"/*.old

    # remove custom user configs from workspace
    for f in "$workdir/etc/$program/"!($program).conf; do
        ExcludeFromWorkSpace "$f"
    done

    # remove selected workflows from workspace
    for workflow in "${EXCLUDE_WORKFLOWS[@]}"; do
        ExcludeFromWorkSpace "$workdir/usr/share/$program/workflows/$workflow"
    done

    popd >&8
}

InstallWorkSpaceIntoTarget() {
    LogPrint "Installing workspace into target-directory..."

    mv "$workdir" "$target"
    StopIfError "Can not install workspace into: $target"
}

ReplaceProgramNameInPath() {
    echo $1 | sed "s#$PROGRAM#$program#g"
    StopIfError "Function: ReplaceProgramNameInPath()"
}

ReplaceVendorInformationInFile() {
    [[ -f "$1" ]]
    StopIfError "Not a file: $1"

    sed -i "s#$PRODUCT#$product#" "$1"
    sed -i "s#$PROGRAM#$program#" "$1"
    sed -i "s#RELEASE_DATE=.*#RELEASE_DATE=$(date +"%Y-%m-%d")#" "$1"
    sed -i "s#VERSION=.*#VERSION=\"0.0.1\"#" "$1"
}

ExcludeFromWorkSpace() {
    [[ -z $1 ]] && return
    LogPrint "Excluding file from workspace: $1"

    pushd "$workspace" >&8

    rm -rf "$1"

    popd >&8
}

