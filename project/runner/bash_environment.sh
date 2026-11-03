# Read by non-interactive MSYS2 Bash. Handle EQY's Windows CRLF files
# without exporting shell options across the Make -> sh -> Bash boundary.
set -o igncr
