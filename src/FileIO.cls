VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "FileIO"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------------------------------------------
'
' [Hecatoncheir] v1
'
' Copyright (c) 2019 Yasuhiro Watanabe
' https://github.com/RelaxTools/Hecatoncheir
' author:relaxtools@opensquare.net
'
' The MIT License (MIT)
'
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
'
' The above copyright notice and this permission notice shall be included in all
' copies or substantial portions of the Software.
'
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
' SOFTWARE.
'
'-----------------------------------------------------------------------------------------------------
' ���̃N���X�� Static�N���X(Attribute VB_PredeclaredId = True) �ł��B
'-----------------------------------------------------------------------------------------------------
' �ˑ����W���[��
'   Lang.bas
'   Registry.bas
'-----------------------------------------------------------------------------------------------------
' 2018-12-16 Ver.1.0.0 �V�K�쐬 CreateObject���Ȃ��Ă��g����FileSystemObject
'-----------------------------------------------------------------------------------------------------
Option Explicit

Private Declare PtrSafe Function FindFirstFileExW Lib "kernel32" (ByVal lpFileName As LongPtr, ByVal fInfoLevelId As Long, ByRef lpFindFileData As WIN32_FIND_DATA, ByVal fSearchOp As Long, ByVal lpSearchFilter As LongPtr, ByVal dwAdditionalFlags As Long) As LongPtr
Private Declare PtrSafe Function FindFirstFileW Lib "kernel32" (ByVal lpFileName As LongPtr, lpFindFileData As WIN32_FIND_DATA) As LongPtr
Private Declare PtrSafe Function FindNextFileW Lib "kernel32" (ByVal hFindFile As LongPtr, lpFindFileData As WIN32_FIND_DATA) As LongPtr
Private Declare PtrSafe Function FindClose Lib "kernel32" (ByVal hFindFile As LongPtr) As LongPtr
Private Declare PtrSafe Function CreateFileW Lib "kernel32" (ByVal lpFileName As LongPtr, ByVal dwDesiredAccess As Long, ByVal dwShareMode As Long, ByVal lpSecurityAttributes As LongPtr, ByVal dwCreationDisposition As Long, ByVal dwFlagsAndAttributes As Long, ByVal hTemplateFile As LongPtr) As LongPtr
Private Declare PtrSafe Function CloseHandle Lib "kernel32" (ByVal hObject As LongPtr) As Long
Private Declare PtrSafe Function LocalFileTimeToFileTime Lib "kernel32" (lpLocalFileTime As FILETIME, lpFileTime As FILETIME) As Long
Private Declare PtrSafe Function SystemTimeToFileTime Lib "kernel32" (lpSystemTime As SystemTime, lpFileTime As FILETIME) As Long
Private Declare PtrSafe Function SetFileTime Lib "kernel32" (ByVal hFile As LongPtr, lpCreationTime As FILETIME, lpLastAccessTime As FILETIME, lpLastWriteTime As FILETIME) As Long
Private Declare PtrSafe Function WNetGetConnectionW Lib "mpr" (ByVal lpszLocalName As LongPtr, ByVal lpszRemoteName As LongPtr, lSize As Long) As Long
Private Declare PtrSafe Function SearchTreeForFileW Lib "dbghelp" (ByVal RootPath As LongPtr, ByVal InputPathName As LongPtr, ByVal OutputPathBuffer As LongPtr) As Long
Private Declare PtrSafe Function StrCmpLogicalW Lib "Shlwapi" (ByVal psz1 As LongPtr, ByVal psz2 As LongPtr) As Long

Private Const MAX_PATH                  As Long = 260 * 2 - 1   '�p�X�̍ő咷
Private Const MAX_PATH_SHORT            As Long = 14 * 2 - 1    '�p�X�̍ő咷

Private Const INVALID_HANDLE_VALUE          As Long = (-1)              '������File Handle�l
Private Const FILE_ATTRIBUTE_HIDDEN         As Long = &H2
Private Const FILE_ATTRIBUTE_SYSTEM         As Long = &H4
Private Const FILE_ATTRIBUTE_DIRECTORY      As Long = &H10               '�t�H���_
Private Const GENERIC_READ                  As Long = &H80000000
Private Const GENERIC_WRITE                 As Long = &H40000000
Private Const FILE_SHARE_READ               As Long = &H1
Private Const FILE_ATTRIBUTE_NORMAL         As Long = &H80
Private Const OPEN_EXISTING                 As Long = 3
Private Const FILE_FLAG_BACKUP_SEMANTICS    As Long = &H2000000

Private Const FindExInfoStandard As Long = 0&
Private Const FindExInfoBasic As Long = 1&              'Win7�ȍ~
Private Const FindExSearchNameMatch As Long = 0
Private Const FindExSearchLimitToDirectories = 1&
Private Const FIND_FIRST_EX_LARGE_FETCH As Long = 2&    'Win7�ȍ~

Private FSO As Object

' FileTime �\����
Private Type FILETIME
    LowDateTime     As Long
    HighDateTime    As Long
End Type

'WIN32_FIND_DATA�\����(�f�B���N�g���G���g��(�t�@�C�����))
Private Type WIN32_FIND_DATA
    dwFileAttributes            As Long             '�t�@�C������
    ftCreationTime              As FILETIME         '�쐬����
    ftLastAccessTime            As FILETIME         '�ŏI�A�N�Z�X����
    ftLastWriteTime             As FILETIME         '�ŏI�X�V����
    nFileSizeHigh               As Long             '�t�@�C���T�C�Y�̏��32bit�l
    nFileSizeLow                As Long             '�t�@�C���T�C�Y�̉���32bit�l
    dwReserved0                 As Long             '�\��(����Ȃ�)
    dwReserved1                 As Long             '�\��(����Ȃ�)
    cFileName(MAX_PATH)         As Byte             '�����O�t�@�C����
    cAlternate(MAX_PATH_SHORT)  As Byte             '�V���[�g�t�@�C����(8+3����)
    dwFileType                  As Long
    dwCreatorType               As Long
    wFinderFlags                As Long
End Type

' SystemTime �\����
Private Type SystemTime
    Year            As Integer
    Month           As Integer
    DayOfWeek       As Integer
    Day             As Integer
    Hour            As Integer
    Minute          As Integer
    Second          As Integer
    Milliseconds    As Integer
End Type

Private Sub Class_Initialize()
    Set FSO = CreateObject("Scripting.FileSystemObject")
End Sub
Private Sub Class_Terminate()
    Set FSO = Nothing
End Sub
'--------------------------------------------------------------
'�@�t�@�C�����݃`�F�b�N
'--------------------------------------------------------------
Public Function FileExists(ByVal strFile As String) As Boolean
 
    With FSO
        FileExists = .FileExists(strFile)
    End With

End Function
'--------------------------------------------------------------
'�@�t�@�C���I�u�W�F�N�g�擾
'--------------------------------------------------------------
Public Function GetFile(ByVal strFile As String) As Object
 
    With FSO
        Set GetFile = .GetFile(strFile)
    End With

End Function
'--------------------------------------------------------------
'�@�t�H���_�[�I�u�W�F�N�g�擾
'--------------------------------------------------------------
Public Function GetFolder(ByVal strFolder As String) As Object
 
    With FSO
        Set GetFolder = .GetFolder(strFolder)
    End With

End Function
'--------------------------------------------------------------
'�@�t�H���_���݃`�F�b�N
'--------------------------------------------------------------
Public Function FolderExists(ByVal strFile As String) As Boolean
 
    With FSO
        FolderExists = .FolderExists(strFile)
    End With

End Function
'--------------------------------------------------------------
'�@�e���|�����t�H���_�擾
'--------------------------------------------------------------
Public Property Get TempFolder() As String

    On Error Resume Next
    
    Dim strFolder As String
    
    TempFolder = ""
    
    With FSO
    
        strFolder = AppDataFolder & "Temp"
        
        If .FolderExists(strFolder) Then
        Else
            .CreateFolder strFolder
        End If
        
        TempFolder = .BuildPath(strFolder, "\")
        
    End With
    

End Property
'--------------------------------------------------------------
'�@�A�v���P�[�V�����t�H���_�擾
'--------------------------------------------------------------
Public Property Get AppDataFolder() As String

    On Error Resume Next
    
    Dim strFolder As String
    
    AppDataFolder = ""
    
    With FSO
    
        strFolder = .BuildPath(CreateObject("Wscript.Shell").SpecialFolders("AppData"), Title)
        
        If .FolderExists(strFolder) Then
        Else
            .CreateFolder strFolder
        End If
        
        AppDataFolder = .BuildPath(strFolder, "\")
        
    End With

End Property
'--------------------------------------------------------------
'�@�t�@�C������
'--------------------------------------------------------------
Public Sub FileSearch(ByVal strPath As String, _
                      ByVal varPatterns As Variant, _
                      ByRef col As Collection, _
             Optional ByVal SubDir As Boolean = True, _
             Optional ByVal NaturalSort = True)

    Dim objfld As Object
    Dim objfl As Object
    Dim objSub As Object
    Dim v As Variant

    With FSO

        Set objfld = .GetFolder(strPath)

        '�t�@�C�����擾
        For Each objfl In objfld.files
            For Each v In varPatterns
                If LCase(objfl.Name) Like LCase(v) And Left(objfl.Name, 2) <> "~$" Then
                    Append col, .BuildPath(objfl.ParentFolder.Path, objfl.Name), NaturalSort
                    Exit For
                End If
            Next
            DoEvents
        Next

        '�T�u�t�H���_����
        If SubDir Then
            For Each objSub In objfld.SubFolders
                FileSearch objSub.Path, varPatterns, col, SubDir, NaturalSort
                DoEvents
            Next
        End If
    End With
End Sub
'--------------------------------------------------------------------------------------------------------------------
'�@�t�@�C������(�t�B���^������)
'
'  FileSystemObject �͕֗������A�t�B���^��������ꂸ�A�S���̃t�@�C����񋓂��邽�߃t�@�C���������x����肪����B
'  VBA.DIR��3���ȏ�̊g���q��Ή��AUNC��Ή��̂��߁AWinddows API �ɂĎ���
'  ���R���\�[�g��ǉ��B
'  SubDir = True(-1):�����Ȃ� False(0):�w��t�H���_�̂� �K��:�w��K���܂Ō���
'--------------------------------------------------------------------------------------------------------------------
Public Sub FileSearchEx(ByVal strPath As String, _
                        ByVal varPatterns As Variant, _
                        ByRef col As Collection, _
               Optional ByVal SubDir As Long = 0, _
               Optional ByVal ReturnFind As Boolean = False, _
               Optional ByVal NaturalSort As Boolean = True, _
               Optional ByVal varExcludedFolder As Variant = "")

    Dim PL As PairLogger: Set PL = Constructor(New PairLogger, TypeName(Me) & ".FileSearchEx")

    Dim v As Variant
    Dim udtWin32FindData        As WIN32_FIND_DATA      '[WIN32_FIND_DATA]�\����(��������)
    Dim hResult As LongPtr
    Dim strSeachFullPath As String
    Dim strFile As String
    Dim strFindFileName As String               '�������ʃt�@�C����
    
    Static lngLevel As Long
    
    '�w�背�x���ȉ��̏ꍇ�A�������Ȃ�
    Select Case True
        Case SubDir = -1
        Case SubDir < lngLevel
            Exit Sub
    End Select
    
    'Collection�ɃC���X�^���X�������ꍇ�ݒ�
    If col Is Nothing Then
        Set col = New Collection
    End If
    
    '�z�񂶂�Ȃ��ꍇ�A�z��ɕϊ�
    If Not IsArray(varPatterns) Then
        varPatterns = Array(varPatterns)
    End If

    For Each v In varPatterns
    
        '�����t���p�X���𐶐�
        If strPath Like "\\*" Then
            strSeachFullPath = "\\?\UNC\" & Mid$(strPath, 3)
        Else
            strSeachFullPath = "\\?\" & strPath
        End If
        
        strSeachFullPath = FileIO.BuildPath(strSeachFullPath, v)
        
        '������Ɉ�v����t�@�C�����������AWIN32_FIND_DATA�\���̂ɒl����
        hResult = FindFirstFileExW(StrPtr(strSeachFullPath), FindExInfoBasic, udtWin32FindData, FindExSearchNameMatch, 0, FIND_FIRST_EX_LARGE_FETCH)
        
        '�t�@�C���L�̏ꍇ
        If hResult <> INVALID_HANDLE_VALUE Then

            Do
                strFindFileName = CStr(udtWin32FindData.cFileName)
                strFile = Left$(strFindFileName, InStr(strFindFileName, vbNullChar) - 1)
                
                Select Case True
                    Case strFile = "."
                    Case strFile = ".."
                    Case Not strFile Like v 'FindFirstFile/FindNextFile�Ŋg���q�S���ȏ�͖�������Ă��܂����ߕʓrLike�Ŕ��肷��B
                    Case Left$(strFile, 2) = "~$"
                    Case udtWin32FindData.dwFileAttributes And FILE_ATTRIBUTE_HIDDEN
                    Case udtWin32FindData.dwFileAttributes And FILE_ATTRIBUTE_SYSTEM
                    Case udtWin32FindData.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY
                    Case Else
                        
                        '��L�ȊO��ǉ�
                        Append col, FileIO.BuildPath(strPath, strFile), NaturalSort
                        
                        '�����^�[��
                        If ReturnFind Then
                            hResult = FindClose(hResult)
                            Exit Sub
                        End If
                            
                End Select
            
            Loop While FindNextFileW(hResult, udtWin32FindData)
        
             '�t�@�C���n���h�����N���[�Y
            hResult = FindClose(hResult)
        
        End If
    Next
    
    '�T�u�t�H���_����
    Dim objfld As Object
    Dim objSub As Object

    If SubDir Then
    
        If Not IsArray(varExcludedFolder) Then
            varExcludedFolder = Array(varExcludedFolder)
        End If

        Set objfld = FSO.GetFolder(strPath)
        For Each objSub In objfld.SubFolders
        
            '���O�t�H���_���[�v
            For Each v In varExcludedFolder
            
                '��v���Ȃ����̂ɂ��Ď擾
                If v <> FileIO.GetFileName(objSub.Path) Then
            
                    '�ċA�Ăяo��
                    lngLevel = lngLevel + 1
                    FileSearchEx objSub.Path, varPatterns, col, SubDir, ReturnFind, NaturalSort, varExcludedFolder
                    lngLevel = lngLevel - 1
        
                    '�����^�[��
                    If ReturnFind And col.Count > 0 Then
                        Exit Sub
                    End If
                    
                End If
            Next
            DoEvents
        Next

    End If

End Sub
'���R���}���\�[�g
Private Sub Append(ByRef col As Collection, _
                   ByVal strFile As String, _
                   ByVal NaturalSort As Boolean)

    Dim i As Long
    
    If NaturalSort Then
        If col.Count = 0 Then
            col.Add strFile
        Else
            For i = col.Count To 1 Step -1

                '�t�@�C���̕����傫�������ꍇ�A���̌�ɑ}���B
                If StrCmpLogicalW(StrPtr(strFile), StrPtr(col(i))) >= 0 Then
                    col.Add strFile, , , i
                    Exit Sub
                End If

            Next
            col.Add strFile, , 1
        End If
    Else
        col.Add strFile
    End If

End Sub

'--------------------------------------------------------------
'�@�t�@�C������(�t�B���^������)
'  �w��̃t�@�C�����t�@�C�������������瑦���^�[�����܂��B
'--------------------------------------------------------------
Public Function SearchTreeForFile(ByVal strPath As String, ByVal strFile As String) As String

    Dim strBuffer As String
    
    strBuffer = String$(MAX_PATH, vbNullChar)
    
    SearchTreeForFile = ""

    If SearchTreeForFileW(StrPtr(strPath), StrPtr(strFile), StrPtr(strBuffer)) Then
        SearchTreeForFile = Left$(strBuffer, InStr(strBuffer, vbNullChar) - 1)
    End If

End Function
'--------------------------------------------------------------
'�@�t�@�C���p�X����
'--------------------------------------------------------------
Public Function BuildPath(ByVal strPath As String, ByVal strFile As String) As String
    
    With FSO
        BuildPath = .BuildPath(strPath, strFile)
    End With

End Function
'--------------------------------------------------------------
'�@�t�H���_�폜
'  �w��t�H���_���ȉ����܂ށA�t�H���_���̂��폜
'--------------------------------------------------------------
Public Sub DeleteFolder(ByVal strPath As String)
    
    With FSO
        .DeleteFolder strPath, True
    End With

End Sub
'--------------------------------------------------------------
'�@�t�@�C���폜
'--------------------------------------------------------------
Public Sub DeleteFile(ByVal strPath As String)
    
    With FSO
        .DeleteFile strPath, True
    End With

End Sub
'--------------------------------------------------------------
'�@�w��t�H���_�ȉ��t�@�C�����t�H���_�폜
'  �w��t�H���_�͏������ɂ���ȉ����������Ƃɒ���
'  ���[�N�t�H���_�̃N���A�Ɍ����B
'--------------------------------------------------------------
Public Sub ClearFolder(ByVal strPath As String)
    
    Dim fld As Object
    Dim f As Object
    
    With FSO
    
        Set fld = .GetFolder(strPath)
        
        For Each f In fld.files
            .DeleteFile .BuildPath(strPath, f.Name), True
        Next
        
        For Each f In fld.SubFolders
            .DeleteFolder .BuildPath(strPath, f.Name), True
        Next
        
    End With

End Sub

'--------------------------------------------------------------
'�@�t�@�C�����擾
'--------------------------------------------------------------
Public Function GetFileName(ByVal strFile As String) As String

    With FSO

        GetFileName = .GetFileName(strFile)
        
    End With
    
'    Dim lngCnt As Long
'    Dim lngMax As Long
'    Dim strResult As String
'
'    strResult = strPath
'
'    lngMax = Len(strPath)
'
'    For lngCnt = lngMax To 1 Step -1
'
'        Select Case Mid$(strPath, lngCnt, 1)
'            Case "\", "/"
'                If lngCnt = lngMax Then
'                Else
'                    strResult = Mid$(strPath, lngCnt + 1)
'                End If
'                Exit For
'        End Select
'
'    Next
'
'    rlxGetFullpathFromFileName = strResult

End Function
'--------------------------------------------------------------
'�@�g���q�擾
'--------------------------------------------------------------
Public Function GetExtensionName(ByVal strFile As String) As String

    With FSO

        GetExtensionName = .GetExtensionName(strFile)
        
    End With
    
'   Dim lngCnt As Long
'    Dim lngMax As Long
'    Dim strResult As String
'
'    strResult = strPath
'
'    lngMax = Len(strPath)
'
'    For lngCnt = lngMax To 1 Step -1
'
'        If Mid$(strPath, lngCnt, 1) = "." Then
'            If lngCnt > 1 Then
'                strResult = Mid$(strPath, 1, lngCnt - 1)
'                Exit For
'            End If
'        End If
'
'    Next
'
'    rlxGetFullpathFromExt = strResult

End Function
'--------------------------------------------------------------
'�@�t�@�C�����擾(�g���q����)
'--------------------------------------------------------------
Public Function GetBaseName(ByVal strFile As String) As String

    With FSO
        GetBaseName = .GetBaseName(strFile)
    End With

End Function
'--------------------------------------------------------------
'�@�p�X���擾
'--------------------------------------------------------------
Public Function GetParentFolderName(ByVal strFile As String) As String

    With FSO

        GetParentFolderName = .GetParentFolderName(strFile)
        
    End With
    
'    Dim lngCnt As Long
'    Dim lngMax As Long
'    Dim strResult As String
'
'    strResult = strPath
'
'    lngMax = Len(strPath)
'
'    For lngCnt = lngMax To 1 Step -1
'
'        Select Case Mid$(strPath, lngCnt, 1)
'            Case "\", "/"
'                If lngCnt > 1 Then
'                    strResult = Mid$(strPath, 1, lngCnt - 1)
'                    Exit For
'                End If
'        End Select
'
'    Next
'
'    rlxGetFullpathFromPathName = strResult

End Function
'--------------------------------------------------------------
'  �t�H���_�̍쐬�i�ċA�j
'--------------------------------------------------------------
Public Sub CreateFolder(ByVal strPath As String)

    With FSO
    
        If .FolderExists(strPath) Then
            Exit Sub
        End If
    
        Call CreateFolder(.GetParentFolderName(strPath))
        
        .CreateFolder strPath
    
    End With

End Sub
'--------------------------------------------------------------
'  �}�C�h�L�������g�t�H���_�ړ�
'--------------------------------------------------------------
Public Sub SetMyDocument()
    On Error Resume Next
    ChDir CreateObject("Wscript.Shell").SpecialFolders("MyDocuments")
End Sub
'--------------------------------------------------------------
'�@�h���C�u����UNC���ϊ�
'�@�h���C�u��(J:��)���w��B�G���[�̏ꍇ�h���C�u�������̂܂ܕԋp
'--------------------------------------------------------------
Public Function DriveToUNC(ByVal strPath As String) As String

    Dim lStatus As Long
    Dim lpLocalName As String
    Dim lpRemoteName As String
    Dim lpnLength As Long
    
    Const NO_ERROR As Long = 0
    
    '�f�t�H���g�Ńp�X���Z�b�g
    DriveToUNC = strPath
    
    If InStr(strPath, ":") = 2 Then
        lpLocalName = Left$(strPath, 2)
    Else
        '�h���C�u��񂪊܂܂�Ȃ��B
        Exit Function
    End If

    lpnLength = MAX_PATH
    
    lpRemoteName = String$(MAX_PATH, vbNullChar)
    
    lStatus& = WNetGetConnectionW(StrPtr(lpLocalName), StrPtr(lpRemoteName), lpnLength)
    
    If lStatus& = NO_ERROR Then
        DriveToUNC = Left$(lpRemoteName, InStr(lpRemoteName, vbNullChar) - 1) & Mid$(strPath, 3)
    End If

End Function
'--------------------------------------------------------------
'  �t�H���_���J��
'--------------------------------------------------------------
Public Sub OpenFolder(ByVal strFolder As String)

    With CreateObject("WScript.Shell")
        .Run ("""" & strFolder & """")
    End With
    
End Sub
'--------------------------------------------------------------
'  �t�@�C�����G�N�X�v���[���[�ŊJ���đI��
'--------------------------------------------------------------
'  ���S�ҖY���^
'  https://www.ka-net.org/blog/?p=9180
'  �w�肵���t�@�C�����G�N�X�v���[���[�ŊJ���đI������VBA�}�N��
'--------------------------------------------------------------
Public Sub OpenFileOnExplorer(ByVal strFile As String)

    '�w�肵���t�@�C�����G�N�X�v���[���[�ŊJ���đI������
    With FSO
        If .FileExists(strFile) Then
            VBA.Shell "EXPLORER.EXE /select,""" & strFile & """", vbNormalFocus
        End If
    End With

End Sub
''--------------------------------------------------------------
''  �t�@�C���R�s�[
''--------------------------------------------------------------
'Public Sub CopyFile(ByVal source As String, ByVal destination As String)
'
'    With FileSystemObject
'        .CopyFile source, destination, True
'    End With
'
'End Sub
'--------------------------------------------------------------
'  �t�@�C���R�s�[(�^�C���X�^���v�ێ����ǂݎ���p�̏㏑���R�s�[�Ή����Ώۃt�@�C�����ł��G���[�ɂȂ�Ȃ�)
'--------------------------------------------------------------
Public Sub CopyFile(ByVal source As String, _
                    ByVal destination As String, _
           Optional ByVal keepTimestamp As Boolean = False)
    
    Dim dateCreated As Date
    Dim dateLastModified As Date
    Dim dateLastAccessed As Date
    Dim udtWin32FindData        As WIN32_FIND_DATA      '[WIN32_FIND_DATA]�\����(��������)
    Dim hResult As LongPtr
    Dim strSeachFullPath As String
    Dim strFile As String

    With FSO
        
        '�����t���p�X���𐶐�
        If source Like "\\*" Then
            strSeachFullPath = "\\?\UNC\" & Mid$(source, 3)
        Else
            strSeachFullPath = "\\?\" & source
        End If
        
        '������Ɉ�v����t�@�C�����������AWIN32_FIND_DATA�\���̂ɒl����
        hResult = FindFirstFileW(StrPtr(strSeachFullPath), udtWin32FindData)
        '�t�@�C�����̏ꍇ
        If hResult = INVALID_HANDLE_VALUE Then
            Exit Sub
        End If
        
        Do
            Dim strFindFileName As String
            
            strFindFileName = CStr(udtWin32FindData.cFileName)
            strFile = Left$(strFindFileName, InStr(strFindFileName, vbNullChar) - 1)
            
            '�t�@�C���̑������f�B���N�g���̏ꍇ�A�p�X
            If strFile = "" Or strFile = "." Or strFile = ".." Then
                GoTo pass
            End If
                
            Select Case True
                Case udtWin32FindData.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY
                    GoTo pass
            End Select
                
            Dim strFullSource As String
            strFullSource = FileIO.BuildPath(FileIO.GetParentFolderName(source), strFile)
            
            '�^�C���X�^���v�擾
            If keepTimestamp Then
                dateCreated = .GetFile(strFullSource).dateCreated
                dateLastModified = .GetFile(strFullSource).dateLastModified
                dateLastAccessed = .GetFile(strFullSource).dateLastAccessed
            End If
            
            '�R�s�[�悪�t�H���_�w��̏ꍇ�A�R�s�[��t�@�C�������쐬
            Dim strFullDest As String
            If FileIO.FolderExists(destination) Then
                strFullDest = FileIO.BuildPath(destination, strFile)
            Else
                strFullDest = destination
            End If
            
            '�ǂݎ���p�t�@�C���΍�B���O�Ƀt�@�C�����폜
            If FileIO.FileExists(strFullDest) Then
                .DeleteFile strFullDest, True
            End If
            
            .CopyFile strFullSource, strFullDest, True
            
            '�^�C���X�^���v��������
            If keepTimestamp Then
                
                Dim lngAttr As Long
                Dim objFile As Object
                
                Set objFile = .GetFile(strFullDest)
                lngAttr = objFile.Attributes
                
                '�W���t�@�C���ɕύX�i�ǂݎ���p�΍�j
                objFile.Attributes = 0
                
                '�^�C���X�^���v��������
                FileIO.SetCreationTime strFullDest, dateCreated
                FileIO.SetLastWriteTime strFullDest, dateLastModified
                FileIO.SetLastAccessTime strFullDest, dateLastAccessed
                
                '���������ɖ߂�
                objFile.Attributes = lngAttr
            
            End If
    
pass:
        Loop While FindNextFileW(hResult, udtWin32FindData)
    
         '�t�@�C���n���h�����N���[�Y
        hResult = FindClose(hResult)
    
    End With

End Sub
'--------------------------------------------------------------
'  �t�@�C���^�t�H���_�̍쐬�����ݒ�
'--------------------------------------------------------------
Public Sub SetCreationTime(ByVal stFilePath As String, ByVal dtCreateTime As Date)
    
    Dim cFileHandle As LongPtr
    Dim tFileTime As FILETIME
    Dim tNullable As FILETIME
    
    cFileHandle = GetFileHandle(stFilePath)
    If cFileHandle <> 0 Then
        tFileTime = GetFileTime(dtCreateTime)
        Call SetFileTime(cFileHandle, tFileTime, tNullable, tNullable)
        Call CloseHandle(cFileHandle)
    End If
    
End Sub
'--------------------------------------------------------------
'  �t�@�C���^�t�H���_�̍X�V�����ݒ�
'--------------------------------------------------------------
Public Sub SetLastWriteTime(ByVal stFilePath As String, ByVal dtUpdateTime As Date)
    
    Dim cFileHandle As LongPtr
    Dim tFileTime As FILETIME
    Dim tNullable As FILETIME
    
    cFileHandle = GetFileHandle(stFilePath)
    If cFileHandle <> 0 Then
        tFileTime = GetFileTime(dtUpdateTime)
        Call SetFileTime(cFileHandle, tNullable, tNullable, tFileTime)
        Call CloseHandle(cFileHandle)
    End If

End Sub
'--------------------------------------------------------------
'  �t�@�C���^�t�H���_�̃A�N�Z�X�����ݒ�
'--------------------------------------------------------------
Public Sub SetLastAccessTime(ByVal stFilePath As String, ByVal dtAccessTime As Date)

    Dim cFileHandle As LongPtr
    Dim tNullable As FILETIME
    Dim tFileTime As FILETIME
    
    cFileHandle = GetFileHandle(stFilePath)
    If cFileHandle <> 0 Then
        tFileTime = GetFileTime(dtAccessTime)
        Call SetFileTime(cFileHandle, tNullable, tFileTime, tNullable)
        Call CloseHandle(cFileHandle)
    End If
    
End Sub

' FileTime ���擾����
Private Function GetFileTime(ByVal dtSetting As Date) As FILETIME

    Dim tSystemTime As SystemTime
    
    With tSystemTime
        .Year = Year(dtSetting)
        .Month = Month(dtSetting)
        .DayOfWeek = Weekday(dtSetting)
        .Day = Day(dtSetting)
        .Hour = Hour(dtSetting)
        .Minute = Minute(dtSetting)
        .Second = Second(dtSetting)
    End With
    
    Dim tLocalTime As FILETIME
    Call SystemTimeToFileTime(tSystemTime, tLocalTime)
    
    Dim tFileTime As FILETIME
    Call LocalFileTimeToFileTime(tLocalTime, tFileTime)
    
    GetFileTime = tFileTime
    
End Function

' �t�@�C���̃n���h�����擾����
Private Function GetFileHandle(ByVal stFilePath As String) As LongPtr

'�t�H���_�̃n���h���̎擾�ɑΉ�
    'GetFileHandle = CreateFile(StrPtr(stFilePath), GENERIC_READ Or GENERIC_WRITE, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
    GetFileHandle = CreateFileW(StrPtr(stFilePath), GENERIC_READ Or GENERIC_WRITE, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, 0)

End Function

'--------------------------------------------------------------
' ���t�H���_�Ɠ����\���̃t�H���_���쐬����B
'--------------------------------------------------------------
Public Sub CreateFolderImage(ByVal strSource As String, ByVal strDest As String)

    Dim strFolder As String
    Dim objfld As Object
    Dim objSub As Object

    With FSO

        Set objfld = .GetFolder(strSource)
    
        For Each objSub In objfld.SubFolders
            
            '�쐬���t�H���_���𐶐�
            strFolder = FileIO.BuildPath(strDest, objSub.Name)
            
            If Not FileIO.FolderExists(strFolder) Then
                
                '�t�H���_�쐬
                FileIO.CreateFolder strFolder
                
                Dim dt As Date
                dt = .GetFolder(objSub.Path).dateCreated
                FileIO.SetCreationTime strFolder, dt
                
                dt = .GetFolder(objSub.Path).dateLastModified
                FileIO.SetLastWriteTime strFolder, dt
            
                dt = .GetFolder(objSub.Path).dateLastAccessed
                FileIO.SetLastAccessTime strFolder, dt
            
            End If
            
            '�T�u�t�H���_���ċA�ɂč쐬
            CreateFolderImage objSub.Path, strFolder
            
            DoEvents
        Next
    
    End With

End Sub


'�A�v���P�[�V�������擾
Private Property Get Title() As String
    Title = ThisWorkbook.BuiltinDocumentProperties("Title").Value
End Property
'--------------------------------------------------------------
'�@�t�@�C�����폜����̂ł͂Ȃ����e�̃N���A
'--------------------------------------------------------------
Sub TruncateFile(ByVal strFile As String)

    Dim fp As Integer

    '�o�̓t�@�C���̃N���A
    fp = FreeFile()
    Open strFile For Output As fp
    Close fp

End Sub