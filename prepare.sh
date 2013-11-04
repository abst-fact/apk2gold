#!/bin/sh
. $(dirname $0)/apk2gold.conf


JD_INTELLIJ_URL="https://bitbucket.org/bric3/jd-intellij"

TAGS_BASE="$(dirname $0)/${TAGS}"
TOOLS_BASE="$(dirname $0)/${TOOLS}"
FRAMEWORK_RES_DEFAULT="${TOOLS_BASE}/Android-x86/framework-res.apk"

mkdir -p "$TAGS_BASE"

if ! [ -e "$TAGS_BASE/tools" ]; then
    if \
       git submodule update --init && \
       ( [ -d "$TOOLS_BASE/jd-intellij" ] || hg clone "$JD_INTELLIJ_URL" "$TOOLS_BASE/jd-intellij" ) && \
       cp -f "$TOOLS_BASE/jd-intellij/src/main/native/nativelib/$HOST_OS/$HOST_ARCH/libjd-intellij."* "$TOOLS_BASE/jd-cli/"
    then
        if ! touch "$TAGS_BASE/tools"
        then
            exit 1
        fi
    else
        exit 1
    fi
fi

if ! [ -e "$TAGS_BASE/tag.${TAG}" ]; then

    FRAMEWORK_RES_APK=""
    # set framework
    if [ $# -lt 1 ]; then
        echo "'framework-res.apk' not specified by arguments."
        echo "Do you want to use default apk? ('$FRAMEWORK_RES_DEFAULT')"
        echo "[Y/n] :"
        if read i && [ "x$i" == "xn" ]; then
            echo "Please retry to prepare with the file path to 'framework-res.apk'"
            echo ""
            echo "e.g.:"
            echo "  $0 ~/android/files/framework-res.apk"
            echo ""
            echo "stopped by user, but will be treated as error."
            exit 1
        fi
        FRAMEWORK_RES_APK="$FRAMEWORK_RES_DEFAULT"
    elif ! [ -f "$1" ]; then
        echo "file '$1' doesn't exist or is not a regular file."
        # echo "do you want to use default? [Y/n]"
        # if read i && [ "x$i" == "xn" ]; then
        #     echo "stopped by user. (treat as error)"
        #     exit 1
        # fi
        # FRAMEWORK_RES_DEFAULT="${TOOLS_BASE}/Android-x86/framework.jar"
        exit 1
    else
        FRAMEWORK_APK="$1"
    fi

    echo "Installing '$FRAMEWORK_RES_APK'."
    "$TOOLS_BASE/apktool/$HOST_OS/apktool" "if" "$FRAMEWORK_RES_APK"

    if ! touch "$TAGS_BASE/tag.${TAG}"
    then
        exit 1
    fi
fi

echo "env '${TAG}' has been ready to use."
echo "if you want to reset, please remove 'prepared/tag.${TAG}' file."
echo "and if you want to reset all the 3rd party tools, do revert using git."

exit 0

