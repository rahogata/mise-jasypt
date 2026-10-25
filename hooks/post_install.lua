-- hooks/post_install.lua
local file = require("file")

local function write_file(path, content)
    local f, err = io.open(path, "wb")
    if not f then
        error("Unable to write " .. path .. ": " .. tostring(err))
    end

    local ok, write_err = f:write(content)
    f:close()

    if not ok then
        error("Unable to write " .. path .. ": " .. tostring(write_err))
    end
end

local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function create_directory(path)
    local is_windows = RUNTIME.osType == "windows"

    local command
    if is_windows then
        command = 'mkdir "' .. path .. '" 2>NUL'
    else
        command = 'mkdir -p "' .. path .. '"'
    end

    local ok = os.execute(command)
    if not ok then
        error("Failed to create directory: " .. path)
    end
end

function PLUGIN:PostInstall(ctx)
    local install_dir = ctx.rootPath
    local wrapper_dir = file.join_path(install_dir, "mise-bin")
    local is_windows = RUNTIME.osType == "windows"

    local unix_wrapper = [=[
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

    local windows_wrapper = [=[
@echo off
setlocal

if not defined JASYPT_HOME (
    echo Error: JASYPT_HOME is not set. Run this command through mise. 1>&2
    exit /b 1
)

if "%~1"=="" goto usage

set "jasypt_command=%~1"
shift

if /i "%jasypt_command%"=="--version" goto version
if /i "%jasypt_command%"=="-V" goto version
if /i "%jasypt_command%"=="--help" goto usage_ok
if /i "%jasypt_command%"=="-h" goto usage_ok
if /i "%jasypt_command%"=="help" goto usage_ok

set "jasypt_script="
if /i "%jasypt_command%"=="encrypt" set "jasypt_script=encrypt.sh"
if /i "%jasypt_command%"=="decrypt" set "jasypt_script=decrypt.sh"
if /i "%jasypt_command%"=="digest" set "jasypt_script=digest.sh"
if /i "%jasypt_command%"=="list-algorithms" set "jasypt_script=listAlgorithms.sh"

if not defined jasypt_script (
    echo Error: Unknown command "%jasypt_command%". 1>&2
    goto usage
)

if not exist "%JASYPT_HOME%\bin\%jasypt_script%" (
    echo Error: Jasypt script not found: "%JASYPT_HOME%\bin\%jasypt_script%" 1>&2
    exit /b 1
)

where sh.exe >nul 2>nul
if errorlevel 1 (
    echo Error: sh.exe is required to run Jasypt scripts on Windows. 1>&2
    echo Install Git for Windows and ensure its usr\bin directory is on PATH. 1>&2
    exit /b 1
)

sh.exe "%JASYPT_HOME%\bin\%jasypt_script%" %*
exit /b %ERRORLEVEL%

:version
if not defined JASYPT_VERSION (
    echo Error: JASYPT_VERSION is not set. 1>&2
    exit /b 1
)
echo jasypt@%JASYPT_VERSION%
exit /b 0

:usage_ok
call :usage
exit /b 0

:usage
echo Usage: jasypt ^<command^> [arguments...]
echo.
echo Commands:
echo   encrypt          Encrypt a value
echo   decrypt          Decrypt a value
echo   digest           Calculate a digest
echo   list-algorithms  List supported algorithms
echo.
echo Options:
echo   -h, --help       Show this help
echo   -V, --version    Show the selected Jasypt version
exit /b 2
]=]

    -- Create the wrapper directory.
    local ok, err = create_directory(wrapper_dir)
    if ok == false then
        error("Unable to create wrapper directory: " .. tostring(err))
    end

    if is_windows then
        local wrapper_path = file.join_path(wrapper_dir, "jasypt.bat")
        write_file(wrapper_path, windows_wrapper)
    else
        local wrapper_path = file.join_path(wrapper_dir, "jasypt")
        write_file(wrapper_path, unix_wrapper)

        -- Mark the Unix wrapper executable.
        local result = os.execute("chmod u+x " .. shell_quote(wrapper_path))

        if result ~= true and result ~= 0 then
            error("Unable to make wrapper executable: " .. wrapper_path)
        end
    end
end
