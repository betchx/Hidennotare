VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Process"
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
'   �Ȃ�
'-----------------------------------------------------------------------------------------------------
' 2018-12-16 Ver.1.0.0 �V�K�쐬
'-----------------------------------------------------------------------------------------------------
Option Explicit

Private Declare PtrSafe Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (destination As Any, source As Any, ByVal Length As LongPtr)

Private RefCount As Long
'--------------------------------------------------------------
' �}���`�v���Z�X���s�p�i�}�N���j
'--------------------------------------------------------------
Public Sub MultiProsess(ByVal strMacro As String)
    
    Err.Clear
    
    On Error Resume Next
    With CreateObject("Excel.Application")
        .Workbooks.Open ThisWorkbook.FullName
        .Run ExcelHelper.BuildOnAction(strMacro)
    End With
    
    If Err.Number <> 0 Then
        MsgBox "Multi Process�N���Ɏ��s���܂����B", vbCritical
    End If
    
End Sub
'--------------------------------------------------------------
' �񓯊����s�p�i�}�N���j
'--------------------------------------------------------------
Function UnsyncRun(ByVal strMacro As String, Optional ByVal lngSec As Long = 0) As Long
    Application.OnTime DateAdd("s", lngSec, Now), strMacro
End Function
'--------------------------------------------------------------
'�@�W���o�͎擾���s
'--------------------------------------------------------------
Function Exec(ByVal strCommand As String) As String

    Dim WSH As Object
    Dim wExec As Object
    
    Set WSH = CreateObject("WScript.Shell")
    
    Set wExec = WSH.Exec(strCommand)
    Do While wExec.Status = 0
        DoEvents
    Loop
    
    Exec = wExec.StdOut.ReadAll
    
    Set wExec = Nothing
    Set WSH = Nothing

End Function
'--------------------------------------------------------------
'�@�A�h���X�����񂩂�I�u�W�F�N�g�ɕϊ�
'--------------------------------------------------------------
Public Function GetObjectFromAddress(ByVal strAddress As String) As Object

    Dim obj As Object

    Dim p As LongPtr
    p = CLngPtr(strAddress)
  
    CopyMemory obj, p, LenB(p)
    
    Set GetObjectFromAddress = obj

End Function
'--------------------------------------------------------------
'�@Shell�R�}���h
'--------------------------------------------------------------
Sub Shell(ByVal strCommand As String, ParamArray p())

    Dim Ret As Variant
    Dim strBuf As String
    Dim v As Variant

    strBuf = """" & strCommand & """"
    
    If UBound(p) >= 0 Then

        For Each v In p
            strBuf = strBuf & " """ & v & """"
        Next

    End If
    
    On Error Resume Next
    Ret = VBA.Shell(strBuf, vbNormalFocus)
    If Ret <> 0 Then
        AppActivate Ret
    End If

End Sub
'--------------------------------------------------------------
'�@OpenFile �R�}���h(�t�@�C�����s)
'--------------------------------------------------------------
Sub OpenFile(ByVal strFile As String, Optional ByVal flg As Boolean = False)

    On Error GoTo e

    With CreateObject("WScript.Shell")
        .Run """" & strFile & """", 1, flg
    End With

    Exit Sub
e:
    MsgBox "�t�@�C�����J���܂���ł����B" & strFile, vbCritical
End Sub
'--------------------------------------------------------------
'�@�����o�b�`���s
'--------------------------------------------------------------
Sub ExecBatch(ByVal strFile As String)

    On Error GoTo e

    With CreateObject("WScript.Shell")
        .Run strFile, 0, True
    End With

    Exit Sub
e:
    MsgBox "�t�@�C�����J���܂���ł����B" & strFile, vbCritical
End Sub