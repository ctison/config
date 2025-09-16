function cv
    set -l projects (jq -r '.backupWorkspaces.folders[].folderUri' ~/Library/Application\ Support/Code\ -\ Insiders/User/globalStorage/storage.json | string unescape --style=url | sed 's|^file://||')
    for project in $projects
        c $project
    end
end
