@ECHO OFF

NET session > NUL 2>&1
IF %ERRORLEVEL% LSS 1 (
GOTO menu
) ELSE (

ECHO.
ECHO  :: WINDOWS 10 AME SFC Modification Deployment Script
ECHO.
ECHO     You must run this script as Administrator
ECHO.
ECHO  :: Press any key to exit...

PAUSE > NUL 2>&1
GOTO :EOF
)

:menu

	ECHO.
	ECHO  :: WINDOWS 10 AME Modification Deployment Script Version 2021.12.23
	ECHO.
	ECHO     This script deploys sfc.bat, renames sfc.exe, and modifies permissions for both
	ECHO.
	ECHO  :: Press any key to continue...
	
	PAUSE > NUL 2>&1
	:: It Arrived! BatChest
	GOTO sfcBatCheck

:sfcBatCheck

	IF EXIST "%SYSTEMROOT%\System32\sfc.bat" (
		TAKEOWN /f %SYSTEMROOT%\System32\sfc.bat /a > NUL 2>&1
		ICACLS %SYSTEMROOT%\System32\sfc.bat /grant Administrators:F > NUL 2>&1
		DEL %SYSTEMROOT%\System32\sfc.bat
		GOTO download

		) ELSE (
		GOTO download
		)

:download

	cls
	ECHO  :: WINDOWS 10 AME Modification Deployment Script
	ECHO.
	ECHO.
	ECHO.
	ECHO  :: Downloading...

	CURL -L https://github.com/McNinjaTNT/AME-SFC-Modification-Script/releases/download/v1.1/sfc.bat --output %SYSTEMROOT%\System32\sfc.bat > NUL 2>&1
	IF %ERRORLEVEL% EQU 0 (
		
		GOTO sfc1ExeCheck

	) ELSE (
		
		cls
		ECHO  :: WINDOWS 10 AME Modification Deployment Script
		ECHO.
		ECHO.	 A failure occured while attempting to download the script.
		ECHO.
		ECHO  :: Press any key to exit...
		
		PAUSE > NUL 2>&1
		GOTO :EOF
	)

:sfc1ExeCheck

	IF EXIST "%SYSTEMROOT%\System32\sfc1.exe" (

		cls
		ECHO  :: WINDOWS 10 AME Modification Deployment Script
		ECHO.
		ECHO.
		ECHO.
		ECHO  :: sfc1.exe Already Exists, Assigning Permissions...

		POWERSHELL -command "Get-Acl c:\Windows\System32\diskmgmt.msc | Set-Acl c:\Windows\System32\sfc1.exe" > NUL 2>&1
		POWERSHELL -command "Get-Acl %SYSTEMROOT%\System32\diskmgmt.msc | Set-Acl %SYSTEMROOT%\System32\sfc.bat" > NUL 2>&1
		GOTO complete
		) ELSE (
		GOTO managePermissions
		)

:managePermissions

	cls
	ECHO  :: WINDOWS 10 AME Modification Deployment Script
	ECHO.
	ECHO.
	ECHO.
	ECHO  :: Assigning Permissions and Renaming sfc.exe...

	:: Copies the ACL from diskmgmt.msc to sfc.bat.
	POWERSHELL -command "Get-Acl %SYSTEMROOT%\System32\diskmgmt.msc | Set-Acl %SYSTEMROOT%\System32\sfc.bat" > NUL 2>&1

	:: Gives the Administrator group full access for renaming sfc.exe to sfc1.exe.
	TAKEOWN /f %SYSTEMROOT%\System32\sfc.exe /a > NUL 2>&1
	ICACLS %SYSTEMROOT%\System32\sfc.exe /grant Administrators:F > NUL 2>&1
	GOTO renamesfcExe

:renamesfcExe

	REN %SYSTEMROOT%\System32\sfc.exe sfc1.exe > NUL 2>&1
	:: Copies the ACL from diskmgmt.msc to sfc1.exe. Essentially resetting its ACL.
	POWERSHELL -command "Get-Acl c:\Windows\System32\diskmgmt.msc | Set-Acl c:\Windows\System32\sfc1.exe" > NUL 2>&1
	GOTO complete

:complete

	cls
	ECHO  :: WINDOWS 10 AME Modification Deployment Script
	ECHO.
	ECHO.	 Deployment is complete^!
	ECHO.
	ECHO  :: Press any key to exit...
	
	PAUSE > NUL 2>&1
	GOTO :EOF
