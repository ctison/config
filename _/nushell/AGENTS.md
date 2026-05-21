This folder contains Nushell configurations.

# Guidelines

## Casing

- Variables -> camelCase
- Constants -> SCREAMING_CASE
- Functions -> lower case separated by spaces, with single quotes when spaces, eg. `def 'alias create' [] {}`.
- Flags -> kebab-case

## Naming pattern

- Functions -> `noun verb (or noun adjective verb for multi-word nouns)`. Omit `list` and `get` (if `list` not present).

## Flags

- Do not add `bool` type to flags, nor default `false` if `false`, eg: `def example [--verbose, --enable-telemetry = true]`.
- Do not default to empty values for optional flags, eg. NOT `--hostname: string = ""` BUT `--hostname: string`, YES `--page = 0`.

## Comments

- Very concise. Don't document flag defaults. Flag comments starts with uppercase.

## If/else

- To check a value emptiness: `if ($varName | is-empty) or ($overVar | is-not-empty) {}`
