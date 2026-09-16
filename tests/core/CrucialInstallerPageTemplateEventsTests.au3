#include-once

#include <TestFramework.au3>
#include <StubConstants.au3>
#include "..\..\src\core\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerPageTemplateEventsTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for the Page Template Events Handlers and On Page Template Events
;                  regions of CrucialInstaller.au3.
;                  Tests handler validation, argument passing, and page event behavior.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerPageTemplateEventsTests.au3"

; ===============================================================================================================================
; Test helpers
; ===============================================================================================================================
Func __TestInfoHandler()
    Return "Info text"
EndFunc

Func __TestInfoHandlerNonString()
    Return 42
EndFunc

Func __TestApplyHandler($idLblProgress, $idProgressbar)
    Return True
EndFunc

Func __TestApplyHandlerFails($idLblProgress, $idProgressbar)
    Return False
EndFunc

Func __TestUpdateSrcHandler($idInputPath)
    Return True
EndFunc

Func __TestUpdateSrcFuncForClick($idInputPath)
    $g_bUpdateSrcCalled = True
EndFunc

; ===============================================================================================================================
; Tests - __RunUpdateInfoFunc
; ===============================================================================================================================
Func _TestRunUpdateInfoFunc_ValidHandler()
    _TestFmkHeader("Test: __RunUpdateInfoFunc() - returns string result from valid handler")

    Local $sResult = __RunUpdateInfoFunc(__TestInfoHandler)

    _TestFmkAssert($sResult = "Info text", "Returns handler result", $sResult, "Info text")
EndFunc

Func _TestRunUpdateInfoFunc_InvalidHandler()
    _TestFmkHeader("Test: __RunUpdateInfoFunc() - returns empty string and sets @error for invalid handler")

    Local $sResult = __RunUpdateInfoFunc("invalid handler")
    Local $iErr    = @error
    Local $iExt    = @extended

    _TestFmkAssert($sResult = "",      "Returns empty string",    $sResult, "")
    _TestFmkAssert($iErr = 0xDEAD,     "Sets @error = 0xDEAD",    $iErr,    0xDEAD)
    _TestFmkAssert($iExt = 0xBEEF,     "Sets @extended = 0xBEEF", $iExt,    0xBEEF)
EndFunc

Func _TestRunUpdateInfoFunc_GuardsAgainstSelf()
    _TestFmkHeader("Test: __RunUpdateInfoFunc() - returns empty string and sets @error when handler is itself")

    Local $sResult = __RunUpdateInfoFunc(__RunUpdateInfoFunc)
    Local $iErr    = @error
    Local $iExt    = @extended

    _TestFmkAssert($sResult = "",      "Returns empty string",    $sResult, "")
    _TestFmkAssert($iErr = 0xDEAD,     "Sets @error = 0xDEAD",    $iErr,    0xDEAD)
    _TestFmkAssert($iExt = 0xBEEF,     "Sets @extended = 0xBEEF", $iExt,    0xBEEF)
EndFunc

Func _TestRunUpdateInfoFunc_NonStringReturn()
    _TestFmkHeader("Test: __RunUpdateInfoFunc() - returns empty string and sets @error when handler returns non-string")

    Local $sResult = __RunUpdateInfoFunc(__TestInfoHandlerNonString)
    Local $iErr    = @error
    Local $iExt    = @extended

    _TestFmkAssert($sResult = "",      "Returns empty string",    $sResult, "")
    _TestFmkAssert($iErr = 0xDEAD,     "Sets @error = 0xDEAD",    $iErr,    0xDEAD)
    _TestFmkAssert($iExt = 0xBEEF,     "Sets @extended = 0xBEEF", $iExt,    0xBEEF)
EndFunc

; ===============================================================================================================================
; Tests - __RunApplyFunc
; ===============================================================================================================================
Func _TestRunApplyFunc_ValidHandler()
    _TestFmkHeader("Test: __RunApplyFunc() - calls handler with correct args and returns result")

    Local $idLblProgress = 10
    Local $idProgressbar = 11

    Local $bResult = __RunApplyFunc(__TestApplyHandler, $idLblProgress, $idProgressbar)

    _TestFmkAssert($bResult = True, "Returns True from handler", $bResult, True)
EndFunc

Func _TestRunApplyFunc_InvalidHandler()
    _TestFmkHeader("Test: __RunApplyFunc() - returns False and sets @error for invalid handler")

    Local $idLblProgress = 10
    Local $idProgressbar = 11

	Local $bResult = __RunApplyFunc("invalid handler", $idLblProgress, $idProgressbar)
    Local $iErr    = @error
    Local $iExt    = @extended

    _TestFmkAssert($bResult = False,   "Returns False",           $bResult, False)
    _TestFmkAssert($iErr = 0xDEAD,     "Sets @error = 0xDEAD",    $iErr,    0xDEAD)
    _TestFmkAssert($iExt = 0xBEEF,     "Sets @extended = 0xBEEF", $iExt,    0xBEEF)
EndFunc

Func _TestRunApplyFunc_GuardsAgainstSelf()
    _TestFmkHeader("Test: __RunApplyFunc() - returns False and sets @error when handler is itself")

    Local $idLblProgress = 10
    Local $idProgressbar = 11

	Local $bResult = __RunApplyFunc(__RunApplyFunc, $idLblProgress, $idProgressbar)
    Local $iErr    = @error
    Local $iExt    = @extended

    _TestFmkAssert($bResult = False,   "Returns False",           $bResult, False)
    _TestFmkAssert($iErr = 0xDEAD,     "Sets @error = 0xDEAD",    $iErr,    0xDEAD)
    _TestFmkAssert($iExt = 0xBEEF,     "Sets @extended = 0xBEEF", $iExt,    0xBEEF)
EndFunc

; ===============================================================================================================================
; Tests - __RunUpdateSrcFunc
; ===============================================================================================================================
Func _TestRunUpdateSrcFunc_ValidHandler()
    _TestFmkHeader("Test: __RunUpdateSrcFunc() - calls handler with correct arg and returns True")

    Local $idInputPath = 10

    Local $bResult = __RunUpdateSrcFunc(__TestUpdateSrcHandler, $idInputPath)

    _TestFmkAssert($bResult = True, "Returns True from handler", $bResult, True)
EndFunc

Func _TestRunUpdateSrcFunc_InvalidHandler()
    _TestFmkHeader("Test: __RunUpdateSrcFunc() - returns False and sets @error for invalid handler")

    Local $idInputPath = 10

	Local $bResult = __RunUpdateSrcFunc("invalid handler", $idInputPath)
    Local $iErr    = @error
    Local $iExt    = @extended

    _TestFmkAssert($bResult = False,   "Returns False",           $bResult, False)
    _TestFmkAssert($iErr = 0xDEAD,     "Sets @error = 0xDEAD",    $iErr,    0xDEAD)
    _TestFmkAssert($iExt = 0xBEEF,     "Sets @extended = 0xBEEF", $iExt,    0xBEEF)
EndFunc

Func _TestRunUpdateSrcFunc_GuardsAgainstSelf()
    _TestFmkHeader("Test: __RunUpdateSrcFunc() - returns False and sets @error when handler is itself")

    Local $idInputPath = 10

	Local $bResult = __RunUpdateSrcFunc(__RunUpdateSrcFunc, $idInputPath)
    Local $iErr    = @error
    Local $iExt    = @extended

    _TestFmkAssert($bResult = False,   "Returns False",           $bResult, False)
    _TestFmkAssert($iErr = 0xDEAD,     "Sets @error = 0xDEAD",    $iErr,    0xDEAD)
    _TestFmkAssert($iExt = 0xBEEF,     "Sets @extended = 0xBEEF", $iExt,    0xBEEF)
EndFunc

; ===============================================================================================================================
; Tests - _OnLoad_ReadyPage
; ===============================================================================================================================
Func _TestOnLoadReadyPage_SetsLabelText()
    _TestFmkHeader("Test: _OnLoad_ReadyPage() - sets label text from handler result")

    Local $idLblInfo = 10

    _OnLoad_ReadyPage($idLblInfo, __TestInfoHandler)

    Local $iLabelId  = _GetStubCall("GUICtrlSetData", $_1st, $Param_ControlId)
    Local $sLabelText = _GetStubCall("GUICtrlSetData", $_1st, $Param_Data)
    _TestFmkAssert($iLabelId   = $idLblInfo,   "Label control ID correct", $iLabelId,   $idLblInfo)
    _TestFmkAssert($sLabelText = "Info text",  "Label text correct",       $sLabelText, "Info text")
EndFunc

Func _TestOnLoadReadyPage_DefaultHandler()
    _TestFmkHeader("Test: _OnLoad_ReadyPage() - does nothing when handler is Default")

	Local $idLblInfo = 10

    _OnLoad_ReadyPage($idLblInfo, Default)

    _TestFmkAssert(_StubCallCount("GUICtrlSetData") = 0, "No GUICtrlSetData call", _StubCallCount("GUICtrlSetData"), 0)
EndFunc

; ===============================================================================================================================
; Tests - _AfterLoad_ProgressPage
; ===============================================================================================================================
Func _TestAfterLoadProgressPage_Success()
    _TestFmkHeader("Test: _AfterLoad_ProgressPage() - success path behavior")

	Local $hWin = 1
	Local $idLblProgress = 10
    Local $idProgressbar = 11
	Local $idBtnNext = 12
	Local $sInstallerTitle = "Test"
	Local $sFailureMsg = "Failed"

	Local $iEventBefore = _GetInstallerEvent()

    _AfterLoad_ProgressPage($hWin, $idLblProgress, $idProgressbar, $idBtnNext, __TestApplyHandler, $sInstallerTitle, $sFailureMsg)

    Local $iEventAfter = _GetInstallerEvent()
	Local $iSendMsgId = _GetStubCall("GUICtrlSendMsg", $_1st, $Param_ControlId)

    _TestFmkAssert(_StubCallCount("MsgBox") = 0, "No failure MsgBox on success", _StubCallCount("MsgBox"), 0)
    _TestFmkAssert($iEventAfter = $iEventBefore, "Event not changed on success", $iEventAfter,             $iEventBefore)
    _TestFmkAssert($iSendMsgId  = $idBtnNext,    "BM_CLICK sent to Next button", $iSendMsgId,              $idBtnNext)
EndFunc

Func _TestAfterLoadProgressPage_Failure()
    _TestFmkHeader("Test: _AfterLoad_ProgressPage() - failure path behavior")

	Local $hWin = 1
	Local $idLblProgress = 10
    Local $idProgressbar = 11
	Local $idBtnNext = 12
	Local $sInstallerTitle = "Test Title"
	Local $sFailureMsg = "Failure message"

	_SetInstallerEvent($EVENT_PROCESSING)
	_AfterLoad_ProgressPage($hWin, $idLblProgress, $idProgressbar, $idBtnNext, __TestApplyHandlerFails, $sInstallerTitle, $sFailureMsg)

    Local $iEventAfter = _GetInstallerEvent()
    Local $sMsg        = _GetStubCall("MsgBox",         $_1st, $Param_Text)
    Local $iSendMsgId  = _GetStubCall("GUICtrlSendMsg", $_1st, $Param_ControlId)

	_SetInstallerEvent($EVENT_DEFAULT)	; Resets the event back to default for next tests

    _TestFmkAssert($sMsg = "Failure message",               "MsgBox shows failure message",   $sMsg,        "Failure message")
    _TestFmkAssert($iEventAfter = $EVENT_CLOSE_PAGE,        "Event set to close page",        $iEventAfter, $EVENT_CLOSE_PAGE)
    _TestFmkAssert($iSendMsgId  = $idBtnNext,               "BM_CLICK sent to Next button",   $iSendMsgId,  $idBtnNext)
EndFunc

; ===============================================================================================================================
; Tests - _AfterLoad_FinishPage
; ===============================================================================================================================
Func _TestAfterLoadFinishPage_SetsCloseEvent()
    _TestFmkHeader("Test: _AfterLoad_FinishPage() - sets installer event to EVENT_CLOSE_PAGE")

    _SetInstallerEvent($EVENT_DEFAULT)
    _AfterLoad_FinishPage()

    _TestFmkAssert(_GetInstallerEvent() = $EVENT_CLOSE_PAGE, "Event set to close page", _GetInstallerEvent(), $EVENT_CLOSE_PAGE)
	_SetInstallerEvent($EVENT_DEFAULT)	; Resets the event back to default for next tests
EndFunc

; ===============================================================================================================================
; Tests - _OnClose_FinishPage
; ===============================================================================================================================
Func _TestOnCloseFinishPage_OpensDocWhenChecked()
    _TestFmkHeader("Test: _OnClose_FinishPage() - opens doc file when checkbox is checked")

    Local $idChkBox  = 10
    Local $sDocFile  = "C:\docs\TestFramework.chm"
    _SetStubReturn("GUICtrlRead", $_1st, $GUI_CHECKED)

    _OnClose_FinishPage($idChkBox, $sDocFile)

	Local $sFile = _GetStubCall("ShellExecute", $_1st, $Param_Filename)
	_TestFmkAssert($sFile = $sDocFile, "ShellExecute called with doc file", $sFile, $sDocFile)
EndFunc

Func _TestOnCloseFinishPage_DoesNothingWhenUnchecked()
    _TestFmkHeader("Test: _OnClose_FinishPage() - does nothing when checkbox is unchecked")

    Local $idChkBox = 10
    _SetStubReturn("GUICtrlRead", $_1st, $GUI_UNCHECKED)

    _OnClose_FinishPage($idChkBox, "C:\docs\TestFramework.chm")

    _TestFmkAssert(_StubCallCount("ShellExecute") = 0, "ShellExecute not called", _StubCallCount("ShellExecute"), 0)
EndFunc

; ===============================================================================================================================
; Tests - _OnClick_SetFolder
; ===============================================================================================================================
Func _TestOnClickSetFolder_UpdatesInputPath()
    _TestFmkHeader("Test: _OnClick_SetFolder() - updates input path when folder selected")

    Local $idInputPath = 10
	Local $sPathLabel = "Install folder"
	Local $hUpdateSrcFunc = Default
    _SetStubReturn("FileSelectFolder", $_1st, "C:\Selected\Folder")

    _OnClick_SetFolder($idInputPath, $sPathLabel, $hUpdateSrcFunc)

    Local $iCtrlId = _GetStubCall("GUICtrlSetData", $_1st, $Param_ControlId)
    Local $sPath   = _GetStubCall("GUICtrlSetData", $_1st, $Param_Data)
    _TestFmkAssert($iCtrlId = $idInputPath,          "Correct control updated",  $iCtrlId, $idInputPath)
    _TestFmkAssert($sPath   = "C:\Selected\Folder",  "Path updated correctly",   $sPath,   "C:\Selected\Folder")
EndFunc

Func _TestOnClickSetFolder_DoesNothingWhenCancelled()
    _TestFmkHeader("Test: _OnClick_SetFolder() - does nothing when folder selection cancelled")

    Local $idInputPath = 10
	Local $sPathLabel = "Install folder"
	Local $hUpdateSrcFunc = Default
    _SetStubReturn("FileSelectFolder", $_1st, $STUB_ERROR)

    _OnClick_SetFolder($idInputPath, $sPathLabel, $hUpdateSrcFunc)

    _TestFmkAssert(_StubCallCount("GUICtrlSetData") = 0, "No update on cancel", _StubCallCount("GUICtrlSetData"), 0)
EndFunc

Func _TestOnClickSetFolder_CallsUpdateSrcFunc()
    _TestFmkHeader("Test: _OnClick_SetFolder() - calls hUpdateSrcFunc after path update")

    Local $idInputPath = 10
	Local $sPathLabel = "Install folder"
	Local $hUpdateSrcFunc = __TestUpdateSrcFuncForClick
    _SetStubReturn("FileSelectFolder", $_1st, "C:\Selected\Folder")

    Global $g_bUpdateSrcCalled = False
	_OnClick_SetFolder($idInputPath, $sPathLabel, $hUpdateSrcFunc)

    _TestFmkAssert($g_bUpdateSrcCalled = True, "UpdateSrcFunc called", $g_bUpdateSrcCalled, True)
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialInstallerPageTemplateEventsTest_RunUpdateInfoFunc(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestRunUpdateInfoFunc_ValidHandler,      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRunUpdateInfoFunc_InvalidHandler,    $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRunUpdateInfoFunc_GuardsAgainstSelf, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRunUpdateInfoFunc_NonStringReturn,   $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplateEventsTest_RunApplyFunc(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestRunApplyFunc_ValidHandler,      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRunApplyFunc_InvalidHandler,    $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRunApplyFunc_GuardsAgainstSelf, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplateEventsTest_RunUpdateSrcFunc(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestRunUpdateSrcFunc_ValidHandler,      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRunUpdateSrcFunc_InvalidHandler,    $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRunUpdateSrcFunc_GuardsAgainstSelf, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplateEventsTest_OnLoadReadyPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestOnLoadReadyPage_SetsLabelText,  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnLoadReadyPage_DefaultHandler, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplateEventsTest_AfterLoadProgressPage(ByRef $bAllPassed)
    _TestFmkSeparator()
	$bAllPassed = _TestFmkRun(_TestAfterLoadProgressPage_Success,     $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestAfterLoadProgressPage_Failure,     $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplateEventsTest_AfterLoadFinishPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestAfterLoadFinishPage_SetsCloseEvent, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplateEventsTest_OnCloseFinishPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestOnCloseFinishPage_OpensDocWhenChecked,    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnCloseFinishPage_DoesNothingWhenUnchecked, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplateEventsTest_OnClickSetFolder(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestOnClickSetFolder_UpdatesInputPath,      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnClickSetFolder_DoesNothingWhenCancelled, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnClickSetFolder_CallsUpdateSrcFunc,    $bAllPassed)
EndFunc

Func _RunCrucialInstallerPageTemplateEventsTests($bWriteSummary = True)
    Local $bAllPassed = True
    __RunCrucialInstallerPageTemplateEventsTest_RunUpdateInfoFunc($bAllPassed)
    __RunCrucialInstallerPageTemplateEventsTest_RunApplyFunc($bAllPassed)
    __RunCrucialInstallerPageTemplateEventsTest_RunUpdateSrcFunc($bAllPassed)
    __RunCrucialInstallerPageTemplateEventsTest_OnLoadReadyPage($bAllPassed)
    __RunCrucialInstallerPageTemplateEventsTest_AfterLoadProgressPage($bAllPassed)
    __RunCrucialInstallerPageTemplateEventsTest_AfterLoadFinishPage($bAllPassed)
    __RunCrucialInstallerPageTemplateEventsTest_OnCloseFinishPage($bAllPassed)
    __RunCrucialInstallerPageTemplateEventsTest_OnClickSetFolder($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerPageTemplateEventsTests, $sScriptName)
