IF %BUILD_ARCH% EQU 64 (
   CALL "%VS140COMNTOOLS%"\..\..\VC\bin\amd64\vcvars64.bat
   SET ARCH_NAME="x64"
) ELSE (
   CALL "%VS140COMNTOOLS%"\..\..\VC\bin\vcvars32.bat
   SET ARCH_NAME="x86"
)

:: Set the number of CPUs to use in building
SET CPU_USE=2

IF "%BUILD_MATLAB%"=="Y" (
git clone https://cantera:%GIT_PW%@cantera.org/mw_headers.git
)
git clone https://github.com/Cantera/cantera.git
cd cantera
git checkout %GIT_COMMIT%

:: Have to use CALL to prevent the script from exiting after calling SCons
CALL scons clean

:: Put important settings into cantera.conf for the build. Use VS 2019 to
:: compile the interface.
ECHO msvc_version='14.2' >> cantera.conf
IF "%BUILD_MATLAB%"=="Y" (
ECHO matlab_toolbox='y' >> cantera.conf
ECHO matlab_path='%CD%/../mw_headers' >> cantera.conf
) ELSE (
ECHO matlab_toolbox='n' >> cantera.conf
)
ECHO debug='n' >> cantera.conf
ECHO f90_interface='n' >> cantera.conf
ECHO system_sundials='n' >> cantera.conf
ECHO python_package='full' >> cantera.conf

ECHO boost_inc_dir="C:/Libraries/boost_1_73_0" >> cantera.conf

CALL scons build -j%CPU_USE%
CALL scons msi

dir

IF %BUILD_ARCH% EQU 64 (
   move Cantera-%CT_VERSION%.win-amd64-py%PY_VER%.msi Cantera-Python-%CT_VERSION%-x64-py%PY_VER%.msi
) ELSE (
   move Cantera-%CT_VERSION%.win32-py%PY_VER%.msi Cantera-Python-%CT_VERSION%-x86-py%PY_VER%.msi
)

if "%BUILD_MATLAB%"=="Y" (
move cantera.msi "Cantera-%CT_VERSION%-%ARCH_NAME%.msi"
) ELSE (
:: Only want cantera.msi from the build that includes the Matlab toolbox
del cantera.msi
)
