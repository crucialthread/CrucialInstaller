#include-once

#include "..\src\core\TestFramework.au3"
#include "..\src\core\StubConstants.au3"
#include "..\src\installer\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerHeaderTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Author ........: Crucial Thread
; Description ...: Unit tests for the Header Constructors Helpers region of CrucialInstaller.au3.
;                  Tests _CreateSeparator, _CreateHeader, _CreateHeaderTitle, _CreateHeaderSub
;                  and _CreateButtons using stubs for GUI calls.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerHeaderTests.au3"

; ===============================================================================================================================
; Tests - _CreateSeparator
; ===============================================================================================================================
Func _TestCreateSeparator_InvalidGUI()
    _TestFmkHeader("Test: _CreateSeparator() - returns Null and sets @error for invalid GUI")

    _SetStubReturn("IsHWnd", $_1st, False)
    Local $idResult = _CreateSeparator(0, 100, 540, 0xCCCCCC)
    Local $iErr     = @error

    _TestFmkAssert($idResult = Null, "Returns Null for invalid GUI", $idResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_GUI, "Sets @error", $iErr, $INST_ERR_INVALID_GUI)
EndFunc

Func _TestCreateSeparator_ValidGUI()
    _TestFmkHeader("Test: _CreateSeparator() - returns control ID for valid GUI")

	Local $idCtrl = 99
    _SetStubReturn("IsHWnd", $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",$_1st, $idCtrl)
    Local $idResult = _CreateSeparator(1, 100, 540, 0xCCCCCC)

    _TestFmkAssert($idResult = $idCtrl, "Returns control ID", $idResult, $idCtrl)
EndFunc

Func _TestCreateSeparator_SetsBackground()
    _TestFmkHeader("Test: _CreateSeparator() - sets background color on created label")

	Local $idCtrl = 99
	Local $vColor = 0xCCCCCC
    _SetStubReturn("IsHWnd", $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",$_1st, $idCtrl)
    Local $idResult = _CreateSeparator(1, 100, 540, $vColor)

    _TestFmkAssert(_StubCallCount("GUICtrlSetBkColor") = 1, "GUICtrlSetBkColor called once", _StubCallCount("GUICtrlSetBkColor"), 1)
    _TestFmkAssert(_StubCall("GUICtrlSetBkColor", $_1st, $Param_Color) = $vColor, "Correct color set", _StubCall("GUICtrlSetBkColor", $_1st, $Param_Color), $vColor)
EndFunc

; ===============================================================================================================================
; Tests - _CreateHeaderTitle
; ===============================================================================================================================
Func _TestCreateHeaderTitle_InvalidGUI()
    _TestFmkHeader("Test: _CreateHeaderTitle() - returns Null and sets @error for invalid GUI")

    _SetStubReturn("IsHWnd", $_1st, False)
    Local $mCfg     = _NewInstallerCfg()
    Local $idResult = _CreateHeaderTitle(0, $mCfg, "Title")
    Local $iErr     = @error

    _TestFmkAssert($idResult = Null, "Returns Null for invalid GUI", $idResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_GUI, "Sets @error", $iErr, $INST_ERR_INVALID_GUI)
EndFunc

Func _TestCreateHeaderTitle_ValidGUI()
    _TestFmkHeader("Test: _CreateHeaderTitle() - returns control ID for valid GUI")

    Local $idCtrl = 10
	_SetStubReturn("IsHWnd", $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",$_1st, $idCtrl)
    Local $mCfg     = _NewInstallerCfg()
    Local $idResult = _CreateHeaderTitle(1, $mCfg, "My Title")

    _TestFmkAssert($idResult = $idCtrl, "Returns control ID", $idResult, $idCtrl)
EndFunc

Func _TestCreateHeaderTitle_StoresText()
    _TestFmkHeader("Test: _CreateHeaderTitle() - creates label with correct title text")

	Local $idCtrl = 10
    _SetStubReturn("IsHWnd", $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",$_1st, $idCtrl)
    Local $mCfg = _NewInstallerCfg()
    _CreateHeaderTitle(1, $mCfg, "My Title")

    _TestFmkAssert(_StubCall("GUICtrlCreateLabel", $_1st, $Param_Text) = "My Title", "Title text correct", _StubCall("GUICtrlCreateLabel", $_1st, $Param_Text), "My Title")
EndFunc

; ===============================================================================================================================
; Tests - _CreateHeaderSub
; ===============================================================================================================================
Func _TestCreateHeaderSub_InvalidGUI()
    _TestFmkHeader("Test: _CreateHeaderSub() - returns Null and sets @error for invalid GUI")

    _SetStubReturn("IsHWnd", $_1st, False)
    Local $mCfg     = _NewInstallerCfg()
    Local $idResult = _CreateHeaderSub(0, $mCfg)
    Local $iErr     = @error

    _TestFmkAssert($idResult = Null, "Returns Null for invalid GUI", $idResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_GUI, "Sets @error", $iErr, $INST_ERR_INVALID_GUI)
EndFunc

Func _TestCreateHeaderSub_ValidGUI()
    _TestFmkHeader("Test: _CreateHeaderSub() - returns control ID for valid GUI")

	Local $idCtrl = 20
    _SetStubReturn("IsHWnd", $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",$_1st, $idCtrl)
    Local $mCfg     = _NewInstallerCfg()
    Local $idResult = _CreateHeaderSub(1, $mCfg)

    _TestFmkAssert($idResult = $idCtrl, "Returns control ID", $idResult, $idCtrl)
EndFunc

Func _TestCreateHeaderSub_EmptyTextByDefault()
    _TestFmkHeader("Test: _CreateHeaderSub() - creates label with empty text by default")

	Local $idCtrl = 20
    _SetStubReturn("IsHWnd", $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",$_1st, $idCtrl)
    Local $mCfg = _NewInstallerCfg()
    _CreateHeaderSub(1, $mCfg)

    _TestFmkAssert(_StubCall("GUICtrlCreateLabel", $_1st, $Param_Text) = "", "Empty text by default", _StubCall("GUICtrlCreateLabel", $_1st, $Param_Text), "")
EndFunc

; ===============================================================================================================================
; Tests - _CreateHeader
; ===============================================================================================================================
Func _TestCreateHeader_InvalidGUI()
    _TestFmkHeader("Test: _CreateHeader() - returns Null and sets @error for invalid GUI")

    _SetStubReturn("IsHWnd", $_1st, False)
    Local $mCfg     = _NewInstallerCfg()
    Local $mResult  = _CreateHeader(0, $mCfg, "Title")
    Local $iErr     = @error

    _TestFmkAssert($mResult = Null, "Returns Null for invalid GUI", $mResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_GUI, "Sets @error", $iErr, $INST_ERR_INVALID_GUI)
EndFunc

Func _TestCreateHeader_ReturnsMap()
    _TestFmkHeader("Test: _CreateHeader() - returns map with all required keys")

    _SetStubReturn("IsHWnd",            $_1st, True)   ; _CreateHeader
    _SetStubReturn("IsHWnd",            $_2nd, True)   ; _CreateHeaderTitle
    _SetStubReturn("IsHWnd",            $_3rd, True)   ; _CreateHeaderSub
    _SetStubReturn("IsHWnd",            $_4th, True)   ; _CreateSeparator
    _SetStubReturn("GUICtrlCreateLabel",$_1st, 1)      ; header bg
    _SetStubReturn("GUICtrlCreateLabel",$_2nd, 2)      ; title
    _SetStubReturn("GUICtrlCreateLabel",$_3rd, 3)      ; sub
    _SetStubReturn("GUICtrlCreateLabel",$_4th, 4)      ; separator
    Local $mCfg    = _NewInstallerCfg()
    Local $mResult = _CreateHeader(1, $mCfg, "Title")

    _TestFmkAssert(IsMap($mResult), "Returns a map", IsMap($mResult), True)
    _TestFmkAssert(MapExists($mResult, "id"),           "Has id key",           MapExists($mResult, "id"),           True)
    _TestFmkAssert(MapExists($mResult, "idTitle"),      "Has idTitle key",      MapExists($mResult, "idTitle"),      True)
    _TestFmkAssert(MapExists($mResult, "idSubheading"), "Has idSubheading key", MapExists($mResult, "idSubheading"), True)
    _TestFmkAssert(MapExists($mResult, "idSeparator"),  "Has idSeparator key",  MapExists($mResult, "idSeparator"),  True)
EndFunc

Func _TestCreateHeader_StoresCorrectIDs()
    _TestFmkHeader("Test: _CreateHeader() - stores correct control IDs in map")

	Local $idHeader     = 10
	Local $idTitle      = 11
	Local $idSubheading = 12
	Local $idSeparator  = 13

    _SetStubReturn("IsHWnd",            $_1st, True)
    _SetStubReturn("IsHWnd",            $_2nd, True)
    _SetStubReturn("IsHWnd",            $_3rd, True)
    _SetStubReturn("IsHWnd",            $_4th, True)
    _SetStubReturn("GUICtrlCreateLabel",$_1st, $idHeader)
    _SetStubReturn("GUICtrlCreateLabel",$_2nd, $idTitle)
    _SetStubReturn("GUICtrlCreateLabel",$_3rd, $idSubheading)
    _SetStubReturn("GUICtrlCreateLabel",$_4th, $idSeparator)
    Local $mCfg    = _NewInstallerCfg()
    Local $mResult = _CreateHeader(1, $mCfg, "Title")

    _TestFmkAssert($mResult.id           = $idHeader,     "id is correct",           $mResult.id,           $idHeader)
    _TestFmkAssert($mResult.idTitle      = $idTitle,      "idTitle is correct",      $mResult.idTitle,      $idTitle)
    _TestFmkAssert($mResult.idSubheading = $idSubheading, "idSubheading is correct", $mResult.idSubheading, $idSubheading)
    _TestFmkAssert($mResult.idSeparator  = $idSeparator,  "idSeparator is correct",  $mResult.idSeparator,  $idSeparator)
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialInstallerHeaderTest_CreateSeparator(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestCreateSeparator_InvalidGUI,        $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreateSeparator_ValidGUI,           $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreateSeparator_SetsBackground,     $bAllPassed)
EndFunc

Func __RunCrucialInstallerHeaderTest_CreateHeaderTitle(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestCreateHeaderTitle_InvalidGUI,       $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreateHeaderTitle_ValidGUI,         $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreateHeaderTitle_StoresText,       $bAllPassed)
EndFunc

Func __RunCrucialInstallerHeaderTest_CreateHeaderSub(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestCreateHeaderSub_InvalidGUI,         $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreateHeaderSub_ValidGUI,           $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreateHeaderSub_EmptyTextByDefault, $bAllPassed)
EndFunc

Func __RunCrucialInstallerHeaderTest_CreateHeader(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestCreateHeader_InvalidGUI,            $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreateHeader_ReturnsMap,            $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCreateHeader_StoresCorrectIDs,      $bAllPassed)
EndFunc

Func _RunCrucialInstallerHeaderTests($bWriteSummary = True)
    Local $bAllPassed = True
	__RunCrucialInstallerHeaderTest_CreateSeparator($bAllPassed)
	__RunCrucialInstallerHeaderTest_CreateHeaderTitle($bAllPassed)
	__RunCrucialInstallerHeaderTest_CreateHeaderSub($bAllPassed)
	__RunCrucialInstallerHeaderTest_CreateHeader($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerHeaderTests, $sScriptName)
