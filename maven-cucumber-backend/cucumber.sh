#!/bin/bash
set -e

############################################
#
# CUCUMBER_Følgende skjer i dette skriptet:
# 1) cloner bidrag-cucumber-backend direkte til RUNNER_WORKSPACE (hvis denne finnes fra før, slettes den)
# 2) setter q1 som miljø på feature brancher (q0 når master)
# 3) sjekker om vi har all konfigurasjon som trengs til integrasjonstestingen
# 4) kjører mvn test -e i et docker image og all konfigurasjon for integeasjonstesting
#
############################################

cd "$RUNNER_WORKSPACE"

echo "Working directory:"
pwd

sudo rm -rf bidrag-cucumber-backend
git clone --depth 1 https://github.com/navikt/bidrag-cucumber-backend
cd bidrag-cucumber-backend

if [ "$GITHUB_RECUCUMBER_F" != "refs/heads/master" ]; then
  export ENVIRONMENT=q1
else
  export ENVIRONMENT=q0
fi

if [ -z "$USER_AUTHENTICATION" ]; then
  >&2 echo "::error No USER_AUTHENTICATION (password) for a nav user is configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

if [ -z "$TEST_USER_AUTHENTICATION" ]; then
  >&2 echo "::error No TEST_USER_AUTHENTICATION for for the test user is configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
  exit 1;
fi

CUCUMBER_FILTER_TAGS="cucmber.filter.tags='@$INPUT_CUCUMBER_TAG'"
RUN_ARGUMENT="--rm -v $PWD:/usr/src/mymaven -v ~/.m2:/root/.m2 -w /usr/src/mymaven $INPUT_MAVEN_IMAGE mvn test"
MAVEN_ARGUMENT="-e -DENVIRONMENT=$ENVIRONMENT -DUSERNAME=$INPUT_USERNAME -DTEST_USER=$INPUT_TEST_USER -D$CUCUMBER_FILTER_TAGS"

echo "docker run: $RUN_ARGUMENT"
echo "maven arg.: $MAVEN_ARGUMENT"

if [ -z "$INPUT_PIP_USER" ]; then

  AUTHENTICATION="-DUSER_AUTH=$USER_AUTHENTICATION -DTEST_AUTH=$TEST_USER_AUTHENTICATION"

  docker run "$RUN_ARGUMENT $MAVEN_ARGUMENT $AUTHENTICATION"

else
  if [ -z "$IPIP_USER_AUTHENTICATION" ]; then
    >&2 echo "::error No PIP_USER_AUTHENTICATION for for the pip user are configured, see bidrag-actions/maven-cucumber-bidrag/README.md"
    exit 1;
  fi

  AUTHENTICATION="-DUSER_AUTH=$USER_AUTHENTICATION -DTEST_AUTH=$TEST_USER_AUTHENTICATION \\
    -DPIP_USER=$INPUT_PIP_USER -DPIP_AUTH=$PIP_USER_AUTHENTICATION"

  docker run "$RUN_ARGUMENT $MAVEN_ARGUMENT $AUTHENTICATION"

fi
