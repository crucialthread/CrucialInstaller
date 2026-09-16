#include-once

#include <TestFramework.au3>
#include <StubConstants.au3>
#include "..\..\src\core\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerInitTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for __OnObjEvent, __OnObjBtnClick, __OnInit_Wizard and _InitWizard
;                  in CrucialInstaller.au3. Drives the wizard event loop by stubbing GUIGetMsg
;                  to return scripted button sequences.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerInitTests.au3"

; ===============================================================================================================================
; Helpers
; ===============================================================================================================================

Global $g_idBtnCancel = 10
Global $g_idBtnBack   = 11
Global $g_idBtnNext   = 12

Func __InitSetupWizardStubs()
	_SetInstallerEvent()

    _SetStubReturn("GUICtrlCreateButton", $_1st, $g_idBtnCancel)
    _SetStubReturn("GUICtrlCreateButton", $_2nd, $g_idBtnBack)
    _SetStubReturn("GUICtrlCreateButton", $_3rd, $g_idBtnNext)

	; Return true for all needed IsHWnd stub calls
	For $i = 1 To 14
		_SetStubReturn("IsHWnd", $i, True)
	Next
EndFunc

Global $g_bInitTestHandlerCalled = False

Func __InitTestClickHandler()
    $g_bInitTestHandlerCalled = True
EndFunc

; ===============================================================================================================================
; Tests - __OnInit_Wizard
; ===============================================================================================================================
Func _TestOnInitWizard_NextNavigatesToPage2()
    _TestFmkHeader("Test: __OnInit_Wizard() - Next button navigates to page 2")

    __InitSetupWizardStubs()
    _SetStubReturn("GUIGetMsg", $_1st, $g_idBtnNext)	; Next (page 1 -> 2)
    _SetStubReturn("GUIGetMsg", $_2nd, $g_idBtnNext)	; Next on finish page -> exits

    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
	Local $idLblProgress = 1
	Local $idProgressbar = 2
	Local $sFinishMsg = "Done"

    _AddIntroPage($mWizard, $mCfg)
	_AddFinishPage($mWizard, $mCfg, $idLblProgress, $idProgressbar, $sFinishMsg)

    __OnInit_Wizard($mWizard)

    _TestFmkAssert($mWizard.iPage = 2, "Wizard moved to page 2", $mWizard.iPage, 2)
EndFunc

Func _TestOnInitWizard_BackNavigatesToPage1()
    _TestFmkHeader("Test: __OnInit_Wizard() - Back button navigates to page 1")

    __InitSetupWizardStubs()
    _SetStubReturn("GUIGetMsg", $_1st, $g_idBtnNext)	; Next (page 1 -> 2)
    _SetStubReturn("GUIGetMsg", $_2nd, $g_idBtnBack)  	; Back (page 2 -> 1)
    _SetStubReturn("GUIGetMsg", $_3rd, $g_idBtnCancel)	; Cancel

    _SetStubReturn("MsgBox", $_1st, $IDYES)

    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
	_AddIntroPage($mWizard, $mCfg)
	_AddReadyPage($mWizard, $mCfg)

    __OnInit_Wizard($mWizard)

    _TestFmkAssert($mWizard.iPage = 1, "Wizard moved back to page 1", $mWizard.iPage, 1)
EndFunc

Func _TestOnInitWizard_CancelConfirmedExitsLoop()
    _TestFmkHeader("Test: __OnInit_Wizard() - Cancel confirmed exits the loop")

    __InitSetupWizardStubs()
    _SetStubReturn("GUIGetMsg", $_1st, $g_idBtnCancel)  ; Cancel
    _SetStubReturn("MsgBox", $_1st, $IDYES)

    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage("Page 1")
    _AddPage($mWizard.mPages, $mPage)

    __OnInit_Wizard($mWizard)

    _TestFmkAssert(_StubCallCount("MsgBox") = 1,    "Cancel message displayed", _StubCallCount("MsgBox"), 1)
	_TestFmkAssert(_StubCallCount("GUIDelete") = 1, "GUIDelete called on exit", _StubCallCount("GUIDelete"), 1)
EndFunc

Func _TestOnInitWizard_CancelDeclinedKeepsLoop()
    _TestFmkHeader("Test: __OnInit_Wizard() - Cancel declined keeps loop running")

    __InitSetupWizardStubs()
    _SetStubReturn("GUIGetMsg", $_1st, $g_idBtnCancel)  ; Cancel - decline
    _SetStubReturn("MsgBox",    $_1st, $IDNO)
    _SetStubReturn("GUIGetMsg", $_2nd, $g_idBtnCancel)  ; Cancel again - confirm
    _SetStubReturn("MsgBox",    $_2nd, $IDYES)

    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage("Page 1")
    _AddPage($mWizard.mPages, $mPage)

    __OnInit_Wizard($mWizard)

    _TestFmkAssert(_StubCallCount("MsgBox") = 2, "MsgBox shown twice", _StubCallCount("MsgBox"), 2)
EndFunc

Func _TestOnInitWizard_CustomButtonClickHandler()
    _TestFmkHeader("Test: __OnInit_Wizard() - custom button OnClick handler is called")

	Local $idCustomBtn = 99
	$g_bInitTestHandlerCalled = False

    __InitSetupWizardStubs()
    _SetStubReturn("GUIGetMsg", $_1st, $idCustomBtn)	; custom button click
    _SetStubReturn("GUIGetMsg", $_2nd, $g_idBtnCancel)  ; Cancel
    _SetStubReturn("MsgBox",    $_1st, $IDYES)

    Local $mCfg     = _NewInstallerCfg()
    Local $mWizard  = _NewWizard($mCfg, "Test", "Test")
    Local $mPage    = _NewPage("Page 1")
    Local $mHandler = _SetEventHandler(__InitTestClickHandler)
    _SetPageBtnOnClickEvent($mPage, $idCustomBtn, $mHandler)  ; custom button ID 99
    _AddPage($mWizard.mPages, $mPage)

    __OnInit_Wizard($mWizard)

    _TestFmkAssert($g_bInitTestHandlerCalled = True, "Custom handler was called", $g_bInitTestHandlerCalled, True)
EndFunc

; ===============================================================================================================================
; Tests - _InitWizard
; ===============================================================================================================================

Func _TestInitWizard_NotReadyShowsError()
    _TestFmkHeader("Test: _InitWizard() - shows error MsgBox when wizard not ready")

	__InitSetupWizardStubs()
    Local $mCfg       	 = _NewInstallerCfg()
    Local $mWizEmptyPage = _NewWizard($mCfg, "Test", "Test")

	; No Page added to the wizard

    _InitWizard($mWizEmptyPage)

    _TestFmkAssert(_StubCallCount("MsgBox") = 1, "Error MsgBox shown", _StubCallCount("MsgBox"), 1)
EndFunc

Func _TestInitWizard_ReadyDelegatesToOnInit()
    _TestFmkHeader("Test: _InitWizard() - delegates to __OnInit_Wizard when ready")

    __InitSetupWizardStubs()
    _SetStubReturn("GUIGetMsg", $_1st, $g_idBtnCancel)
    _SetStubReturn("MsgBox",    $_1st, $IDYES)

    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage("Page 1")
    _AddPage($mWizard.mPages, $mPage)

    _InitWizard($mWizard)

    _TestFmkAssert(_StubCallCount("GUIDelete") = 1, "Wizard ran and deleted", _StubCallCount("GUIDelete"), 1)
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialInstallerInitTest_OnInitWizard(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestOnInitWizard_NextNavigatesToPage2,      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnInitWizard_BackNavigatesToPage1,      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnInitWizard_CancelConfirmedExitsLoop,  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnInitWizard_CancelDeclinedKeepsLoop,   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnInitWizard_CustomButtonClickHandler,  $bAllPassed)
EndFunc

Func __RunCrucialInstallerInitTest_InitWizard(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestInitWizard_NotReadyShowsError,          $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestInitWizard_ReadyDelegatesToOnInit,      $bAllPassed)
EndFunc

Func _RunCrucialInstallerInitTests($bWriteSummary = True)
    Local $bAllPassed = True
	__RunCrucialInstallerInitTest_OnInitWizard($bAllPassed)
	__RunCrucialInstallerInitTest_InitWizard($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerInitTests, $sScriptName)
