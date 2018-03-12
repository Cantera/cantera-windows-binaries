IF %BUILD_ARCH% EQU 64 (
   CALL "%VS140COMNTOOLS%"\..\..\VC\bin\amd64\vcvars64.bat
   SET ARCH_NAME="x64"
) ELSE (
   CALL "%VS140COMNTOOLS%"\..\..\VC\bin\vcvars32.bat
   SET ARCH_NAME="x86"
)

:: The major version of Python being used
SET PY_MAJ_VER=%PY_VER:~0,1%

IF %PY_MAJ_VER% EQU 2 (
   CALL pip install 3to2
   CALL %PYTHON3_LOC%\Scripts\pip install numpy==1.11.3
)

:: Set the number of CPUs to use in building
SET CPU_USE=2

IF "%BUILD_MATLAB%"=="Y" (
git clone https://cantera:%GIT_PW%@cantera.org/mw_headers.git
)
git clone https://github.com/Cantera/cantera.git
cd cantera
git checkout %CANTERA_TAG%

:: Have to use CALL to prevent the script from exiting after calling SCons
CALL scons clean

:: Put important settings into cantera.conf for the build. Use VS 2015 to
:: compile the interface.
ECHO msvc_version='14.0' >> cantera.conf
IF "%BUILD_MATLAB%"=="Y" (
ECHO matlab_toolbox='y' >> cantera.conf
ECHO matlab_path='%CD%/../mw_headers' >> cantera.conf
) ELSE (
ECHO matlab_toolbox='n' >> cantera.conf
)
ECHO debug='n' >> cantera.conf
ECHO f90_interface='n' >> cantera.conf
ECHO system_sundials='n' >> cantera.conf

IF %PY_MAJ_VER% EQU 2 (
    ECHO python3_cmd='%PYTHON3_LOC%/python.exe' >> cantera.conf
    ECHO python3_package='y' >> cantera.conf
)

SET "ESC_PREFIX=%PREFIX:\=/%"
ECHO boost_inc_dir="C:/Libraries/boost" >> cantera.conf

CALL scons build -j%CPU_USE% python_package=y
CALL scons msi

dir

IF %BUILD_ARCH% EQU 64 (
   move Cantera-%CT_VERSION%.win-amd64-py%PY_VER%.msi Cantera-Python-%CT_VERSION%-x64-py%PY_VER%.msi
   IF %PY_MAJ_VER% EQU 2 (
      move Cantera-%CT_VERSION%.win-amd64-py3.4.msi Cantera-Python-%CT_VERSION%-x64-py3.4.msi
   )
) ELSE (
   move Cantera-%CT_VERSION%.win32-py%PY_VER%.msi Cantera-Python-%CT_VERSION%-x86-py%PY_VER%.msi
   IF %PY_MAJ_VER% EQU 2 (
      move Cantera-%CT_VERSION%.win32-py3.4.msi Cantera-Python-%CT_VERSION%-x86-py3.4.msi
   )
)

if "%BUILD_MATLAB%"=="Y" (
move cantera.msi "Cantera-%CT_VERSION%-%ARCH_NAME%.msi"
) ELSE (
:: Only want cantera.msi from the build that includes the Matlab toolbox
del cantera.msi
)
