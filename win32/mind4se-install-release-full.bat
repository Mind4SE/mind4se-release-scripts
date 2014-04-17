@echo off
setlocal enableextensions

rem *******************************************************************************
rem USAGE: mind4se-install-release-full.bat [manifest_branch_name] [manifest_url]
rem
rem DETAILS:
rem This script will create a workspace and then generate a MIND4SE release.
rem 
rem WARNING:
rem Parameters are specified by order of importance.
rem You *MUST* specify "manifest_branch_name" if "manifest_url" need to be changed.
rem
rem REQUIREMENTS:
rem Need installed and in the path:
rem 	- python 3+
rem 	- git 1.7.2+
rem 	- curl or wget download utility
rem 	- mingw (gcc)
rem 	- maven
rem *******************************************************************************

rem PRIVATE - WORKSPACE
set release_workspace=mind4se-release

echo.
echo.===============================================================================
echo.== MIND4SE Release script: INSTALL RELEASE FULL
echo.===============================================================================
echo.

if "%1" == "-h" (
	echo.*******************************************************************************
	echo.USAGE: %0 [manifest_branch_name] [manifest_url]
	echo.
	echo.DETAILS:
	echo.This script will create a workspace in "%release_workspace%" and then generate a MIND4SE release.
	echo.
	echo.WARNING:
	echo.Parameters are specified by order of importance.
	echo.You *MUST* specify "manifest_branch_name" if "manifest_url" need to be changed.
	echo.
	echo.REQUIREMENTS:
	echo.Need installed and in the path:
	echo.	- python 3+
	echo.	- git 1.7.2+
	echo.	- curl or wget download utility
	echo.	- gcc ^(mingw^)
	echo.	- maven
	echo.*******************************************************************************
	exit /b 0
)

echo.*******************************************************************************
echo.Workspace creation (calling script mind4se-create-workspace.bat)
echo.

cmd /c mind4se-create-workspace.bat %release_workspace% %1 %2 || exit /b 1

echo.
echo.*******************************************************************************
echo.Maven install build (calling script mind4se-install-release.bat)
echo.

cmd /c mind4se-install-release.bat %release_workspace% || exit /b 1

endlocal
@echo on
