@echo off
pushd %~dp0
cd builds
call python build.py %*
popd
