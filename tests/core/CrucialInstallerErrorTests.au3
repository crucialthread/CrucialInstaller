#include-once

#include <TestFramework.au3>
#include "..\..\src\core\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerErrorTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for the Error Management region of CrucialInstaller.au3.
;                  Tests error message mapping and debug error info behavior.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerErrorTests.au3"

; ===============================================================================================================================
; Tests - __CrucialInstErrMsg
; ===============================================================================================================================
Func _TestCrucialInstErrMsg_InvalidWizard()
    _TestFmkHeader("Test: __CrucialInstErrMsg() - returns correct message for INST_ERR_INVALID_WIZARD")

	Local $sResult = __CrucialInstErrMsg($INST_ERR_INVALID_WIZARD)

    _TestFmkAssert($sResult = $INST_ERR_MSG_WIZARD, "Returns correct message", $sResult, $INST_ERR_MSG_WIZARD)
EndFunc

Func _TestCrucialInstErrMsg_InvalidCfg()
    _TestFmkHeader("Test: __CrucialInstErrMsg() - returns correct message for INST_ERR_INVALID_CFG")

	Local $sResult = __CrucialInstErrMsg($INST_ERR_INVALID_CFG)

    _TestFmkAssert($sResult = $INST_ERR_MSG_CFG, "Returns correct message", $sResult, $INST_ERR_MSG_CFG)
EndFunc

Func _TestCrucialInstErrMsg_InvalidGUI()
    _TestFmkHeader("Test: __CrucialInstErrMsg() - returns correct message for INST_ERR_INVALID_GUI")

    Local $sResult = __CrucialInstErrMsg($INST_ERR_INVALID_GUI)

    _TestFmkAssert($sResult = $INST_ERR_MSG_GUI, "Returns correct message", $sResult, $INST_ERR_MSG_GUI)
EndFunc

Func _TestCrucialInstErrMsg_InvalidCtrl()
    _TestFmkHeader("Test: __CrucialInstErrMsg() - returns correct message for INST_ERR_INVALID_CTRL")

    Local $sResult = __CrucialInstErrMsg($INST_ERR_INVALID_CTRL)

    _TestFmkAssert($sResult = $INST_ERR_MSG_CTRL, "Returns correct message", $sResult, $INST_ERR_MSG_CTRL)
EndFunc

Func _TestCrucialInstErrMsg_InvalidAimr()
    _TestFmkHeader("Test: __CrucialInstErrMsg() - returns correct message for INST_ERR_INVALID_AIMR")

	Local $sResult = __CrucialInstErrMsg($INST_ERR_INVALID_AIMR)

    _TestFmkAssert($sResult = $INST_ERR_MSG_AIMR, "Returns correct message", $sResult, $INST_ERR_MSG_AIMR)
EndFunc

Func _TestCrucialInstErrMsg_UnknownError()
    _TestFmkHeader("Test: __CrucialInstErrMsg() - returns unknown error message for unrecognized code")

    Local $sResult = __CrucialInstErrMsg(9999)

    _TestFmkAssert($sResult = $INST_ERR_MSG_UNKNOWN, "Returns unknown error message", $sResult, $INST_ERR_MSG_UNKNOWN)
EndFunc

; ===============================================================================================================================
; Tests - __DebugErrorInfo
; ===============================================================================================================================
Func _TestDebugErrorInfo_SetsError()
    _TestFmkHeader("Test: __DebugErrorInfo() - sets @error to the given error code")

    __DebugErrorInfo(__DebugErrorInfo, $INST_ERR_INVALID_GUI, 0, Null)
    Local $iErr = @error

    _TestFmkAssert($iErr = $INST_ERR_INVALID_GUI, "Sets @error correctly", $iErr, $INST_ERR_INVALID_GUI)
EndFunc

Func _TestDebugErrorInfo_SetsExtended()
    _TestFmkHeader("Test: __DebugErrorInfo() - sets @extended to the given value")

    __DebugErrorInfo(__DebugErrorInfo, $INST_ERR_INVALID_GUI, 5, Null)
    Local $iExt = @extended

    _TestFmkAssert($iExt = 5, "Sets @extended correctly", $iExt, 5)
EndFunc

Func _TestDebugErrorInfo_ReturnsValue()
    _TestFmkHeader("Test: __DebugErrorInfo() - returns the given return value")

    Local $vResult = __DebugErrorInfo(__DebugErrorInfo, $INST_ERR_INVALID_GUI, 0, "returnValue")

    _TestFmkAssert($vResult = "returnValue", "Returns correct value", $vResult, "returnValue")
EndFunc

Func _TestDebugErrorInfo_DoesNotWriteInTestMode()
    _TestFmkHeader("Test: __DebugErrorInfo() - does not call ConsoleWrite in test mode")

    __DebugErrorInfo(__DebugErrorInfo, $INST_ERR_INVALID_GUI, 0, Null)

    _TestFmkAssert(_StubCallCount("ConsoleWrite") = 0, "ConsoleWrite not called in test mode", _StubCallCount("ConsoleWrite"), 0)
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialInstallerErrorTest_CrucialInstErrMsg(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestCrucialInstErrMsg_InvalidWizard, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCrucialInstErrMsg_InvalidCfg,    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCrucialInstErrMsg_InvalidGUI,    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCrucialInstErrMsg_InvalidCtrl,   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCrucialInstErrMsg_InvalidAimr,   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCrucialInstErrMsg_UnknownError,  $bAllPassed)
EndFunc

Func __RunCrucialInstallerErrorTest_DebugErrorInfo(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestDebugErrorInfo_SetsError,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestDebugErrorInfo_SetsExtended,          $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestDebugErrorInfo_ReturnsValue,          $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestDebugErrorInfo_DoesNotWriteInTestMode,$bAllPassed)
EndFunc

Func _RunCrucialInstallerErrorTests($bWriteSummary = True)
    Local $bAllPassed = True
    __RunCrucialInstallerErrorTest_CrucialInstErrMsg($bAllPassed)
    __RunCrucialInstallerErrorTest_DebugErrorInfo($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerErrorTests, $sScriptName)
