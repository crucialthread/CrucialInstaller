#include-once

#include "..\src\core\TestFramework.au3"
#include "..\src\core\StubConstants.au3"
#include "..\src\installer\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerNavTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for the Page Navigation and Main Buttons regions of CrucialInstaller.au3.
;                  Tests page movement logic, direction handling, and button control ID accessors.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerNavTests.au3"

; ===============================================================================================================================
; Tests - __NextPage
; ===============================================================================================================================
Func _TestNextPage_FromFirstPage()
    _TestFmkHeader("Test: __NextPage() - advances from first page")

    Local $iResult = __NextPage(1, $eFirstPage)

    _TestFmkAssert($iResult = 2, "Returns 2 from page 1", $iResult, 2)
EndFunc

Func _TestNextPage_FromMidPage()
    _TestFmkHeader("Test: __NextPage() - advances from mid page")

    Local $iResult = __NextPage(2, $eMidPage)

    _TestFmkAssert($iResult = 3, "Returns 3 from page 2", $iResult, 3)
EndFunc

Func _TestNextPage_StaysAtLastPage()
    _TestFmkHeader("Test: __NextPage() - stays at last page")

    Local $iResult = __NextPage(3, $eLastPage)

    _TestFmkAssert($iResult = 3, "Stays at page 3", $iResult, 3)
EndFunc

Func _TestNextPage_StaysAtSinglePage()
    _TestFmkHeader("Test: __NextPage() - stays at single page")

    Local $iResult = __NextPage(1, $eSinglePage)

    _TestFmkAssert($iResult = 1, "Stays at page 1", $iResult, 1)
EndFunc

Func _TestNextPage_InvalidPosition()
    _TestFmkHeader("Test: __NextPage() - stays when position is invalid")

    Local $iResult = __NextPage(1, $eInvalidPage)

    _TestFmkAssert($iResult = 1, "Stays at page 1 for invalid position", $iResult, 1)
EndFunc

; ===============================================================================================================================
; Tests - __BackPage
; ===============================================================================================================================
Func _TestBackPage_FromLastPage()
    _TestFmkHeader("Test: __BackPage() - goes back from last page")

    Local $iResult = __BackPage(3, $eLastPage)

    _TestFmkAssert($iResult = 2, "Returns 2 from page 3", $iResult, 2)
EndFunc

Func _TestBackPage_FromMidPage()
    _TestFmkHeader("Test: __BackPage() - goes back from mid page")

    Local $iResult = __BackPage(2, $eMidPage)

    _TestFmkAssert($iResult = 1, "Returns 1 from page 2", $iResult, 1)
EndFunc

Func _TestBackPage_StaysAtFirstPage()
    _TestFmkHeader("Test: __BackPage() - stays at first page")

    Local $iResult = __BackPage(1, $eFirstPage)

    _TestFmkAssert($iResult = 1, "Stays at page 1", $iResult, 1)
EndFunc

Func _TestBackPage_StaysAtSinglePage()
    _TestFmkHeader("Test: __BackPage() - stays at single page")

    Local $iResult = __BackPage(1, $eSinglePage)

    _TestFmkAssert($iResult = 1, "Stays at page 1", $iResult, 1)
EndFunc

Func _TestBackPage_InvalidPosition()
    _TestFmkHeader("Test: __BackPage() - stays when position is invalid")

    Local $iResult = __BackPage(2, $eInvalidPage)

    _TestFmkAssert($iResult = 2, "Stays at page 2 for invalid position", $iResult, 2)
EndFunc

; ===============================================================================================================================
; Tests - __PageMove
; ===============================================================================================================================
Func _TestPageMove_Next()
    _TestFmkHeader("Test: __PageMove() - moves forward with ePageNext")

    Local $iResult = __PageMove(1, $eFirstPage, $ePageNext)

    _TestFmkAssert($iResult = 2, "Moves to page 2", $iResult, 2)
EndFunc

Func _TestPageMove_Back()
    _TestFmkHeader("Test: __PageMove() - moves backward with ePageBack")

    Local $iResult = __PageMove(3, $eLastPage, $ePageBack)

    _TestFmkAssert($iResult = 2, "Moves to page 2", $iResult, 2)
EndFunc

Func _TestPageMove_Stay()
    _TestFmkHeader("Test: __PageMove() - stays with ePageStay")

    Local $iResult = __PageMove(2, $eMidPage, $ePageStay)

    _TestFmkAssert($iResult = 2, "Stays at page 2", $iResult, 2)
EndFunc

Func _TestPageMove_OutOfRangeDirection()
    _TestFmkHeader("Test: __PageMove() - treats out-of-range direction as ePageStay")

    Local $iResult = __PageMove(2, $eMidPage, 99)

    _TestFmkAssert($iResult = 2, "Stays at page 2 for invalid direction", $iResult, 2)
EndFunc

; ===============================================================================================================================
; Tests - __NavPage
; ===============================================================================================================================
Func _TestNavPage_InvalidWizard()
    _TestFmkHeader("Test: __NavPage() - returns Null for invalid wizard")

    Local $vResult = __NavPage("invalid wizard", $ePageNext)

    _TestFmkAssert($vResult = Null, "Returns Null for invalid wizard", $vResult, Null)
EndFunc

Func _TestNavPage_InvalidPagePosition()
    _TestFmkHeader("Test: __NavPage() - returns current page when position is invalid")

    _SetInstallerEvent($EVENT_DEFAULT)

	Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    $mWizard.iPage = 0

    Local $vResult = __NavPage($mWizard, $ePageNext)

    _TestFmkAssert($vResult = 0, "Returns 0 for invalid page position", $vResult, 0)
EndFunc

Func _TestNavPage_MovesToNextPage()
    _TestFmkHeader("Test: __NavPage() - moves to next page and returns new page index")

    _SetInstallerEvent($EVENT_DEFAULT)

	Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage1  = _NewPage("Page 1")
    Local $mPage2  = _NewPage("Page 2")
    _AddPage($mWizard.mPages, $mPage1)
    _AddPage($mWizard.mPages, $mPage2)
    $mWizard.iPage = 1

    Local $iResult = __NavPage($mWizard, $ePageNext)

    _TestFmkAssert($iResult = 2, "Returns 2 after Next", $iResult, 2)
    _TestFmkAssert($mWizard.iPage = 2, "Wizard iPage updated", $mWizard.iPage, 2)
EndFunc

Func _TestNavPage_MovesToPreviousPage()
    _TestFmkHeader("Test: __NavPage() - moves to previous page and returns new page index")

    _SetInstallerEvent($EVENT_DEFAULT)

	Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage1  = _NewPage("Page 1")
    Local $mPage2  = _NewPage("Page 2")
    _AddPage($mWizard.mPages, $mPage1)
    _AddPage($mWizard.mPages, $mPage2)
    $mWizard.iPage = 2

    Local $iResult = __NavPage($mWizard, $ePageBack)

    _TestFmkAssert($iResult = 1, "Returns 1 after Back", $iResult, 1)
    _TestFmkAssert($mWizard.iPage = 1, "Wizard iPage updated", $mWizard.iPage, 1)
EndFunc

Func _TestNavPage_StaysOnSamePage()
    _TestFmkHeader("Test: __NavPage() - stays on same page with ePageStay")

    _SetInstallerEvent($EVENT_DEFAULT)

	Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage1  = _NewPage("Page 1")
    Local $mPage2  = _NewPage("Page 2")
    _AddPage($mWizard.mPages, $mPage1)
    _AddPage($mWizard.mPages, $mPage2)
    $mWizard.iPage = 1

    Local $iResult = __NavPage($mWizard, $ePageStay)

    _TestFmkAssert($iResult = 1, "Returns 1 after Stay", $iResult, 1)
    _TestFmkAssert($mWizard.iPage = 1, "Wizard iPage unchanged", $mWizard.iPage, 1)
EndFunc

Func _TestNavPage_ReturnsExitSignalOnClosePage()
    _TestFmkHeader("Test: __NavPage() - returns EXIT_WIZARD_SIGNAL when event is EVENT_CLOSE_PAGE")

    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage   = _NewPage("Page 1")
    _AddPage($mWizard.mPages, $mPage)
    $mWizard.iPage = 1

	_SetInstallerEvent($EVENT_CLOSE_PAGE)
    Local $iResult = __NavPage($mWizard, $ePageNext)

    _TestFmkAssert($iResult = $EXIT_WIZARD_SIGNAL, "Returns EXIT_WIZARD_SIGNAL", $iResult, $EXIT_WIZARD_SIGNAL)
EndFunc

Func _TestNavPage_OutOfRangeDirection()
    _TestFmkHeader("Test: __NavPage() - treats out of range direction as ePageStay")

    _SetInstallerEvent($EVENT_DEFAULT)

	Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Local $mPage1  = _NewPage("Page 1")
    Local $mPage2  = _NewPage("Page 2")
    _AddPage($mWizard.mPages, $mPage1)
    _AddPage($mWizard.mPages, $mPage2)
    $mWizard.iPage = 1

    Local $iResult = __NavPage($mWizard, 99)

    _TestFmkAssert($iResult = 1, "Stays on page 1 for invalid direction", $iResult, 1)
    _TestFmkAssert($mWizard.iPage = 1, "Wizard iPage unchanged", $mWizard.iPage, 1)
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialInstallerNavTest_NextPage(ByRef $bAllPassed)
	_TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestNextPage_FromFirstPage,     $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestNextPage_FromMidPage,       $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestNextPage_StaysAtLastPage,   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestNextPage_StaysAtSinglePage, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestNextPage_InvalidPosition,   $bAllPassed)
EndFunc

Func __RunCrucialInstallerNavTest_BackPage(ByRef $bAllPassed)
	_TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestBackPage_FromLastPage,      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestBackPage_FromMidPage,       $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestBackPage_StaysAtFirstPage,  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestBackPage_StaysAtSinglePage, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestBackPage_InvalidPosition,   $bAllPassed)
EndFunc

Func __RunCrucialInstallerNavTest_PageMove(ByRef $bAllPassed)
	_TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestPageMove_Next,                		  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestPageMove_Back,                		  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestPageMove_Stay,                		  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestPageMove_OutOfRangeDirection, 		  $bAllPassed)
EndFunc

Func __RunCrucialInstallerNavTest_NavPage(ByRef $bAllPassed)
	_TestFmkSeparator()
	$bAllPassed = _TestFmkRun(_TestNavPage_InvalidWizard, 		  		  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNavPage_InvalidPagePosition, 		  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNavPage_MovesToNextPage, 	 		  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNavPage_MovesToPreviousPage,  		  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNavPage_StaysOnSamePage,  			  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNavPage_ReturnsExitSignalOnClosePage,  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNavPage_OutOfRangeDirection,  		  $bAllPassed)
EndFunc

Func _RunCrucialInstallerNavTests($bWriteSummary = True)
	Local $bAllPassed = True
	__RunCrucialInstallerNavTest_NextPage($bAllPassed)
	__RunCrucialInstallerNavTest_BackPage($bAllPassed)
	__RunCrucialInstallerNavTest_PageMove($bAllPassed)
	__RunCrucialInstallerNavTest_NavPage($bAllPassed)
	If $bWriteSummary Then _TestFmkSummary()
	Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerNavTests, $sScriptName)
