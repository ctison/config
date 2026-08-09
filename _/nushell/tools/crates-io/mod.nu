export const DIR = ($cfg.DIR_STATE_GLOBAL)/crates.io
export const DIR_LATEST = ($DIR)/latest/data

export def main [] {
  log info $'Cache age: ((ls -Dl ($DIR)/latest).0.target | into datetime)'

  open ($DIR_LATEST)/crates.csv
  | reject max_features max_upload_size
  | %update name {|row| $row.documentation | ansi link -t $row.name }
  | %update description { into string }
  | %update created_at { into datetime }
  | %update updated_at { into datetime }
  | %update trustpub_only { match $in { f => false, t => true } }
  | join (open ($DIR_LATEST)/crate_downloads.csv) id crate_id
  | reject crate_id
  | sort-by downloads
  | metadata set { upsert select [name description homepage updated_at downloads] }
}

export def lol [] {
  log info $'Cache age: ((ls -Dl ($DIR)/latest).target | into datetime)'
  let filepath = ($DIR_LATEST)/versions.msgpackz
  if not ($filepath | path exists) {
    open ($DIR_LATEST)/versions.csv
    | to msgpackz
    | save $filepath
  }
  open $filepath
}

export def update [] {
  cd $DIR
  let filename = $'db-dump.(date now | format date %F).tar.gz'
  xh -d -o $filename https://static.crates.io/db-dump.tar.gz
  tar -xf $filename
  null
}
