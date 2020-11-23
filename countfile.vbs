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