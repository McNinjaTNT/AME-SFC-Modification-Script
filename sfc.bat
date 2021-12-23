@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:: This script is to prevent users from unknowingly entering sfc /scannow
:: and causing de-amelioration

CMD /c "exit /b 0"
NET session > NUL 2>&1
IF %ERRORLEVEL% GTR 0 (
	
	ECHO.
	ECHO You must be an administrator running a console session in order to
	ECHO use the sfc utility.
		
	GOTO :EOF

) ELSE (
	GOTO checkScannow
)

:checkScannow
	
	CMD /c "exit /b 0"
	SET checkString=/scannow
	ECHO "%*" | FIND /i "%checkString%" > NUL 2>&1
	IF %ERRORLEVEL% EQU 0 (
		
		ECHO.
		ECHO This command will cause de-amelioration^^! DO NOT RUN
		ECHO Are you sure you want to run this command?
		ECHO.
		ECHO Enter "Cancel" to Exit
		
		SET /p input=Enter "I know what I'm doing" to Confirm: 

			IF "!input!"=="I know what I'm doing" GOTO scannowProcedure+SelfDestruction
			IF "!input!"=="Cancel" GOTO :EOF
		
			ECHO.
			ECHO Incorrect Input Entered.
			
			GOTO :EOF

	) ELSE (
		GOTO verifyOnlyProcedure
	)

:verifyOnlyProcedure

	SET checkString=/verifyonly
	IF /i "%*"=="%checkString%" (

		ECHO.
		ECHO Beginning system scan.  This process will take some time.
		TIMEOUT /T 1 /NOBREAK > NUL 2>&1
		ECHO.
		ECHO Beginning verification phase of system scan.
		TIMEOUT /T 2 /NOBREAK > NUL 2>&1
		ECHO Verifying...
		
		:: %* is all the text entered after "sfc ".
		sfc1 %*

		ECHO Windows Resource Protection found integrity violations.
		ECHO For online repairs, details are included in the CBS log file located at
		ECHO windir^\Logs^\CBS^\CBS.log. For example C^:^\Windows^\Logs^\CBS^\CBS.log. For offline
		ECHO repairs, details are included in the log file provided by the ^/OFFLOGFILE flag.

		GOTO :EOF

	) ELSE (
		GOTO incorrectSyntaxMessage
	)

:incorrectSyntaxMessage
	
	CMD /c "exit /b 0"
	sfc1 %*
	IF %ERRORLEVEL% GTR 0 (

		ECHO.
		ECHO System File Checker
		ECHO.
		ECHO Scans the integrity of all protected system files and replaces incorrect versions with
		ECHO correct Microsoft versions.
		ECHO.
		ECHO SFC ^[^/SCANNOW^] ^[^/VERIFYONLY^] ^[^/SCANFILE^=^<file^>^] ^[^/VERIFYFILE^=^<file^>]
		ECHO     ^[^/OFFWINDIR^=^<offline windows directory^> ^/OFFBOOTDIR^=^<offline boot directory^> ^[^/OFFLOGFILE^=^<log file path^>^]^]
		ECHO. 
		ECHO ^/SCANNOW        Scans integrity of all protected system files and repairs files with
		ECHO                 problems when possible.
		ECHO ^/VERIFYONLY     Scans integrity of all protected system files. No repair operation is
		ECHO                 performed.
		ECHO ^/SCANFILE       Scans integrity of the referenced file, repairs file if problems are
		ECHO                 identified. Specify full path ^<file^>
		ECHO ^/VERIFYFILE     Verifies the integrity of the file with full path ^<file^>.  No repair
		ECHO                 operation is performed.
		ECHO ^/OFFBOOTDIR     For offline repair, specify the location of the offline boot directory
		ECHO ^/OFFWINDIR      For offline repair, specify the location of the offline windows directory
		ECHO ^/OFFLOGFILE     For offline repair, optionally enable logging by specifying a log file path
		ECHO. 
		ECHO e.g.
		ECHO. 
		ECHO         sfc ^/SCANNOW
		ECHO         sfc ^/VERIFYFILE^=c^:^\windows^\system32^\kernel32.dll
		ECHO         sfc ^/SCANFILE^=d^:^\windows^\system32^\kernel32.dll ^/OFFBOOTDIR^=d^:^\ ^/OFFWINDIR^=d^:^\windows
		ECHO         sfc ^/SCANFILE^=d^:^\windows^\system32^\kernel32.dll ^/OFFBOOTDIR^=d^:^\ ^/OFFWINDIR^=d^:^\windows ^/OFFLOGFILE^=c^:^\log.txt
		ECHO         sfc ^/VERIFYONLY

		GOTO :EOF

	) ELSE (
	GOTO grabCBSInfo
	)

:grabCBSInfo
	


	SET count=1
	FOR /F "tokens=2 delims=]" %%a IN ('powershell -command "Get-Content '%SYSTEMROOT%\Logs\CBS\CBS.log' -tail 3"') DO (
		SET var!count!=%%a
		SET /a count=!count!+1
	)
	GOTO noViolationProcedure

:noViolationProcedure

	SET checkString=Beginning
	ECHO %var2% | FIND /i "%checkString%" > NUL 2>&1
	IF %ERRORLEVEL% EQU 0 (
	
		ECHO Windows Resource Protection did not find any integrity violations.

		GOTO :EOF

	) ELSE (
	GOTO foundViolationProcedure
	)

:foundViolationProcedure
	
CMD /c "exit /b 0"
	SET checkString=reproject
	ECHO %var1% | FIND /i "%checkString%" > NUL 2>&1
	IF %ERRORLEVEL% EQU 0 (

		ECHO Windows Resource Protection found integrity violations.
		ECHO For online repairs, details are included in the CBS log file located at
        	ECHO windir^\Logs^\CBS\CBS.log. For example C^:^\Windows^\Logs^\CBS^\CBS.log. For offline
		ECHO repairs, details are included in the log file provided by the ^/OFFLOGFILE flag.

		GOTO :EOF
		
		) ELSE (
		:: This will most likely never happen
		GOTO :unknownResults
		)

:unknownResults

ECHO Cannot output results. See %HOMEDRIVE%\Windows^\Logs^\CBS^\CBS.log for more details.

GOTO :EOF

:scannowProcedure+SelfDestruction
:: This will cause sfc.bat to no longer function, unless sfc.bat is specified.
:: This is due to the .exe extension being prioritized over .bat. The PATHEXT environment variable can change this.
TAKEOWN /f %SYSTEMROOT%\System32\sfc1.exe /a > NUL 2>&1
ICACLS %SYSTEMROOT%\System32\sfc1.exe /grant Administrators:F > NUL 2>&1
REN %SYSTEMROOT%\System32\sfc1.exe sfc.exe > NUL 2>&1

:: Copy ACL from diskmgmt.msc to sfc.exe. Essentially resetting sfc.exe's ACL.
POWERSHELL -command "Get-Acl %SYSTEMROOT%\System32\diskmgmt.msc | Set-Acl %SYSTEMROOT%\System32\sfc.exe" > NUL 2>&1
sfc %*

:: Self-destruction
TAKEOWN /f %SYSTEMROOT%\System32\sfc.bat /a > NUL 2>&1
ICACLS %SYSTEMROOT%\System32\sfc.bat /grant Administrators:F > NUL 2>&1
(GOTO) 2>NUL & del "%~f0" > NUL 2>&1
