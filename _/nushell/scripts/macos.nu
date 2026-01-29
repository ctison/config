use ./utils/str.nu dedent

export def clean [
  ...apps: string
  --all(-a)
]: nothing -> nothing {
  $apps | par-each {
    match $in {
      'final_cut' => {
        # cSpell:words ffuserdata
        rm `~/Library/Application Support/.ffuserdata`
      }
      'context' => {
        '
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
          <dict>
            <key>CTStartDate2</key>
            <date>2030-04-09T16:43:55Z</date>
          </dict>
        </plist>
        ' | dedent | str trim -l o> `~/Library/Application Support/.com.contextsformac.Contexts.plist`
      }
    }
  }
  null
}

export def 'ipsw ls' [id?: string] {
  if $id != nil {
    http get $'https://api.ipsw.me/v4/device/($id)'
  } else {
    http get https://api.ipsw.me/v4/devices
  }
}
