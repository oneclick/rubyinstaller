@ECHO OFF
REM Determine where is RUBY_BIN (where this script is)
PUSHD %~dp0.
SET RUBY_BIN=%CD%
POPD

REM Add RUBY_BIN to the PATH
SET PATH=%PATH%;%RUBY_BIN%
SET RUBY_BIN=

REM Display Ruby version
ruby.exe -v
