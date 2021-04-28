@echo off

set domain=
set broker_ip=
set xml_location=
set tags_location=
set smb_report=
set share_report=
set logs_file=
set login_list=


Powershell.exe -executionpolicy remotesigned -File  ADscript.ps1 -server %domain% -hostip %broker_ip%
PingCastle.exe --healthcheck --server %domain%
PingCastle.exe --scanner smb --server %domain%
PingCastle.exe --scanner share --server %domain%

python XMLparser.py %xml_location% %tags_location% %broker_ip% %domain% 
python SMBParser.py %smb_report% %broker_ip% %domain% 
python shareCounter.py %share_report% %broker_ip% %domain% 
rem python userCounter.py %logs_file% %login_list% %broker_ip% %domain%
