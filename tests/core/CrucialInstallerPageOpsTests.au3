#include-once

#include <TestFramework.au3>
#include <StubConstants.au3>
#include "..\..\src\core\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerPageOpsTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for the Page Operations region of CrucialInstaller.au3.
;                  Tests page hide/show behavior, subheader update, page load, page close,
;                  and full page set sequence.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerPageOpsTests.au3"

; ===============================================================================================================================
; Tests - __HidePage
; ===============================================================================================================================
Func _TestHidePage_HidesAllControls()
    _TestFmkHeader("Test: __HidePage() - calls GUICtrlSetState hide for each control")

    Local $idLblIntro  = 10
	Local $idblVersion = 11
	_SetStubReturn("GUICtrlGetHandle", $_1st, $idLblIntro)
	_SetStubReturn("GUICtrlGetHandle", $_2nd, $idblVersion)

	Local $mPage = _NewPage()
    _SetPageCtrl($mPage, $idLblIntro, "LblIntro")
    _SetPageCtrl($mPage, $idblVersion, "LblVersion")

    __HidePage($mPage.aControls)

    Local $iCount       = _StubCallCount("GUICtrlSetState")
    Local $iFirstState  = _GetStubCall("GUICtrlSetState", $_1st, $Param_State)
    Local $iSecondState = _GetStubCall("GUICtrlSetState", $_2nd, $Param_State)

    _TestFmkAssert($iCount = 2,                "GUICtrlSetState called twice", $iCount,       2)
    _TestFmkAssert($iFirstState  = $GUI_HIDE,  "First call hides",             $iFirstState,  $GUI_HIDE)
    _TestFmkAssert($iSecondState = $GUI_HIDE,  "Second call hides",            $iSecondState, $GUI_HIDE)
EndFunc

Func _TestHidePage_InvalidArray()
    _TestFmkHeader("Test: __HidePage() - does nothing for invalid array")

    __HidePage("invalid array")

    _TestFmkAssert(_StubCallCount("GUICtrlSetState") = 0, "No calls for invalid array", _StubCallCount("GUICtrlSetState"), 0)
EndFunc

; ===============================================================================================================================
; Tests - __HidePages
; ===============================================================================================================================
Func _TestHidePages_HidesAllPages()
    _TestFmkHeader("Test: __HidePages() - hides controls across all pages")

    Local $idLblPage1  = 10
	Local $idLblPage2  = 11
	_SetStubReturn("GUICtrlGetHandle", $_1st, $idLblPage1)
	_SetStubReturn("GUICtrlGetHandle", $_2nd, $idLblPage2)

    Local $mPages = _CreatePages()
    Local $mPage1 = _NewPage()
    Local $mPage2 = _NewPage()
    _SetPageCtrl($mPage1, 10, "LblPage1")
    _SetPageCtrl($mPage2, 11, "LblPage2")
    _AddPage($mPages, $mPage1)
    _AddPage($mPages, $mPage2)

    __HidePages($mPages)

    Local $iCount = _StubCallCount("GUICtrlSetState")

    _TestFmkAssert($iCount = 2, "GUICtrlSetState called for each control", $iCount, 2)
EndFunc

Func _TestHidePages_InvalidMap()
    _TestFmkHeader("Test: __HidePages() - does nothing for invalid pages map")

    __HidePages("invalid pages map")

    _TestFmkAssert(_StubCallCount("GUICtrlSetState") = 0, "No calls for invalid map", _StubCallCount("GUICtrlSetState"), 0)
EndFunc

; ===============================================================================================================================
; Tests - __ShowPageControls
; ===============================================================================================================================
Func _TestShowPageControls_ShowsAllControls()
    _TestFmkHeader("Test: __ShowPageControls() - calls GUICtrlSetState show for each control")

    Local $idLblIntro   = 10
	Local $idLblVersion = 11
	_SetStubReturn("GUICtrlGetHandle", $_1st, $idLblIntro)
	_SetStubReturn("GUICtrlGetHandle", $_2nd, $idLblVersion)

    Local $mPage = _NewPage()
    _SetPageCtrl($mPage, 10, "LblIntro")
    _SetPageCtrl($mPage, 11, "LblVersion")

    __ShowPageControls($mPage)

    Local $iCount       = _StubCallCount("GUICtrlSetState")
    Local $iFirstState  = _GetStubCall("GUICtrlSetState", $_1st, $Param_State)
    Local $iSecondState = _GetStubCall("GUICtrlSetState", $_2nd, $Param_State)
    _TestFmkAssert($iCount = 2,                "GUICtrlSetState called twice", $iCount,       2)
    _TestFmkAssert($iFirstState  = $GUI_SHOW,  "First call shows",             $iFirstState,  $GUI_SHOW)
    _TestFmkAssert($iSecondState = $GUI_SHOW,  "Second call shows",            $iSecondState, $GUI_SHOW)
EndFunc

Func _TestShowPageControls_InvalidPage()
    _TestFmkHeader("Test: __ShowPageControls() - does nothing for invalid page")

    __ShowPageControls("invalid page")

    _TestFmkAssert(_StubCallCount("GUICtrlSetState") = 0, "No calls for invalid page", _StubCallCount("GUICtrlSetState"), 0)
EndFunc

; ===============================================================================================================================
; Tests - __SetPageSubHeader
; ===============================================================================================================================
Func _TestSetPageSubHeader_SetsData()
    _TestFmkHeader("Test: __SetPageSubHeader() - calls GUICtrlSetData with subheading text")

	Local $idHeaderSub = 20
    __SetPageSubHeader($idHeaderSub, "Choose install folder")

    Local $iCount = _StubCallCount("GUICtrlSetData")
    Local $sData  = _GetStubCall("GUICtrlSetData", $_1st, $Param_Data)
    _TestFmkAssert($iCount = 1,                           "GUICtrlSetData called once",    $iCount, 1)
    _TestFmkAssert($sData = "Choose install folder",      "Subheading set correctly",      $sData,  "Choose install folder")
EndFunc

; ===============================================================================================================================
; Tests - __PageLoad
; ===============================================================================================================================

Func __TestOnLoadHandler()
    $g_bOnLoadCalled = True
EndFunc

Func __TestAfterLoadHandler()
    $g_bAfterLoadCalled = True
EndFunc

Func _TestPageLoad_InvalidPage()
    _TestFmkHeader("Test: __PageLoad() - does nothing for invalid page")

    _SetStubReturn("IsHWnd", $_1st, True)

	Local $hGUI = 1
    Local $mButtons = _CreateButtons($hGUI, _NewInstallerCfg())

	Local $idHeaderSub = 20
    __PageLoad("invalid page", $mButtons, $idHeaderSub, $eFirstPage)

    _TestFmkAssert(_StubCallCount("GUICtrlSetData") = 0, "No calls for invalid page", _StubCallCount("GUICtrlSetData"), 0)
EndFunc

Func _TestPageLoad_InvalidPosition()
    _TestFmkHeader("Test: __PageLoad() - does nothing for invalid page position")

    _SetStubReturn("IsHWnd", $_1st, True)

    Local $hGUI     = 1
	Local $mPage    = _NewPage("Test Page")
    Local $mButtons = _CreateButtons($hGUI, _NewInstallerCfg())
	Local $idHeaderSub = 20

    __PageLoad($mPage, $mButtons, $idHeaderSub, $eInvalidPage)

    _TestFmkAssert(_StubCallCount("GUICtrlSetData") = 0, "No calls for invalid position", _StubCallCount("GUICtrlSetData"), 0)
EndFunc

Func _TestPageLoad_SetsSubHeader()
    _TestFmkHeader("Test: __PageLoad() - sets subheader text on load")

    _SetStubReturn("IsHWnd", $_1st, True)

	Local $hGUI     = 1
    Local $mPage    = _NewPage("My Subheading")
    Local $mButtons = _CreateButtons($hGUI, _NewInstallerCfg())
	Local $idHeaderSub = 20

    __PageLoad($mPage, $mButtons, $idHeaderSub, $eFirstPage)

    Local $sData = _GetStubCall("GUICtrlSetData", $_1st, $Param_Data)
    _TestFmkAssert($sData = "My Subheading", "Subheader set correctly", $sData, "My Subheading")
EndFunc

Func _TestPageLoad_ShowsPageControls()
    _TestFmkHeader("Test: __PageLoad() - shows page controls on load")

    Local $idCtrl = 20
	_SetStubReturn("IsHWnd", $_1st, True)
	_SetStubReturn("GUICtrlGetHandle", $_1st, $idCtrl)

	Local $hGUI     = 1
    Local $mPage    = _NewPage("Test")
    _SetPageCtrl($mPage, $idCtrl, "LblTest")
    Local $mButtons = _CreateButtons($hGUI, _NewInstallerCfg())
	Local $idHeaderSub = 30

    __PageLoad($mPage, $mButtons, $idHeaderSub, $eFirstPage)

    Local $iFirstShowState = _GetStubCall("GUICtrlSetState", $_1st, $Param_State)
    _TestFmkAssert($iFirstShowState = $GUI_SHOW, "Page control shown", $iFirstShowState, $GUI_SHOW)
EndFunc

Func _TestPageLoad_SetsButtons()
    _TestFmkHeader("Test: __PageLoad() - calls __SetButtons to update button states")

	Local $idBtnCancel = 10
	Local $idBtnBack   = 11
	Local $idBtnNext   = 12
	_SetStubReturn("GUICtrlCreateButton", $_1st, $idBtnCancel)
	_SetStubReturn("GUICtrlCreateButton", $_2nd, $idBtnBack)
	_SetStubReturn("GUICtrlCreateButton", $_3rd, $idBtnNext)
    _SetStubReturn("IsHWnd", $_1st, True)

	Local $hGUI     = 1
    Local $mPage    = _NewPage("Test")
    Local $mButtons = _CreateButtons($hGUI, _NewInstallerCfg())
	Local $idHeaderSub = 20

    __PageLoad($mPage, $mButtons, $idHeaderSub, $eFirstPage)

	Local $iCancelId = _GetStubCall("GUICtrlSetState", $_1st, $Param_ControlId)
	Local $iBackId   = _GetStubCall("GUICtrlSetState", $_2nd, $Param_ControlId)
	Local $iNextId   = _GetStubCall("GUICtrlSetState", $_3rd, $Param_ControlId)
	_TestFmkAssert($iCancelId = $idBtnCancel, "Cancel button updated", $iCancelId, $idBtnCancel)
	_TestFmkAssert($iBackId   = $idBtnBack,   "Back button updated",   $iBackId,   $idBtnBack)
	_TestFmkAssert($iNextId   = $idBtnNext,   "Next button updated",   $iNextId,   $idBtnNext)
EndFunc

Func _TestPageLoad_SetsInstallerEvent()
    _TestFmkHeader("Test: __PageLoad() - sets installer event from page status")

    _SetStubReturn("IsHWnd", $_1st, True)

	Local $hGUI     = 1
    Local $mPage    = _NewPage("New Page", $eProceedPage)
    Local $mButtons = _CreateButtons($hGUI, _NewInstallerCfg())
	Local $idHeaderSub = 20

    __PageLoad($mPage, $mButtons, $idHeaderSub, $eFirstPage)

    _TestFmkAssert(_GetInstallerEvent() = $eProceedPage, "Event set from page status", _GetInstallerEvent(), $eProceedPage)
EndFunc

Func _TestPageLoad_TriggersOnLoad()
    _TestFmkHeader("Test: __PageLoad() - triggers OnLoad handler")

    _SetStubReturn("IsHWnd",              $_1st, True)

    Global $g_bOnLoadCalled = False
	Local $hGUI     = 1
    Local $mPage    = _NewPage("Test")
    $mPage[$ONLOAD] = _SetEventHandler(__TestOnLoadHandler)
    Local $mButtons = _CreateButtons($hGUI, _NewInstallerCfg())
	Local $idHeaderSub = 20

    __PageLoad($mPage, $mButtons, $idHeaderSub, $eFirstPage)

    _TestFmkAssert($g_bOnLoadCalled = True, "OnLoad handler called", $g_bOnLoadCalled, True)
EndFunc

Func _TestPageLoad_TriggersAfterLoad()
    _TestFmkHeader("Test: __PageLoad() - triggers AfterLoad handler")

    _SetStubReturn("IsHWnd",              $_1st, True)

    Global $g_bAfterLoadCalled = False
	Local $hGUI     	 = 1
    Local $mPage         = _NewPage("Test")
    $mPage[$AFTERLOAD]   = _SetEventHandler(__TestAfterLoadHandler)
    Local $mButtons      = _CreateButtons($hGUI, _NewInstallerCfg())
	Local $idHeaderSub 	 = 20

    __PageLoad($mPage, $mButtons, $idHeaderSub, $eFirstPage)

    _TestFmkAssert($g_bAfterLoadCalled = True, "AfterLoad handler called", $g_bAfterLoadCalled, True)
EndFunc

; ===============================================================================================================================
; Tests - __ClosePage
; ===============================================================================================================================

Func __TestOnCloseHandler()
    $g_bOnCloseCalled = True
EndFunc

Func _TestClosePage_TriggersOnClose()
    _TestFmkHeader("Test: __ClosePage() - triggers OnClose handler for page")

    Global $g_bOnCloseCalled = False
    Local $mPages = _CreatePages()
    Local $mPage  = _NewPage("Test")
    $mPage[$ONCLOSE] = _SetEventHandler(__TestOnCloseHandler)
    _AddPage($mPages, $mPage)

    Local $iPage = 1
	__ClosePage($iPage, $mPages)

    _TestFmkAssert($g_bOnCloseCalled = True, "OnClose handler called", $g_bOnCloseCalled, True)
EndFunc

Func _TestClosePage_InvalidPages()
    _TestFmkHeader("Test: __ClosePage() - does nothing for invalid pages map")

    Global $g_bOnCloseCalled = False

	Local $iPage = 1
    __ClosePage($iPage, "invalid pages map")

    _TestFmkAssert($g_bOnCloseCalled = False, "No call for invalid pages map", $g_bOnCloseCalled, False)
EndFunc

; ===============================================================================================================================
; Tests - __SetPage
; ===============================================================================================================================
Func _TestSetPage_HidesPagesBeforeLoad()
    _TestFmkHeader("Test: __SetPage() - hides all pages before loading target page")

    Local $idLblPage1 = 20
	_SetStubReturn("IsHWnd", $_1st, True)
	_SetStubReturn("GUICtrlGetHandle", $_1st, $idLblPage1)

	Local $hGUI 	  = 1
    Local $mPages     = _CreatePages()
    Local $mPage1     = _NewPage("Page 1")
    Local $mPage2     = _NewPage("Page 2")
    _SetPageCtrl($mPage1, $idLblPage1, "LblPage1")
    _AddPage($mPages, $mPage1)
    _AddPage($mPages, $mPage2)
    Local $mButtons   = _CreateButtons($hGUI, _NewInstallerCfg())

	Local $iPage = 2
	Local $idHeaderSub = 30
    __SetPage($iPage, $idHeaderSub, $mPages, $mButtons)

    Local $iHideId    = _GetStubCall("GUICtrlSetState", $_1st, $Param_ControlId)
    Local $iHideState = _GetStubCall("GUICtrlSetState", $_1st, $Param_State)
    _TestFmkAssert($iHideId    = $idLblPage1, "Correct control hidden",  $iHideId,    $idLblPage1)
    _TestFmkAssert($iHideState = $GUI_HIDE,   "Control state is hidden", $iHideState, $GUI_HIDE)
EndFunc

Func _TestSetPage_LoadsCorrectPage()
    _TestFmkHeader("Test: __SetPage() - loads the correct page")

    _SetStubReturn("IsHWnd", $_1st, True)

	Local $hGUI 	= 1
    Local $mPages   = _CreatePages()
    Local $mPage1   = _NewPage("Page 1")
    Local $mPage2   = _NewPage("Page 2")
    _AddPage($mPages, $mPage1)
    _AddPage($mPages, $mPage2)
    Local $mButtons = _CreateButtons($hGUI, _NewInstallerCfg())

	Local $iPage = 2
	Local $idHeaderSub = 30
    __SetPage($iPage, $idHeaderSub, $mPages, $mButtons)

    Local $sData = _GetStubCall("GUICtrlSetData", $_1st, $Param_Data)
    _TestFmkAssert($sData = "Page 2", "Page 2 subheader loaded", $sData, "Page 2")
EndFunc

; ===============================================================================================================================
; Tests - _ProgressStep
; ===============================================================================================================================
Func _TestProgressStep_SetsProgressValue()
    _TestFmkHeader("Test: _ProgressStep() - sets progress bar to correct percentage")

    Local $idLabel     = 10
    Local $idProgress  = 11
	Local $iStep	   = 1
	Local $iTotalSteps = 4
	Local $sStatus	   = "Installing..."

    _ProgressStep($idLabel, $idProgress, $iStep, $iTotalSteps, $sStatus)

    Local $iProgressId  = _GetStubCall("GUICtrlSetData", $_1st, $Param_ControlId)
    Local $iProgressVal = _GetStubCall("GUICtrlSetData", $_1st, $Param_Data)
    _TestFmkAssert($iProgressId  = $idProgress, "Progress bar control ID correct", $iProgressId,  $idProgress)
    _TestFmkAssert($iProgressVal = 25,           "Progress set to 25%",             $iProgressVal, 25)
EndFunc

Func _TestProgressStep_SetsStatusLabel()
    _TestFmkHeader("Test: _ProgressStep() - sets status label text")

    Local $idLabel     = 10
    Local $idProgress  = 11
	Local $iStep	   = 1
	Local $iTotalSteps = 4
	Local $sStatus	   = "Installing..."

    _ProgressStep($idLabel, $idProgress, $iStep, $iTotalSteps, $sStatus)

    Local $iLabelId   = _GetStubCall("GUICtrlSetData", $_2nd, $Param_ControlId)
    Local $sLabelText = _GetStubCall("GUICtrlSetData", $_2nd, $Param_Data)
    _TestFmkAssert($iLabelId   = $idLabel,       "Label control ID correct", $iLabelId,   $idLabel)
    _TestFmkAssert($sLabelText = "Installing...", "Status text correct",      $sLabelText, "Installing...")
EndFunc

Func _TestProgressStep_100PercentOnLastStep()
    _TestFmkHeader("Test: _ProgressStep() - sets progress to 100% on last step")

    Local $idLabel     = 10
    Local $idProgress  = 11
	Local $iStep	   = 4
	Local $iTotalSteps = 4
	Local $sStatus	   = "Done"

    _ProgressStep($idLabel, $idProgress, $iStep, $iTotalSteps, $sStatus)

    Local $iProgressVal = _GetStubCall("GUICtrlSetData", $_1st, $Param_Data)
    _TestFmkAssert($iProgressVal = 100, "Progress set to 100%", $iProgressVal, 100)
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialInstallerPageOpsTest_HidePage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestHidePage_HidesAllControls, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestHidePage_InvalidArray,     $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageOpsTest_HidePages(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestHidePages_HidesAllPages, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestHidePages_InvalidMap,    $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageOpsTest_ShowPageControls(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestShowPageControls_ShowsAllControls, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestShowPageControls_InvalidPage,      $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageOpsTest_SetPageSubHeader(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestSetPageSubHeader_SetsData, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageOpsTest_PageLoad(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestPageLoad_InvalidPage,       $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestPageLoad_InvalidPosition,   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestPageLoad_SetsSubHeader,     $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestPageLoad_ShowsPageControls, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestPageLoad_SetsButtons, 	   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestPageLoad_SetsInstallerEvent,$bAllPassed)
    $bAllPassed = _TestFmkRun(_TestPageLoad_TriggersOnLoad,    $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestPageLoad_TriggersAfterLoad, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageOpsTest_ClosePage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestClosePage_TriggersOnClose, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestClosePage_InvalidPages,    $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageOpsTest_SetPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestSetPage_HidesPagesBeforeLoad,  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetPage_LoadsCorrectPage, 	  $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageOpsTest_ProgressStep(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestProgressStep_SetsProgressValue,  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestProgressStep_SetsStatusLabel,    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestProgressStep_100PercentOnLastStep, $bAllPassed)
EndFunc

Func _RunCrucialInstallerPageOpsTests($bWriteSummary = True)
    Local $bAllPassed = True
    __RunCrucialInstallerPageOpsTest_HidePage($bAllPassed)
    __RunCrucialInstallerPageOpsTest_HidePages($bAllPassed)
    __RunCrucialInstallerPageOpsTest_ShowPageControls($bAllPassed)
    __RunCrucialInstallerPageOpsTest_SetPageSubHeader($bAllPassed)
    __RunCrucialInstallerPageOpsTest_PageLoad($bAllPassed)
    __RunCrucialInstallerPageOpsTest_ClosePage($bAllPassed)
    __RunCrucialInstallerPageOpsTest_SetPage($bAllPassed)
	__RunCrucialInstallerPageOpsTest_ProgressStep($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerPageOpsTests, $sScriptName)
