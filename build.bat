:: @ECHO off

IF %BUILD_ARCH% EQU 64 (
   CALL "%VS140COMNTOOLS%"\..\..\VC\bin\amd64\vcvars64.bat
) ELSE (
   CALL "%VS140COMNTOOLS%"\..\..\VC\bin\vcvars32.bat
)

:: The major version of Python being used
SET PY_MAJ_VER=%PY_VER:~0,1%

IF %PY_MAJ_VER% EQU 2 (
   CALL pip install 3to2
)

:: Set the number of CPUs to use in building
SET CPU_USE=2

git clone https://github.com/Cantera/cantera.git
cd cantera
git checkout %CANTERA_TAG%

:: Have to use CALL to prevent the script from exiting after calling SCons
CALL scons clean

:: Put important settings into cantera.conf for the build. Use VS 2015 to
:: compile the interface.
ECHO msvc_version='14.0' >> cantera.conf
ECHO matlab_toolbox='n' >> cantera.conf
ECHO debug='n' >> cantera.conf
ECHO f90_interface='n' >> cantera.conf
ECHO system_sundials='n' >> cantera.conf

SET "ESC_PREFIX=%PREFIX:\=/%"
ECHO boost_inc_dir="%ESC_PREFIX%/Library/include" >> cantera.conf

CALL scons build -j%CPU_USE% python_package=y python_cmd="%PYTHON%"
CALL scons msi
