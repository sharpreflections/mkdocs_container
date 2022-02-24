print_help() {
cat << EOF
Usage: $0 --dir <DIR>
Mandatory options:
  --dir <DIR>           DIR points to documentation source folder (where the mkdocs.yml is)

Optional options:
  --pdf <0 or 1>        Set to 1 to build pdf and html, 0 to only build html (standard)
  --podman              Use podman instead of docker
  --help                Print this help
EOF
  exit 0
}

RUNTIME="docker"

if [[ $# == 0 ]]; then
    print_help
    return
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)      DIR="$2"; shift;;
    --pdf)      PDF="$2"; shift;;
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

# Run the buil if dir is not empty
if [[ ! -z "$DIR" ]]; then
    $RUNTIME run --name mkdocs_test \
                 -v $DIR:/root/src:Z \
                 -u root \
                 --env ENABLE_PDF_EXPORT=$PDF \
                 mkdocs:latest
    $RUNTIME rm -v mkdocs_test
else
    echo "--dir <DIR> was not set!"
fi
