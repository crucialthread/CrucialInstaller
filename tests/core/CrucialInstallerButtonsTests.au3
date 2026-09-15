#include-once

#include "..\..\lib\TestFramework\TestFramework.au3"
#include "..\..\lib\TestFramework\StubConstants.au3"
#include "..\..\src\core\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerButtonsTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for the Main Buttons region of CrucialInstaller.au3.
;                  Tests __BtnCaptionsUpdate, __SetButtons, __GetButton, __GetBtnCancel,
;                  __GetBtnBack, __GetBtnNext, and _CreateButtons.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerButtonsTests.au3"

; ===============================================================================================================================
; Helpers
; ===============================================================================================================================
Global $g_idBtnCancel = 10
Global $g_idBtnBack   = 11
Global $g_idBtnNext   = 12

Func __SetupButtonStubs()
    For $i = 1 To 9
        _SetStubReturn("IsHWnd", $i, True)
    Next
    _SetStubReturn("GUICtrlCreateButton", $_1st, $g_idBtnCancel)
    _SetStubReturn("GUICtrlCreateButton", $_2nd, $g_idBtnBack)
    _SetStubReturn("GUICtrlCreateButton", $_3rd, $g_idBtnNext)
EndFunc

; ===============================================================================================================================
; Tests - __BtnCaptionsUpdate
; ===============================================================================================================================
Func _TestBtnCaptionsUpdate_UpdatesGlobals()
    _TestFmkHeader("Test: __BtnCaptionsUpdate() - updates global caption variables from config")

    Local $mCaptions = _NewBtnCaptions("Forward", "Backward", "Exit", "Done", "Apply")
    Local $mCfg      = _NewInstallerCfg(_NewWndCfg(), _NewFontCfg(), _NewBtnCfg(_NewBtnDim(), $mCaptions))
    __BtnCaptionsUpdate($mCfg)

    _TestFmkAssert($__g_BTN_CAPTION_NEXT   = "Forward",  "Next caption updated",   $__g_BTN_CAPTION_NEXT,   "Forward")
    _TestFmkAssert($__g_BTN_CAPTION_BACK   = "Backward", "Back caption updated",   $__g_BTN_CAPTION_BACK,   "Backward")
    _TestFmkAssert($__g_BTN_CAPTION_CANCEL = "Exit",     "Cancel caption updated", $__g_BTN_CAPTION_CANCEL, "Exit")
    _TestFmkAssert($__g_BTN_CAPTION_FINISH = "Done",     "Finish caption updated", $__g_BTN_CAPTION_FINISH, "Done")
    _TestFmkAssert($__g_BTN_CAPTION_APPLY  = "Apply",    "Apply caption updated",  $__g_BTN_CAPTION_APPLY,  "Apply")
EndFunc

Func _TestBtnCaptionsUpdate_InvalidConfig()
    _TestFmkHeader("Test: __BtnCaptionsUpdate() - does nothing for invalid config")

    Local $sNextBefore = $__g_BTN_CAPTION_NEXT
    __BtnCaptionsUpdate("invalid config")

    _TestFmkAssert($__g_BTN_CAPTION_NEXT = $sNextBefore, "Globals unchanged for invalid config", $__g_BTN_CAPTION_NEXT, $sNextBefore)
EndFunc

; ===============================================================================================================================
; Tests - __SetButtons
; ===============================================================================================================================
Func _TestSetButtons_InvalidMap()
    _TestFmkHeader("Test: __SetButtons() - does nothing for invalid buttons map")

    __SetButtons($eFirstPage, "invalid buttons", $EVENT_DEFAULT)

    _TestFmkAssert(_StubCallCount("GUICtrlSetState") = 0, "No calls for invalid map", _StubCallCount("GUICtrlSetState"), 0)
EndFunc

; Events
Func _TestSetButtons_ProceedPage()
    _TestFmkHeader("Test: __SetButtons() - on proceed page > sets Apply caption to Btn Next")

    __SetupButtonStubs()
    Local $mCfg     = _NewInstallerCfg()
    Local $mButtons = _CreateButtons(1, $mCfg)
    __SetButtons($eMidPage, $mButtons, $EVENT_READY_TO_PROCEED)

	Local $sCaption     = _GetStubCall("GUICtrlSetData",  $_1st, $Param_Data)
	Local $idBtnCaption = _GetStubCall("GUICtrlSetData",  $_1st, $Param_ControlId)

	_TestFmkAssert($sCaption     = $__g_BTN_CAPTION_APPLY, "Apply caption set",        $sCaption,     $__g_BTN_CAPTION_APPLY)
	_TestFmkAssert($idBtnCaption = $g_idBtnNext,           "Caption set on Btn Next",  $idBtnCaption, $g_idBtnNext)
EndFunc

Func _TestSetButtons_ProcessingPage()
    _TestFmkHeader("Test: __SetButtons() - on processing page > disables all buttons")

	__SetupButtonStubs()
    Local $mCfg     = _NewInstallerCfg()
    Local $mButtons = _CreateButtons(1, $mCfg)
	__SetButtons($eMidPage, $mButtons, $EVENT_PROCESSING)

    Local $iCancelState = _GetStubCall("GUICtrlSetState", $_1st, $Param_State)
    Local $iBackState   = _GetStubCall("GUICtrlSetState", $_2nd, $Param_State)
    Local $iNextState   = _GetStubCall("GUICtrlSetState", $_3rd, $Param_State)
	Local $iSetBtnCalls = _StubCallCount("GUICtrlSetState")

    _TestFmkAssert($iCancelState = $GUI_DISABLE, "Cancel disabled on processing", $iCancelState, $GUI_DISABLE)
    _TestFmkAssert($iBackState   = $GUI_DISABLE, "Back disabled on processing",   $iBackState,   $GUI_DISABLE)
    _TestFmkAssert($iNextState   = $GUI_DISABLE, "Next disabled on processing",   $iNextState,   $GUI_DISABLE)
	_TestFmkAssert($iSetBtnCalls = 3, "Set button state only 3 times and returns", $iSetBtnCalls, 3)
EndFunc

Func _TestSetButtons_FinishPage()
	_TestFmkHeader("Test: __SetButtons() - on finish page > sets Finish caption and enables Next, disables Cancel and Back ")

    __SetupButtonStubs()
    Local $mCfg     = _NewInstallerCfg()
    Local $mButtons = _CreateButtons(1, $mCfg)
    __SetButtons($eLastPage, $mButtons, $EVENT_FINISH_PROCESS)

    Local $sCaption      = _GetStubCall("GUICtrlSetData",  $_1st, $Param_Data)
	Local $idBtnCaption  = _GetStubCall("GUICtrlSetData",  $_1st, $Param_ControlId)
    Local $iCancelState  = _GetStubCall("GUICtrlSetState", $_1st, $Param_State)
    Local $iBackState    = _GetStubCall("GUICtrlSetState", $_2nd, $Param_State)
    Local $iNextState    = _GetStubCall("GUICtrlSetState", $_3rd, $Param_State)
	Local $iSetBtnCalls  = _StubCallCount("GUICtrlSetState")
	Local $iSetCaptCalls = _StubCallCount("GUICtrlSetData")

    _TestFmkAssert($sCaption      = $__g_BTN_CAPTION_FINISH, "Finish caption set",                        $sCaption,      $__g_BTN_CAPTION_FINISH)
	_TestFmkAssert($idBtnCaption  = $g_idBtnNext,            "Caption set on Btn Next",                   $idBtnCaption,  $g_idBtnNext)
	_TestFmkAssert($iSetCaptCalls = 1,                       "Set button captions just once",             $iSetCaptCalls, 1)
    _TestFmkAssert($iCancelState  = $GUI_DISABLE,            "Cancel disabled on finish",                 $iCancelState,  $GUI_DISABLE)
    _TestFmkAssert($iBackState    = $GUI_DISABLE,            "Back disabled on finish",                   $iBackState,    $GUI_DISABLE)
    _TestFmkAssert($iNextState    = $GUI_ENABLE,             "Next enabled on finish",                    $iNextState,    $GUI_ENABLE)
	_TestFmkAssert($iSetBtnCalls  = 3,                       "Set button state only 3 times and returns", $iSetBtnCalls,  3)
EndFunc

Func _TestSetButtons_ElseEvent()
    _TestFmkHeader("Test: __SetButtons() - on no special event > resets the Next Btn caption")

    __SetupButtonStubs()
    Local $mCfg     = _NewInstallerCfg()
    Local $mButtons = _CreateButtons(1, $mCfg)
    __SetButtons($eMidPage, $mButtons, $EVENT_DEFAULT)

	Local $sCaption     = _GetStubCall("GUICtrlSetData",  $_1st, $Param_Data)
	Local $idBtnCaption = _GetStubCall("GUICtrlSetData",  $_1st, $Param_ControlId)

	_TestFmkAssert($sCaption     = $__g_BTN_CAPTION_NEXT, "Next caption set",        $sCaption,     $__g_BTN_CAPTION_NEXT)
	_TestFmkAssert($idBtnCaption = $g_idBtnNext,          "Caption set on Btn Next", $idBtnCaption, $g_idBtnNext)
EndFunc

; Page Positions
Func _TestSetButtons_SinglePage()
	_TestFmkHeader("Test: __SetButtons() - on single page > disables Back, enables Cancel and Next with Finish caption")

    __SetupButtonStubs()
    Local $mCfg     = _NewInstallerCfg()
    Local $mButtons = _CreateButtons(1, $mCfg)
    __SetButtons($eSinglePage, $mButtons, $EVENT_DEFAULT)

    Local $iCancelState = _GetStubCall("GUICtrlSetState", $_1st, $Param_State)
    Local $iBackState   = _GetStubCall("GUICtrlSetState", $_2nd, $Param_State)
    Local $iNextState   = _GetStubCall("GUICtrlSetState", $_3rd, $Param_State)
	Local $sCaption     = _GetStubCall("GUICtrlSetData",  $_2nd, $Param_Data)
	Local $idBtnCaption = _GetStubCall("GUICtrlSetData",  $_2nd, $Param_ControlId)

    _TestFmkAssert($iCancelState = $GUI_ENABLE,             "Cancel enabled on single page",  $iCancelState, $GUI_ENABLE)
    _TestFmkAssert($iBackState   = $GUI_DISABLE,            "Back disabled on single page",   $iBackState,   $GUI_DISABLE)
    _TestFmkAssert($iNextState   = $GUI_ENABLE,             "Next enabled on single page",    $iNextState,   $GUI_ENABLE)
	_TestFmkAssert($sCaption     = $__g_BTN_CAPTION_FINISH, "Finish caption set",             $sCaption,     $__g_BTN_CAPTION_FINISH)
	_TestFmkAssert($idBtnCaption = $g_idBtnNext,            "Caption set on Btn Next",        $idBtnCaption, $g_idBtnNext)
EndFunc

Func _TestSetButtons_FirstPage()
	_TestFmkHeader("Test: __SetButtons() - on first page > disables Back, enables Cancel and Next")

    __SetupButtonStubs()
    Local $mCfg     = _NewInstallerCfg()
    Local $mButtons = _CreateButtons(1, $mCfg)
    __SetButtons($eFirstPage, $mButtons, $EVENT_DEFAULT)

    Local $iCancelState = _GetStubCall("GUICtrlSetState", $_1st, $Param_State)
    Local $iBackState   = _GetStubCall("GUICtrlSetState", $_2nd, $Param_State)
    Local $iNextState   = _GetStubCall("GUICtrlSetState", $_3rd, $Param_State)

    _TestFmkAssert($iCancelState = $GUI_ENABLE,  "Cancel enabled on first page", $iCancelState, $GUI_ENABLE)
    _TestFmkAssert($iBackState   = $GUI_DISABLE, "Back disabled on first page",  $iBackState,   $GUI_DISABLE)
    _TestFmkAssert($iNextState   = $GUI_ENABLE,  "Next enabled on first page",   $iNextState,   $GUI_ENABLE)
EndFunc

Func _TestSetButtons_MidPage()
    _TestFmkHeader("Test: __SetButtons() - on mid page > enables all buttons")

    __SetupButtonStubs()
    Local $mCfg     = _NewInstallerCfg()
    Local $mButtons = _CreateButtons(1, $mCfg)
    __SetButtons($eMidPage, $mButtons, $EVENT_DEFAULT)

    Local $iCancelState = _GetStubCall("GUICtrlSetState", $_1st, $Param_State)
    Local $iBackState   = _GetStubCall("GUICtrlSetState", $_2nd, $Param_State)
    Local $iNextState   = _GetStubCall("GUICtrlSetState", $_3rd, $Param_State)
    _TestFmkAssert($iCancelState = $GUI_ENABLE, "Cancel enabled on mid page", $iCancelState, $GUI_ENABLE)
    _TestFmkAssert($iBackState   = $GUI_ENABLE, "Back enabled on mid page",   $iBackState,   $GUI_ENABLE)
    _TestFmkAssert($iNextState   = $GUI_ENABLE, "Next enabled on mid page",   $iNextState,   $GUI_ENABLE)
EndFunc

Func _TestSetButtons_LastPage()
    _TestFmkHeader("Test: __SetButtons() - on last page > disables Next, enables Cancel and Back")

    __SetupButtonStubs()
    Local $mCfg     = _NewInstallerCfg()
    Local $mButtons = _CreateButtons(1, $mCfg)
    __SetButtons($eLastPage, $mButtons, $EVENT_DEFAULT)

    Local $iCancelState = _GetStubCall("GUICtrlSetState", $_1st, $Param_State)
    Local $iBackState   = _GetStubCall("GUICtrlSetState", $_2nd, $Param_State)
    Local $iNextState   = _GetStubCall("GUICtrlSetState", $_3rd, $Param_State)

    _TestFmkAssert($iCancelState = $GUI_ENABLE,  "Cancel enabled on last page", $iCancelState, $GUI_ENABLE)
    _TestFmkAssert($iBackState   = $GUI_ENABLE,  "Back enabled on last page",   $iBackState,   $GUI_ENABLE)
    _TestFmkAssert($iNextState   = $GUI_DISABLE, "Next disabled on last page",  $iNextState,   $GUI_DISABLE)
EndFunc

Func _TestSetButtons_UnknownPosition()
    _TestFmkHeader("Test: __SetButtons() - on unknown page position > disables all buttons")

    __SetupButtonStubs()
    Local $mCfg        = _NewInstallerCfg()
    Local $mButtons    = _CreateButtons(1, $mCfg)
	Local $iUnknownPos = 99
    __SetButtons($iUnknownPos, $mButtons, $EVENT_DEFAULT)

    Local $iCancelState = _GetStubCall("GUICtrlSetState", $_1st, $Param_State)
    Local $iBackState   = _GetStubCall("GUICtrlSetState", $_2nd, $Param_State)
    Local $iNextState   = _GetStubCall("GUICtrlSetState", $_3rd, $Param_State)

    _TestFmkAssert($iCancelState = $GUI_DISABLE, "Cancel disabled on unknown page position", $iCancelState, $GUI_DISABLE)
    _TestFmkAssert($iBackState   = $GUI_DISABLE, "Back disabled on unknown page position",   $iBackState,   $GUI_DISABLE)
    _TestFmkAssert($iNextState   = $GUI_DISABLE, "Next disabled on unknown page position",   $iNextState,   $GUI_DISABLE)
EndFunc

; ===============================================================================================================================
; Tests - __GetButton / __GetBtnCancel / __GetBtnBack / __GetBtnNext
; ===============================================================================================================================
Func _TestGetButton_Cancel()
    _TestFmkHeader("Test: __GetButton() - returns Cancel button ID")

    __SetupButtonStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage()
    _AddPage($mWizard.mPages, $mPage)

    Local $idResult = __GetButton($mWizard, $BTN_CANCEL)

    _TestFmkAssert($idResult = $g_idBtnCancel, "Returns Cancel ID", $idResult, $g_idBtnCancel)
EndFunc

Func _TestGetButton_Back()
    _TestFmkHeader("Test: __GetButton() - returns Back button ID")

    __SetupButtonStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage()
    _AddPage($mWizard.mPages, $mPage)

    Local $idResult = __GetButton($mWizard, $BTN_BACK)

    _TestFmkAssert($idResult = $g_idBtnBack, "Returns Back ID", $idResult, $g_idBtnBack)
EndFunc

Func _TestGetButton_Next()
    _TestFmkHeader("Test: __GetButton() - returns Next button ID")

    __SetupButtonStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage()
    _AddPage($mWizard.mPages, $mPage)

    Local $idResult = __GetButton($mWizard, $BTN_NEXT)

    _TestFmkAssert($idResult = $g_idBtnNext, "Returns Next ID", $idResult, $g_idBtnNext)
EndFunc

Func _TestGetButton_InvalidKey()
    _TestFmkHeader("Test: __GetButton() - returns 0 for unrecognized key")

    __SetupButtonStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage()
    _AddPage($mWizard.mPages, $mPage)

    Local $idResult = __GetButton($mWizard, "idBtnUnknown")

    _TestFmkAssert($idResult = 0, "Returns 0 for unknown key", $idResult, 0)
EndFunc

Func _TestGetButton_InvalidWizard()
    _TestFmkHeader("Test: __GetButton() - returns 0 for invalid wizard")

    Local $idResult = __GetButton("invalid wizard", $BTN_NEXT)

    _TestFmkAssert($idResult = 0, "Returns 0 for invalid wizard", $idResult, 0)
EndFunc

Func _TestGetBtnCancel_ReturnsId()
    _TestFmkHeader("Test: __GetBtnCancel() - returns Cancel button ID")

    __SetupButtonStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage()
    _AddPage($mWizard.mPages, $mPage)

    Local $idResult = __GetBtnCancel($mWizard)

    _TestFmkAssert($idResult = $g_idBtnCancel, "Returns Cancel ID", $idResult, $g_idBtnCancel)
EndFunc

Func _TestGetBtnBack_ReturnsId()
    _TestFmkHeader("Test: __GetBtnBack() - returns Back button ID")

    __SetupButtonStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage()
    _AddPage($mWizard.mPages, $mPage)

    Local $idResult = __GetBtnBack($mWizard)

    _TestFmkAssert($idResult = $g_idBtnBack, "Returns Back ID", $idResult, $g_idBtnBack)
EndFunc

Func _TestGetBtnNext_ReturnsId()
    _TestFmkHeader("Test: __GetBtnNext() - returns Next button ID")

    __SetupButtonStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage()
    _AddPage($mWizard.mPages, $mPage)

    Local $idResult = __GetBtnNext($mWizard)

    _TestFmkAssert($idResult = $g_idBtnNext, "Returns Next ID", $idResult, $g_idBtnNext)
EndFunc

; ===============================================================================================================================
; Tests - _CreateButtons
; ===============================================================================================================================
Func _TestCreateButtons_InvalidGUI()
    _TestFmkHeader("Test: _CreateButtons() - returns Null and sets @error for invalid GUI")

    _SetStubReturn("IsHWnd", $_1st, False)
    Local $mCfg    = _NewInstallerCfg()

	Local $mResult = _CreateButtons(0, $mCfg)
    Local $iErr    = @error

    _TestFmkAssert($mResult = Null, "Returns Null for invalid GUI", $mResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_GUI, "Sets @error", $iErr, $INST_ERR_INVALID_GUI)
EndFunc

Func _TestCreateButtons_ReturnsMap()
    _TestFmkHeader("Test: _CreateButtons() - returns map with all button keys")

    _SetStubReturn("IsHWnd",              $_1st, True)
    _SetStubReturn("GUICtrlCreateButton", $_1st, $g_idBtnCancel)
    _SetStubReturn("GUICtrlCreateButton", $_2nd, $g_idBtnBack)
    _SetStubReturn("GUICtrlCreateButton", $_3rd, $g_idBtnNext)
    Local $mCfg    = _NewInstallerCfg()
    Local $mResult = _CreateButtons(1, $mCfg)

    _TestFmkAssert(IsMap($mResult),                  "Returns a map",   IsMap($mResult),                  True)
    _TestFmkAssert(MapExists($mResult, $BTN_CANCEL), "Has Cancel key",  MapExists($mResult, $BTN_CANCEL), True)
    _TestFmkAssert(MapExists($mResult, $BTN_BACK),   "Has Back key",    MapExists($mResult, $BTN_BACK),   True)
    _TestFmkAssert(MapExists($mResult, $BTN_NEXT),   "Has Next key",    MapExists($mResult, $BTN_NEXT),   True)
EndFunc

Func _TestCreateButtons_StoresCorrectIDs()
    _TestFmkHeader("Test: _CreateButtons() - stores correct control IDs in map")

    _SetStubReturn("IsHWnd",              $_1st, True)
    _SetStubReturn("GUICtrlCreateButton", $_1st, $g_idBtnCancel)
    _SetStubReturn("GUICtrlCreateButton", $_2nd, $g_idBtnBack)
    _SetStubReturn("GUICtrlCreateButton", $_3rd, $g_idBtnNext)
    Local $mCfg    = _NewInstallerCfg()
    Local $mResult = _CreateButtons(1, $mCfg)

    _TestFmkAssert($mResult[$BTN_CANCEL] = $g_idBtnCancel, "Cancel ID correct", $mResult[$BTN_CANCEL], $g_idBtnCancel)
    _TestFmkAssert($mResult[$BTN_BACK]   = $g_idBtnBack,   "Back ID correct",   $mResult[$BTN_BACK],   $g_idBtnBack)
    _TestFmkAssert($mResult[$BTN_NEXT]   = $g_idBtnNext,   "Next ID correct",   $mResult[$BTN_NEXT],   $g_idBtnNext)
EndFunc

Func _TestCreateButtons_UsesConfigCaptions()
    _TestFmkHeader("Test: _CreateButtons() - uses captions from config")

    _SetStubReturn("IsHWnd",              $_1st, True)
    _SetStubReturn("GUICtrlCreateButton", $_1st, $g_idBtnCancel)
    _SetStubReturn("GUICtrlCreateButton", $_2nd, $g_idBtnBack)
    _SetStubReturn("GUICtrlCreateButton", $_3rd, $g_idBtnNext)
    Local $mCaptions = _NewBtnCaptions("Forward", "Backward", "Exit")
    Local $mCfg      = _NewInstallerCfg(_NewWndCfg(), _NewFontCfg(), _NewBtnCfg(_NewBtnDim(), $mCaptions))
    _CreateButtons(1, $mCfg)

    _TestFmkAssert(_StubCall("GUICtrlCreateButton", $_1st, $Param_Text) = "Exit",     "Cancel caption from config", _StubCall("GUICtrlCreateButton", $_1st, $Param_Text), "Exit")
    _TestFmkAssert(_StubCall("GUICtrlCreateButton", $_2nd, $Param_Text) = "Backward", "Back caption from config",   _StubCall("GUICtrlCreateButton", $_2nd, $Param_Text), "Backward")
    _TestFmkAssert(_StubCall("GUICtrlCreateButton", $_3rd, $Param_Text) = "Forward",  "Next caption from config",   _StubCall("GUICtrlCreateButton", $_3rd, $Param_Text), "Forward")
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialInstallerButtonsTest_BtnCaptionsUpdate(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestBtnCaptionsUpdate_UpdatesGlobals,   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestBtnCaptionsUpdate_InvalidConfig,    $bAllPassed)
EndFunc

Func __RunCrucialInstallerButtonsTest_SetButtons(ByRef $bAllPassed)
    _TestFmkSeparator()
	$bAllPassed = _TestFmkRun(_TestSetButtons_InvalidMap,              $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetButtons_ProceedPage,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetButtons_ProcessingPage,          $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetButtons_FinishPage,              $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetButtons_ElseEvent,               $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetButtons_SinglePage,              $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetButtons_FirstPage,               $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetButtons_MidPage,                 $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetButtons_LastPage,                $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetButtons_UnknownPosition,         $bAllPassed)
EndFunc

Func __RunCrucialInstallerButtonsTest_GetButton(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestGetButton_Cancel,                   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetButton_Back,                     $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetButton_Next,                     $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetButton_InvalidKey,               $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetButton_InvalidWizard,            $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetBtnCancel_ReturnsId,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetBtnBack_ReturnsId,               $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetBtnNext_ReturnsId,               $bAllPassed)
EndFunc

Func __RunCrucialInstallerButtonsTest_CreateButtons(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestCreateButtons_InvalidGUI,           $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreateButtons_ReturnsMap,           $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreateButtons_StoresCorrectIDs,     $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreateButtons_UsesConfigCaptions,   $bAllPassed)
EndFunc

Func _RunCrucialInstallerButtonsTests($bWriteSummary = True)
    Local $bAllPassed = True
	__RunCrucialInstallerButtonsTest_BtnCaptionsUpdate($bAllPassed)
	__RunCrucialInstallerButtonsTest_SetButtons($bAllPassed)
	__RunCrucialInstallerButtonsTest_GetButton($bAllPassed)
	__RunCrucialInstallerButtonsTest_CreateButtons($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerButtonsTests, $sScriptName)
