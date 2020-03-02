#!/bin/bash
set -e

echo "Working directory:"
pwd

if [ -z "$INPUT_MAVEN_IMAGE" ]; then
  >&2 echo "::error A name of an image cantaining java and maven must be provided, see https://hub.docker.com/_/maven"
  exit 1;
fi

sudo rm -rf bidrag-cucumber-backend
git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
cd bidrag-cucumber-backend

if [ "$GITHUB_REF" != "refs/heads/master" ]; then
  export ENVIRONMENT=q1
else
  export ENVIRONMENT=q0
fi

if [ -z "$MAVEN_PIP_USER_CREDENTIALS" ]; then
  docker run --rm -v $PWD:/usr/src/mymaven -v ~/.m2:/root/.m2 -w /usr/src/mymaven "$INPUT_MAVEN_IMAGE" mvn clean test \
    -DENVIRONMENT="$ENVIRONMENT" \
    $"MAVEN_USER_CREDENTIALS" \
    $"MAVEN_TEST_USER_CREDENTIALS" \
    -Dcucumber.options='--tags "@bidrag-dokument"'
else
  docker run --rm -v $PWD:/usr/src/mymaven -v ~/.m2:/root/.m2 -w /usr/src/mymaven "$INPUT_MAVEN_IMAGE" mvn clean test \
    -DENVIRONMENT="$ENVIRONMENT" \
    $"MAVEN_USER_CREDENTIALS" \
    $"MAVEN_TEST_USER_CREDENTIALS" \
    $"MAVEN_PIP_USER_CREDENTIALS" \
    -Dcucumber.options='--tags "@bidrag-sak"'
fi