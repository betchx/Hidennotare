VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CheckDigit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'-----------------------------------------------------------------------------------------------------
'
' [Hidennotare] v1
'
' Copyright (c) 2019 Yasuhiro Watanabe
' https://github.com/RelaxTools/Hidennotare
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
Option Explicit
'--------------------------------------------------------------
'�@Luhn�A���S���Y���iISO/IEC 7812-1�j
'�@�N���W�b�g�J�[�h�ԍ��̃`�F�b�N
'--------------------------------------------------------------
Function IsLuhn(ByVal strNo As String) As Boolean

    Dim lngLen As Long
    Dim lngOdd As Long
    Dim lngEvn As Long
    
    Dim i As Long
    
    Dim lngAns As Long
    
    Dim strCheckDigit As String
    
    lngLen = Len(strNo)
    lngOdd = 0
    lngEvn = 0

    If lngLen < 2 Then
        IsLuhn = False
        Exit Function
    End If
    
    If RegExp.Test(strNo, "[0-9]*") Then
    Else
        IsLuhn = False
        Exit Function
    End If
    
    For i = 1 To lngLen
    
        If (i Mod 2) = 1 Then
            '����݂̂����Z�i�`�F�b�N�f�B�W�b�g�������j
            lngOdd = lngOdd + Val(Mid$(strNo, lngLen - i + 1, 1))
        Else
            '�������݂̂����Z
            Dim lngWork As Long
            lngWork = Val(Mid$(strNo, lngLen - i + 1, 1)) * 2
            lngEvn = lngEvn + Fix(lngWork / 10) + lngWork Mod 10
        End If
    
    Next

    lngAns = (lngOdd + lngEvn) Mod 10

    If lngAns = 0 Then
        IsLuhn = True
    Else
        IsLuhn = False
    End If

End Function
'--------------------------------------------------------------
'�@�}�C�i���o�[�`�F�b�N�f�W�b�g�i�l�j
'--------------------------------------------------------------
Function IsMyNumber(ByVal strNo As String) As Boolean

 '�}�C�i���o�[�`�F�b�N�f�W�b�g�`�F�b�N
    Dim strBuf As String
    Dim i As Long
    Dim c As Long
    Dim sum As Long
    Dim ANS As Long
    Dim cd As Long
    
    IsMyNumber = False
    
    If RegExp.Test(strNo, "[0-9]{12}") Then
    Else
        Exit Function
    End If
    
'    If Len(strNo) <> 12 Then
'        Exit Function
'    End If
    
    sum = 0

    For i = 0 To 11
    
        c = Val(Mid$(strNo, 11 - i + 1, 1))
        
        Select Case i
            Case 1 To 6
                sum = sum + c * (i + 1)
            Case 7 To 11
                sum = sum + c * (i - 5)
            Case 0
                cd = c
        End Select
    
    Next
    
    sum = sum Mod 11
    
    Select Case sum
        Case 0, 1
            ANS = 0
        Case Else
            ANS = 11 - sum
    End Select

    IsMyNumber = (ANS = cd)
    
End Function
'--------------------------------------------------------------
'�@�}�C�i���o�[�`�F�b�N�f�W�b�g(���)
'--------------------------------------------------------------
Function IsCorpNumber(ByVal strNo As String) As Boolean

    '�@�l�ԍ��`�F�b�N�f�W�b�g�`�F�b�N
    Dim strBuf As String
    Dim i As Long
    Dim c As Long
    Dim sum As Long
    Dim ANS As Long
    Dim cd As Long
    
    IsCorpNumber = False
    
    If RegExp.Test(strNo, "[0-9]{13}") Then
    Else
        Exit Function
    End If
    
'    If Len(strNo) <> 13 Then
'        Exit Function
'    End If
    
    sum = 0

    For i = 1 To 13
    
        c = Val(Mid$(strNo, 13 - i + 1, 1))
        
        Select Case i
            Case 1 To 12
                sum = sum + c * IIf(i Mod 2, 1, 2)
            Case 13
                cd = c
        End Select
    
    Next
    
    sum = sum Mod 9
    
    ANS = 9 - sum

    IsCorpNumber = (ANS = cd)

    
End Function
'--------------------------------------------------------------
'�@���W�����X�P�O/�E�F�C�g3-1
'--------------------------------------------------------------
Function IsModulus10(ByVal strNo As String) As Boolean

    Dim lngLen As Long
    Dim lngOdd As Long
    Dim lngEvn As Long
    
    Dim i As Long
    
    Dim lngAns As Long
    
    Dim lngCheckDigit As Long
    
    lngLen = Len(strNo)
    lngOdd = 0
    lngEvn = 0
    
    If lngLen < 2 Then
        IsModulus10 = False
        Exit Function
    End If
    
    If RegExp.Test(strNo, "[0-9]*") Then
    Else
        IsModulus10 = False
        Exit Function
    End If

    For i = 1 To lngLen
    
        If i = 1 Then
            lngCheckDigit = Val(Mid$(strNo, lngLen - i + 1, 1))
        Else
            If (i Mod 2) = 1 Then
                '����݂̂����Z�i�`�F�b�N�f�B�W�b�g�������j
                lngOdd = lngOdd + Val(Mid$(strNo, lngLen - i + 1, 1))
            Else
                '�������݂̂����Z
                lngEvn = lngEvn + Val(Mid$(strNo, lngLen - i + 1, 1))
            End If
        End If
    Next

    '��̉��Z�Ƌ����̉��Z���R�{�������̂����Z�B���P�����P�O�������
    lngAns = 10 - (lngOdd + lngEvn * 3) Mod 10

    If lngAns = lngCheckDigit Then
        IsModulus10 = True
    Else
        IsModulus10 = False
    End If

End Function
'--------------------------------------------------------------
'�@���W�����X�P�P�E�F�C�g10-2
'--------------------------------------------------------------
Function IsModulus11_10_2(ByVal strNo As String) As Boolean

    Dim lngLen As Long
    Dim lngWork As Long
    Dim lngWeight As Long
    
    Dim i As Long
    
    Dim lngAns As Long
    
    Dim lngCheckDigit As Long
    
    lngLen = Len(strNo)
    lngWork = 0
    
    If lngLen < 2 Then
        IsModulus11_10_2 = False
        Exit Function
    End If

    For i = 1 To lngLen
    
        If i = 1 Then
            lngCheckDigit = xVal(Mid$(strNo, lngLen - i + 1, 1))
        Else
            Select Case (i Mod 9)
                Case 2
                    lngWeight = 2
                Case 3
                    lngWeight = 3
                Case 4
                    lngWeight = 4
                Case 5
                    lngWeight = 5
                Case 6
                    lngWeight = 6
                Case 7
                    lngWeight = 7
                Case 8
                    lngWeight = 8
                Case 0
                    lngWeight = 9
                Case 1
                    lngWeight = 10
            End Select
            lngWork = lngWork + (Val(Mid$(strNo, lngLen - i + 1, 1)) * i)
        End If
    Next

    lngAns = (11 - (lngWork Mod 11)) Mod 11


    If lngAns = lngCheckDigit Then
        IsModulus11_10_2 = True
    Else
        IsModulus11_10_2 = False
    End If

End Function
'--------------------------------------------------------------
'�@ISBN�R�[�h�Ń`�F�b�N�f�B�W�b�g���w�ɂȂ����ꍇ�̕ϊ��B
'--------------------------------------------------------------
Private Function xVal(ByVal strNo) As Long
    If LCase(strNo) = "x" Then
        xVal = 10
    Else
        xVal = Val(strNo)
    End If
End Function
'--------------------------------------------------------------
'�@���W�����X�P�P�E�F�C�g2-7
'--------------------------------------------------------------
Function IsModulus11_2_7(ByVal strNo As String) As Boolean

    Dim lngLen As Long
    Dim lngWork As Long
    Dim lngWeight As Long
    
    Dim i As Long
    
    Dim lngAns As Long
    
    Dim lngCheckDigit As Long
    
    lngLen = Len(strNo)
    lngWork = 0
    
    If lngLen < 2 Then
        IsModulus11_2_7 = False
        Exit Function
    End If
    
    If RegExp.Test(strNo, "[0-9]*") Then
    Else
        IsModulus11_2_7 = False
        Exit Function
    End If

    For i = 1 To lngLen
    
        If i = 1 Then
            lngCheckDigit = Val(Mid$(strNo, lngLen - i + 1, 1))
        Else
            Select Case (i Mod 6)
                Case 2
                    lngWeight = 2
                Case 3
                    lngWeight = 3
                Case 4
                    lngWeight = 4
                Case 5
                    lngWeight = 5
                Case 0
                    lngWeight = 6
                Case 1
                    lngWeight = 7
            End Select
            lngWork = lngWork + (Val(Mid$(strNo, lngLen - i + 1, 1)) * lngWeight)
        End If
    Next

    lngAns = (11 - (lngWork Mod 11))

    If lngAns = lngCheckDigit Then
        IsModulus11_2_7 = True
    Else
        IsModulus11_2_7 = False
    End If

End Function
'--------------------------------------------------------------
'�@���W�����X11/�n�������c�̃R�[�h
'--------------------------------------------------------------
Function IsModulus11_Pref(ByVal strNo As String) As Boolean

    Dim lngLen As Long
    Dim lngWork As Long
    Dim lngMod As Long
    
    Dim i As Long
    
    Dim lngAns As Long
    
    Dim lngCheckDigit As Long
    
    lngLen = Len(strNo)
    lngWork = 0
    
    If lngLen < 2 Then
        IsModulus11_Pref = False
        Exit Function
    End If
    
    If RegExp.Test(strNo, "[0-9]*") Then
    Else
        IsModulus11_Pref = False
        Exit Function
    End If
    
    For i = 1 To lngLen
    
        If i = 1 Then
            lngCheckDigit = Val(Mid$(strNo, lngLen - i + 1, 1))
        Else
            lngWork = lngWork + (Val(Mid$(strNo, lngLen - i + 1, 1)) * i)
        End If
    Next

    lngMod = lngWork Mod 11
    Select Case lngMod
        Case 0
            lngAns = 1
        Case 1
            lngAns = 0
        Case Else
            lngAns = 11 - lngMod
    End Select

    If lngAns = lngCheckDigit Then
        IsModulus11_Pref = True
    Else
        IsModulus11_Pref = False
    End If

End Function
