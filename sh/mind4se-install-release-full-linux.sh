#!/bin/bash

# *******************************************************************************
# USAGE: mind4se-install-release-full-linux.bat manifest_url manifest_branch_name
#
# This script will create a workspace and then generate a MIND4SE release
# Parameters are in order of importance (must specify $1 if manifest_branch_name must be changed)
#
# REQUIREMENTS:
# Need installed and in the path:
# - python 3+
# - git 1.7.2+
# - curl or wget download utility
# - mingw (gcc)
# - maven
# *******************************************************************************

# PRIVATE - WORKSPACE
export release_workspace=mind4se-release
# PRIVATE - MANIFEST
export mind4se_manifest_default_url=https://github.com/geoffroyjabouley/mind4se-release-manifest
export mind4se_manifest_default_branch=master

printf '\n'
printf '===============================================================================\n'
printf '== MIND4SE Release script: INSTALL RELEASE FULL\n'
printf '===============================================================================\n'
printf '\n'
printf '*******************************************************************************\n'
printf '[STEP 1] Checking parameter\n'
printf '\n'

if [ -z "$1" ]; then
	printf '\t[INFO] No manifest branch name specified. Using default branch "%s".\n' $mind4se_manifest_default_branch
	export mind4se_manifest_branch=$mind4se_manifest_default_branch
	printf 'Press any key to continue...\n' && read
else
	export mind4se_manifest_branch=$1
fi

/bin/bash mind4se-create-workspace-linux.sh $mind4se_manifest_branch $release_workspace || exit 1

/bin/bash mind4se-install-release.sh $release_workspace || exit 1
