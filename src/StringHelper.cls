VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "StringHelper"
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
'-----------------------------------------------------------------------------------------------------
' �ˑ����W���[��
'   Math.bas
'-----------------------------------------------------------------------------------------------------
' 2018-12-16 Ver.1.0.0 �V�K�쐬
'-----------------------------------------------------------------------------------------------------
Option Explicit
'--------------------------------------------------------------
'  �T���Q�[�g�y�A�Ή�Len
'--------------------------------------------------------------
Public Function LenEx(ByVal strBuf As String) As Long

    Dim bytBuf() As Byte
    Dim lngBuf As Long
    Dim i As Long
    Dim lngLen As Long
    
    lngLen = 0
    
    If Len(strBuf) = 0 Then
        LenEx = 0
        Exit Function
    End If
    
    bytBuf = strBuf
    
    For i = LBound(bytBuf) To UBound(bytBuf) Step 2
    
        lngBuf = Math.LShift(bytBuf(i + 1), 8) + bytBuf(i)
    
        Select Case lngBuf
            '��ʃT���Q�[�g
            Case &HD800& To &HDBFF&
                lngLen = lngLen + 1
            '���ʃT���Q�[�g
            Case &HDC00& To &HDFFF&
                '�J�E���g���Ȃ�
            Case Else
                lngLen = lngLen + 1
        End Select
    
    Next
    
    LenEx = lngLen

End Function
'--------------------------------------------------------------
'  �S�p�Ή��g����
'--------------------------------------------------------------
Public Function TrimEx(ByVal strBuf As String) As String
 
    Dim lngLen As Long
    Dim lngStart As Long
    Dim lngEnd As Long
    
    lngLen = Len(strBuf)
    
    lngStart = 1
    Do Until lngStart > lngLen
        Select Case Mid$(strBuf, lngStart, 1)
            Case Is <= " "
            Case Is = "�@"
            Case Else
                Exit Do
        End Select
        lngStart = lngStart + 1
    Loop
    
    lngEnd = lngLen
    Do Until lngEnd < 1
        Select Case Mid$(strBuf, lngEnd, 1)
            Case Is <= " "
            Case Is = "�@"
            Case Else
                Exit Do
        End Select
        lngEnd = lngEnd - 1
    Loop
    
    If lngEnd > 0 Or lngStart <= lngLen Then
        TrimEx = Mid$(strBuf, lngStart, (lngEnd - lngStart) + 1)
    Else
        TrimEx = ""
    End If

End Function
'--------------------------------------------------------------
'�@������̃o�C�g�������߂�B�����Q�o�C�g�A���p�P�o�C�g�B
'--------------------------------------------------------------
Public Function AscLen(ByVal var As Variant) As Long

    Dim ascVar As Variant
    
    ascVar = VBA.StrConv(var, vbFromUnicode)

    AscLen = LenB(ascVar)

End Function
'----------------------------------------------------------------------------------
'�@������̍��[����w�肵�����������̕������Ԃ��B�����Q�o�C�g�A���p�P�o�C�g�B
'----------------------------------------------------------------------------------
Public Function AscLeft(ByVal var As Variant, ByVal lngSize As Long) As String

    Dim lngLen As Long
    Dim i As Long
    
    Dim strChr As String
    Dim strResult As String
    
    lngLen = Len(var)
    strResult = ""

    For i = 1 To lngLen
    
        strChr = Mid(var, i, 1)
        If AscLen(strResult & strChr) > lngSize Then
            Exit For
        End If
        strResult = strResult & strChr
    
    Next

    AscLeft = strResult

End Function
'----------------------------------------------------------------------------------
'�@������̉E�[����w�肵�����������̕������Ԃ��B�����Q�o�C�g�A���p�P�o�C�g�B
'----------------------------------------------------------------------------------
Public Function AscRight(ByVal var As Variant, ByVal lngSize As Long) As String

    Dim ascVar As Variant
    
    ascVar = VBA.StrConv(var, vbFromUnicode)

    AscRight = VBA.StrConv(RightB(ascVar, lngSize), vbUnicode)

End Function
'----------------------------------------------------------------------------------
'�@�����񂩂�w�肵�����������̕������Ԃ��B�����Q�o�C�g�A���p�P�o�C�g�B
'----------------------------------------------------------------------------------
Public Function AscMid(ByVal var As Variant, ByVal lngPos As Long, Optional ByVal varSize As Variant) As String

    Dim ascVar As Variant
    
    ascVar = VBA.StrConv(var, vbFromUnicode)

    If IsMissing(varSize) Then
        AscMid = VBA.StrConv(MidB(ascVar, lngPos), vbUnicode)
    Else
        AscMid = VBA.StrConv(MidB(ascVar, lngPos, varSize), vbUnicode)
    End If

End Function
'--------------------------------------------------------------
'�@������̕����i�J���}�j
'--------------------------------------------------------------
Public Function SplitEx(ByVal strBuf As String, Optional ByVal Separator As String = vbTab) As Variant

    Dim lngLen As Long
    Dim lngCnt As Long
    Dim i As Long
    Dim strCol As String
    Dim blnSw As Boolean
    
    Const C_QUAT As String = """"
    
    Dim result() As Variant
    
    lngLen = Len(strBuf)
    blnSw = False
    strCol = ""
    lngCnt = 0
    
    Dim IC As ICursor
    Set IC = Constructor(New CharCursor, strBuf)
    
    Do Until IC.Eof
    
        Dim blnBreak As Boolean
        blnBreak = False
        strCol = ""
        
        Do Until IC.Eof Or blnBreak
        
            If IC = C_QUAT And IC.PreviousItem <> "\" Then
                blnSw = Not blnSw
            End If
            
            If blnSw Then
                strCol = strCol & IC
            Else
                Select Case IC
                    Case Separator
                        blnBreak = True
                    Case Else
                        strCol = strCol & IC
                End Select
            End If
            IC.MoveNext
        Loop
    
        lngCnt = lngCnt + 1
        ReDim Preserve result(0 To lngCnt - 1)
        result(lngCnt - 1) = strCol
    
    Loop

    SplitEx = result
    
End Function
'--------------------------------------------------------------
'�@�J�n������̔���
'--------------------------------------------------------------
Public Function StartsWith(ByVal strBuf As String, ByVal strWith As String) As Boolean

    StartsWith = (strWith = Left$(strBuf, Len(strWith)))

End Function
'--------------------------------------------------------------
'�@�I��������̔���
'--------------------------------------------------------------
Public Function EndsWith(ByVal strBuf As String, ByVal strWith As String) As Boolean

    EndsWith = (strWith = Right$(strBuf, Len(strWith)))

End Function