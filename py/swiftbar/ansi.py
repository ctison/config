from typing import List, SupportsAbs


def encode(*codes: List[SupportsAbs]):
  return f'\033[{";".join(map(str, codes))}m'


reset = encode(0)
bold = encode(1)
black = encode(30)
red = encode(31)
green = encode(32)
yellow = encode(33)
blue = encode(34)
magenta = encode(35)
cyan = encode(36)
white = encode(37)
bright_black = encode(90)
bright_red = encode(91)
bright_green = encode(92)
bright_yellow = encode(93)
bright_blue = encode(94)
bright_magenta = encode(95)
bright_cyan = encode(96)
bright_white = encode(97)

if __name__ == '__main__':
  print(f'{red} OK')
