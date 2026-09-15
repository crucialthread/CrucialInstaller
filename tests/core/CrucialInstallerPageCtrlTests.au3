#include-once

#include "..\..\lib\TestFramework\TestFramework.au3"
#include "..\..\lib\TestFramework\StubConstants.au3"
#include "..\..\src\core\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerPageCtrlTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for the Page Controls region of CrucialInstaller.au3.
;                  Tests page control array creation, control name normalization,
;                  control registration, retrieval, and array replacement.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerPageCtrlTests.au3"

; ===============================================================================================================================
; Tests - __CreatePageCtrls
; ===============================================================================================================================
Func _TestCreatePageCtrls_DefaultSize()
    _TestFmkHeader("Test: __CreatePageCtrls() - returns empty array by default")

    Local $aResult = __CreatePageCtrls()

    _TestFmkAssert(IsArray($aResult),    "Returns an array",     IsArray($aResult),    True)
    _TestFmkAssert(UBound($aResult) = 0, "Array is empty",       UBound($aResult),     0)
EndFunc

Func _TestCreatePageCtrls_CustomSize()
    _TestFmkHeader("Test: __CreatePageCtrls() - returns array with specified size")

    Local $aResult = __CreatePageCtrls(3)

    _TestFmkAssert(IsArray($aResult),    "Returns an array",       IsArray($aResult),    True)
    _TestFmkAssert(UBound($aResult) = 3, "Array has 3 elements",   UBound($aResult),     3)
EndFunc

; ===============================================================================================================================
; Tests - __ArrayInMapReplace
; ===============================================================================================================================
Func _TestArrayInMapReplace_ReplacesValue()
    _TestFmkHeader("Test: __ArrayInMapReplace() - replaces value at given index")

    Local $aArray[3] = [10, 20, 30]
    __ArrayInMapReplace($aArray, 1, 99)

    _TestFmkAssert($aArray[1] = 99, "Value replaced at index 1", $aArray[1], 99)
EndFunc

Func _TestArrayInMapReplace_InvalidIndex()
    _TestFmkHeader("Test: __ArrayInMapReplace() - sets @error for out of range index")

    Local $aArray[3] = [10, 20, 30]
    __ArrayInMapReplace($aArray, 5, 99)
    Local $iErr = @error

    _TestFmkAssert($iErr = $INST_ERR_INVALID_AIMR, "Sets @error for invalid index", $iErr, $INST_ERR_INVALID_AIMR)
EndFunc

Func _TestArrayInMapReplace_InvalidArray()
    _TestFmkHeader("Test: __ArrayInMapReplace() - sets @error for invalid array")

    Local $vNotArray = 0
    __ArrayInMapReplace($vNotArray, 0, 99)
    Local $iErr = @error

    _TestFmkAssert($iErr = $INST_ERR_INVALID_AIMR, "Sets @error for invalid array", $iErr, $INST_ERR_INVALID_AIMR)
EndFunc

; ===============================================================================================================================
; Tests - __PageCtrlName
; ===============================================================================================================================
Func _TestPageCtrlName_AddsPrefix()
    _TestFmkHeader("Test: __PageCtrlName() - adds i prefix when missing")

    _TestFmkAssert(__PageCtrlName("BtnNext") = "iBtnNextId", "Adds i prefix and Id suffix", __PageCtrlName("BtnNext"), "iBtnNextId")
EndFunc

Func _TestPageCtrlName_AddsSuffix()
    _TestFmkHeader("Test: __PageCtrlName() - adds Id suffix when missing")

    _TestFmkAssert(__PageCtrlName("iBtnNext") = "iBtnNextId", "Adds Id suffix only", __PageCtrlName("iBtnNext"), "iBtnNextId")
EndFunc

Func _TestPageCtrlName_AlreadyNormalized()
    _TestFmkHeader("Test: __PageCtrlName() - leaves already normalized name unchanged")

    _TestFmkAssert(__PageCtrlName("iBtnNextId") = "iBtnNextId", "Already normalized", __PageCtrlName("iBtnNextId"), "iBtnNextId")
EndFunc

; ===============================================================================================================================
; Tests - __GetPageCtrlIndex
; ===============================================================================================================================
Func _TestGetPageCtrlIndex_Found()
    _TestFmkHeader("Test: __GetPageCtrlIndex() - returns index for registered control")

	Local $idBtnNext = 10
    _SetStubReturn("GUICtrlGetHandle", $_1st, $idBtnNext)

	Local $mPage = _NewPage()
    _SetPageCtrl($mPage, $idBtnNext, "BtnNext")

    Local $iResult = __GetPageCtrlIndex($mPage, "iBtnNextId")

    _TestFmkAssert($iResult <> Null, "Returns valid index", $iResult <> Null, True)
EndFunc

Func _TestGetPageCtrlIndex_NotFound()
    _TestFmkHeader("Test: __GetPageCtrlIndex() - returns Null for unregistered control")

    Local $mPage = _NewPage()

    Local $iResult = __GetPageCtrlIndex($mPage, "iBtnNextId")

    _TestFmkAssert($iResult = Null, "Returns Null when not found", $iResult, Null)
EndFunc

Func _TestGetPageCtrlIndex_InvalidPage()
    _TestFmkHeader("Test: __GetPageCtrlIndex() - returns Null for invalid page")

    Local $iResult = __GetPageCtrlIndex(0, "iBtnNextId")

    _TestFmkAssert($iResult = Null, "Returns Null for invalid page", $iResult, Null)
EndFunc

; ===============================================================================================================================
; Tests - _SetPageCtrl
; ===============================================================================================================================
Func _TestSetPageCtrl_AddsNewControl()
    _TestFmkHeader("Test: _SetPageCtrl() - registers new control and returns its index")

	Local $idCtrl = 10
	_SetStubReturn("GUICtrlGetHandle", $_1st, $idCtrl)

    Local $mPage     = _NewPage()
    Local $sCtrlName = "MyControl"
    Local $sNormalized = __PageCtrlName($sCtrlName)

    Local $iIdx = _SetPageCtrl($mPage, $idCtrl, $sCtrlName)

    _TestFmkAssert($iIdx <> Null,                   "Returns valid index",       $iIdx <> Null,                   True)
    _TestFmkAssert(MapExists($mPage, $sNormalized), "Control key added to page", MapExists($mPage, $sNormalized), True)
EndFunc

Func _TestSetPageCtrl_UpdatesExistingControl()
    _TestFmkHeader("Test: _SetPageCtrl() - updates existing control without adding duplicate")

	Local $idCtrl = 10
	Local $iNewId = 20
	_SetStubReturn("GUICtrlGetHandle", $_1st, $idCtrl)
	_SetStubReturn("GUICtrlGetHandle", $_2nd, $iNewId)

	Local $mPage     = _NewPage()

    Local $sCtrlName = "MyControl"

    _SetPageCtrl($mPage, $idCtrl, $sCtrlName)
    _SetPageCtrl($mPage, $iNewId, $sCtrlName)

    _TestFmkAssert(_GetPageCtrl($mPage, $sCtrlName) = 20, "Control updated to new ID",     _GetPageCtrl($mPage, $sCtrlName), 20)
    _TestFmkAssert(UBound($mPage.aControls) = 1,          "No duplicate in controls array", UBound($mPage.aControls),        1)
EndFunc

Func _TestSetPageCtrl_InvalidPage()
    _TestFmkHeader("Test: _SetPageCtrl() - returns Null and sets @error for invalid page")

    Local $mPage  = "invalid page"
    Local $idCtrl = 10

    Local $iIdx = _SetPageCtrl($mPage, $idCtrl, "BtnNext")
    Local $iErr = @error

    _TestFmkAssert($iErr = $INST_ERR_INVALID_CTRL, "Sets @error for invalid page", $iErr,  $INST_ERR_INVALID_CTRL)
    _TestFmkAssert($iIdx = Null,                   "Returns Null for invalid page", $iIdx, Null)
EndFunc

Func _TestSetPageCtrl_InvalidCtrl()
    _TestFmkHeader("Test: _SetPageCtrl() - returns Null and sets @error for invalid numeric id")

    Local $mPage     = _NewPage()
    Local $idCtrl    = 0
    Local $sCtrlName = "MyControl"

    Local $iIdx = _SetPageCtrl($mPage, $idCtrl, $sCtrlName)
    Local $iErr = @error

    _TestFmkAssert($iErr = $INST_ERR_INVALID_CTRL, "Sets @error for invalid ctrl id", $iErr,  $INST_ERR_INVALID_CTRL)
    _TestFmkAssert($iIdx = Null,                   "Returns Null for invalid ctrl id", $iIdx, Null)
EndFunc

Func _TestSetPageCtrl_InvalidNaNCtrl()
    _TestFmkHeader("Test: _SetPageCtrl() - returns Null and sets @error for non-numeric id")

    Local $mPage     = _NewPage()
    Local $idCtrl    = "invalid id"
    Local $sCtrlName = "MyControl"

    Local $iIdx = _SetPageCtrl($mPage, $idCtrl, $sCtrlName)
    Local $iErr = @error

    _TestFmkAssert($iErr = $INST_ERR_INVALID_CTRL, "Sets @error for non-numeric id", $iErr,  $INST_ERR_INVALID_CTRL)
    _TestFmkAssert($iIdx = Null,                   "Returns Null for non-numeric id", $iIdx, Null)
EndFunc

; ===============================================================================================================================
; Tests - _GetPageCtrl
; ===============================================================================================================================
Func _TestGetPageCtrl_Found()
    _TestFmkHeader("Test: _GetPageCtrl() - returns control ID for registered control")

	Local $idCtrl = 10
	_SetStubReturn("GUICtrlGetHandle", $_1st, $idCtrl)

    Local $mPage     = _NewPage()
    Local $sCtrlName = "MyControl"

    _SetPageCtrl($mPage, $idCtrl, $sCtrlName)

    _TestFmkAssert(_GetPageCtrl($mPage, $sCtrlName) = $idCtrl, "Returns correct control ID", _GetPageCtrl($mPage, $sCtrlName), $idCtrl)
EndFunc

Func _TestGetPageCtrl_NotFound()
    _TestFmkHeader("Test: _GetPageCtrl() - returns Null for unregistered control")

    Local $mPage     = _NewPage()
    Local $idCtrl    = 10
    Local $sCtrlName = "MyControl"

    _SetPageCtrl($mPage, $idCtrl, $sCtrlName)

    _TestFmkAssert(_GetPageCtrl($mPage, "AnotherControl") = Null, "Returns Null for missing control", _GetPageCtrl($mPage, "AnotherControl"), Null)
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialInstallerPageCtrlTest_CreatePageCtrls(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestCreatePageCtrls_DefaultSize,         $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreatePageCtrls_CustomSize,          $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageCtrlTest_ArrayInMapReplace(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestArrayInMapReplace_ReplacesValue,     $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestArrayInMapReplace_InvalidIndex,      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestArrayInMapReplace_InvalidArray,      $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageCtrlTest_PageCtrlName(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestPageCtrlName_AddsPrefix,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestPageCtrlName_AddsSuffix,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestPageCtrlName_AlreadyNormalized,      $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageCtrlTest_GetPageCtrlIndex(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestGetPageCtrlIndex_Found,              $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetPageCtrlIndex_NotFound,           $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetPageCtrlIndex_InvalidPage,        $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageCtrlTest_SetPageCtrl(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestSetPageCtrl_AddsNewControl,          $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetPageCtrl_UpdatesExistingControl,  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetPageCtrl_InvalidPage,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetPageCtrl_InvalidCtrl,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetPageCtrl_InvalidNaNCtrl,          $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageCtrlTest_GetPageCtrl(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestGetPageCtrl_Found,                   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetPageCtrl_NotFound,                $bAllPassed)
EndFunc

Func _RunCrucialInstallerPageCtrlTests($bWriteSummary = True)
    Local $bAllPassed = True
    __RunCrucialInstallerPageCtrlTest_CreatePageCtrls($bAllPassed)
    __RunCrucialInstallerPageCtrlTest_ArrayInMapReplace($bAllPassed)
    __RunCrucialInstallerPageCtrlTest_PageCtrlName($bAllPassed)
    __RunCrucialInstallerPageCtrlTest_GetPageCtrlIndex($bAllPassed)
    __RunCrucialInstallerPageCtrlTest_SetPageCtrl($bAllPassed)
    __RunCrucialInstallerPageCtrlTest_GetPageCtrl($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerPageCtrlTests, $sScriptName)
