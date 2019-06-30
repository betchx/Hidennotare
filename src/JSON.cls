VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "JSON"
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
' ���̃N���X�͌�����JSON�ł͂Ȃ�VBA�ŃI�u�W�F�N�g�̃V���A���C�Y�^�f�V���A���C�Y�ɓ������Ă��܂��B
'-----------------------------------------------------------------------------------------------------
' �ˑ����W���[��
'   �Ȃ�
'-----------------------------------------------------------------------------------------------------
' 2018-12-16 Ver.1.0.0 �V�K�쐬
'-----------------------------------------------------------------------------------------------------
Option Explicit

'---------------------------------------------------------------
' JSON�p�[�X
'---------------------------------------------------------------
Public Function ParseJSON(ByVal strJSON As String) As Object

    Select Case Left$(strJSON, 1)
        Case """"
            ParseJSON = ParseString(strJSON)
        Case "{"
            Set ParseJSON = ParseObject(strJSON)
        Case "["
            Set ParseJSON = ParseArray(strJSON)
    End Select

End Function

'-------------------------------------------------
' Object�̃p�[�X
'-------------------------------------------------
Public Function ParseObject(ByVal strJSON As String) As Dictionary
    
    Dim objDic As Dictionary
    Dim propertyName As String
    Dim valueBuffer As String
    Dim lineBreak As Boolean
    
    If Not StringHelper.StartsWith(strJSON, "{") Or Not StringHelper.EndsWith(strJSON, "}") Then
        Message.Throw 1, Me, "ParseObject", "JSONFormatError"
    End If
    
    Set objDic = New Dictionary
    
    strJSON = Mid$(strJSON, 2, Len(strJSON) - 2)
    
    Dim IC As ICursor
    Set IC = Constructor(New CharCursor, strJSON)
    
    Do Until IC.Eof
        
        propertyName = ""
        valueBuffer = ""
        lineBreak = False
        
        '�I���܂��͍s�̏I���
        Do Until IC.Eof Or lineBreak
        
            Select Case IC.Item
                Case """"
                    
                    If Len(propertyName) > 0 Then
                        
                        objDic.Add propertyName, ParseString(StringExtraction(IC))
                        propertyName = ""
                    
                    Else
                        propertyName = ParseString(StringExtraction(IC))
                    End If
                    
                Case ":"
                    
                    If Len(propertyName) = 0 Then
                        Message.Throw 2, Me, "ParseObject", "JSONFormatError"
                        Exit Function
                    End If
                    
                Case "["
                    
                    objDic.Add propertyName, ParseArray(ElementExtraction(IC))
                    propertyName = ""
                    
                Case "{"
                    
                    objDic.Add propertyName, ParseObject(ElementExtraction(IC))
                    propertyName = ""
                
                Case " ", vbTab, vbCr, vbLf, vbCrLf
                
                Case ","
                    lineBreak = True
                Case Else
                    
                    valueBuffer = valueBuffer & IC
            
            End Select
            IC.MoveNext
        Loop
    
        If Len(valueBuffer) > 0 Then
            
            If Len(propertyName) = 0 Then
                Message.Throw 3, Me, "ParseObject", "JSONFormatError"
                Exit Function
            End If
            
            objDic.Add propertyName, ParseValue(valueBuffer)
            
        End If
    
    Loop

    Set ParseObject = objDic

End Function
'-------------------------------------------------
' Array�̃p�[�X
'-------------------------------------------------
Public Function ParseArray(strJSON As String) As ArrayList
    
    Dim objAry As IList
    Dim itemBuffer As String
    Dim lineBreak As Boolean
    
    If Not StringHelper.StartsWith(strJSON, "[") Or Not StringHelper.EndsWith(strJSON, "]") Then
        Message.Throw 1, Me, "ParseArray", "JSONFormatError"
        Exit Function
    End If
    
    Set objAry = New ArrayList
    
    strJSON = Mid$(strJSON, 2, Len(strJSON) - 2)
    
    Dim IC As ICursor
    Set IC = Constructor(New CharCursor, strJSON)
    
    Do Until IC.Eof
    
        itemBuffer = ""
        lineBreak = False
        
        Do Until IC.Eof Or lineBreak
        
            Select Case IC.Item
                Case """"
                    
                    objAry.Add ParseString(StringExtraction(IC))
                    
                Case "["
                    
                    objAry.Add ParseArray(ElementExtraction(IC))
                    
                Case "{"
                    
                    objAry.Add ParseObject(ElementExtraction(IC))
                
                Case " ", vbTab, vbCr, vbLf, vbCrLf
                    
                Case ","
                    lineBreak = True
                
                Case Else
                    itemBuffer = itemBuffer & IC
            
            End Select
            
            IC.MoveNext
        
        Loop
    
        If Len(itemBuffer) > 0 Then
        
            objAry.Add ParseValue(itemBuffer)
        
        End If
    
    Loop
    
    Set ParseArray = objAry

End Function
'-------------------------------------------------
' �_�u���R�[�e�[�V�����͈͎̔擾
'-------------------------------------------------
Private Function StringExtraction(ByRef IC As ICursor) As String
    
    Dim buffer As String
    Dim doubleQuat As Long
    
    buffer = ""
        
    doubleQuat = 0
    Do Until IC.Eof
    
        buffer = buffer & IC
        
        If IC = """" And IC.PreviousItem <> "\" Then
            doubleQuat = doubleQuat + 1
        End If
        If doubleQuat = 2 Then
            Exit Do
        End If
        
        IC.MoveNext
    
    Loop
    
    If Len(buffer) > 1 Then
        StringExtraction = buffer
        Exit Function
    End If
        
    Message.Throw 1, Me, "StringExtraction", "JSONFormatError"
End Function
'-------------------------------------------------
' �p�J�b�R�܂��͔g�J�b�R�͈͎̔擾
'-------------------------------------------------
Private Function ElementExtraction(ByRef IC As ICursor) As String
    
    Dim strBuf As String
    
    Dim squareBrackets As Long
    Dim curlyBraces As Long
    
    Dim sw As Boolean
    
    sw = False
    strBuf = ""
    
    Do Until IC.Eof
        
        strBuf = strBuf & IC.Item
        
        If IC.Item = """" And IC.PreviousItem <> "\" Then
            sw = Not sw
        End If
        
        If Not sw Then
            
            Select Case IC.Item
                Case "["
                    squareBrackets = squareBrackets + 1
                
                Case "]"
                    squareBrackets = squareBrackets - 1
                    
                Case "{"
                    curlyBraces = curlyBraces + 1
                    
                Case "}"
                    curlyBraces = curlyBraces - 1
            End Select
        
        End If
        
        If squareBrackets = 0 And curlyBraces = 0 Then
            ElementExtraction = strBuf
            Exit Function
        End If
        
        IC.MoveNext
    Loop
    
    Message.Throw 1, Me, "ElementExtraction", "JSONFormatError"
End Function
'---------------------------------------------------------------------
' ������̃p�[�X
'---------------------------------------------------------------------
Public Function ParseString(strJSON As String) As String
    
    If Not StringHelper.StartsWith(strJSON, """") Or Not StringHelper.EndsWith(strJSON, """") Then
        Message.Throw 1, Me, "ParseString", "JSONFormatError"
        Exit Function
    End If
    
    '�O��̃_�u���R�[�e�[�V�������폜
    strJSON = Mid$(strJSON, 2, Len(strJSON) - 2)
    
    '�������UnEscape
    ParseString = Convert.UnEscape(strJSON)

End Function
'---------------------------------------------------------------------
' �l�̃p�[�X
'---------------------------------------------------------------------
Private Function ParseValue(ByVal strJSON As String) As Variant

    Select Case True
        Case LCase(strJSON) = "null"
           
           ParseValue = Empty
        
        Case LCase(strJSON) = "true" Or LCase(strJSON) = "false"
           
           ParseValue = CBool(strJSON)
        
        Case IsNumeric(strJSON)
            
            ParseValue = Val(strJSON)
        
        Case Else
            
            ParseValue = strJSON
    
    End Select

End Function