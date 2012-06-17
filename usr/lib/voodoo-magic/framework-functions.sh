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
            source "$1" ${ARGS[@]}
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

StageWorkflowConfig() {
    # source the workflow config
    Source "$WF_CONFIG_DIR/$WORKFLOW.conf"
    Source "$CONF_DIR/$WORKFLOW.conf"
}

StageWorkflowHelpers() {
    # stage workflow helper functions
    if [[ -d "$WF_HELPER_DIR" ]]; then
        Log "Staging functions from dir for workflow: $WORKFLOW"
        SourceStage "$WF_HELPER_DIR"
    elif [[ -f "$WF_HELPER_DIR" ]]; then
        Log "Staging functions from dir for workflow: $WORKFLOW"
        Source "$WF_HELPER_DIR"
    else
        Log "No helpers found for workflow: $WORKFLOW"
    fi
}

StageWorkflowEnv() {
    declare -g WF_BASEDIR="$WORKFLOW_DIR/$WORKFLOW"
    declare -g WF_FILE="$WF_BASEDIR/workflow_$WORKFLOW"

    declare -g WF_CONFIG_DIR="$WF_BASEDIR/conf"
    declare -g WF_DOC_DIR="$WF_BASEDIR/doc"
    declare -g WF_HELPER_DIR="$WF_BASEDIR/functions"
    declare -g WF_TEMP_DIR="$WF_BASEDIR/tmp"
    declare -g WF_WORKFLOWS="$WF_BASEDIR/workflows"

    declare -g WF_DESCRIPTION="$WF_CONFIG_DIR/description"
    declare -g WF_USAGE="$WF_CONFIG_DIR/usage"

    # empty temp dir if exists
    [[ -d "$WF_TEMP_DIR" ]] && \
        rm -rf "$WF_TEMP_DIR"/* && \
        AddExitTask "rm '$WF_TEMP_DIR'/*"
}

StageWorkflow() {
    StageWorkflowEnv
    StageWorkflowConfig
    StageWorkflowHelpers

    # stage the workflow
    Log "Staging workflow: $WORKFLOW"
    $DEBUG && set -x
    Source "$WF_FILE"
    $DEBUG && set +x

    # parse workflow arguments
    Log "Parsing workflow arguments"
    $DEBUG && set -x
    ParseWorkflowArgs ${ARGS[@]}
    $DEBUG && set +x

    $SIMULATE && return

    # execute workflow
    Log "Executing workflow: $WORKFLOW"
    has_binary WORKFLOW_$WORKFLOW
    StopIfError "Can not find function: WORKFLOW_$WORKFLOW"

    $DEBUG && set -x
    WORKFLOW_$WORKFLOW "${ARGS[@]}"
    $DEBUG && set +x
}

