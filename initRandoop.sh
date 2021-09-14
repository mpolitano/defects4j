################################################################################
HOST_URL="https://defects4j.org/downloads"

# Directories for project repositories and external libraries
BASE="$(cd "$(dirname "$0")"; pwd)"
DIR_REPOS="$BASE/project_repos"
DIR_LIB_GEN="$BASE/framework/lib/test_generation/generation"
DIR_LIB_RT="$BASE/framework/lib/test_generation/runtime"
DIR_LIB_GRADLE="$BASE/framework/lib/build_systems/gradle"
mkdir -p "$DIR_LIB_GEN" && mkdir -p "$DIR_LIB_RT" && mkdir -p "$DIR_LIB_GRADLE"

################################################################################
#
# Utility functions
#

# MacOS does not install the timeout command by default.
if [ "$(uname)" = "Darwin" ] ; then
  function timeout() { perl -e 'alarm shift; exec @ARGV' "$@"; }
fi

# Download the remote resource to a local file of the same name.
# Takes a single command-line argument, a URL.
# Skips the download if the remote resource is newer.
# Works around connections that hang.
download_url() {
    if [ "$#" -ne 1 ]; then
        echo "Illegal number of arguments"
    fi
    URL=$1
    echo "Downloading ${URL}"
    if [ "$(uname)" = "Darwin" ] ; then
        wget -nv -N "$URL" && echo "Downloaded $URL"
    else
        BASENAME="$(basename "$URL")"
        if [ -f "$BASENAME" ]; then
            ZBASENAME="-z $BASENAME"
        else
            ZBASENAME=""
        fi
        (timeout 300 curl -s -S -R -L -O $ZBASENAME "$URL" || (echo "retrying curl $URL" && rm -f "$BASENAME" && curl -R -L -O "$URL")) && echo "Downloaded $URL"
    fi
}

# Download the remote resource and unzip it.
# Takes a single command-line argument, a URL.
# Skips the download if the local file of the same name is newer.
# Works around connections that hang and corrupted downloads.
download_url_and_unzip() {
    if [ "$#" -ne 1 ]; then
        echo "Illegal number of arguments"
    fi
    URL=$1
    BASENAME="$(basename "$URL")"
    download_url "$URL"
    if ! unzip -o "$BASENAME" > /dev/null ; then
        echo "retrying download and unzip"
        rm -rf "$BASENAME"
        download_url "$URL"
        unzip -o "$BASENAME"
    fi
}



################################################################################
#
# Download Randoop
#
version=$1
echo
echo "Setting up Randoop ... "
RANDOOP_VERSION=$version
RANDOOP_URL="https://github.com/randoop/randoop/releases/download/v${RANDOOP_VERSION}"
RANDOOP_ZIP="randoop-${RANDOOP_VERSION}.zip"
RANDOOP_JAR="randoop-all-${RANDOOP_VERSION}.jar"
REPLACECALL_JAR="replacecall-${RANDOOP_VERSION}.jar"
COVEREDCLASS_JAR="covered-class-${RANDOOP_VERSION}.jar"
(cd "$DIR_LIB_GEN" && download_url_and_unzip "$RANDOOP_URL/$RANDOOP_ZIP")
# Set symlink for the supported version of Randoop
(cd "$DIR_LIB_GEN" && ln -sf "randoop-${RANDOOP_VERSION}/$RANDOOP_JAR" "randoop-current.jar")
(cd "$DIR_LIB_GEN" && ln -sf "randoop-${RANDOOP_VERSION}/$REPLACECALL_JAR" "replacecall-current.jar")
(cd "$DIR_LIB_GEN" && ln -sf "randoop-${RANDOOP_VERSION}/$COVEREDCLASS_JAR" "covered-class-current.jar")




