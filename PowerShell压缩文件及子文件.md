**PowerShell压缩文件及子文件**

把多个文件以及文件夹下的子文件打包成zip的PowerShell脚本，并且每压缩个文件并且保持20MB左右，无需第三方程序（如WinRAR）或类库，来跟大家分享下。其实.Net本身就自带了Zip压缩的类库，只是由于不怎么常用，默认没加载。只要添加引用WindowsBase.dll就行了。
.Net Framework需要3.0或以上，我在Windows Server 2020 R2.Net Framework 3.5+PowerShell 2.0下测试通过。
以下是PowerShell脚本：

```powershell
$Source="D:\tes\tk" #文件所在的文件夹

#加载依赖
[System.Reflection.Assembly]::Load("WindowsBase,Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")

$partCnt=1
[long]$BreakSize=0

#最终输出的Zip文件，以时间动态生成
$destZip = "D:\tes\bk\z" + (Get-Date).ToString('yyyyMMddhhmmss') +$partCnt.ToString("000") +".zip" 。
#删除已有的压缩包
if (Test-Path($destZip))
{
	Remove-Item $destZip
}

#打开压缩包
$ZipPackage=[System.IO.Packaging.ZipPackage]::Open($destZip,[System.IO.FileMode]"OpenOrCreate", [System.IO.FileAccess]"ReadWrite")

$files = Get-ChildItem -path $Source -Recurse | ForEach-Object -Process{
    if($_-is[System.IO.FileInfo]){
        $BreakSize+=$_.Length
        if($BreakSize/1024/1024/20 -ge 1){
            $BreakSize = 0
            $partCnt += 1
            ####xml File delete Start####
            
            ####xml File delete End #####
            $ZipPackage.close()
            #最终输出的Zip文件，以时间动态生成。
            $destZip = "D:\tes\bk\z" + (Get-Date).ToString('yyyyMMddhhmmss')+$partCnt.ToString("000") + ".zip" 
            if (Test-Path($destZip))
            {
	            Remove-Item $destZip
            }
            #打开压缩包
            $ZipPackage=[System.IO.Packaging.ZipPackage]::Open($destZip,[System.IO.FileMode]"OpenOrCreate", [System.IO.FileAccess]"ReadWrite")
        }

        #为了获取相对路劲，此处先截取想要的路径。根据个人电脑路径不一致，多调试
        #调试不好会提示CategoryInfo  : NotSpecified: (:) [], MethodInvocationException错误
        $UriPath=$_.FullName.Replace("\","/").Replace("D:/tes/tk","")
        #此处打开的文件名字最好是英文或者数字，有其他符号会报错
        $partName=New-Object System.Uri($UriPath, [System.UriKind]"Relative")
        #加入文件到压缩包,有很多种模式比如： NotCompressed， Normal， Fast 
        #NotCompressed是表示不压缩的压缩，压缩率是0，压缩速度将会最大大概45s/GB
        #Normal 压缩率5% 速度130s/GB
        #Fast  压缩率4.5% 速度100s/GB
        $pkgPart=$ZipPackage.CreatePart($partName, "application/zip",[System.IO.Packaging.CompressionOption]::NotCompressed)
        $bytes=[System.IO.File]::ReadAllBytes($_.FullName)
	    $stream=$pkgPart.GetStream()
	    $stream.Write($bytes, 0, $bytes.Length)
	    $stream.Close()
        #删除文件
        #Remove-Item $file.FullName
    }
}

$ZipPackage.close()
```

**压缩一个文件夹下的文件,并且删除压缩前文件，无需第三方程序（如WinRAR）或类库**

```powershell
$EmlPath="C:\tes\bk" #文件所在的文件夹
$partCnt=1
[long]$BreakSize=0
 $ZipPath="C:\tes\bks\bk" + (Get-Date).ToString('yyyy-MM-dd hh-mm-ss') + $partCnt.ToString("000") + ".zip" #最终输出的Zip文件，以时间动态生成。

#加载依赖
[System.Reflection.Assembly]::Load("WindowsBase,Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")

#删除已有的压缩包
if (Test-Path($ZipPath))
{
	Remove-Item $ZipPath
}

#获取文件集合
$Di=New-Object System.IO.DirectoryInfo($EmlPath);
$files = $Di.GetFiles()
if($files.Count -eq 0)
{
	exit
}

#打开压缩包
$pkg=[System.IO.Packaging.ZipPackage]::Open($ZipPath,[System.IO.FileMode]"OpenOrCreate", [System.IO.FileAccess]"ReadWrite")

#加入文件到压缩包
ForEach ($file In $files)
{
    if($file-is[System.IO.FileInfo]){
        $BreakSize+=$file.Length
        if($BreakSize/1024/1024/1024/3 -ge 1){
            $BreakSize = 0
            $partCnt += 1
            ####xml File delete Start####
            
            ####xml File delete End #####
            $pkg.close()
            #最终输出的Zip文件，以时间动态生成。
            $ZipPath="C:\tes\bks\bk" + (Get-Date).ToString('yyyy-MM-dd hh-mm-ss') + $partCnt.ToString("000") + ".zip" #最终输出的Zip文件，以时间动态生成。
            if (Test-Path($destZip))
            {
	            Remove-Item $destZip
            }
            #打开压缩包
            $pkg=[System.IO.Packaging.ZipPackage]::Open($ZipPath,[System.IO.FileMode]"OpenOrCreate", [System.IO.FileAccess]"ReadWrite")
        }
    }

	$uriString="/" +$file.Name
    echo $uriString
	$partName=New-Object System.Uri($uriString, [System.UriKind]"Relative")
	$pkgPart=$pkg.CreatePart($partName, "application/zip",[System.IO.Packaging.CompressionOption]"NotCompressed")
	$bytes=[System.IO.File]::ReadAllBytes($file.FullName)
	$stream=$pkgPart.GetStream()
	$stream.Write($bytes, 0, $bytes.Length)
	$stream.Close()
  Remove-Item $file.FullName
}

#关闭压缩包
$pkg.Close()
```

vbs打印压缩完成之后的文件名字到txt文件

```vbscript
Option Explicit
Dim ObjWsShell
DIm ObjFSO
Dim currentDir
Dim ObjFolder
Dim SubFolders
Dim txt
Dim fso
Dim files
Dim filesTree
Dim file

Set ObjWsShell = WScript.CreateObject("wscript.shell")
currentDir=ObjWsShell.CurrentDirectory
Set ObjFSO = CreateObject("Scripting.FileSystemObject") 

filesTree = "." & vbCrLf
Call FilesInFolder(currentDir)
Msgbox filesTree

set fso = createobject("scripting.filesystemobject")     
if  Not fso.FileExists(".\countfile.txt") then
	fso.createTextFile ".\countfile.txt"
end if

set txt = fso.opentextfile(".\countfile.txt",8)       
txt.writeLine now & chr(9) & currentDir
txt.writeLine filesTree                      
txt.writeLine now    
txt.close                                  

Sub FilesInFolder(folderPath)
	Set ObjFolder=objFSO.GetFolder(folderPath)
	Set files=ObjFolder.files
	For Each file In files
		filesTree = filesTree & "-" & file.name & vbCrLf
	Next
End Sub

set ObjFSO=Nothing
set currentDir=Nothing
set fso=Nothing
```

**通过CMD把压缩文件发送到某服务器后者是把文件夹发送到某服务器，保持属性不变**

```bash
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
```

