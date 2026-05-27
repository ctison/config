# cSpell:words sysadminctl

# Clean some data
export def clean [
  --all(-a)
  ...apps: string
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
        ' | str dedent | str trim -l o> `~/Library/Application Support/.com.contextsformac.Contexts.plist`
      }
      'monodraw' => {
        rm `~/Library/Preferences/com.helftone.monodraw.plist`
      }
    }
  }
  null
}

# List macos images from ipsw.me
export def 'ipsw ls' [id?: string] {
  if $id != nil {
    http get $'https://api.ipsw.me/v4/device/($id)'
  } else {
    http get https://api.ipsw.me/v4/devices
  }
}
