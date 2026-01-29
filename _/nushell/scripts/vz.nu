use ./utils/cfg.nu

# cSpell:ignore vfkit virtio

export const DIR_VZ = $cfg.DIR_X | path join vz

export def main []: nothing -> nothing {
  ignore
}

export def list []: nothing -> table {
  mkdir $DIR_VZ
  ls $DIR_VZ
}

export def start [name?: string]: nothing -> nothing {
  (vfkit
    --cpus 4
    --memory 8192
    --bootloader macos,machineIdentifierPath=TODO,hardwareModelPath=TODO,auxImagePath=TODO
    --device virtio-blk
  )
}

def make_state []: nothing -> nothing {
}
