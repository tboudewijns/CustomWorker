echo commands %1 %2 %3 %4 > C:\PTC\custom_workers\AutoCADWorker\pdfworker_test.txt
set PATH=e:\ptc\windchill_9.1\java\bin;%PATH%
copy %1 C:\PTC\custom_workers\AutoCADWorker\temp\

#cleanup
del /F /Q C:\PTC\custom_workers\AutoCADWorker\temp\pdffailed
del /F /Q C:\PTC\custom_workers\AutoCADWorker\temp\timerstart
del /F /Q C:\PTC\custom_workers\AutoCADWorker\temp\timerstarted
del /F /Q C:\PTC\custom_workers\AutoCADWorker\temp\timerstop
del /F /Q C:\PTC\custom_workers\AutoCADWorker\temp\timerstopped

rem 64 bit command
rem start C:\PTC\custom_workers\AutoCADWorker\starttimer.bat
rem call C:\Perl64\bin\perl.exe D:\PTC\custom_workers\AutoCADWorker\CallPDFcreator.pl %1

rem 32bit command
start C:\PTC\custom_workers\AutoCADWorker\starttimer.bat
call C:\PTC\ActivePerl-5.8.6.811\Perl\bin\perl.exe C:\PTC\custom_workers\AutoCADWorker\CallPDFcreator.pl %1



