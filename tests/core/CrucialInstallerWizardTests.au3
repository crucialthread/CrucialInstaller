#include-once

#include "..\..\lib\TestFramework\TestFramework.au3"
#include "..\..\lib\TestFramework\StubConstants.au3"
#include "..\..\src\core\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerWizardTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for the Wizard Helpers and Wizard Init regions of CrucialInstaller.au3.
;                  Tests wizard validation, cancel confirmation, and wizard initialization.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerWizardTests.au3"

; ===============================================================================================================================
; Helpers
; ===============================================================================================================================
Func __SetupWizardStubs()
	_SetStubReturn("IsHWnd", $_1st, True)	; _CreateHeader
	_SetStubReturn("IsHWnd", $_2nd, True)	; _CreateHeaderTitle
	_SetStubReturn("IsHWnd", $_3rd, True)	; _CreateHeaderSub
	_SetStubReturn("IsHWnd", $_4th, True)	; _CreateSeparator (by _CreateHeader)
	_SetStubReturn("IsHWnd", $_5th, True)	; _CreateSeparator (by _NewWizard - idFooterSep)
	_SetStubReturn("IsHWnd", $_6th, True)	; _CreateButtons
    _SetStubReturn("IsHWnd", $_7th, True)	; __IsValidWizard
EndFunc

; ===============================================================================================================================
; Tests - __IsValidWizardHeader
; ===============================================================================================================================
Func _TestIsValidWizardHeader_ValidHeader()
    _TestFmkHeader("Test: __IsValidWizardHeader() - returns True for valid header")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")

    _TestFmkAssert(__IsValidWizardHeader($mWizard) = True, "Returns True for valid header", __IsValidWizardHeader($mWizard), True)
EndFunc

Func _TestIsValidWizardHeader_NotAMap()
    _TestFmkHeader("Test: __IsValidWizardHeader() - returns False when header is not a map")

    Local $mWizard[]
    $mWizard.mHeader = "invalid header"

	Local $bCondition = __IsValidWizardHeader($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False for non-map header", $bCondition, False)
EndFunc

Func _TestIsValidWizardHeader_MissingId()
    _TestFmkHeader("Test: __IsValidWizardHeader() - returns False when id missing")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    MapRemove($mWizard.mHeader, "id")

	Local $bCondition = __IsValidWizardHeader($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False when id missing", $bCondition, False)
EndFunc

Func _TestIsValidWizardHeader_MissingIdTitle()
    _TestFmkHeader("Test: __IsValidWizardHeader() - returns False when idTitle missing")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    MapRemove($mWizard.mHeader, "idTitle")

	Local $bCondition = __IsValidWizardHeader($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False when idTitle missing", $bCondition, False)
EndFunc

Func _TestIsValidWizardHeader_MissingIdSubheading()
    _TestFmkHeader("Test: __IsValidWizardHeader() - returns False when idSubheading missing")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    MapRemove($mWizard.mHeader, "idSubheading")

	Local $bCondition = __IsValidWizardHeader($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False when idSubheading missing", $bCondition, False)
EndFunc

Func _TestIsValidWizardHeader_MissingIdSeparator()
    _TestFmkHeader("Test: __IsValidWizardHeader() - returns False when idSeparator missing")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    MapRemove($mWizard.mHeader, "idSeparator")

	Local $bCondition = __IsValidWizardHeader($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False when idSeparator missing", $bCondition, False)
EndFunc

; ===============================================================================================================================
; Tests - __IsValidWizardButtons
; ===============================================================================================================================
Func _TestIsValidWizardButtons_ValidButtons()
    _TestFmkHeader("Test: __IsValidWizardButtons() - returns True for valid buttons")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")

	Local $bCondition = __IsValidWizardButtons($mWizard)

    _TestFmkAssert($bCondition = True, "Returns True for valid buttons", $bCondition, True)
EndFunc

Func _TestIsValidWizardButtons_NotAMap()
    _TestFmkHeader("Test: __IsValidWizardButtons() - returns False when buttons is not a map")

    Local $mWizard[]
    $mWizard.mButtons = 0

	Local $bCondition = __IsValidWizardButtons($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False for non-map buttons", $bCondition, False)
EndFunc

Func _TestIsValidWizardButtons_LessThanRequired()
    _TestFmkHeader("Test: __IsValidWizardButtons() - returns False when there are Less buttons than required")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
	MapRemove($mWizard.mButtons, $BTN_NEXT)

	Local $bCondition = __IsValidWizardButtons($mWizard)

	_TestFmkAssert(UBound($mWizard.mButtons) = 2, "There are 2 button entries", UBound($mWizard.mButtons), 2)
    _TestFmkAssert($bCondition = False, "Returns False when there are less buttons than required", $bCondition, False)
EndFunc

Func _TestIsValidWizardButtons_MoreThanRequired()
    _TestFmkHeader("Test: __IsValidWizardButtons() - returns False when there are more buttons than required")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
	$mWizard["mButtons"]["newBtn"] = 0

	Local $bCondition = __IsValidWizardButtons($mWizard)

	_TestFmkAssert(UBound($mWizard.mButtons) = 4, "There are 4 button entries", UBound($mWizard.mButtons), 4)
    _TestFmkAssert($bCondition = False, "Returns False when there are more buttons than required", $bCondition, False)
EndFunc

Func _TestIsValidWizardButtons_MissingBtnCancel()
    _TestFmkHeader("Test: __IsValidWizardButtons() - returns False when " & $BTN_CANCEL & " missing")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
	MapRemove($mWizard.mButtons, $BTN_CANCEL)
	$mWizard["mButtons"]["newBtn"] = 0

	Local $bCondition = __IsValidWizardButtons($mWizard)

	_TestFmkAssert(UBound($mWizard.mButtons) = 3, "There are 3 button entries", UBound($mWizard.mButtons), 3)
    _TestFmkAssert($bCondition = False, "Returns False when " & $BTN_CANCEL & " missing", $bCondition, False)
EndFunc

Func _TestIsValidWizardButtons_MissingBtnBtnBack()
    _TestFmkHeader("Test: __IsValidWizardButtons() - returns False when " & $BTN_BACK & " missing")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
	MapRemove($mWizard.mButtons, $BTN_BACK)
	$mWizard["mButtons"]["newBtn"] = 0

	Local $bCondition = __IsValidWizardButtons($mWizard)

	_TestFmkAssert(UBound($mWizard.mButtons) = 3, "There are 3 button entries", UBound($mWizard.mButtons), 3)
    _TestFmkAssert($bCondition = False, "Returns False when " & $BTN_BACK & " missing", $bCondition, False)
EndFunc

Func _TestIsValidWizardButtons_MissingBtnBtnNext()
    _TestFmkHeader("Test: __IsValidWizardButtons() - returns False when " & $BTN_NEXT & " missing")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
	MapRemove($mWizard.mButtons, $BTN_NEXT)
	$mWizard["mButtons"]["newBtn"] = 0

	Local $bCondition = __IsValidWizardButtons($mWizard)

	_TestFmkAssert(UBound($mWizard.mButtons) = 3, "There are 3 button entries", UBound($mWizard.mButtons), 3)
    _TestFmkAssert($bCondition = False, "Returns False when " & $BTN_NEXT & " missing", $bCondition, False)
EndFunc

; ===============================================================================================================================
; Tests - __IsValidWizard
; ===============================================================================================================================
Func _TestIsValidWizard_ValidWizard()
    _TestFmkHeader("Test: __IsValidWizard() - returns True for fully valid wizard")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")

	Local $bCondition = __IsValidWizard($mWizard)

    _TestFmkAssert($bCondition = True, "Returns True for valid wizard", $bCondition, True)
EndFunc

Func _TestIsValidWizard_NotAMap()
    _TestFmkHeader("Test: __IsValidWizard() - returns False for non-map input")

	Local $bCondition = __IsValidWizard("not a map")

    _TestFmkAssert($bCondition = False, "Returns False for non-map", $bCondition, False)
EndFunc

Func _TestIsValidWizard_InvalidHeader()
    _TestFmkHeader("Test: __IsValidWizard() - returns False for invalid header")

    __SetupWizardStubs()
	Local $mEmpty[]
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
	$mWizard.mHeader = $mEmpty

	Local $bCondition = __IsValidWizard($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False for invalid header", $bCondition, False)
EndFunc

Func _TestIsValidWizard_InvalidButtons()
    _TestFmkHeader("Test: __IsValidWizard() - returns False for invalid buttons")

    __SetupWizardStubs()
	Local $mEmpty[]
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
	$mWizard.mButtons = $mEmpty

	Local $bCondition = __IsValidWizard($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False for invalid buttons", $bCondition, False)
EndFunc

Func _TestIsValidWizard_InvalidPages()
    _TestFmkHeader("Test: __IsValidWizard() - returns False for invalid pages")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
	$mWizard.mPages = "invalid pages"

	Local $bCondition = __IsValidWizard($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False for invalid pages", $bCondition, False)
EndFunc

Func _TestIsValidWizard_MissingHWin()
    _TestFmkHeader("Test: __IsValidWizard() - returns False when hWin missing")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    MapRemove($mWizard, "hWin")

	Local $bCondition = __IsValidWizard($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False when hWin missing", $bCondition, False)
EndFunc

Func _TestIsValidWizard_MissingIdFooterSep()
    _TestFmkHeader("Test: __IsValidWizard() - returns False when idFooterSep missing")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    MapRemove($mWizard, "idFooterSep")

	Local $bCondition = __IsValidWizard($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False when idFooterSep missing", $bCondition, False)
EndFunc

Func _TestIsValidWizard_MissingIPage()
    _TestFmkHeader("Test: __IsValidWizard() - returns False when iPage missing")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    MapRemove($mWizard, "iPage")

	Local $bCondition = __IsValidWizard($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False when iPage missing", $bCondition, False)
EndFunc

Func _TestIsValidWizard_InvalidHWin()
    _TestFmkHeader("Test: __IsValidWizard() - returns False when hWin is invalid")

    __SetupWizardStubs()
	_SetStubReturn("IsHWnd", $_7th, False)	; __IsValidWizard
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")

	Local $bCondition = __IsValidWizard($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False when hWin is invalid", $bCondition, False)
EndFunc

; ===============================================================================================================================
; Tests - __IsWizardReady
; ===============================================================================================================================
Func _TestIsWizardReady_WithPages()
    _TestFmkHeader("Test: __IsWizardReady() - returns True when wizard has pages")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage()
    _AddPage($mWizard.mPages, $mPage)

	$bCondition = __IsWizardReady($mWizard)

    _TestFmkAssert($bCondition = True, "Returns True with pages", $bCondition, True)
EndFunc

Func _TestIsWizardReady_NoPages()
    _TestFmkHeader("Test: __IsWizardReady() - returns False when wizard has no pages")

    __SetupWizardStubs()
    _SetStubReturn("IsHWnd", 1, True)
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")

	$bCondition = __IsWizardReady($mWizard)

    _TestFmkAssert($bCondition = False, "Returns False with no pages", $bCondition, False)
EndFunc

Func _TestIsWizardReady_InvalidWizard()
    _TestFmkHeader("Test: __IsWizardReady() - returns False for invalid wizard")

	$bCondition = __IsWizardReady("invalid wizard")

    _TestFmkAssert($bCondition = False, "Returns False for invalid wizard", $bCondition, False)
EndFunc

; ===============================================================================================================================
; Tests - __MsgCloseInstall
; ===============================================================================================================================
Func _TestMsgCloseInstall_ShowMsgOnlyWhenAllowed()
    _TestFmkHeader("Test: __MsgCloseInstall() - Shows close message only for allowed page types")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
	Local $iMsgCount = 0
	Local $bAllowed = True

	; Create page for all page status
	For $iPageType = $eClosePage To $eFinishPage
		Local $mPage = _NewPage("Page" & $iPageType, $iPageType)
		_AddPage($mWizard.mPages, $mPage)
	Next

	; Navigate through all pages and call __MsgCloseInstall
	For $iPage = 1 To __MaxPages($mWizard.mPages)
		$mWizard.iPage = $iPage
		__MsgCloseInstall($mWizard)

		; Check if any unallowed page status type has called the MsgBox
		Local $iStatus = $mWizard["mPages"][$iPage]["iStatus"]
		$bAllowed = $bAllowed And (_StubCallCount("MsgBox") = $iMsgCount Or $iStatus = $eNormalPage Or $iStatus = $eProceedPage)
		$iMsgCount = _StubCallCount("MsgBox")
	Next

	; Only normal and proceed page types should display the message
	_TestFmkAssert(_StubCallCount("MsgBox") = 2, "Two MsgBox shown", _StubCallCount("MsgBox"), 2)
	_TestFmkAssert($bAllowed = True, "Shown only for allowed page types", $bAllowed, True)
EndFunc

Func _TestMsgCloseInstall_UnallowedPageDoesNothing()
    _TestFmkHeader("Test: __MsgCloseInstall() - returns IDNO without MsgBox on unallowed page status")

    __SetupWizardStubs()
	; It is not expected any msg to be shown,
	; but if any shows then confirms by default to fail the test
	_SetStubReturn("MsgBox",  1, $IDYES)
	_SetStubReturn("MsgBox",  2, $IDYES)
	_SetStubReturn("MsgBox",  3, $IDYES)

    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")

	; Not allowed page status
    Local $mPage1  = _NewPage("Close page", 	 $eClosePage)
	Local $mPage2  = _NewPage("Processing page", $eProcessingPage)
	Local $mPage3  = _NewPage("Finish page", 	 $eFinishPage)
    Local $iPage1  = _AddPage($mWizard.mPages, $mPage1)
	Local $iPage2  = _AddPage($mWizard.mPages, $mPage2)
	Local $iPage3  = _AddPage($mWizard.mPages, $mPage3)

	Local $iResult = 0xF	;Bitwise operation mask

	$mWizard.iPage = 1
	For $iPage = 1 To 3
		$mWizard.iPage = $iPage
		$iResult = BitAND($iResult, Abs(__MsgCloseInstall($mWizard)))
	Next

	_TestFmkAssert($iResult = $IDNO, "Returns IDNO on unallowed page status", $iResult, $IDNO)
	_TestFmkAssert(_StubCallCount("MsgBox") = 0, "No MsgBox shown", _StubCallCount("MsgBox"), 0)
EndFunc

Func _TestMsgCloseInstall_Confirmed()
    _TestFmkHeader("Test: __MsgCloseInstall() - returns EXIT_WIZARD_SIGNAL when user confirms")

    __SetupWizardStubs()
    _SetStubReturn("MsgBox",  1, $IDYES)
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage("Normal page",  $eNormalPage)
    _AddPage($mWizard.mPages, $mPage)
	$mWizard.iPage = 1

    Local $iResult = __MsgCloseInstall($mWizard)

	_TestFmkAssert(_StubCallCount("MsgBox") = 1, "One MsgBox shown", _StubCallCount("MsgBox"), 1)
    _TestFmkAssert($iResult = $EXIT_WIZARD_SIGNAL, "Returns EXIT_WIZARD_SIGNAL when confirmed", $iResult, $EXIT_WIZARD_SIGNAL)
EndFunc

Func _TestMsgCloseInstall_Declined()
    _TestFmkHeader("Test: __MsgCloseInstall() - returns IDNO when user declines")

    __SetupWizardStubs()
    _SetStubReturn("MsgBox",  1, $IDNO)
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage("page", $eNormalPage)
    _AddPage($mWizard.mPages, $mPage)
	$mWizard.iPage = 1

    Local $iResult = __MsgCloseInstall($mWizard)

	_TestFmkAssert(_StubCallCount("MsgBox") = 1, "One MsgBox shown", _StubCallCount("MsgBox"), 1)
    _TestFmkAssert($iResult = $IDNO, "Returns IDNO when declined", $iResult, $IDNO)
EndFunc

; ===============================================================================================================================
; Tests - _NewWizard
; ===============================================================================================================================
Func _TestNewWizard_ReturnsValidWizard()
    _TestFmkHeader("Test: _NewWizard() - returns valid wizard map")

    __SetupWizardStubs()
    _SetStubReturn("IsHWnd", 1, True)
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")

	Local $bIsValidWizard = __IsValidWizard($mWizard)

    _TestFmkAssert(IsMap($mWizard), "Returns a map",     IsMap($mWizard), True)
    _TestFmkAssert($bIsValidWizard, "Wizard is valid",   $bIsValidWizard, True)
EndFunc

Func _TestNewWizard_InvalidConfig()
    _TestFmkHeader("Test: _NewWizard() - returns Null for invalid config")

	Local $mCfg = "Invalid Config"
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")

    _TestFmkAssert($mWizard = Null, "Returns Null for invalid config", $mWizard, Null)
EndFunc

Func _TestNewWizard_StoresTitle()
    _TestFmkHeader("Test: _NewWizard() - stores title in wizard map")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test Wizard", "Test Header")

	Local $vTitle = _Tstbl_GUICtrlRead($mWizard.mHeader.idTitle)

    _TestFmkAssert($mWizard.sTitle = "Test Wizard", "Title stored correctly", $mWizard.sTitle, "Test Wizard")
EndFunc

; TODO ensure it calls __BtnCaptionsUpdate

; ===============================================================================================================================
; Tests - _GetWizardPage
; ===============================================================================================================================
Func _TestGetWizardPage_Found()
    _TestFmkHeader("Test: _GetWizardPage() - returns page map for valid index")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage("My Page")
    _AddPage($mWizard.mPages, $mPage)

    Local $mResult = _GetWizardPage($mWizard, 1)

    _TestFmkAssert(IsMap($mResult), "Returns a map", IsMap($mResult), True)
    _TestFmkAssert($mResult.sSubheading = "My Page", "Correct page returned", $mResult.sSubheading, "My Page")
EndFunc

Func _TestGetWizardPage_NotFound()
    _TestFmkHeader("Test: _GetWizardPage() - returns Null for missing index")

    __SetupWizardStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage("My Page")
    Local $iPage   = _AddPage($mWizard.mPages, $mPage)

	Local $iInvalidIndex = __MaxPages($mWizard) + 1
	Local $vResult = _GetWizardPage($mWizard, $iInvalidIndex)

    _TestFmkAssert($vResult = Null, "Returns Null for missing index", $vResult, Null)
EndFunc

Func _TestGetWizardPage_InvalidWizard()
    _TestFmkHeader("Test: _GetWizardPage() - returns Null for invalid wizard")

	Local $vResult = _GetWizardPage("invalid wizard", 1)

    _TestFmkAssert($vResult = Null, "Returns Null for invalid wizard", $vResult, Null)
EndFunc

; ===============================================================================================================================
; Run 8tests
; ===============================================================================================================================
Func __RunCrucialInstallerWizardTest_IsValidWizardHeader(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestIsValidWizardHeader_ValidHeader,             $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizardHeader_NotAMap,                 $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizardHeader_MissingId,               $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizardHeader_MissingIdTitle,          $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsValidWizardHeader_MissingIdSubheading,     $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizardHeader_MissingIdSeparator,      $bAllPassed)
EndFunc

Func __RunCrucialInstallerWizardTest_IsValidWizardButtons(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestIsValidWizardButtons_ValidButtons,           $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizardButtons_NotAMap,                $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizardButtons_MoreThanRequired,       $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizardButtons_LessThanRequired,       $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsValidWizardButtons_MissingBtnCancel,       $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizardButtons_MissingBtnBtnBack,      $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizardButtons_MissingBtnBtnNext,      $bAllPassed)
EndFunc

Func __RunCrucialInstallerWizardTest_IsValidWizard(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestIsValidWizard_ValidWizard,                   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsValidWizard_NotAMap,                       $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizard_InvalidHeader,                 $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizard_InvalidButtons,                $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizard_InvalidPages,                  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsValidWizard_MissingHWin,                   $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizard_MissingIPage,                  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizard_MissingIdFooterSep,            $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidWizard_InvalidHWin,                   $bAllPassed)
EndFunc

Func __RunCrucialInstallerWizardTest_IsWizardReady(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestIsWizardReady_WithPages,                     $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsWizardReady_NoPages,                       $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsWizardReady_InvalidWizard,                 $bAllPassed)
EndFunc

Func __RunCrucialInstallerWizardTest_MsgCloseInstall(ByRef $bAllPassed)
    _TestFmkSeparator()
	$bAllPassed = _TestFmkRun(_TestMsgCloseInstall_ShowMsgOnlyWhenAllowed,      $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestMsgCloseInstall_UnallowedPageDoesNothing,    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestMsgCloseInstall_Confirmed,         			$bAllPassed)
    $bAllPassed = _TestFmkRun(_TestMsgCloseInstall_Declined,          		    $bAllPassed)
EndFunc

Func __RunCrucialInstallerWizardTest_NewWizard(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestNewWizard_ReturnsValidWizard,                $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestNewWizard_InvalidConfig,                     $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestNewWizard_StoresTitle,                       $bAllPassed)
EndFunc

Func __RunCrucialInstallerWizardTest_GetWizardPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestGetWizardPage_Found,                         $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetWizardPage_NotFound,                      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetWizardPage_InvalidWizard,                 $bAllPassed)
EndFunc

Func _RunCrucialInstallerWizardTests($bWriteSummary = True)
    Local $bAllPassed = True
	__RunCrucialInstallerWizardTest_IsValidWizardHeader($bAllPassed)
	__RunCrucialInstallerWizardTest_IsValidWizardButtons($bAllPassed)
	__RunCrucialInstallerWizardTest_IsValidWizard($bAllPassed)
	__RunCrucialInstallerWizardTest_IsWizardReady($bAllPassed)
	__RunCrucialInstallerWizardTest_MsgCloseInstall($bAllPassed)
	__RunCrucialInstallerWizardTest_NewWizard($bAllPassed)
	__RunCrucialInstallerWizardTest_GetWizardPage($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerWizardTests, $sScriptName)
