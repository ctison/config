export const DIR_                = path self | path expand | path dirname -n 4
export const DIR_BIN             = $DIR_ | path join bin/
export const DIR_ROOT            = $DIR_ | path dirname
export const DIR_X               = $DIR_ROOT | path dirname
export const DIR_NU              = path self | path expand | path dirname -n 3
export const DIR_STATE_LOCAL     = '.x'
export const DIR_STATE_GLOBAL    = $DIR_ROOT | path join $DIR_STATE_LOCAL
export const DIR_STATE_DOCKER    = $DIR_STATE_GLOBAL | path join .docker

const SELF = path self
const DIR_SELF = $SELF | path dirname
