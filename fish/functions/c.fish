function c
  argparse 'a/all' -- $argv
  or return 1
  if set -q _flag_all || test (count $argv) -eq 0
    set -a argv \
      (jq -r '.backupWorkspaces.folders[].folderUri' \
      "$HOME/Library/Application Support/Code - Insiders/User/globalStorage/storage.json" \
      | string unescape --style=url | sed 's|^file://||')
  end
  for project in $argv
    echo ">>> $project"
    cd $project
    mise i && mise up
    mise exec -- (echo $EDITOR | string split -f1 ' ') .
    cd -
  end
end
complete -c c -f -a '(__fish_complete_directories)'
complete -c c -s a -l all -d 'Reopen all projects'
