$Source="C:\tes\tk" #文件所在的文件夹

#加载依赖
[System.Reflection.Assembly]::Load("WindowsBase,Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")

$partCnt=1
[long]$BreakSize=0

#最终输出的Zip文件，以时间动态生成
$destZip = "C:\tes\bk\z" + (Get-Date).ToString('yyyyMMddhhmmss') +$partCnt.ToString("000") +".zip"
#删除已有的压缩包
if (Test-Path($destZip))
{
	Remove-Item $destZip
}

#打开压缩包
$ZipPackage=[System.IO.Packaging.ZipPackage]::Open($destZip,[System.IO.FileMode]"OpenOrCreate", [System.IO.FileAccess]"ReadWrite")

$files = Get-ChildItem -path $Source -Recurse | ForEach-Object -Process{
#Get-ChildItem -path $Source -Recurse | ForEach-Object -Process{
    if($_-is[System.IO.FileInfo]){
        $BreakSize+=$_.Length
        if($BreakSize/1024/1024/1024/2 -ge 1){
            $BreakSize = 0
            $partCnt += 1
            ####xml File delete Start####
            
            ####xml File delete End #####
            $ZipPackage.close()
            #最终输出的Zip文件，以时间动态生成。
            $destZip = "C:\tes\bk\z" + (Get-Date).ToString('yyyyMMddhhmmss')+$partCnt.ToString("000") + ".zip" 
            if (Test-Path($destZip))
            {
	            Remove-Item $destZip
            }
            #打开压缩包
            $ZipPackage=[System.IO.Packaging.ZipPackage]::Open($destZip,[System.IO.FileMode]"OpenOrCreate", [System.IO.FileAccess]"ReadWrite")
        }
        $UriPath=$_.FullName.Replace("C:","").Replace("\","/")
        #$UriPath=$_.FullName.Replace("\","/").Replace("C:/tes/tk","")
        echo $UriPath
        $partName=New-Object System.Uri($UriPath, [System.UriKind]"Relative")
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
