#!/bin/sh
. $(dirname $0)/apk2gold.conf


set -x
JD_INTELLIJ_URL="https://bitbucket.org/bric3/jd-intellij"

TAGS_BASE="$(dirname $0)/${TAGS}"
TOOLS_BASE="$(dirname $0)/${TOOLS}"
FRAMEWORK_DEFAULT="${TOOLS_BASE}/Android-x86/framework.jar"

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

    FRAMEWORK_JAR=""
    # set framework
    if [ $# -lt 1 ]; then
        echo "framework.jar not specified."
        echo "do you want to use default? [Y/n]"
        if read i && [ "x$i" == "xn" ]; then
            echo "stopped by user. (treat as error)"
            exit 1
        fi
        FRAMEWORK_DEFAULT="${TOOLS_BASE}/Android-x86/framework.jar"
    elif ! [ -f "$1" ]; then
        echo "file '$1' doesn't exist or is not a regular file."
        # echo "do you want to use default? [Y/n]"
        # if read i && [ "x$i" == "xn" ]; then
        #     echo "stopped by user. (treat as error)"
        #     exit 1
        # fi
        # FRAMEWORK_DEFAULT="${TOOLS_BASE}/Android-x86/framework.jar"
        exit 1
    else
        FRAMEWORK_JAR="$1"
    fi

    "$TOOLS_BASE/apktool/$HOST_OS/apktool" "if" "$FRAMEWORK_JAR"

    if ! touch "$TAGS_BASE/tag.${TAG}"
    then
        exit 1
    fi
fi

echo "env '${TAG}' has been ready to use."
echo "if you want to reset, please remove 'prepared/tag.${TAG}' file"

exit 0

