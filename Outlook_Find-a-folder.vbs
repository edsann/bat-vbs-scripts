' Find a Folder by its Name
' http://www.vboffice.net/en/developers/find-folder-by-name/?mnu=2&cmd=showitem

' Some people have so many folders that they've got problems to find them. And with a deep hierarchy of folders it can also be a pain to click through all of them in order to activate a certain folder.

' This example finds a folder by its name, and you can choose to get the found folder activated.
' You can either enter the full name, or use wildcards. '*' and '%' are allowed as wildcards.
' Upper/lower cases will be ignored.
' See the constant SpeedUp in the head of the module: The default setting of True means the search will be somewhat faster, however, Outlook will be blocked during the search.
' If the search takes too long due to a great many folders, you can set the value to False.
' Set the constant StopAtFirstMatch to False if the search should not stop with the first match.

' Copy the code into the module 'ThisOutlookSession'. For instance, it can be started by pressing alt+f8.

Private m_Folder As Outlook.MAPIFolder
Private m_Find As String
Private m_Wildcard As Boolean

Private Const SpeedUp As Boolean = True
Private Const StopAtFirstMatch As Boolean = True

Public Sub FindFolder()
  Dim Name$
  Dim Folders As Outlook.Folders

  Set m_Folder = Nothing
  m_Find = ""
  m_Wildcard = False

  Name = InputBox("Find name:", "Search folder")
  If Len(Trim$(Name)) = 0 Then Exit Sub
  m_Find = Name

  m_Find = LCase$(m_Find)
  m_Find = Replace(m_Find, "%", "*")
  m_Wildcard = (InStr(m_Find, "*"))

  Set Folders = Application.Session.Folders
  LoopFolders Folders

  If Not m_Folder Is Nothing Then
    If MsgBox("Activate folder: " & vbCrLf & m_Folder.FolderPath, vbQuestion Or vbYesNo) = vbYes Then
      Set Application.ActiveExplorer.CurrentFolder = m_Folder
    End If
  Else
    MsgBox "Not found", vbInformation
  End If
End Sub

Private Sub LoopFolders(Folders As Outlook.Folders)
  Dim F As Outlook.MAPIFolder
  Dim Found As Boolean
  
  If SpeedUp = False Then DoEvents

  For Each F In Folders
    If m_Wildcard Then
      Found = (LCase$(F.Name) Like m_Find)
    Else
      Found = (LCase$(F.Name) = m_Find)
    End If

    If Found Then
      If StopAtFirstMatch = False Then
        If MsgBox("Found: " & vbCrLf & F.FolderPath & vbCrLf & vbCrLf & "Continue?", vbQuestion Or vbYesNo) = vbYes Then
          Found = False
        End If
      End If
    End If
    If Found Then
      Set m_Folder = F
      Exit For
    Else
      LoopFolders F.Folders
      If Not m_Folder Is Nothing Then Exit For
    End If
  Next
End Sub
