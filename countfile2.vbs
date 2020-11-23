Set ObjWS = WScript.CreateObject("wscript.shell")
currentDir=ObjWS.CurrentDirectory
Set ObjFSO = CreateObject("Scripting.FileSystemObject") 

Dim filesTree
filesTree = "." & vbCrLf

Call SearchFolder(currentDir)
Msgbox filesTree


Sub FilesInFolder(folderPath)
	Set ObjFolder=objFSO.GetFolder(folderPath)
	Set files=ObjFolder.files
	For Each file In files
		filesTree = filesTree & "-" & file.name & vbCrLf
	Next
End Sub

Sub SearchFolder(folderPath)
	Set ObjFolder=objFSO.GetFolder(folderPath)
	Set SubFolders=ObjFolder.SubFolders
	
	FilesInFolder(folderPath)
	
	if SubFolders.Count =0 then
		'msgbox "exit search:" & folderPath
		exit Sub
	end if
	
	For Each subFolder In SubFolders
		'MsgBox subFolder.path
		filesTree = filesTree & subFolder.path & vbCrLf
		SearchFolder(subFolder.path)
	Next

End Sub
