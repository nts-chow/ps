@echo off
echo %time%
::压缩整个文件夹到NAS服务器
robocopy   C:\tes\bk\z20201123090852001.zip   \\192.168.100.102\Amor1T\tmp /e /mt:128 /log+:robocopy.log

::压缩单个文件到NAS服务器
echo deploy index.html to 192.168.100.102
net use \\192.168.100.102ipc$ "123456!@#" /user:"Administrator"
echo begin copy

xcopy C:\tes\copy.cmd \\192.168.100.102\Amor1T\tmp /c /e /r /y

echo copy end
net use \\100.2.93.12 /del
pause
echo %time%