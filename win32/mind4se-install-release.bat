@echo off
setlocal enableextensions

rem *******************************************************************************
rem USAGE: mind4se-install-release.bat [release_workspace]
rem
rem DETAILS:
rem This script will generate the MIND4SE release with maven using the provided workspace.
rem Environment variable BUILD_OPTIONS can contain maven build options.
rem
rem REQUIREMENTS:
rem Need installed and in the path:
rem 	- mingw (gcc)
rem 	- maven
rem *******************************************************************************

echo.
echo.===============================================================================
echo.== MIND4SE Release script: INSTALL RELEASE
echo.===============================================================================
echo.

if "%1" == "-h" (
	echo.*******************************************************************************
	echo.USAGE: %0 [release_workspace]
	echo.
	echo.DETAILS:
	echo.This script will generate the MIND4SE release with maven using the provided workspace.
	echo.Environment variable BUILD_OPTIONS can contain maven build options.
	echo.
	echo.REQUIREMENTS:
	echo.Need installed and in the path:
	echo.	- gcc ^(mingw^)
	echo.	- maven
	echo.*******************************************************************************
	exit /b 0
)

echo.*******************************************************************************
echo.[STEP 1] Checking parameter
echo.

if "%1"=="" echo [ERROR] An existing workspace folder is a mandatory parameter. Exiting. & exit /b 1
set release_workspace=%1

echo.
echo.*******************************************************************************
echo.[STEP 2] Checking environment
echo.

where /q mvn || echo.[ERROR] MAVEN not found in the path. MAVEN is needed to build the release. Exiting. && exit /b 1
echo.	[INFO] MAVEN found
where /q gcc || echo.[ERROR] GCC not found in the path. GCC is needed to build the release. Exiting. && exit /b 1
echo.	[INFO] GCC found

echo.
echo.*******************************************************************************
echo.[STEP 3] Build the MIND4SE release into workspace "%release_workspace%"
echo.

pushd %release_workspace%

rem Cleanup maven local repository
rem rmdir /Q /S "%USERPROFILE%/.m2/repository"

rem Install mind-parent jar into maven local repository (all mind4se modules depend transitively on this one, needed before building)
echo.mvn -U clean install -f maven/mind-parent/pom.xml %BUILD_OPTIONS%
call mvn -U clean install -f maven/mind-parent/pom.xml %BUILD_OPTIONS% || exit /b 1

rem Install mind-compiler pom into maven local repository (all mind4se plug-ins pom depend on this one, needed before building)
echo.mvn -U clean install -f ./mind-compiler/pom.xml --projects :mind-compiler %BUILD_OPTIONS%
call mvn -U clean install -f ./mind-compiler/pom.xml --projects :mind-compiler %BUILD_OPTIONS% || exit /b 1

rem Build the mind4se release
echo.mvn -U clean install %BUILD_OPTIONS%
call mvn -U clean install %BUILD_OPTIONS% || exit /b 1

popd

endlocal
@echo on