VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "RangeCursor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
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
' Range�ǂݍ��݃N���X
'-----------------------------------------------------------------------------------------------------
' Dim IC As ICursor
' Set IC = Constructor(New RangeCursor, Renge�͈�)
' Do Until IC.Eof
'     Debug.Print IC(1).Value '�͈͂̂P���
'     IC.MoveNext
' Loop
'-----------------------------------------------------------------------------------------------------
Option Explicit
Implements IConstructor
Implements ICursor

'Range
Private mRange As Range

'�������J�[�\��
Private mStartRow As Long
Private mEofCol As Variant
Private mRow As Long
'--------------------------------------------------------------
' �R���X�g���N�^
'--------------------------------------------------------------
' Arg1 - Range   : UsedRange/ActiveSheet.Range(ActiveSheet.PrintArea) etc...
'--------------------------------------------------------------
Private Function IConstructor_Instancing(ByRef Args As Collection) As Object

    Const RANGE_AREA As Long = 1  '�����P�@RANGE �I�u�W�F�N�g
    
    Select Case Args.Count
        Case 1
        Case Else
            Exit Function
    End Select
    
    Set mRange = Args(RANGE_AREA)
                
    mRow = 1
    mStartRow = mRow
    
    SkipHiddenRow
    
    Set IConstructor_Instancing = Me

End Function
'------------------------------------------------------
' �f�X�g���N�^
'------------------------------------------------------
Private Sub Class_Terminate()
    Set mRange = Nothing
End Sub
'------------------------------------------------------
' ��\���s���X�L�b�v
'------------------------------------------------------
Private Sub SkipHiddenRow()
    Do Until Not mRange.Rows(mRow).Hidden Or ICursor_Eof
        mRow = mRow + 1
    Loop
End Sub
'--------------------------------------------------------------
' ICursor �C���^�[�t�F�[�X���擾
'--------------------------------------------------------------
Public Property Get GetCursor() As ICursor
    Set GetCursor = Me
End Property
'------------------------------------------------------
' �I������
'------------------------------------------------------
Private Property Get ICursor_Eof() As Boolean
    ICursor_Eof = (mRange.Rows.Count < mRow)
End Property
'------------------------------------------------------
' �Z���擾�i�K��̃v���p�e�B�Ȃ̂ŏȗ��\�L�j
'------------------------------------------------------
Private Property Get ICursor_Item(Optional ByVal opt As Variant) As Variant
    Set ICursor_Item = mRange.Cells(mRow, opt)
End Property
'------------------------------------------------------
' �O�̃Z���擾
'------------------------------------------------------
Private Property Get ICursor_PreviousItem(Optional ByVal opt As Variant) As Variant
    Set ICursor_PreviousItem = mRange.Cells(mRow - 1, opt)
End Property
'------------------------------------------------------
' �ŏ��̍s�Ɉړ�
'------------------------------------------------------
Private Sub ICursor_MoveFirst()
    mRow = mStartRow
    SkipHiddenRow
End Sub
'------------------------------------------------------
' ���s�擾
'------------------------------------------------------
Private Sub ICursor_MoveNext()
    mRow = mRow + 1
    SkipHiddenRow
End Sub