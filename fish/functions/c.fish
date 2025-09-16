function c -a project
    if test -d $project
        echo "Opening project: $project"
    else
        echo "Directory does not exist: $project"
        return 1
    end
    pushd $project
    mise exec -- code-insiders .
    popd
end
