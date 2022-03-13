:: Set the number of CPUs to use in building
SET CPU_USE=2

cd cantera

IF %BUILD_ARCH% EQU "x64" (
	CALL "%VS142COMNTOOLS%"\..\..\VC\bin\amd64\vcvars64.bat
) ELSE (
	CALL "%VS142COMNTOOLS%"\..\..\VC\bin\vcvars32.bat
)

:: Have to use CALL to prevent the script from exiting after calling SCons
CALL scons clean

:: Put important settings into cantera.conf for the build. Use VS 2019 to
:: compile the interface.
ECHO msvc_version='14.2' >> cantera.conf
SET "ESC_MATLAB=%MW_HEADERS_DIR:\=/%"
ECHO %ESC_MATLAB%
ECHO matlab_toolbox='y' >> cantera.conf
ECHO matlab_path="%ESC_MATLAB%" >> cantera.conf
ECHO debug='n' >> cantera.conf
ECHO f90_interface='n' >> cantera.conf
ECHO system_sundials='n' >> cantera.conf
ECHO python_package='none' >> cantera.conf

SET "ESC_BOOST=%BOOST_ROOT_1_72_0:\=/%"
ECHO boost_inc_dir="%ESC_BOOST%" >> cantera.conf

CALL scons build -j%CPU_USE% VERBOSE=y
IF ERRORLEVEL 1 EXIT 1
CALL scons msi
IF ERRORLEVEL 1 EXIT 1

dir

move cantera.msi "Cantera-%BUILD_ARCH%.msi"
IF ERRORLEVEL 1 EXIT 1
