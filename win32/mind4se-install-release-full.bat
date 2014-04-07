@echo off
setlocal enableextensions

rem set PATH=C:/ECP_SF/Tools/Python-3.3.3;%PATH%;C:/ECP_SF/Tools/Git/cmd

rem *******************************************************************************
rem USAGE: mind4se-install-release-full.bat manifest_url manifest_branch_name
rem
rem This script will create a workspace and then generate a MIND4SE release
rem Parameters are in order of importance (must specify $1 if manifest_branch_name must be changed)
rem
rem REQUIREMENTS:
rem Need installed and in the path:
rem - python 3+
rem - git 1.7.2+
rem - curl or wget download utility
rem - mingw (gcc)
rem - maven
rem *******************************************************************************

rem PRIVATE - WORKSPACE
set release_workspace=mind4se-release
rem PRIVATE - MANIFEST
set mind4se_manifest_default_url=https://github.com/geoffroyjabouley/mind4se-release-manifest
set mind4se_manifest_default_branch=master

echo.===============================================================================
echo.== MIND4SE Release script: INSTALL RELEASE FULL
echo.===============================================================================
echo.
echo.*******************************************************************************
echo.Checking parameter
echo.

if "%1" == "" (
	echo. 	[INFO] No manifest url specified. Using default branch "%mind4se_manifest_default_url%". & set mind4se_manifest_url=%mind4se_manifest_default_url%
	pause
) else (
	set mind4se_manifest_url=%1
)
echo.	[PARAMETER] mind4se_manifest_url = %mind4se_manifest_url%

if "%2" == "" (
	echo. 	[INFO] No manifest branch name specified. Using default branch "%mind4se_manifest_default_branch%". & set mind4se_manifest_branch=%mind4se_manifest_default_branch%
	pause
) else (
	set mind4se_manifest_branch=%2
)
echo.	[PARAMETER] mind4se_manifest_branch = %mind4se_manifest_branch%

echo.
echo.*******************************************************************************
echo.Workspace creation (calling script mind4se-create-workspace-only.bat)
echo.

cmd /c mind4se-create-workspace-only.bat %mind4se_manifest_url% %mind4se_manifest_branch% %release_workspace% || exit /b 1

echo.
echo.*******************************************************************************
echo.Maven install build (calling script mind4se-install-release.bat)
echo.

cmd /c mind4se-install-release.bat %release_workspace% || exit /b 1

endlocal
@echo on
