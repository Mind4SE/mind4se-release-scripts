#!/bin/bash

# *******************************************************************************
# USAGE: mind4se-install-release.sh [release_workspace]
#
# DETAILS:
# This script will generate the MIND4SE release with maven using the provided workspace.
# Environment variable BUILD_OPTIONS can contain maven build options.
#
# REQUIREMENTS:
# Need installed and in the path:
# 	- gcc
# 	- maven
# *******************************************************************************

printf '\n'
printf '===============================================================================\n'
printf '== MIND4SE Release script: INSTALL RELEASE\n'
printf '===============================================================================\n'
printf '\n'

if [ "$1" == "-h" ]; then
	printf '*******************************************************************************\n'
	printf 'USAGE: %s [release_workspace]\n' $0
	printf '\n'
	printf 'DETAILS:\n'
	printf 'This script will generate the MIND4SE release with maven using the provided workspace.\n'
	printf 'Environment variable BUILD_OPTIONS can contain maven build options.\n'
	printf '\n'
	printf 'REQUIREMENTS:\n'
	printf 'Need installed and in the path:\n'
	printf '	- gcc\n'
	printf '	- maven\n'
	printf '*******************************************************************************\n'
	exit 0
fi

printf '*******************************************************************************\n'
printf '[STEP 1] Checking parameter\n'
printf '\n'

if [ -z "$1" ]; then
	printf '[ERROR] An existing workspace folder is a mandatory parameter. Exiting.\n'
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

if ! which gcc > /dev/null 2>&1; then
	printf '[ERROR] GCC not found in the path. GCC is needed to build the release. Exiting.\n'
	exit 1
fi
printf '\t[INFO] GCC found\n'

printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 3] Build the MIND4SE release into workspace "%s"\n' $release_workspace
printf '\n'

pushd $release_workspace > /dev/null 2>&1

# Cleanup maven local repository
# rm -rf "~/.m2/repository"

# Install mind-parent jar into maven local repository (all mind4se modules depend transitively on this one, needed before building)
printf 'mvn -U clean install -f maven/mind-parent/pom.xml %s\n' $BUILD_OPTIONS
mvn -U clean install -f maven/mind-parent/pom.xml $BUILD_OPTIONS || exit 1

# Install mind-compiler pom into maven local repository (all mind4se plug-ins pom depend on this one, needed before building)
printf 'mvn -U clean install -f ./mind-compiler/pom.xml --projects :mind-compiler %s\n' $BUILD_OPTIONS
mvn -U clean install -f ./mind-compiler/pom.xml --projects :mind-compiler $BUILD_OPTIONS || exit 1

# Build the mind4se release
printf 'mvn -U clean install %s\n' $BUILD_OPTIONS
mvn -U clean install $BUILD_OPTIONS || exit 1

popd > /dev/null 2>&1
