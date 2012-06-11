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

# define a global shortcut variable
WORKFLOW_DIR="$SHARE_DIR/workflows"

# source a file given in $1
Source() {
    # skip empty
    [[ -z "$1" ]] && return
    [[ -d "$1" ]] && Debug "$1 is a directory, cannot source" && return

    if [[ -s "$1" ]]; then
        local relname="${1##$SHARE_DIR/}"
        if $SIMULATE && expr "$1" : "$SHARE_DIR" >&8; then
            # simulate sourcing the scripts in $SHARE_DIR
            LogPrint "Source $relname"
        else
            Log "Including ${1##$SHARE_DIR/}"
            $DEBUGSCRIPTS && set -x
            source "$1"
            $DEBUGSCRIPTS && set +x
        fi
    else
        Debug "Skipping $1 (file not found or empty)"
    fi
}

SourceStage() {
    local stagedir="$1"

    [[ -d "$stagedir" ]]
    StopIfError "Can not SourceStage, not a directory: $stagedir"
    
    IFS=$'\n' files=( $(
        find "$stagedir" -type f -name \*.sh | \
            sed -e 's#/\([0-9][0-9]\)_#/!\1!_#g' | sort -t \! -k 2 | tr -d \!
    ) )

    for file in "${files[@]}"; do
        Source "$file"
    done
}

WorkflowStage() {
    # source the workflow config
    Source "$WORKFLOW_DIR/$WORKFLOW/conf/$WORKFLOW.conf"
    Source "$CONF_DIR/$WORKFLOW.conf"

    # stage workflow helper functions
    Log "Staging functions for: $WORKFLOW"
    SourceStage "$WORKFLOW_DIR/$WORKFLOW/functions"
    LogIfError "WARNING: Functions for $WORKFLOW either broken or not present"

    # stage the workflow
    Log "Staging workflow: $WORKFLOW"
    Source "$WORKFLOW_DIR/$WORKFLOW/workflow_$WORKFLOW"

    $SIMULATE && return

    # execute workflow
    has_binary WORKFLOW_$WORKFLOW
    StopIfError "Can not find function: WORKFLOW_$WORKFLOW"
    WORKFLOW_$WORKFLOW "${ARGS[@]}"
}

