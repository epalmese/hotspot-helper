@echo off

:top
cls
echo Welcome, select an option (enter a number):
for /f "tokens=4-5 delims=. " %%a in ('ver') do set os=%%a.%%b
set old=(!) - Antiquated OS detected. Only Windows 7 and later support hosted network.
if %os%==6.0 echo %old%
for /f "tokens=1 delims=." %%a in ('echo %os%') do set os=%%a
if %os% GEQ 10 echo (!) - Windows 10 or later detected, try the new Mobile Hotspot feature first.
if %os% LSS 6 echo %old%
net session >NUL 2>&1
if NOT %errorLevel%==0 echo (!) - Run this script as an administrator to setup hosted network.
echo(
echo [1] Configure Hotspot
echo [2] Turn On Hotspot
echo [3] Turn Off Hotspot
echo [4] Help
echo(
echo [0] Exit
set /p op=
if %op%==1 goto config
if %op%==2 goto on
if %op%==3 goto off
if %op%==4 goto help
if %op%==0 exit
echo Not an option, please choose from the above list.
pause
goto top

:config
netsh wlan stop hostednetwork >NUL
echo Enter the SSID (name) for the hotspot
set /p getname=
echo Enter the password for the hotspot (8 character minimum)
set /p getpass=
echo Always start hotspot manually [1] or launch automatically [2] at startup?
set /p persist=
netsh wlan set hostednetwork mode=allow ssid="%getname%" key="%getpass%"
netsh wlan start hostednetwork
netsh wlan show hostednetwork setting=security
if "%persist%"=="2" (
	echo netsh wlan start hostednetwork > "%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\launch_hotspot.cmd"
	echo Hotspot will launch at startup.
)
if NOT "%persist%"=="2" (
	del /f /q "%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\launch_hotspot.cmd" >NUL
	echo Hotspot will not launch at startup.
)
pause
cls
echo (!) - IF THIS IS YOUR FIRST SETUP:
echo You will need to share your working connection with the new "hotspot" network.
echo - Open 'Control Panel' to 'Network and Internet' to 'Network and Sharing Center' to 'Change adapter settings'.
echo - Select your working internet connection and open the 'Properties'.
echo - Go to the 'Sharing' tab and check 'Internet Connection Sharing' on.
echo - Select the adapter from the drop-down list with the network name you chose.
echo - Click OK. You should now be able to use your new network like any other.
pause
goto top

:on
netsh wlan start hostednetwork
pause
goto top

:off
netsh wlan stop hostednetwork
pause
goto top

:help
cls
echo If you ran this as an administrator and it did not work, try the following:
echo [1] Check Compatibility
echo(
echo [0] Return to Menu
set /p op=
if %op%==1 goto comp
if %op%==0 goto top

:comp
cls
echo Checking drivers...
netsh wlan show drivers | find /i "Hosted network supported"
for /f "tokens=5" %%c in ('netsh wlan show drivers ^| find /i "Hosted network supported"') do set hns=%%c
if %hns%==Yes echo You should be able to host a network from this computer.
if NOT %hns%==Yes echo You can not host a network from this computer. Try updating your drivers.
pause
goto help
