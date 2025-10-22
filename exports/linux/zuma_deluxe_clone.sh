#!/bin/sh
echo -ne '\033c\033]0;MuZa\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/zuma_deluxe_clone.x86_64" "$@"
