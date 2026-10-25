local file = require("file")
local cmd = require("cmd")

local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

function PLUGIN:PostInstall(ctx)
    local install_dir = ctx.rootPath
    local wrapper_dir = file.join_path(install_dir, "mise-bin")
    local wrapper_path = file.join_path(wrapper_dir, "jasypt")

    local wrapper = [=[
#!/bin/sh
set -eu

if [ -z "${JASYPT_HOME:-}" ]; then
    echo "Error: JASYPT_HOME is not set. Run this command through mise." >&2
    exit 1
fi

usage() {
    cat <<'EOF'
Usage: jasypt <command> [arguments...]

Commands:
  encrypt          Encrypt a value
  decrypt          Decrypt a value
  digest           Calculate a digest
  list-algorithms  List supported algorithms

Options:
  -h, --help        Show this help
  -V, --version     Show the selected Jasypt version

Examples:
  jasypt encrypt input="hello"
  jasypt decrypt input="ENC(...)"
  jasypt digest input="hello"
  jasypt list-algorithms
EOF
}

if [ "$#" -eq 0 ]; then
    usage
    exit 2
fi

command=$1
shift

case "$command" in
    --version|-V)
        if [ -z "${JASYPT_VERSION:-}" ]; then
            echo "Error: JASYPT_VERSION is not set." >&2
            exit 1
        fi
        echo "jasypt@$JASYPT_VERSION"
        exit 0
        ;;
    encrypt)         script=encrypt.sh ;;
    decrypt)         script=decrypt.sh ;;
    digest)          script=digest.sh ;;
    list-algorithms) script=listAlgorithms.sh ;;
    -h|--help|help)
        usage
        exit 0
        ;;
    *)
        echo "Error: Unknown command '$command'." >&2
        usage >&2
        exit 2
        ;;
esac

script_path="$JASYPT_HOME/bin/$script"

if [ ! -f "$script_path" ]; then
    echo "Error: Jasypt script not found: $script_path" >&2
    echo "Check the layout of the installed Jasypt distribution." >&2
    exit 1
fi

exec sh "$script_path" "$@"
]=]

    cmd.exec("mkdir -p " .. shell_quote(wrapper_dir))

    local write_command = "cat > "
        .. shell_quote(wrapper_path)
        .. " <<'JASYPT_WRAPPER_EOF'\n"
        .. wrapper
        .. "\nJASYPT_WRAPPER_EOF"

    cmd.exec(write_command)
    cmd.exec("chmod u+x " .. shell_quote(wrapper_path))
end
