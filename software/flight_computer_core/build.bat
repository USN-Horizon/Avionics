@echo off
rem Debug build, then run.
cmake -S "%~dp0." -B "%~dp0build" -G "Visual Studio 17 2022"
if errorlevel 1 exit /b 1
cmake --build "%~dp0build" --config Debug
if errorlevel 1 exit /b 1
"%~dp0build\Debug\rocket_app.exe"
