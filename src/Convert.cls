VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Convert"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
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
' �ϊ��N���X
'-----------------------------------------------------------------------------------------------------
Private Declare PtrSafe Function MultiByteToWideChar Lib "kernel32" (ByVal CodePage As Long, ByVal dwFlags As Long, ByVal lpMultiByteStr As LongPtr, ByVal cchMultiByte As Long, ByVal lpWideCharStr As LongPtr, ByVal cchWideChar As Long) As Long
Private Declare PtrSafe Function WideCharToMultiByte Lib "kernel32" (ByVal CodePage As Long, ByVal dwFlags As Long, ByVal lpWideCharStr As LongPtr, ByVal cchWideChar As Long, ByVal lpMultiByteStr As LongPtr, ByVal cchMultiByte As Long, ByVal lpDefaultChar As LongPtr, ByVal lpUsedDefaultChar As Long) As Long

Private Const CP_UTF8 As Long = 65001
Private Const MB_PRECOMPOSED As Long = &H1
'------------------------------------------------------------------------------------------------------------------------
' UTF-8 �� UTF-16(LE)
'------------------------------------------------------------------------------------------------------------------------
Function FromUTF8(ByRef bytBuf() As Byte) As String
    
    Dim strBuf As String
    Dim lngSize As Long
    Dim lngByte As Long

    If UBound(bytBuf) < 0 Then
        Exit Function
    End If
    
    lngByte = UBound(bytBuf) - LBound(bytBuf) + 1

    lngSize = MultiByteToWideChar(CP_UTF8, 0, VarPtr(bytBuf(0)), lngByte, 0, 0)
    
    strBuf = String$(lngSize, vbNullChar)
    
    lngSize = MultiByteToWideChar(CP_UTF8, 0, VarPtr(bytBuf(0)), lngByte, StrPtr(strBuf), lngSize)

    FromUTF8 = strBuf

End Function
'------------------------------------------------------------------------------------------------------------------------
' UTF-16(LE) �� UTF-8
'------------------------------------------------------------------------------------------------------------------------
Function ToUTF8(ByVal strBuf As String) As Byte()
    
    If Len(strBuf) = 0 Then
        ToUTF8 = ""
        Exit Function
    End If
    
    Dim lngSize As Long
    Dim bytBuf() As Byte
    
    lngSize = WideCharToMultiByte(CP_UTF8, 0, StrPtr(strBuf), Len(strBuf), 0, 0, 0, 0)
    
    ReDim bytBuf(0 To lngSize - 1)
    
    WideCharToMultiByte CP_UTF8, 0, StrPtr(strBuf), Len(strBuf), VarPtr(bytBuf(0)), lngSize, 0, 0
    
    ToUTF8 = bytBuf

End Function
'----------------------------------------------------------------------------------
'�@������̃G�X�P�[�v
'----------------------------------------------------------------------------------
Public Function Escape(ByVal v As String) As String

    Dim strChr As String
    Dim sb As StringBuilder
    Dim i As Long
    
    Set sb = New StringBuilder
    
    For i = 1 To Len(v)
        
        strChr = Mid$(v, i, 1)
        
        Select Case Unicode(strChr)
            Case &H0 To &H7, &HB, &HE To &H1F, &H7F
                sb.Append "\u" & Hex$(Unicode(strChr))
            Case &H8
                sb.Append "\b"
            Case &H9
                sb.Append "\t"
            Case &HA
                sb.Append "\n"
            Case &HC
                sb.Append "\f"
            Case &HD
                sb.Append "\r"
            Case &H22
                sb.Append "\"""
            Case &H2F
                sb.Append "\/"
            Case &H5C
                sb.Append "\\"
            Case Else
                sb.Append strChr
        End Select

    Next
    
    Escape = sb.ToString

End Function
'---------------------------------------------------------------------
'�@������̃A���G�X�P�[�v
'---------------------------------------------------------------------
Public Function UnEscape(ByVal v As String) As String
    Const PROC_NAME As String = ".EscDecode"

    Dim strChr As String
    Dim strBuf As String
    Dim sb As StringBuilder
    Dim i As Long
    
    '�{����JSON����Ȃ炱����UTF8�ϊ�
    
    Set sb = New StringBuilder
    i = 1
    Do Until i > Len(v)

        strChr = Mid$(v, i, 2)
        
        Select Case strChr
            Case "\u"
            
                If i + 6 > Len(v) Then
                    Message.Throw 1, Me, "UnEscape", "format error"
                End If
            
                sb.Append ChrW$(Val("&H" & Mid$(v, i + 2, 4)))
                i = i + 6
            Case "\b"
                sb.Append Chr$(&H8)
                i = i + 2
            Case "\t"
                sb.Append vbTab
                i = i + 2
            Case "\n"
                sb.Append vbLf
                i = i + 2
            Case "\f"
                sb.Append Chr$(&HC)
                i = i + 2
            Case "\r"
                sb.Append vbCr
                i = i + 2
            Case "\"""
                sb.Append """"
                i = i + 2
            Case "\/"
                sb.Append "/"
                i = i + 2
            Case "\\"
                sb.Append "\"
                i = i + 2
            Case Else
                sb.Append Left(strChr, 1)
                i = i + 1
        End Select

    Loop

    UnEscape = sb.ToString

End Function
'--------------------------------------------------------------
'  UNICODE�Ή��Ђ炪�ȁ��J�^�J�i�ϊ�
'--------------------------------------------------------------
Public Function ToKatakana(ByVal strBuf As String, Optional ByVal flag As Boolean = False) As String

    Dim bytBuf() As Byte
    Dim retBuf() As Byte
    Dim lngBuf As Long
    Dim i As Long
    Dim lngLen As Long
    Dim lngConv As Long
    Dim lngOpt As Long
    
    lngLen = 0
    
    If Len(strBuf) = 0 Then
        ToKatakana = ""
        Exit Function
    End If
    
    bytBuf = strBuf
    retBuf = strBuf
    
    If flag Then
        lngOpt = &H3096&
    Else
        lngOpt = &H3094&
    End If
    
    For i = LBound(bytBuf) To UBound(bytBuf) Step 2
    
        lngBuf = Math.LShift(bytBuf(i + 1), 8) + bytBuf(i)
    
        Select Case lngBuf
            '�Ђ炪��
            Case &H3041& To lngOpt, &H309D&, &H309E&
            
                lngConv = lngBuf + &H60&
                retBuf(i) = Math.LByte(lngConv)
                retBuf(i + 1) = Math.UByte(lngConv)
            
        End Select
    
    Next
    
    ToKatakana = retBuf()

End Function
'--------------------------------------------------------------
'  UNICODE�Ή��J�^�J�i���Ђ炪�ȕϊ�
'--------------------------------------------------------------
Public Function ToHiragana(ByVal strBuf As String, Optional ByVal flag As Boolean = False) As String

    Dim bytBuf() As Byte
    Dim retBuf() As Byte
    Dim lngBuf As Long
    Dim i As Long
    Dim lngLen As Long
    Dim lngConv As Long
    Dim lngOpt As Long
    
    lngLen = 0
    
    If Len(strBuf) = 0 Then
        ToHiragana = ""
        Exit Function
    End If
    
    bytBuf = strBuf
    retBuf = strBuf
    
    If flag Then
        lngOpt = &H30F6&
    Else
        lngOpt = &H30F4&
    End If
    
    For i = LBound(bytBuf) To UBound(bytBuf) Step 2
    
        lngBuf = Math.LShift(bytBuf(i + 1), 8) + bytBuf(i)
    
        Select Case lngBuf
            '�J�^�J�i
            Case &H30A1& To lngOpt, &H30FD&, &H30FE&
            
                lngConv = lngBuf - &H60&
                retBuf(i) = Math.LByte(lngConv)
                retBuf(i + 1) = Math.UByte(lngConv)
            
        End Select
    
    Next
    
    ToHiragana = retBuf()

End Function
'--------------------------------------------------------------
'���������Ή�StrConv(vbUnicode, vbFromUnicode�̓T�|�[�g�O)
'--------------------------------------------------------------
Public Function StrConvU(ByVal strSource As String, Conv As VbStrConv) As String

    Dim i As Long
    Dim strBuf As String
    Dim c As String
    Dim strRet As String
    Dim strBefore As String
    Dim strChr As String
    Dim strNext As String

    strRet = ""
    strBuf = ""
    strBefore = ""
    strNext = ""

    For i = 1 To Len(strSource)

        c = Mid$(strSource, i, 1)
        
        If i = Len(strSource) Then
            strNext = ""
        Else
            strNext = Mid$(strSource, i + 1, 1)
        End If

        Select Case c
            '�S�p�́�
            Case "��"
                If (Conv And vbNarrow) > 0 Then
                    strChr = "\"
                    strRet = strRet & VBA.StrConv(strBuf, Conv) & strChr
                    strBuf = ""
                Else
                    strBuf = strBuf & c
                End If
           
            '���p��\
            Case "\"
                If (Conv And vbWide) > 0 Then
                    strChr = "��"
                    strRet = strRet & VBA.StrConv(strBuf, Conv) & strChr
                    strBuf = ""
                Else
                    strBuf = strBuf & c
                End If
            '�S�p�̑��_�A�����_
            Case "�K", "�J"
                If (Conv And vbNarrow) > 0 Then
                    If c = "�K" Then
                        strChr = "�"
                    Else
                        strChr = "�"
                    End If
                    strRet = strRet & VBA.StrConv(strBuf, Conv) & strChr
                    strBuf = ""
                Else
                    strBuf = strBuf & c
                End If
                
            '���p�̔����_
            Case "�"
                '�P�O�̕���
                Select Case strBefore
                    Case "�" To "�"
                        strBuf = strBuf & c
                    Case Else
                        If (Conv And vbWide) > 0 Then
                             strChr = "�K"
                            strRet = strRet & VBA.StrConv(strBuf, Conv) & strChr
                            strBuf = ""
                        Else
                            strBuf = strBuf & c
                        End If
                End Select
                
            '���p�̑��_
            Case "�"
                '�P�O�̕���
                Select Case strBefore
                    Case "�", "�" To "�", "�" To "�", "�" To "�", "�" To "�"
                        strBuf = strBuf & c
                    Case Else
                        If (Conv And vbWide) > 0 Then
                            strChr = "�J"
                            strRet = strRet & VBA.StrConv(strBuf, Conv) & strChr
                            strBuf = ""
                        Else
                            strBuf = strBuf & c
                        End If
                End Select
            '��
            Case "��"
                If (Conv And vbHiragana) > 0 Then
                    Dim b() As Byte
                    ReDim b(0 To 1)
                    b(0) = &H94
                    b(1) = &H30
                    strChr = b
                    strRet = strRet & VBA.StrConv(strBuf, Conv) & strChr
                    strBuf = ""
                Else
                    strBuf = strBuf & c
                End If
            '���J
            Case "��"
                If strNext = "�J" And (Conv And vbKatakana) > 0 Then
                    strChr = "��"
                    strRet = strRet & VBA.StrConv(strBuf, Conv) & strChr
                    strBuf = ""
                    i = i + 1
                Else
                    strBuf = strBuf & c
                End If

            '����
            Case "��", "��"
                If (Conv And vbHiragana) > 0 Then
                    strRet = strRet & VBA.StrConv(strBuf, Conv) & c
                    strBuf = ""
                Else
                    strBuf = strBuf & c
                End If

            '���̑�
            Case Else
                '��񐅏���StrConv�ŕ�������������̂�ޔ�
                If Asc(c) = 63 And c <> "?" Then
                    strRet = strRet & VBA.StrConv(strBuf, Conv) & c
                    strBuf = ""
                Else
                    '���h
                    If Unicode(c) = &H3094 Then
                        If Conv = vbKatakana Then
                            strRet = strRet & VBA.StrConv(strBuf, Conv) & "��"
                            strBuf = ""
                        Else
                            strRet = strRet & VBA.StrConv(strBuf, Conv) & c
                            strBuf = ""
                        End If
                    Else
                        strBuf = strBuf & c
                    End If
                End If
        End Select
        
        '�P�O�̕���
        strBefore = c

    Next

    If strBuf <> "" Then
        strRet = strRet & VBA.StrConv(strBuf, Conv)
    End If

    StrConvU = strRet

End Function
Private Function Unicode(ByVal strBuf As String) As Long
    Dim bytBuf() As Byte
    
    If Len(strBuf) <> 0 Then
        bytBuf = strBuf
        Unicode = CLng(bytBuf(1)) * &H100 + bytBuf(0)
    End If
End Function

'--------------------------------------------------------------
'  RGB����CSS�\�L
'--------------------------------------------------------------
Function RGBToCSS(ByVal lngColor As Variant) As String

    Dim strBuf As String
    If IsNull(lngColor) Then
        RGBToCSS = "#000000"
    Else
        strBuf = Right$("000000" & Hex$(lngColor), 6)
        RGBToCSS = "#" & Mid$(strBuf, 5, 2) & Mid$(strBuf, 3, 2) & Mid$(strBuf, 1, 2)
    End If
End Function
'--------------------------------------------------------------
'  �g�s�l�k������̃T�j�^�C�W���O���s���B
'--------------------------------------------------------------
Public Function Sanitizing(ByVal strBuf As String) As String

    Dim strRep As String

    strRep = Replace(strRep, "&", "&amp;")
    strRep = Replace(strBuf, """", "&quot;")
    strRep = Replace(strRep, "<", "&lt;")
    strRep = Replace(strRep, ">", "&gt;")
    strRep = Replace(strRep, "'", "&#39;")
    Sanitizing = strRep

End Function
'----------------------------------------------------------------------------------
'�@���[�}�����ϊ�
'----------------------------------------------------------------------------------
Function ToRoman(ByVal lngNum As Long) As String

    Dim lng1000 As Long
    Dim lng500 As Long
    Dim lng100 As Long
    Dim lng50 As Long
    Dim lng10 As Long
    Dim lng5 As Long
    
    Dim strAns As String

    'M
    lng1000 = lngNum \ 1000
    lngNum = lngNum - 1000 * lng1000
    
    'D
    lng500 = lngNum \ 500
    lngNum = lngNum - 500 * lng500
    
    'C
    lng100 = lngNum \ 100
    lngNum = lngNum - 100 * lng100
    
    'L
    lng50 = lngNum \ 50
    lngNum = lngNum - 50 * lng50
    
    'X
    lng10 = lngNum \ 10
    lngNum = lngNum - 10 * lng10
    
    'V
    lng5 = lngNum \ 5
    lngNum = lngNum - 5 * lng5
    
    strAns = strAns & String(lng1000, "M")
    strAns = strAns & String(lng500, "D")
    strAns = strAns & String(lng100, "C")
    strAns = strAns & String(lng50, "L")
    strAns = strAns & String(lng10, "X")
    strAns = strAns & String(lng5, "V")
    strAns = strAns & String(lngNum, "I")
    
    '��O
    strAns = Replace(strAns, "DCCCC", "CM")
    strAns = Replace(strAns, "LXXXX", "XC")
    strAns = Replace(strAns, "VIIII", "IX")
    strAns = Replace(strAns, "CCCC", "CD")
    strAns = Replace(strAns, "XXXX", "XL")
    strAns = Replace(strAns, "IIII", "IV")
    
    ToRoman = strAns

End Function
