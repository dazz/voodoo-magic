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

AddArg 'name:' 'wf_name=$2'

CreateWorkflowDirectories() {
    # create the directories
    LogPrint "Creating new workflow: $wf_name"
    directories=( "$wf_dir" "$wf_dir/"{conf,doc,functions,tmp} )
    files=(
        "$wf_dir/conf/$wf_name.conf"
        "$wf_dir/doc/"{description,usage}
        "$wf_dir/functions/00_general.sh"
        "$wf_dir/workflow_$wf_name"
    )
    LogPrint "Creating workflow directories"
    for d in "${directories[@]}"; do
        install -d "$d"
    done
}

CreateWorkflowFiles() {
    # create files by writing the GNU/GPL header in each file
    LogPrint "Creating workflow files"
    for f in "${files[@]}"; do
        head -n 18 $0 > "$f"
    done
}

AddWorkflowSkel() {
    # add the workflow function skel
    LogPrint "Adding workflow function"
    echo "WORKFLOW_$wf_name() {
        
    }
    " >> "$wf_dir/workflow_$wf_name"
}

