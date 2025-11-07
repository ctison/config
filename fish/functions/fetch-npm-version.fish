function fetch-npm-version
  for package in $argv
    set latest_version \
      (curl -s "https://registry.npmjs.org/$package/latest" | jq -r '.version')
    echo "\"$package\": \"$latest_version\","
  end
end
complete -c fetch-npm-version -f
