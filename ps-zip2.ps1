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