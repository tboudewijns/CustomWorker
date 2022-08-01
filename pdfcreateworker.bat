rem @echo off
set PATH=C:\Program Files\Java\jre1.8.0_321\bin;%PATH%
set CLASSPATH=C:\PTC\custom_workers\AutoCADWorker\codebase\wvs.jar
set GENERIC_INSTALL=C:\PTC\custom_workers\AutoCADWorker
set PORT="5600"
set HOST="icenterv01"
set DEBUG="-D"
set TYPE="AUTOCAD"
set CMD="%GENERIC_INSTALL%\doc2pdf.bat"
set DIR="C:\PTC\custom_workers\AutoCADWorker"
set LOG="log"
C:
cd \ptc\custom_workers\AutoCADWorker
java com.ptc.wvs.server.cadagent.GenericWorker %DEBUG% -PORT %PORT% -HOST %HOST% -TYPE %TYPE% -CMD %CMD% -DIR %DIR% -LOG %LOG%
