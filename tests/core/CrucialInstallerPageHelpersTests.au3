#include-once

#include "..\..\lib\TestFramework\TestFramework.au3"
#include "..\..\src\core\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerPageHelpersTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for the Page Helpers region of CrucialInstaller.au3.
;                  Tests page map construction, page status, position logic, and
;                  page collection management.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerPageHelpersTests.au3"

; ===============================================================================================================================
; Tests - __SetPageEvent
; ===============================================================================================================================
Func _TestSetPageEvent_ValidStatus()
    _TestFmkHeader("Test: __SetPageEvent() - returns valid status unchanged")

    Local $iResult = __SetPageEvent($eProceedPage)

    _TestFmkAssert($iResult = $eProceedPage, "Returns eProceedPage", $iResult, $eProceedPage)
EndFunc

Func _TestSetPageEvent_InvalidStatusFallsBack()
    _TestFmkHeader("Test: __SetPageEvent() - returns eNormalPage for invalid status")

    Local $iResult = __SetPageEvent(99)

    _TestFmkAssert($iResult = $eNormalPage, "Returns eNormalPage for invalid", $iResult, $eNormalPage)
EndFunc

; ===============================================================================================================================
; Tests - __IsPageStatusValid
; ===============================================================================================================================
Func _TestIsPageStatusValid_ValidStatuses()
    _TestFmkHeader("Test: __IsPageStatusValid() - returns True for all valid statuses")

    _TestFmkAssert(__IsPageStatusValid($eClosePage),      "eClosePage is valid",      __IsPageStatusValid($eClosePage),      True)
    _TestFmkAssert(__IsPageStatusValid($eNormalPage),     "eNormalPage is valid",     __IsPageStatusValid($eNormalPage),     True)
    _TestFmkAssert(__IsPageStatusValid($eProceedPage),    "eProceedPage is valid",    __IsPageStatusValid($eProceedPage),    True)
    _TestFmkAssert(__IsPageStatusValid($eProcessingPage), "eProcessingPage is valid", __IsPageStatusValid($eProcessingPage), True)
    _TestFmkAssert(__IsPageStatusValid($eFinishPage),     "eFinishPage is valid",     __IsPageStatusValid($eFinishPage),     True)
EndFunc

Func _TestIsPageStatusValid_InvalidStatus()
    _TestFmkHeader("Test: __IsPageStatusValid() - returns False for invalid status")

    _TestFmkAssert(__IsPageStatusValid(99)  = False, "99 is invalid",  __IsPageStatusValid(99),  False)
    _TestFmkAssert(__IsPageStatusValid(-99) = False, "-99 is invalid", __IsPageStatusValid(-99), False)
EndFunc

; ===============================================================================================================================
; Tests - __GetPageStatus
; ===============================================================================================================================
Func _TestGetPageStatus_ValidPage()
    _TestFmkHeader("Test: __GetPageStatus() - returns page status from valid page map")

    Local $mPage = _NewPage("", $eProceedPage)

    _TestFmkAssert(__GetPageStatus($mPage) = $eProceedPage, "Returns eProceedPage", __GetPageStatus($mPage), $eProceedPage)
EndFunc

Func _TestGetPageStatus_InvalidMap()
    _TestFmkHeader("Test: __GetPageStatus() - returns eNormalPage for invalid map")

    _TestFmkAssert(__GetPageStatus("Invalid Page") = $eNormalPage, "Returns eNormalPage for invalid", __GetPageStatus("Invalid Page"), $eNormalPage)
EndFunc

Func _TestGetPageStatus_MissingStatus()
    _TestFmkHeader("Test: __GetPageStatus() - returns eNormalPage when status key missing")

    Local $mPage[]
    $mPage.sSubheading = "test"

    _TestFmkAssert(__GetPageStatus($mPage) = $eNormalPage, "Returns eNormalPage when missing", __GetPageStatus($mPage), $eNormalPage)
EndFunc

; ===============================================================================================================================
; Tests - __IsValidPagePosition
; ===============================================================================================================================
Func _TestIsValidPagePosition_ValidPositions()
    _TestFmkHeader("Test: __IsValidPagePosition() - returns True for valid positions")

    _TestFmkAssert(__IsValidPagePosition($eSinglePage), "eSinglePage is valid", __IsValidPagePosition($eSinglePage), True)
    _TestFmkAssert(__IsValidPagePosition($eFirstPage),  "eFirstPage is valid",  __IsValidPagePosition($eFirstPage),  True)
    _TestFmkAssert(__IsValidPagePosition($eMidPage),    "eMidPage is valid",    __IsValidPagePosition($eMidPage),    True)
    _TestFmkAssert(__IsValidPagePosition($eLastPage),   "eLastPage is valid",   __IsValidPagePosition($eLastPage),   True)
EndFunc

Func _TestIsValidPagePosition_InvalidPage()
    _TestFmkHeader("Test: __IsValidPagePosition() - returns False for eInvalidPage")

    _TestFmkAssert(__IsValidPagePosition($eInvalidPage) = False, "eInvalidPage is invalid", __IsValidPagePosition($eInvalidPage), False)
EndFunc

Func _TestIsValidPagePosition_OutOfRange()
    _TestFmkHeader("Test: __IsValidPagePosition() - returns False for out of range position")

    _TestFmkAssert(__IsValidPagePosition($eLastPage + 1)    = False, "Upper out of range is invalid", __IsValidPagePosition($eLastPage + 1),    False)
    _TestFmkAssert(__IsValidPagePosition($eInvalidPage - 1) = False, "Lower out of range is invalid", __IsValidPagePosition($eInvalidPage - 1), False)
EndFunc

; ===============================================================================================================================
; Tests - __GetPagePosition
; ===============================================================================================================================
Func _TestGetPagePosition_SinglePage()
    _TestFmkHeader("Test: __GetPagePosition() - returns eSinglePage when only one page")

    _TestFmkAssert(__GetPagePosition(1, 1) = $eSinglePage, "Single page returns eSinglePage", __GetPagePosition(1, 1), $eSinglePage)
EndFunc

Func _TestGetPagePosition_FirstPage()
    _TestFmkHeader("Test: __GetPagePosition() - returns eFirstPage for page 1 of many")

    _TestFmkAssert(__GetPagePosition(1, 3) = $eFirstPage, "First of 3 returns eFirstPage", __GetPagePosition(1, 3), $eFirstPage)
EndFunc

Func _TestGetPagePosition_MidPage()
    _TestFmkHeader("Test: __GetPagePosition() - returns eMidPage for middle page")

    _TestFmkAssert(__GetPagePosition(2, 3) = $eMidPage, "Middle of 3 returns eMidPage", __GetPagePosition(2, 3), $eMidPage)
EndFunc

Func _TestGetPagePosition_LastPage()
    _TestFmkHeader("Test: __GetPagePosition() - returns eLastPage for last page")

    _TestFmkAssert(__GetPagePosition(3, 3) = $eLastPage, "Last of 3 returns eLastPage", __GetPagePosition(3, 3), $eLastPage)
EndFunc

Func _TestGetPagePosition_InvalidPage()
    _TestFmkHeader("Test: __GetPagePosition() - returns eInvalidPage for out of range")

    _TestFmkAssert(__GetPagePosition(0, 3)  = $eInvalidPage, "Page 0 is invalid",      __GetPagePosition(0, 3),  $eInvalidPage)
    _TestFmkAssert(__GetPagePosition(4, 3)  = $eInvalidPage, "Page 4 of 3 is invalid", __GetPagePosition(4, 3),  $eInvalidPage)
    _TestFmkAssert(__GetPagePosition(-1, 3) = $eInvalidPage, "Page -1 is invalid",     __GetPagePosition(-1, 3), $eInvalidPage)
EndFunc

; ===============================================================================================================================
; Tests - __MaxPages
; ===============================================================================================================================
Func _TestMaxPages_EmptyMap()
    _TestFmkHeader("Test: __MaxPages() - returns 0 for empty pages map")

    Local $mPages = _CreatePages()

    _TestFmkAssert(__MaxPages($mPages) = 0, "Empty map returns 0", __MaxPages($mPages), 0)
EndFunc

Func _TestMaxPages_WithPages()
    _TestFmkHeader("Test: __MaxPages() - returns correct count after adding pages")

    Local $mPages = _CreatePages()
    Local $mPage1 = _NewPage()
    Local $mPage2 = _NewPage()
    _AddPage($mPages, $mPage1)
    _AddPage($mPages, $mPage2)

    _TestFmkAssert(__MaxPages($mPages) = 2, "Returns 2 after adding 2 pages", __MaxPages($mPages), 2)
EndFunc

Func _TestMaxPages_InvalidMap()
    _TestFmkHeader("Test: __MaxPages() - returns 0 for invalid map")

    _TestFmkAssert(__MaxPages("not a map") = 0, "Returns 0 for invalid input", __MaxPages("not a map"), 0)
EndFunc

; ===============================================================================================================================
; Tests - __GetPage
; ===============================================================================================================================
Func _TestGetPage_Found()
    _TestFmkHeader("Test: __GetPage() - returns correct page map for valid index")

    Local $mPages = _CreatePages()
    Local $mPage1 = _NewPage("Page1")
    Local $mPage2 = _NewPage("Page2")
    Local $mPage3 = _NewPage("Page3")
    _AddPage($mPages, $mPage1)
    _AddPage($mPages, $mPage2)
    _AddPage($mPages, $mPage3)

    Local $mResult = __GetPage($mPages, 2)

    _TestFmkAssert(IsMap($mResult),                    "Returns a map",          IsMap($mResult),          True)
    _TestFmkAssert($mResult.sSubheading = "Page2",     "Correct page returned",  $mResult.sSubheading,     "Page2")
EndFunc

Func _TestGetPage_NotFound()
    _TestFmkHeader("Test: __GetPage() - returns Null for missing index")

    Local $mPages = _CreatePages()
    Local $mPage1 = _NewPage("Page1")
    _AddPage($mPages, $mPage1)

    _TestFmkAssert(__GetPage($mPages, 2) = Null, "Returns Null for missing index", __GetPage($mPages, 2), Null)
EndFunc

Func _TestGetPage_InvalidMap()
    _TestFmkHeader("Test: __GetPage() - returns Null for invalid pages map")

    _TestFmkAssert(__GetPage("invalid page map", 1) = Null, "Returns Null for invalid map", __GetPage("invalid page map", 1), Null)
EndFunc

; ===============================================================================================================================
; Tests - _NewPage
; ===============================================================================================================================
Func _TestNewPage_DefaultValues()
    _TestFmkHeader("Test: _NewPage() - returns page map with default values")

    Local $mPage = _NewPage()

    _TestFmkAssert(IsMap($mPage),             "Returns a map",        IsMap($mPage),             True)
    _TestFmkAssert($mPage.sSubheading = "",   "Subheading is empty",  $mPage.sSubheading,        "")
    _TestFmkAssert(IsArray($mPage.aControls), "Controls is an array", IsArray($mPage.aControls), True)
    _TestFmkAssert(IsMap($mPage.mBtnEvents),  "BtnEvents is a map",   IsMap($mPage.mBtnEvents),  True)
EndFunc

Func _TestNewPage_CustomSubheading()
    _TestFmkHeader("Test: _NewPage() - stores custom subheading")

    Local $mPage = _NewPage("My Subheading")

    _TestFmkAssert($mPage.sSubheading = "My Subheading", "Subheading stored", $mPage.sSubheading, "My Subheading")
EndFunc

; ===============================================================================================================================
; Tests - _AddPage
; ===============================================================================================================================
Func _TestAddPage_Returns1BasedIndex()
    _TestFmkHeader("Test: _AddPage() - returns 1-based index")

    Local $mPages = _CreatePages()
    Local $mPage  = _NewPage()

    Local $iIdx = _AddPage($mPages, $mPage)

    _TestFmkAssert($iIdx = 1, "First page index is 1", $iIdx, 1)
EndFunc

Func _TestAddPage_IncrementsIndex()
    _TestFmkHeader("Test: _AddPage() - increments index for each page")

    Local $mPages = _CreatePages()
    Local $mPage1 = _NewPage()
    Local $mPage2 = _NewPage()

    Local $iIdx1 = _AddPage($mPages, $mPage1)
    Local $iIdx2 = _AddPage($mPages, $mPage2)

    _TestFmkAssert($iIdx1 = 1,             "First index is 1",  $iIdx1,          1)
    _TestFmkAssert($iIdx2 = 2,             "Second index is 2", $iIdx2,          2)
    _TestFmkAssert(UBound($mPages) = 2,    "Two pages added",   UBound($mPages), 2)
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialInstallerPageHelperTest_SetPageEvent(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestSetPageEvent_ValidStatus,            $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetPageEvent_InvalidStatusFallsBack, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageHelperTest_IsPageStatusValid(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestIsPageStatusValid_ValidStatuses,     $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsPageStatusValid_InvalidStatus,     $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageHelperTest_GetPageStatus(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestGetPageStatus_ValidPage,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetPageStatus_InvalidMap,            $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetPageStatus_MissingStatus,         $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageHelperTest_IsValidPagePosition(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestIsValidPagePosition_ValidPositions,  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsValidPagePosition_InvalidPage,     $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsValidPagePosition_OutOfRange,      $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageHelperTest_GetPagePosition(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestGetPagePosition_SinglePage,          $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetPagePosition_FirstPage,           $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetPagePosition_MidPage,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetPagePosition_LastPage,            $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetPagePosition_InvalidPage,         $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageHelperTest_MaxPages(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestMaxPages_EmptyMap,                   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestMaxPages_WithPages,                  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestMaxPages_InvalidMap,                 $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageHelperTest_GetPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestGetPage_Found,                       $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetPage_NotFound,                    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestGetPage_InvalidMap,                  $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageHelperTest_NewPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestNewPage_DefaultValues,               $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestNewPage_CustomSubheading,            $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageHelperTest_AddPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestAddPage_Returns1BasedIndex,          $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestAddPage_IncrementsIndex,             $bAllPassed)
EndFunc

Func _RunCrucialInstallerPageHelpersTests($bWriteSummary = True)
    Local $bAllPassed = True
    __RunCrucialInstallerPageHelperTest_SetPageEvent($bAllPassed)
    __RunCrucialInstallerPageHelperTest_IsPageStatusValid($bAllPassed)
    __RunCrucialInstallerPageHelperTest_GetPageStatus($bAllPassed)
    __RunCrucialInstallerPageHelperTest_IsValidPagePosition($bAllPassed)
    __RunCrucialInstallerPageHelperTest_GetPagePosition($bAllPassed)
    __RunCrucialInstallerPageHelperTest_MaxPages($bAllPassed)
    __RunCrucialInstallerPageHelperTest_GetPage($bAllPassed)
    __RunCrucialInstallerPageHelperTest_NewPage($bAllPassed)
    __RunCrucialInstallerPageHelperTest_AddPage($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerPageHelpersTests, $sScriptName)
