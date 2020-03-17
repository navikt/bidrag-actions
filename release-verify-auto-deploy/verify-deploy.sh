#!/bin/bash
set -e

############################################
#
# Følgende skjer i dette skriptet:
# 1) henter ut tekst som er skrevet i en tabell (ie. changelog)
# 2) Teller antall innslag av gitt versjonsnummer fra changelog (feiler ikke ved tallet 0: count -c "$INPUT_RELEASE_VERSION" || true)
#    0 - kan ikke auto-deployes
#    1 - kan auto-deployes
#
############################################

RELEASE_TABLE=$(cat "$INPUT_CHANGELOG_FILE" | grep '|')            # the release table in the changelog file
COUNT="$(echo "$RELEASE_TABLE" | grep -c "$INPUT_RELEASE_VERSION" || true)" # count all mentions of 'RELEASE_VERSION' in the 'RELEASE_TABLE' from the changelog

echo "echo Found $COUNT mentioning(s) of $INPUT_RELEASE_VERSION in $INPUT_CHANGELOG_FILE."

if [ "$COUNT" -eq 0 ]
  then
    echo ::set-output name=is_release_candidate=false
    exit 0;
fi

echo ::set-output name=is_release_candidate=true
