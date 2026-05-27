#!/bin/sh
# Replacement for: dmsetup create --concise "$(parse-android-dynparts /dev/sda30)"
#
# Works around a buggy dmsetup --concise parser that fails on multi-segment
# linear tables (e.g. product_b with non-contiguous extents). Calls
# parse-android-dynparts to get the concise string, then issues one
# `dmsetup create` per device with the table fed via stdin, so multi-segment
# tables work reliably.

set -e

CONCISE="$(/usr/bin/parse-android-dynparts /dev/sda30)"

if [ -z "$CONCISE" ]; then
        echo "ERROR: parse-android-dynparts produced empty output" >&2
        exit 1
fi

# Split into device entries on ';'
echo "$CONCISE" | tr ';' '\n' | while IFS= read -r entry; do
        [ -z "$entry" ] && continue

        # Peel off the first four comma-delimited metadata fields.
        # Whatever remains after the fourth comma is the table portion,
        # which itself may contain commas separating segments.
        name="${entry%%,*}";  entry="${entry#*,}"
        uuid="${entry%%,*}";  entry="${entry#*,}"
        minor="${entry%%,*}"; entry="${entry#*,}"
        flags="${entry%%,*}"; table="${entry#*,}"

        [ -z "$name" ] && continue

        # Translate flags. parse-android-dynparts emits "ro" for all
        # dynparts (they're mounted read-only).
        set -- "$name"
        case ",$flags," in
                *,ro,*) set -- --readonly "$@" ;;
        esac
        [ -n "$uuid" ]  && set -- --uuid "$uuid"   "$@"
        [ -n "$minor" ] && set -- --minor "$minor" "$@"

        # Convert remaining commas in the table to newlines, then feed
        # to dmsetup via stdin. dmsetup reads one table line per stdin
        # line when --table is not given.
        echo "$table" | tr ',' '\n' | dmsetup create "$@"
done
