VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Parser"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------------------------------------------
'
' [Hidennotare] v2
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
'>### Parser �N���X
'>
'>**Remarks**
'>
'>JSON�����񂩂�I�u�W�F�N�g���p�[�X����N���X�ł��B<br>
'>ArrayList��Dictionary����JSON�ɕϊ�����ɂ͊e�N���X��ToString���\�b�h�ŁB<br>
'>**���̃N���X�� Static�N���X(Attribute VB_PredeclaredId = True) �ł��B**
'>
'>**Dependent**
'>
'>* Message
'>* StringBuilder
'>* ArrayList
'>* Dictionary
'>* IList
'>* IDictionary
'>* INewInstance
'>* ICompatibleProperty
'>* StringHelper
'>* Convert
'>* ICursor
'>* CharCursor
'>
'-----------------------------------------------------------------------------------------------------
Option Explicit
'>---
'>#### ParseJSON(Parser)
'>
'>**Syntax**
'>
'>```
'>Set ret = Parser.ParseJSON(strJSON, [obj = Nothing])
'>```
'>
'>**Parameters**
'>
'>|Name|Required/Optional|Data type|Description|
'>---|---|---|---
'>|strJSON|�K�{|String|JSON��������w��|
'>|obj|�ȗ���|object/Collection|�I�u�W�F�N�g�i�ȗ��j�ȗ������ꍇ�AObject = Dictionary, Array = ArrayList �Ńp�[�X����܂��B<br>JSON�����񂪃l�X�g����Ă���A��������I�u�W�F�N�g���w�肵�����ꍇ�ACollection �ɃC���X�^���X��ݒ肵�����̂��w�肷��B|
'>
'>**Return Value**
'>
'>|Name|Data type|Description|
'>---|---|---
'>|ret|Object|�ϊ���̃I�u�W�F�N�g|
'>
'>**Remarks**
'>
'>JSON�����񂩂�Dictionary(OrderedDictionary/SortedDictionary) �܂��� ArrayList �𕜌�����@�\�B<br>
'>ICompatibleProperty(I/F)��INewInstance(I/F)�ɑΉ�����΁A�ʏ�̃N���X�ɂ������\�B
'>
'>**Example**
'>
'>�����w�肷��ꍇ�ACollection�ɋl�߂Ďw�肷��
'>
'>```
'>    Dim col As Collection
'>    Set col = new Collection
'>
'>    col.Add New OrderdDictionary  '�l�X�g��1���x���ڂɎg�p�����I�u�W�F�N�g
'>    col.Add New ArrayList         '�l�X�g��2���x���ڂɎg�p�����I�u�W�F�N�g
'>    col.Add New CustomPerson      '�l�X�g��3���x���ڂɎg�p�����I�u�W�F�N�g
'>
'>    Set dic = JSON.ParseJSON(strJSON, col)
'>```
'>
'>�P���w�肷��ꍇ�ACollection ��p�������ڎw�肷��
'>
'>```
'>    Set dic = JSON.ParseJSON(strJSON, New CustomPerson)
'>```
'>
'>**See also**
'>
'>* ArrayList
'>* Dictionary
'>* OrderdDictionary
'>* SortedDictionary
'>
Public Function ParseJSON(ByVal strJSON As String, Optional ByRef obj As Object = Nothing) As Object

    Dim PL As PairLoggerInfo: Set PL = PairLoggerInfo.CreateObject(TypeName(Me) & ".ParseJSON")
    
    Dim Level As Long
    
    Level = 0
    
    Select Case Left$(strJSON, 1)
        Case """"
            ParseJSON = ParseString(strJSON)
        Case "{"
            Set ParseJSON = ParseObject(strJSON, obj, Level)
        Case "["
            Set ParseJSON = ParseArray(strJSON, obj, Level)
    End Select

End Function
'-------------------------------------------------
' Object�̃p�[�X
'-------------------------------------------------
Private Function ParseObject(ByVal strJSON As String, obj As Object, ByVal Level As Long) As Object
    
    Dim objJObj As Object
    
    Dim propertyName As String
    Dim lineBreak As Boolean
    Dim SB As StringBuilder
    
    If Not Core.StartsWith(strJSON, "{") Or Not Core.EndsWith(strJSON, "}") Then
        Err.Raise 512 + 1, TypeName(Me) & ".ParseObject", "JSONFormatError"
    End If
    
    'JSON�̃l�X�g���x��
    Level = Level + 1
    
    Select Case True
        
        'Default
        Case obj Is Nothing
            Set objJObj = CoreEx.GetNewInstance(New Dictionary)
        
        '�l�X�g���x���w��
        Case TypeOf obj Is Collection
            Set objJObj = CoreEx.GetNewInstance(obj(Level))
        
        '���ڎw��
        Case Else
            Set objJObj = CoreEx.GetNewInstance(obj)
    
    End Select
    
    strJSON = Mid$(strJSON, 2, Len(strJSON) - 2)
    
    Dim IC As ICursor
    Set IC = CharCursor.CreateObject(strJSON)
    
    Do Until IC.Eof
        
        propertyName = ""
        Set SB = New StringBuilder
        lineBreak = False
        
        '�I���܂��͍s�̏I���
        Do Until IC.Eof Or lineBreak
        
            Select Case IC.Item
                Case """"
                    
                    If Len(propertyName) > 0 Then
                        
                        CoreEx.CastICompatibleProperty(objJObj).SetProperty propertyName, ParseString(StringExtraction(IC))
                        propertyName = ""
                    
                    Else
                        propertyName = ParseString(StringExtraction(IC))
                    End If
                    
                Case ":"
                    
                    If Len(propertyName) = 0 Then
                        Err.Raise 512 + 2, TypeName(Me) & ".ParseObject", "JSONFormatError"
                        Exit Function
                    End If
                    
                Case "["
                    
                    '���ʃ��x���̃p�[�X�iArray)
                    CoreEx.CastICompatibleProperty(objJObj).SetProperty propertyName, ParseArray(ElementExtraction(IC), obj, Level)
                    propertyName = ""
                    
                Case "{"
                    
                    '���ʃ��x���̃p�[�X�iObject)
                    CoreEx.CastICompatibleProperty(objJObj).SetProperty propertyName, ParseObject(ElementExtraction(IC), obj, Level)
                    propertyName = ""
                
                Case " ", vbTab, vbCr, vbLf, vbCrLf
                    '����
                
                Case ","
                    lineBreak = True
                
                Case Else
                    
                    SB.Append IC.Item
            
            End Select
            IC.MoveNext
        Loop
    
        If SB.Length > 0 Then
            
            If Len(propertyName) = 0 Then
                Err.Raise 512 + 3, TypeName(Me) & ".ParseObject", "JSONFormatError"
                Exit Function
            End If
            
            CoreEx.CastICompatibleProperty(objJObj).SetProperty propertyName, ParseValue(SB.ToString)
            
        End If
    
    Loop
    
    Set ParseObject = objJObj

End Function
'-------------------------------------------------
' Array�̃p�[�X
'-------------------------------------------------
Private Function ParseArray(strJSON As String, obj As Object, ByVal Level As Long) As IList
    
    Dim objAry As IList
    Dim lineBreak As Boolean
    Dim SB As StringBuilder
    
    If Not Core.StartsWith(strJSON, "[") Or Not Core.EndsWith(strJSON, "]") Then
        Err.Raise 512 + 1, TypeName(Me) & ".ParseArray", "JSONFormatError"
        Exit Function
    End If
    
    Level = Level + 1
    
    Select Case True
        
        Case obj Is Nothing
            Set objAry = CoreEx.GetNewInstance(New ArrayList)
        
        Case TypeOf obj Is Collection
            Set objAry = CoreEx.GetNewInstance(obj(Level))
        
        Case Else
            Set objAry = CoreEx.GetNewInstance(obj)
    
    End Select
    
    
    strJSON = Mid$(strJSON, 2, Len(strJSON) - 2)
    
    Dim IC As ICursor
    Set IC = CharCursor.CreateObject(strJSON)
    
    Do Until IC.Eof
    
        Set SB = New StringBuilder
        lineBreak = False
        
        Do Until IC.Eof Or lineBreak
        
            Select Case IC.Item
                Case """"
                    
                    objAry.Add ParseString(StringExtraction(IC))
                    
                Case "["
                    
                    '���ʃ��x���̃p�[�X�iArray)
                    objAry.Add ParseArray(ElementExtraction(IC), obj, Level)
                    
                Case "{"
                    
                    '���ʃ��x���̃p�[�X�iObject)
                    objAry.Add ParseObject(ElementExtraction(IC), obj, Level)
                
                Case " ", vbTab, vbCr, vbLf, vbCrLf
                    
                Case ","
                    lineBreak = True
                
                Case Else
                    
                    SB.Append IC.Item
            
            End Select
            
            IC.MoveNext
        
        Loop
    
        If SB.Length > 0 Then
            objAry.Add ParseValue(SB.ToString)
        End If
    
    Loop
    
    Set ParseArray = objAry

End Function
'-------------------------------------------------
' �_�u���R�[�e�[�V�����͈͎̔擾
'-------------------------------------------------
Private Function StringExtraction(ByRef IC As ICursor) As String
    
    Dim Buffer As String
    Dim doubleQuat As Long
    
    Dim SB As StringBuilder
    Set SB = New StringBuilder
    
    doubleQuat = 0
    Do Until IC.Eof
    
        SB.Append IC.Item
        
        If IC.Item = """" And IC.Item(-1) <> "\" Then
            doubleQuat = doubleQuat + 1
        End If
        If doubleQuat = 2 Then
            Exit Do
        End If
        
        IC.MoveNext
    
    Loop
    
    If SB.Length > 0 Then
        StringExtraction = SB.ToString
        Exit Function
    End If
        
    Err.raie 512 + 1, TypeName(Me) & "StringExtraction", "JSONFormatError"
End Function
'-------------------------------------------------
' �p�J�b�R�܂��͔g�J�b�R�͈͎̔擾
'-------------------------------------------------
Private Function ElementExtraction(ByRef IC As ICursor) As String
    
    Dim squareBrackets As Long
    Dim curlyBraces As Long
    
    Dim sw As Boolean
    Dim SB As StringBuilder
    
    sw = False
    Set SB = New StringBuilder
    
    Do Until IC.Eof
        
        SB.Append IC.Item
        
        If IC.Item = """" And IC.Item(-1) <> "\" Then
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
            ElementExtraction = SB.ToString
            Exit Function
        End If
        
        IC.MoveNext
    Loop
    
    Err.Raise 512 + 1, TypeName(Me) & ".ElementExtraction", "JSONFormatError"
End Function
'---------------------------------------------------------------------
' ������̃p�[�X
'---------------------------------------------------------------------
Private Function ParseString(strJSON As String) As String
    
    If Not Core.StartsWith(strJSON, """") Or Not Core.EndsWith(strJSON, """") Then
        Err.Raise 512 + 1, TypeName(Me) & ".ParseString", "JSONFormatError"
        Exit Function
    End If
    
    '�O��̃_�u���R�[�e�[�V�������폜
    strJSON = Mid$(strJSON, 2, Len(strJSON) - 2)
    
    '�������UnEscape
    ParseString = Core.Unescape(strJSON)

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


'>---
'>#### ParseFromListbox(Parser)
'>
'>**Syntax**
'>
'>```
'>Set ret = Parser.ParseFromListbox(objList,[obj = Nothing])
'>```
'>
'>**Parameters**
'>
'>|Name|Required/Optional|Data type|Description|
'>---|---|---|---
'>|objList|�K�{|Object|Parse���� ListBox or ComboBox ���w��|
'>|obj|�ȗ���|Object|���R�[�h�Ɏg�p����I�u�W�F�N�g���w��B�ȗ����� Dictionary |
'>
'>**Return Value**
'>
'>|Name|Data type|Description|
'>---|---|---
'>|ret|Boolean|�V�����C���X�^���X(ArrayList)|
'>
'>
'>**Remarks**
'>
'>ListBox/ComboBox �p�[�X<br>
'>ListBox/ComboBox����ArrayList(���R�[�h��Dictionary)�𐶐�����B<br>
'>Tag�Ƀ��R�[�h�𐶐����邽�߂̃t�B�[���h�����X�g�i�J���}��؂�j���K�{�B<br>
'>���R�[�h�Ɏg�p����I�u�W�F�N�g�� INewInstance �� ICompatibleProperty �� Implements �����N���X�ł��邱�ƁB
'>
'>**Example**
'>
'>```
'>    '����̓R�[�h�ł͂Ȃ��v���p�e�B�E�B���h�E�Őݒ肵�Ă��ǂ�
'>    lstFavorite.Tag = "No,Name,Address"
'>
'>    Dim lst As IList
'>    Set lst = Parser.ParseFromListbox(lstFavorite, New FavoriteBean)
'>
'>```
'>
'>**See also**
'>
'>* Parser.CopyToListbox
'>* Dictionary
'>* INewInstance
'>* ICompatibleProperty
'>
Public Function ParseFromListbox(objList As Object, Optional obj As Object = Nothing) As IList

    Dim ary As IList
    Dim objRec As Object
    Dim Fields As Variant
    Dim i As Long
    Dim j As Long
    
    'Tag�Ƀt�B�[���h��񂪖����ꍇ
    If objList.Tag = "" Then
        Err.Raise 512 + 1, TypeName(Me) & ".ParseFromListbox", "Item name is not set in tag"
    End If
    
    '�z��ɕϊ�
    Fields = Split(objList.Tag, ",")
    
    '�����ɂ��C���X�^���X������I�u�W�F�N�g�𔻒�
    Select Case True
        Case obj Is Nothing
            Set ary = New ArrayList
        Case Else
            If TypeOf obj Is Collection Then
                Set ary = CoreEx.GetNewInstance(obj(1))
            Else
                Set ary = New ArrayList
            End If
    End Select
        
    For i = 0 To objList.ListCount - 1
        
        '�����ɂ��C���X�^���X������I�u�W�F�N�g�𔻒�
        Select Case True
            Case obj Is Nothing
                Set objRec = New Dictionary
            Case Else
                If TypeOf obj Is Collection Then
                    Set objRec = CoreEx.GetNewInstance(obj(2))
                Else
                    Set objRec = CoreEx.GetNewInstance(obj)
                End If
        End Select
        
        For j = 0 To objList.ColumnCount - 1
        
            '�ݒ肳��Ă���t�B�[���h�̂݃R�s�[����B
            If Fields(j) <> "" Then
                CoreEx.CastICompatibleProperty(objRec).SetProperty Fields(j), objList.List(i, j)
            End If
        Next
            
        ary.Add objRec
    
    Next

    Set ParseFromListbox = ary

End Function
'>---
'>#### ParseFromListObject(Parser)
'>
'>**Syntax**
'>
'>```
'>Set ret = Parser.ParseFromListObject(objList,[obj = Nothing])
'>```
'>
'>**Parameters**
'>
'>|Name|Required/Optional|Data type|Description|
'>---|---|---|---
'>|objList|�K�{|Listobject|Parse���� Listobject ���w��|
'>|obj|�ȗ���|Object|���R�[�h�Ɏg�p����I�u�W�F�N�g���w��B�ȗ����� Dictionary |
'>
'>**Return Value**
'>
'>|Name|Data type|Description|
'>---|---|---
'>|ret|Boolean|�V�����C���X�^���X(ArrayList)|
'>
'>**Remarks**
'>
'>ListObject �p�[�X<br>
'>Listobject����ArrayList(���R�[�h��Dictionary)�𐶐�����B<br>
'>ListObject(�e�[�u��)�̗�w�b�_�̏�񂪕K�{<br>
'>���R�[�h�Ɏg�p����I�u�W�F�N�g�� INewInstance �� ICompatibleProperty �� Implements �����N���X�ł��邱�ƁB
'>
'>**Example**
'>
'>```
'>Sub ArrayList_ParseFromListObject_Sample()
'>
'>    Dim lst As IList
'>    Dim dic As IDictionary
'>    Dim Key As Variant
'>
'>    Set lst = Parser.ParseFromListObject(ActiveSheet.ListObjects(1))
'>
'>    For Each dic In lst
'>
'>        For Each Key In dic.Keys
'>
'>            Debug.Print dic.Item(Key)
'>
'>        Next
'>
'>    Next
'>
'>    Dim a As ArrayList
'>
'>    Set a = lst
'>
'>    a.CopyToListObject ActiveSheet.ListObjects(2)
'>
'>End Sub
'>
'>```
'>
'>**See also**
'>
'>* Parser.CopyToListObject
'>* Dictionary
'>* INewInstance
'>* ICompatibleProperty
'>
Public Function ParseFromListObject(LO As ListObject, Optional obj As Object = Nothing) As IList

    Dim lst As IList
    Dim objRec As Object
    Dim i As Long
    Dim j As Long
    
    '�����ɂ��C���X�^���X������I�u�W�F�N�g�𔻒�
    Select Case True
        Case obj Is Nothing
            Set lst = New ArrayList
        Case Else
            If TypeOf obj Is Collection Then
                Set lst = CoreEx.GetNewInstance(obj(1))
            Else
                Set lst = New ArrayList
            End If
    End Select
        
    For i = 1 To LO.DataBodyRange.Rows.Count
        
        '�����ɂ��C���X�^���X������I�u�W�F�N�g�𔻒�
        Select Case True
            Case obj Is Nothing
                Set objRec = New Dictionary
            Case Else
                If TypeOf obj Is Collection Then
                    Set objRec = CoreEx.GetNewInstance(obj(2))
                Else
                    Set objRec = CoreEx.GetNewInstance(obj)
                End If
        End Select
        
        For j = 1 To LO.HeaderRowRange.Columns.Count
        
            CoreEx.CastICompatibleProperty(objRec).SetProperty LO.HeaderRowRange(, j).Value, LO.DataBodyRange.Cells(i, j).Value
        Next
    
        lst.Add objRec
    
    Next

    Set ParseFromListObject = lst

End Function
'--------------------------------------------------------------
' CSV�p�[�T�[ RFC4180����
' �R�[�e�[�V�����̗L��, �f���~�^�w�肠��
'--------------------------------------------------------------
Public Function ParseCsv(ByVal strBuf As String, Optional ByVal Quatation As Boolean = False, Optional ByVal Delimiter As String = ",") As Collection

    Const C_QUAT As String = """"
    Dim IC As ICursor
    Dim sw As Boolean
    Dim blnLineBreak As Boolean
    Dim blnItemBreak As Boolean
    Dim col As Collection
    Dim Row As Collection
    Dim lngQuot As Long
    
    lngQuot = 0
    
    sw = False
    
    Set Row = New Collection
    
    Set IC = CharCursor.CreateObject(strBuf)
    Do Until IC.Eof
        
        '������
        Set col = New Collection
        blnLineBreak = False

        Do Until IC.Eof Or blnLineBreak
        
            '������
            Dim SB As StringBuilder
            Set SB = New StringBuilder
            blnItemBreak = False
            
            Do Until IC.Eof Or blnLineBreak Or blnItemBreak

                Select Case IC.Item
                    Case C_QUAT

                        '�R�[�e�[�V��������̏ꍇ
                        If Quatation Then

                            lngQuot = lngQuot + 1

                            If sw Then

                                '���̕�����Quatation
                                If IC.Item(1) = C_QUAT Then
                                    lngQuot = lngQuot + 1
                                    SB.Append C_QUAT
                                    IC.MoveNext
                                Else
                                    sw = False
                                End If

                            Else
                                sw = True
                            End If
                        End If

                    Case vbCr

                        If sw Then
                            SB.Append IC.Item
                        End If

                    Case vbLf

                        If sw Then
                            SB.Append IC.Item
                        Else
                            blnLineBreak = True
                        End If

                    Case Delimiter

                        If sw Then
                            SB.Append IC.Item
                        Else
                            blnItemBreak = True
                        End If

                    Case Else

                        SB.Append IC.Item

                End Select
            
                IC.MoveNext
            Loop
            
            '��ǉ�����
            col.Add SB.ToString
            
        Loop
        
        '�s�ǉ�����
        Row.Add col
        
    Loop
    
    '�_�u���R�[�e�[�V�����������ł͂Ȃ��ꍇ
    If lngQuot Mod 2 <> 0 Then
        Err.Raise 512 + 1, TypeName(Me) & ".CsvParser", "Invalid Format(Quotation)"
    End If
    
    Set ParseCsv = Row
    
End Function
