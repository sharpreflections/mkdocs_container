print_help() {
cat << EOF
Usage: $0

Run $0 in same same directory as your mkdocs.yml file or specify --dir <DIR>

Optional:
  --pdf                 To also build a PDF from the html documentation
  --dir <DIR>           DIR points to documentation source folder (where the mkdocs.yml is)
  --serve               To serve html site on localhost:8000 for live preview
  --podman              Use podman instead of docker
  --help                Print this help
EOF
  exit 0
}

RUNTIME="docker"
IMAGE="quay.io/sharpreflections/mkdocs_container"
FILE=$PWD/mkdocs.yml

# Check if script is run in same directory as mkdocs.yml
if [[ ! $* == *"--dir"* ]] && test -f "$FILE"; then
  DIR=$PWD
elif [[ $* == *"--dir"* ]]; then
  :
else
  print_help
fi

# Handle commmand line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)      DIR="$2"; shift;;
    --pdf)      PDF=1; shift;;
    --serve)    MODE="serve";;
    --podman)   RUNTIME="podman";;
    --help)     print_help;;
    "")         print_help;;
  esac
  shift
done

# check whether dir path is absolute or relative
if [[ ! -z "$DIR" ]]; then
  if [[ "$DIR" == *"$PWD"* ]]; then
    echo "DIR Path is absolute"
    echo "$DIR"
  else
    echo "DIR Path is relative"
    DIR="$PWD/$DIR"
    echo "$DIR"
  fi
fi

# find out the user name
get_username() {
  if [ -n "$SUDO_USER" ]; then
    echo "$SUDO_USER"
    is_sudo="via sudo"
  else
    echo "$LOGNAME"
  fi
}

calling_username=$(get_username)
calling_uid=$(id "${calling_username}" --user)
calling_gid=$(id "${calling_username}" --group)

# Run the build if dir is set
if [[ ! -z "$DIR" ]]; then
  $RUNTIME pull $IMAGE
  $RUNTIME run --name mkdocs_container \
               --user ${calling_uid}:${calling_gid} \
               --net=host \
               -v $DIR:/workdir/src:Z \
               --env ENABLE_PDF_EXPORT=$PDF \
               --env MKDOCS_MODE=$MODE \
               -it \
               $IMAGE
  $RUNTIME rm -v mkdocs_container
else
  echo "--dir <DIR> was not set!"
fi
