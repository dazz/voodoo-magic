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

CopyGitRelatedContent() {
    LogPrint "Copying git related content..."

    pushd "$BASEDIR" >&8

    [[ -d .git ]]
    StopIfError "Can not migrate .git/, folder doesn't exist."
    
    cp -a .git "$workdir"/

    for f in $(find . -name .gitignore | sed 's#\./##'); do
        cp "$f" "$workdir/$(dirname "$f")/"
    done

    popd >&8
}

FixGitIgnoreFiles() {
    LogPrint "Fixing .gitignore files..."

    pushd "$BASEDIR" >&8

    IFS=$'\n' gitignorefiles=( "$(
        find . -name .gitignore | sed 's#\./##'
    )" )
    
    for f in "${gitignorefiles[@]}"; do
        ReplaceVendorInformationInFile "$f"
    done

    popd >&8
}

GitCommit() {
    LogPrint "Committing to git as: $program"

    pushd "$workdir" >&8

    git rm -rf --cached . >&2
    git add . >&2
    git commit -m "forking $PROGRAM to $program" >&2
    StopIfError "Can not commit to git" >&2

    # tag fork as version 0.0.1
    git tag -a "0.0.1" -m "Forking $PRODUCT-$VERSION to $product-0.0.1" >&2

    popd >&8
}
