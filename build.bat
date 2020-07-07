:: Set the number of CPUs to use in building
SET CPU_USE=2

cd cantera

:: Have to use CALL to prevent the script from exiting after calling SCons
CALL scons clean

:: Put important settings into cantera.conf for the build. Use VS 2019 to
:: compile the interface.
ECHO msvc_version='14.2' >> cantera.conf
IF "%BUILD_MATLAB%"=="Y" (
ECHO matlab_toolbox='y' >> cantera.conf
ECHO matlab_path='%MW_HEADERS_DIR%' >> cantera.conf
) ELSE (
ECHO matlab_toolbox='n' >> cantera.conf
)
ECHO debug='n' >> cantera.conf
ECHO f90_interface='n' >> cantera.conf
ECHO system_sundials='n' >> cantera.conf
ECHO python_package='full' >> cantera.conf

SET "ESC_BOOST=%BOOST_ROOT_1_72_0:\=/%"
ECHO boost_inc_dir="%ESC_BOOST%" >> cantera.conf

CALL scons build -j%CPU_USE% VERBOSE=y
IF %ERRORLEVEL% 1 EXIT 1
CALL scons msi
IF %ERRORLEVEL% 1 EXIT 1

dir

IF "%BUILD_ARCH%"=="x64" (
   move Cantera-%CT_VERSION%.win-amd64-py%PY_VER%.msi Cantera-Python-%CT_VERSION%-x64-py%PY_VER%.msi
) ELSE (
   move Cantera-%CT_VERSION%.win32-py%PY_VER%.msi Cantera-Python-%CT_VERSION%-x86-py%PY_VER%.msi
)

if "%BUILD_MATLAB%"=="Y" (
move cantera.msi "Cantera-%CT_VERSION%-%BUILD_ARCH%.msi"
) ELSE (
:: Only want cantera.msi from the build that includes the Matlab toolbox
del cantera.msi
)
