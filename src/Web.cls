VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Web"
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
'   RegExp.cls
'-----------------------------------------------------------------------------------------------------
' 2019-07-05 Ver.1.0.0 Web
'-----------------------------------------------------------------------------------------------------
Option Explicit
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
'--------------------------------------------------------------
' URL�`�F�b�N
'--------------------------------------------------------------
Public Function IsUrl(ByVal strURL As String) As Boolean
    
    IsUrl = RegExp.Test(strURL, "(^http://.*|^https://.*)")

End Function