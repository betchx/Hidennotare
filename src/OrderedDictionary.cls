VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "OrderedDictionary"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'-----------------------------------------------------------------------------------------------------
'
' [MLangBuilder] v1
'
' Copyright (c) 2019 Yasuhiro Watanabe
' https://github.com/RelaxTools/MFunctionCreater
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
' OrderedDictionary �N���X
' �Ϗ� : Dictionary
'-----------------------------------------------------------------------------------------------------
' TODO:Orderd �Ȃ̂Œǉ������ێ����邽�ߍ폜�̃p�t�H�[�}���X�͈����̂Œ��ӂ��ׂ��B
' Collection���g�p���Ȃ����R�́ACollection�͑啶���������𓯈ꎋ���邽�߁B
'-----------------------------------------------------------------------------------------------------
Option Explicit
Implements ICursor
Implements IDictionary
Implements INewInstance
Implements IJSONObject

'VBA�ł́u�p���v���ł��Ȃ����߁u�Ϗ��v����B
Private mDic As IDictionary
Private mCP As IComparer
Private mIndex As Long
Private mKeys As Variant
Private Sub Class_Initialize()
    Set mDic = New Dictionary
    mIndex = 0
    mKeys = Array()
End Sub
Private Sub Class_Terminate()
    Set mDic = Nothing
End Sub
'--------------------------------------------------------------
'  IDictionary I/F �擾
'--------------------------------------------------------------
Public Function GetIDictionary() As IDictionary
    Set GetIDictionary = Me
End Function

Private Function IDictionary_Add(ByVal KeyValue As String, obj As Variant)
    
    mDic.Add KeyValue, obj
    
    '�z��ɃL�[�[��ۑ�
    ReDim Preserve mKeys(0 To mDic.Count - 1)
    mKeys(mDic.Count - 1) = KeyValue

End Function
Private Function IDictionary_ContainsKey(ByVal KeyValue As String) As Boolean
    IDictionary_ContainsKey = mDic.ContainsKey(KeyValue)
End Function
'--------------------------------------------------------------
'  �\�[�g�ς݃L�[���X�g�擾
'--------------------------------------------------------------
Private Property Get IDictionary_Keys() As Variant
   
    IDictionary_Keys = mKeys

End Property
Private Property Get IDictionary_Count() As Long
    IDictionary_Count = mDic.Count
End Property
Private Property Get IDictionary_Item(ByVal KeyValue As String) As Variant
    If VBA.IsObject(mDic.Item(KeyValue)) Then
        Set IDictionary_Item = mDic.Item(KeyValue)
    Else
        IDictionary_Item = mDic.Item(KeyValue)
    End If
End Property
Private Property Let IDictionary_Item(ByVal KeyValue As String, NewItem As Variant)
    mDic.Item(KeyValue) = NewItem
End Property
Private Property Set IDictionary_Item(ByVal KeyValue As String, NewItem As Variant)
    Set mDic.Item(KeyValue) = NewItem
End Property
Private Property Let IDictionary_Key(ByVal OldKey As String, NewKey As Variant)
    
    mDic.Key(OldKey) = NewKey
    
    Dim i As Long
    For i = LBound(mKeys) To UBound(mKeys)
        If mKeys(i) = OldKey Then
            mKeys(i) = NewKey
            Exit Property
        End If
    Next
    
End Property
Private Sub IDictionary_Remove(ByVal KeyValue As String)
    
    mDic.Remove KeyValue
    
    If mDic.Count = 0 Then
        mKeys = Array()
    Else
    
        Dim lngCnt As Long
        Dim i As Long
        Dim j As Long
        Dim NewKeys As Variant
        
        NewKeys = Array()
        
        lngCnt = mDic.Count - 1
        
        ReDim NewKeys(0 To lngCnt)
        
        j = 0
        For i = LBound(mKeys) To UBound(mKeys)
            If mKeys(i) <> KeyValue Then
                NewKeys(j) = mKeys(i)
                j = j + 1
            End If
        Next
    
        mKeys = NewKeys
    
    End If

End Sub
Private Sub IDictionary_Clear()
    mDic.Clear
    mKeys = Array()
End Sub
Private Function IDictionary_ToString() As String
    IDictionary_ToString = mDic.ToString
End Function
Private Property Get IDictionary_GetCursor() As ICursor
    Set IDictionary_GetCursor = Me
End Property
'--------------------------------------------------------------
'  ICursor �� Eof �v���p�e�B���擾
'--------------------------------------------------------------
Private Property Get ICursor_Eof() As Boolean
    ICursor_Eof = mIndex > mDic.Count - 1
End Property
'--------------------------------------------------------------
'  ICursor �� Item �v���p�e�B���擾
'--------------------------------------------------------------
Private Property Get ICursor_Item(Optional ByVal opt As Variant) As Variant
    
    If mIndex > mDic.Count - 1 Then
        ICursor_Item = mKeys(mDic.Count - 1)
    Else
        ICursor_Item = mKeys(mIndex)
    End If

End Property
'--------------------------------------------------------------
'  ICursor �� �J�[�\���ʒu��������
'--------------------------------------------------------------
Private Sub ICursor_MoveFirst()
    mIndex = 0
End Sub
'--------------------------------------------------------------
'  ICursor �� �J�[�\���ʒu�����Ɉړ�
'--------------------------------------------------------------
Private Sub ICursor_MoveNext()

    mIndex = mIndex + 1
    If mIndex > mDic.Count Then
        mIndex = mDic.Count
    End If

End Sub
'--------------------------------------------------------------
' �C���X�^���X���� I/F
'--------------------------------------------------------------
Private Function INewInstance_NewInstance() As Object

    Dim d As IDictionary
    
    Set d = New OrderedDictionary

    Set INewInstance_NewInstance = d

End Function
'--------------------------------------------------------------
' JSON Object I/F
'--------------------------------------------------------------
Private Sub IJSONObject_SetProperty(prop As Variant, Val As Variant)
    Me.GetIDictionary.Add prop, Val
End Sub
