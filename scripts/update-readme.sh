#!/bin/bash

# I would have written this diretly in the Makefile, but that was difficult.

CMD="$1"

TMP=`mktemp`
TMP2=`mktemp`
terraform-docs md . > "$TMP"
sed '/^<!-- START -->$/,/<!-- END -->/{//!d;}' README.md | sed "/^<!-- START -->$/r $TMP" > $TMP2

case "$CMD" in
    update)
        mv $TMP2 README.md
    ;;
    check)
        diff $TMP2 README.md >/dev/null
    ;;
    *)
        echo "unknown command"
        exit -1
esac

exit $?