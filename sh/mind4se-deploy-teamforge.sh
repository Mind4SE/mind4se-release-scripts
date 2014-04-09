#!/bin/bash

# *******************************************************************************
# USAGE: mind4se-deploy-teamforge.sh [release_workspace]
#
# DETAILS:
# This script will deploy to Teamforge the MIND4SE release previously generated into release_workspace.
#
# REQUIREMENTS:
# Need installed and in the path:
# 	- maven with a valid settings.xml file with teamforge credentials
# *******************************************************************************

printf '\n'
printf '===============================================================================\n'
printf '== MIND4SE Release script: DEPLOY RELEASE\n'
printf '===============================================================================\n'
printf '\n'

if [ "$1" == "-h" ]; then
	printf '*******************************************************************************\n'
	printf 'USAGE: %s [release_workspace]\n' $0
	printf '\n'
	printf 'DETAILS:\n'
	printf 'This script will deploy to Teamforge the MIND4SE release previously generated into release_workspace.\n'
	printf '\n'
	printf 'REQUIREMENTS:\n'
	printf 'Need installed and in the path:\n'
	printf '	- maven with a valid settings.xml file with teamforge credentials\n'
	printf '*******************************************************************************\n'
	exit 0
fi

printf '*******************************************************************************\n'
printf '[STEP 1] Checking parameter\n'
printf '\n'

if [ -z "$1" ]; then
	printf '[ERROR] Missing workspace folder, which is a mandatory parameter. Exiting.\n'
	exit 1
fi
if [ ! -d "$1" ]; then
	printf '[ERROR] Provided workspace "%s" does not exist. Exiting.\n' $1
	exit 1
fi
export release_workspace=$1

printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 2] Checking environment\n'
printf '\n'

if ! which mvn > /dev/null 2>&1; then
	printf '[ERROR] MAVEN not found in the path. MAVEN is needed to build the release. Exiting.\n'
	exit 1
fi
printf '\t[INFO] MAVEN found\n'

printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 3] Deploying MIND4SE release into teamforge\n'
printf '\n'

pushd $release_workspace > /dev/null 2>&1

printf 'mvn clean install collabnet:deploy-to-releases --projects :mind4se-compiler -Dteamforge -DskipTests\n'
mvn clean install collabnet:deploy-to-releases --projects :mind4se-compiler -Dteamforge -DskipTests || exit 1

popd > /dev/null 2>&1
