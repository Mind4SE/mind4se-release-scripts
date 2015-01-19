@echo off
setlocal enableextensions

rem *******************************************************************************
rem USAGE: mind4se-create-workspace.bat [workspace_folder] [manifest_branch_name] [manifest_url]
rem
rem DETAILS:
rem This script generates a full workspace into provided workspace_folder folder.
rem
rem WARNING:
rem Parameters are specified by order of importance.
rem You *MUST* specify "workspace_folder" and "manifest_branch_name" if "manifest_url" need to be changed.
rem
rem REQUIREMENTS:
rem Need installed and in the path:
rem 	- python 3+
rem 	- git 1.7.2+
rem 	- curl or wget download utility
rem *******************************************************************************

rem PRIVATE - HTTP PROXY
set proxy_url=205.167.7.126:80
set http_proxy=http://%proxy_url%
set https_proxy=https://%proxy_url%
rem PRIVATE - REPO TOOL
set repo_tool_url=https://raw.githubusercontent.com/esrlabs/git-repo/master/repo
set repo_tool_dir=repo_tool
rem PRIVATE - WORKSPACE
set release_default_workspace=mind4se-release
rem PRIVATE - MANIFEST
set mind4se_manifest_default_url=https://github.com/Mind4SE/mind4se-release-manifest
set mind4se_manifest_default_branch=master
set local_release_manifest_file=src/assemble/resources/manifest.xml
rem PRIVATE - TOOLS MINIMAL VERSION
set python_minimal_version_required=3
set git_minimal_version_required=1.7.2

echo.
echo.===============================================================================
echo.== MIND4SE Release script: CREATE WORKSPACE
echo.===============================================================================
echo.

if "%1" == "-h" (
	echo.*******************************************************************************
	echo.USAGE: %0 [workspace_folder] [manifest_branch_name] [manifest_url]
	echo.
	echo.DETAILS:
	echo.This script generates a full workspace into provided workspace_folder folder.
	echo.
	echo.DEFAULT PARAMS VALUES:
	echo.	workspace_folder	= %CD%\%release_default_workspace%
	echo.	manifest_branch_name	= %mind4se_manifest_default_branch%
	echo.	manifest_url		= %mind4se_manifest_default_url%
	echo.
	echo.WARNING:
	echo.Parameters are specified by order of importance.
	echo.You *MUST* specify "workspace_folder" and "manifest_branch_name" if "manifest_url" need to be changed.
	echo.
	echo.REQUIREMENTS:
	echo.Need installed and in the path:
	echo.	- python %python_minimal_version_required%+
	echo.	- git %git_minimal_version_required%+
	echo.	- curl or wget download utility
	echo.*******************************************************************************
	exit /b 0
)

echo.*******************************************************************************
echo.[STEP 1] Checking parameter
echo.

if "%1" == "" (
	echo. 	[INFO] No release workspace folder provided. Using default worskpace "%release_default_workspace%". & set release_workspace=%release_default_workspace%
	pause
) else (
	set release_workspace=%1
)

if "%2" == "" (
	echo. 	[INFO] No manifest branch name specified. Using default branch "%mind4se_manifest_default_branch%". & set mind4se_manifest_branch=%mind4se_manifest_default_branch%
	pause
) else (
	set mind4se_manifest_branch=%2
)

if "%3" == "" (
	echo. 	[INFO] No manifest url specified. Using default url "%mind4se_manifest_default_url%". & set mind4se_manifest_url=%mind4se_manifest_default_url%
	pause
) else (
	set mind4se_manifest_url=%3
)

echo.
echo.	[CONFIG] release_workspace = %release_workspace%
echo.	[CONFIG] mind4se_manifest_branch = %mind4se_manifest_branch%
echo.	[CONFIG] mind4se_manifest_url = %mind4se_manifest_url%
echo.

echo.
echo.*******************************************************************************
echo.[STEP 2] Checking environment
echo.
echo.[STEP 2.1] Checking Tools availability into path
echo.

where /q python || echo.[ERROR] PYTHON not found in the path. PYTHON %python_minimal_version_required%+ is needed to download source code. Exiting. && exit /b 1
echo.	[INFO] PYTHON found
where /q git || echo.[ERROR] GIT not found in the path. GIT %git_minimal_version_required%+ is needed to download source code. Exiting. && exit /b 1
echo.	[INFO] GIT found

where /q curl && set curl_available=1 && echo.	[INFO] CURL found
where /q wget && set wget_available=1 && echo.	[INFO] WGET found
if not defined curl_available if not defined wget_available echo.[ERROR] CURL or WGET not found in the path. Needed to download repo tool. Exiting. & exit /b 1

echo.
echo.[STEP 2.2] Checking Tools versions
echo.

python --version > output.tmp 2>&1
set /p python_version= < output.tmp
del output.tmp
echo.	[INFO] PYTHON version: %python_version:~7%
if %python_version:~7% lss %python_minimal_version_required% echo.[ERROR] PYTHON version %python_minimal_version_required%+ is required. Exiting. & exit /b 1

git --version > output.tmp 2>&1
set /p git_version= < output.tmp
del output.tmp
echo.	[INFO] GIT version: %git_version:~12%
if %git_version:~12% lss %git_minimal_version_required% echo.[ERROR] GIT version %git_minimal_version_required%+ is required. Exiting. & exit /b 1

echo.
echo.[STEP 2.3] Checking Git configuration
echo.

git config -l > config.tmp 2>&1
findstr /I "core.autocrlf=false" config.tmp > NUL 2>&1
set wrong_git_config=%ERRORLEVEL%
del config.tmp
if %wrong_git_config% neq 0 echo.[ERROR] Missing GIT configuration autocrlf=false. Execute git config --global core.autocrlf=false then restart. Exiting. & exit /b 1

echo.
echo.*******************************************************************************
echo.[STEP 3] Repo tool install
echo.
echo.[STEP 3.1] Downloading repo tool
echo.

rmdir /S /Q %repo_tool_dir% > NUL 2>&1
mkdir %repo_tool_dir%
if defined wget_available (
	echo.	[INFO] Downloading repo tool from "%repo_tool_url%" into folder "%repo_tool_dir%" using wget
	wget -e https_proxy=%proxy_url% --no-check-certificate %repo_tool_url% -O %repo_tool_dir%/repo
	wget -e https_proxy=%proxy_url% --no-check-certificate %repo_tool_url%.cmd -O %repo_tool_dir%/repo.cmd
)
if not defined wget_available if defined curl_available (
	echo. [INFO] Downloading repo tool from "%repo_tool_url%" into folder "%repo_tool_dir%" using curl
	curl -x %proxy_url% --insecure --output %repo_tool_dir%/repo %repo_tool_url%
	curl -x %proxy_url% --insecure --output %repo_tool_dir%/repo.cmd %repo_tool_url%.cmd
)

echo.
echo.[STEP 3.2] Installing repo tool in the path
echo.

set PATH=%CD:\=/%/%repo_tool_dir%;%PATH:\=/%
echo.	[INFO] Repo tool installed in path
echo.	%PATH%
echo.

echo.
echo.*******************************************************************************
echo.[STEP 4] Downloading the MIND4SE source code using repo tool
echo.
echo.[STEP 4.1] Create the release workspace "%release_workspace%"
echo.

rem rmdir /Q /S %release_workspace% > NUL 2>&1
mkdir %release_workspace%
pushd %release_workspace%

echo.
echo.[STEP 4.2] Initialize the workspace using manifest file available at 
echo. "%mind4se_manifest_url%" (branch %mind4se_manifest_branch%)
echo.

call repo init -u %mind4se_manifest_url% -b %mind4se_manifest_branch% || exit /b 1

echo.
echo.[STEP 4.3] Synchronize the workspace by downloading source code
echo.

call repo sync -c --no-clone-bundle --jobs=4 || exit /b 1

echo.
echo.[STEP 4.4] Generate release specific manifest file into "%local_release_manifest_file%"
echo.

call repo --no-pager manifest -r -o %local_release_manifest_file% || exit /b 1

popd

endlocal
@echo on
