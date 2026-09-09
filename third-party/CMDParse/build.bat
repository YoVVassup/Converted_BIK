@echo off
call "C:\Program Files\Microsoft Visual Studio\18\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
cl /EHsc /std:c++17 /I. Cross_Converted_BIK.cpp /Fe:CMDParse.exe
