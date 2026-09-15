#include-once

#include "..\..\lib\TestFramework\TestFramework.au3"
#include "..\..\src\core\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerEventsTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for the Installer Events and Events Handler regions of CrucialInstaller.au3.
;                  Tests event state management, handler registration, and event dispatching.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerEventsTests.au3"

; ===============================================================================================================================
; Helpers
; ===============================================================================================================================

Func __EventsTestHandlerReturnsValue()
    Return 42
EndFunc

Func __EventsTestHandlerExpectsOneArg($iVal)
	Return $iVal * 2
EndFunc

Global $g_bEventsTestHandlerCalled = False

Func __EventsTestClickHandler()
    $g_bEventsTestHandlerCalled = True
EndFunc

; ===============================================================================================================================
; Tests - _GetInstallerEvent / _SetInstallerEvent
; ===============================================================================================================================
Func _TestGetInstallerEvent_ReturnsDefault()
    _TestFmkHeader("Test: _GetInstallerEvent() - returns EVENT_DEFAULT by default")

    _TestFmkAssert(_GetInstallerEvent() = $EVENT_DEFAULT, "Returns EVENT_DEFAULT", _GetInstallerEvent(), $EVENT_DEFAULT)
EndFunc

Func _TestSetInstallerEvent_SetsCorrectly()
    _TestFmkHeader("Test: _SetInstallerEvent() - sets and retrieves each event type")

    _SetInstallerEvent($EVENT_CLOSE_PAGE)
    _TestFmkAssert(_GetInstallerEvent() = $EVENT_CLOSE_PAGE, "Sets EVENT_CLOSE_PAGE", _GetInstallerEvent(), $EVENT_CLOSE_PAGE)

    _SetInstallerEvent($EVENT_READY_TO_PROCEED)
    _TestFmkAssert(_GetInstallerEvent() = $EVENT_READY_TO_PROCEED, "Sets EVENT_READY_TO_PROCEED", _GetInstallerEvent(), $EVENT_READY_TO_PROCEED)

    _SetInstallerEvent($EVENT_PROCESSING)
    _TestFmkAssert(_GetInstallerEvent() = $EVENT_PROCESSING, "Sets EVENT_PROCESSING", _GetInstallerEvent(), $EVENT_PROCESSING)

    _SetInstallerEvent($EVENT_FINISH_PROCESS)
    _TestFmkAssert(_GetInstallerEvent() = $EVENT_FINISH_PROCESS, "Sets EVENT_FINISH_PROCESS", _GetInstallerEvent(), $EVENT_FINISH_PROCESS)
EndFunc

Func _TestSetInstallerEvent_DefaultParam()
    _TestFmkHeader("Test: _SetInstallerEvent() - resets to EVENT_DEFAULT when called with no args")

    _SetInstallerEvent($EVENT_PROCESSING)
    _SetInstallerEvent()

    _TestFmkAssert(_GetInstallerEvent() = $EVENT_DEFAULT, "Resets to EVENT_DEFAULT", _GetInstallerEvent(), $EVENT_DEFAULT)
EndFunc

; ===============================================================================================================================
; Tests - __IsValidArgs
; ===============================================================================================================================
Func _TestIsValidArgs_NonArray()
    _TestFmkHeader("Test: __IsValidArgs() - returns False for non-array")

    Local $bResult = __IsValidArgs("not an array")

    _TestFmkAssert($bResult = False, "Returns False for non-array", $bResult, False)
EndFunc

Func _TestIsValidArgs_EmptyArray()
    _TestFmkHeader("Test: __IsValidArgs() - returns False for empty array")

    Local $aArgs[0]
    Local $bResult = __IsValidArgs($aArgs)

    _TestFmkAssert($bResult = False, "Returns False for empty array", $bResult, False)
EndFunc

Func _TestIsValidArgs_InvalidFirstElement()
    _TestFmkHeader("Test: __IsValidArgs() - returns False when first element is not CallArgArray")

    Local $aArgs[2] = ["not", "CallArgArray"]
    Local $bResult = __IsValidArgs($aArgs)

    _TestFmkAssert($bResult = False, "Returns False for invalid first element", $bResult, False)
EndFunc

Func _TestIsValidArgs_ValidArgs()
    _TestFmkHeader("Test: __IsValidArgs() - returns True for valid args array")

    Local $aArgs = _HandlerArgs("arg1", "arg2")
    Local $bResult = __IsValidArgs($aArgs)

    _TestFmkAssert($bResult = True, "Returns True for valid args", $bResult, True)
EndFunc

; ===============================================================================================================================
; Tests - __HasArgs
; ===============================================================================================================================
Func _TestHasArgs_ValidArgs()
    _TestFmkHeader("Test: __HasArgs() - returns True for valid args")

	Local $aArgs = _HandlerArgs("first", "second")

    _TestFmkAssert(__HasArgs($aArgs) = True, "Returns True for valid args", __HasArgs($aArgs), True)
EndFunc

Func _TestHasArgs_InvalidArgs()
    _TestFmkHeader("Test: __HasArgs() - returns False for invalid array args")

    Local $aArgs[2] = ["a", "b"]

    _TestFmkAssert(__HasArgs($aArgs) = False, "Returns False for invalid array args", __HasArgs($aArgs), False)
EndFunc

Func _TestHasArgs_Default()
    _TestFmkHeader("Test: __HasArgs() - returns False for Default")

    _TestFmkAssert(__HasArgs(Default) = False, "Returns False for Default", __HasArgs(Default), False)
EndFunc

Func _TestHasArgs_NonArray()
    _TestFmkHeader("Test: __HasArgs() - returns False for non-array")

    Local $sVal = "not an array"

    _TestFmkAssert(__HasArgs($sVal) = False, "Returns False for string", __HasArgs($sVal), False)
EndFunc

; ===============================================================================================================================
; Tests - __RunEventHandler
; ===============================================================================================================================

Func _TestRunEventHandler_ValidHandler()
    _TestFmkHeader("Test: __RunEventHandler() - calls handler and returns result")

    Local $vResult = __RunEventHandler(__EventsTestHandlerReturnsValue)

    _TestFmkAssert($vResult = 42, "Returns handler result", $vResult, 42)
EndFunc

Func _TestRunEventHandler_WithArgs()
    _TestFmkHeader("Test: __RunEventHandler() - calls handler with args")

    Local $aArgs = _HandlerArgs(5)
    Local $vResult = __RunEventHandler(__EventsTestHandlerExpectsOneArg, $aArgs)

    _TestFmkAssert($vResult = 10, "Returns handler result with args", $vResult, 10)
EndFunc

Func _TestRunEventHandler_InvalidHandler()
    _TestFmkHeader("Test: __RunEventHandler() - returns Null for invalid handler")

    Local $vResult = __RunEventHandler("Invalid Handler")

    _TestFmkAssert($vResult = Null, "Returns Null for invalid handler", $vResult, Null)
EndFunc

Func _TestRunEventHandler_GuardsAgainstSelf()
    _TestFmkHeader("Test: __RunEventHandler() - returns Null when handler is itself")

    Local $vResult = __RunEventHandler(__RunEventHandler)

    _TestFmkAssert($vResult = Null, "Returns Null for self-reference", $vResult, Null)
EndFunc

Func _TestRunEventHandler_WrongArgCount()
    _TestFmkHeader("Test: __RunEventHandler() - returns Null and sets @error when wrong arg count")

    Local $vResult = __RunEventHandler(__EventsTestHandlerExpectsOneArg)
    Local $iErr    = @error
    Local $iExt    = @extended

    _TestFmkAssert($vResult = Null, "Returns Null on arg count mismatch", $vResult, Null)
    _TestFmkAssert($iErr = 0xDEAD,  "Sets @error = 0xDEAD", $iErr, 0xDEAD)
    _TestFmkAssert($iExt = 0xBEEF,  "Sets @extended = 0xBEEF", $iExt, 0xBEEF)
EndFunc

Func _TestRunEventHandler_FewerArgsThanRequired()
    _TestFmkHeader("Test: __RunEventHandler() - returns Null and sets @error when fewer args than required")

    Local $vResult = __RunEventHandler(__EventsTestHandlerExpectsOneArg)
    Local $iErr    = @error
    Local $iExt    = @extended

    _TestFmkAssert($vResult = Null, "Returns Null when fewer args than required", $vResult, Null)
    _TestFmkAssert($iErr = 0xDEAD,  "Sets @error = 0xDEAD", $iErr, 0xDEAD)
    _TestFmkAssert($iExt = 0xBEEF,  "Sets @extended = 0xBEEF", $iExt, 0xBEEF)
EndFunc

Func _TestRunEventHandler_MoreArgsThanRequired()
    _TestFmkHeader("Test: __RunEventHandler() - returns Null and sets @error when more args than required")

    Local $aArgs   = _HandlerArgs("extra1", "extra2")
    Local $vResult = __RunEventHandler(__EventsTestHandlerExpectsOneArg, $aArgs)
    Local $iErr    = @error
    Local $iExt    = @extended

    _TestFmkAssert($vResult = Null, "Returns Null when more args than required", $vResult, Null)
    _TestFmkAssert($iErr = 0xDEAD,  "Sets @error = 0xDEAD", $iErr, 0xDEAD)
    _TestFmkAssert($iExt = 0xBEEF,  "Sets @extended = 0xBEEF", $iExt, 0xBEEF)
EndFunc

Func _TestRunEventHandler_InvalidArgsArray()
    _TestFmkHeader("Test: __RunEventHandler() - returns Null and sets @error when args array is not valid")

	Local $aInvalidArrayArgs = [2]
    Local $vResult = __RunEventHandler(__EventsTestHandlerExpectsOneArg, $aInvalidArrayArgs)
    Local $iErr    = @error
    Local $iExt    = @extended

    _TestFmkAssert($vResult = Null, "Returns Null when args array is not valid", $vResult, Null)
    _TestFmkAssert($iErr = 0xDEAD,  "Sets @error = 0xDEAD", $iErr, 0xDEAD)
    _TestFmkAssert($iExt = 0xBEEF,  "Sets @extended = 0xBEEF", $iExt, 0xBEEF)
EndFunc

; ===============================================================================================================================
; Tests - __OnObjEvent
; ===============================================================================================================================
Func _TestOnObjEvent_CallsHandler()
    _TestFmkHeader("Test: __OnObjEvent() - calls registered handler")

    $g_bEventsTestHandlerCalled = False
    Local $mPage = _NewPage()
    Local $mEvent[]
    $mEvent.hHandler = __EventsTestClickHandler
    $mPage[$ONCLICK] = $mEvent

    __OnObjEvent($mPage, $ONCLICK)

    _TestFmkAssert($g_bEventsTestHandlerCalled = True, "Handler was called", $g_bEventsTestHandlerCalled, True)
EndFunc

Func _TestOnObjEvent_InvalidMap()
    _TestFmkHeader("Test: __OnObjEvent() - returns Null for invalid map")

    Local $vResult = __OnObjEvent("invalid obj map", $ONCLICK)

    _TestFmkAssert($vResult = Null, "Returns Null for invalid map", $vResult, Null)
EndFunc

Func _TestOnObjEvent_MissingEvent()
    _TestFmkHeader("Test: __OnObjEvent() - returns Null when event key missing")

    Local $mPage = _NewPage()

    Local $vResult = __OnObjEvent($mPage, $ONCLICK)

    _TestFmkAssert($vResult = Null, "Returns Null when event missing", $vResult, Null)
EndFunc

Func _TestOnObjEvent_MissingHandler()
    _TestFmkHeader("Test: __OnObjEvent() - returns Null when handler key missing")

    Local $mPage = _NewPage()
    Local $mEvent[]
    $mPage[$ONCLICK] = $mEvent

    Local $vResult = __OnObjEvent($mPage, $ONCLICK)

    _TestFmkAssert($vResult = Null, "Returns Null when handler missing", $vResult, Null)
EndFunc

; ===============================================================================================================================
; Tests - __OnObjBtnClick
; ===============================================================================================================================
Func _TestOnObjBtnClick_CallsRegisteredHandler()
    _TestFmkHeader("Test: __OnObjBtnClick() - calls registered button handler")

    $g_bEventsTestHandlerCalled = False
	Local $idBtn = 10

    Local $mPage    = _NewPage()
    Local $mHandler = _SetEventHandler(__EventsTestClickHandler)
    _SetPageBtnOnClickEvent($mPage, $idBtn, $mHandler)

    __OnObjBtnClick($mPage, $idBtn)

    _TestFmkAssert($g_bEventsTestHandlerCalled = True, "Handler was called", $g_bEventsTestHandlerCalled, True)
EndFunc

Func _TestOnObjBtnClick_UnregisteredButton()
    _TestFmkHeader("Test: __OnObjBtnClick() - does nothing for unregistered button")

    $g_bEventsTestHandlerCalled = False
	Local $idBtn = 10
	Local $idUnregisteredBtn = 99

    Local $mPage = _NewPage()
    Local $mHandler = _SetEventHandler(__EventsTestClickHandler)
    _SetPageBtnOnClickEvent($mPage, $idBtn, $mHandler)

    __OnObjBtnClick($mPage, $idUnregisteredBtn)

    _TestFmkAssert($g_bEventsTestHandlerCalled = False, "Handler not called", $g_bEventsTestHandlerCalled, False)
EndFunc

Func _TestOnObjBtnClick_InvalidPage()
    _TestFmkHeader("Test: __OnObjBtnClick() - does nothing for invalid page")

    $g_bEventsTestHandlerCalled = False
	Local $idBtn = 10
	Local $mPage = "Invalid, must to be a map"

    __OnObjBtnClick($mPage, $idBtn)

    _TestFmkAssert($g_bEventsTestHandlerCalled = False, "Handler not called for invalid page", $g_bEventsTestHandlerCalled, False)
EndFunc

; ===============================================================================================================================
; Tests - _HandlerArgs
; ===============================================================================================================================
Func _TestHandlerArgs_NoArgs()
    _TestFmkHeader("Test: _HandlerArgs() - returns CallArgArray with only header when no args")

    Local $aArgs = _HandlerArgs()

    _TestFmkAssert(IsArray($aArgs), "Returns array", IsArray($aArgs), True)
    _TestFmkAssert(UBound($aArgs) = 1, "Array has 1 element (CallArgArray header)", UBound($aArgs), 1)
    _TestFmkAssert($aArgs[0] = "CallArgArray", "First element is CallArgArray", $aArgs[0], "CallArgArray")
EndFunc

Func _TestHandlerArgs_WithArgs()
    _TestFmkHeader("Test: _HandlerArgs() - returns CallArgArray with supplied args")

    Local $aArgs = _HandlerArgs("a", "b", "c")

    _TestFmkAssert(UBound($aArgs) = 4, "Array has 4 elements", UBound($aArgs), 4)
    _TestFmkAssert($aArgs[0] = "CallArgArray", "First element is CallArgArray", $aArgs[0], "CallArgArray")
    _TestFmkAssert($aArgs[1] = "a", "Second element correct", $aArgs[1], "a")
    _TestFmkAssert($aArgs[2] = "b", "Third element correct",  $aArgs[2], "b")
    _TestFmkAssert($aArgs[3] = "c", "Fourth element correct", $aArgs[3], "c")
EndFunc

; ===============================================================================================================================
; Tests - _SetEventHandler
; ===============================================================================================================================
Func __TestHandlerFunc()
    Return "handled"
EndFunc

Func _TestSetEventHandler_ValidHandler()
    _TestFmkHeader("Test: _SetEventHandler() - stores valid handler")

    Local $mHandler = _SetEventHandler(__TestHandlerFunc)

    _TestFmkAssert(IsMap($mHandler), "Returns a map", IsMap($mHandler), True)
    _TestFmkAssert(MapExists($mHandler, "hHandler"), "Has hHandler key", MapExists($mHandler, "hHandler"), True)
    _TestFmkAssert(FuncName($mHandler.hHandler) = "__TestHandlerFunc", "Handler stored correctly", FuncName($mHandler.hHandler), "__TestHandlerFunc")
EndFunc

Func _TestSetEventHandler_WithArgs()
    _TestFmkHeader("Test: _SetEventHandler() - stores handler with args")

    Local $aArgs = _HandlerArgs("arg1", "arg2")
    Local $mHandler = _SetEventHandler(__TestHandlerFunc, $aArgs)

    _TestFmkAssert(MapExists($mHandler, "aArgs"), "Has aArgs key", MapExists($mHandler, "aArgs"), True)
EndFunc

Func _TestSetEventHandler_WithInvalidArgs()
    _TestFmkHeader("Test: _SetEventHandler() - stores handler but do not store args if invalid args")

    Local $aArgs = "Invalid Args"
    Local $mHandler = _SetEventHandler(__TestHandlerFunc, $aArgs)

	_TestFmkAssert(IsMap($mHandler), "Returns a map", IsMap($mHandler), True)
	_TestFmkAssert(MapExists($mHandler, "hHandler"), "Has hHandler key", MapExists($mHandler, "hHandler"), True)
    _TestFmkAssert(Not MapExists($mHandler, "aArgs"), "No aArgs key", MapExists($mHandler, "aArgs"), False)
EndFunc

Func _TestSetEventHandler_InvalidHandler()
    _TestFmkHeader("Test: _SetEventHandler() - returns empty map for invalid handler")

    Local $mHandler = _SetEventHandler("Invalid Handler")

    _TestFmkAssert(IsMap($mHandler), "Returns a map", IsMap($mHandler), True)
    _TestFmkAssert(Not MapExists($mHandler, "hHandler"), "No hHandler key", MapExists($mHandler, "hHandler"), False)
EndFunc

; ===============================================================================================================================
; Tests - _SetPageBtnOnClickEvent
; ===============================================================================================================================
Func _TestSetPageBtnOnClickEvent_RegistersHandler()
    _TestFmkHeader("Test: _SetPageBtnOnClickEvent() - registers OnClick handler for button")

    Local $mPage = _NewPage()
    Local $mHandler = _SetEventHandler(__TestHandlerFunc)
	Local $idBtn = 10

    _SetPageBtnOnClickEvent($mPage, $idBtn, $mHandler)

    _TestFmkAssert(IsMap($mPage["mBtnEvents"][$idBtn]), "Button event map created", IsMap($mPage["mBtnEvents"][$idBtn]), True)
    _TestFmkAssert(MapExists($mPage["mBtnEvents"][$idBtn], "OnClick"), "OnClick key exists", MapExists($mPage["mBtnEvents"][$idBtn], "OnClick"), True)
EndFunc

Func _TestSetPageBtnOnClickEvent_InvalidPage()
    _TestFmkHeader("Test: _SetPageBtnOnClickEvent() - does nothing for invalid page")

    Local $mPage = "Invalid page"
    Local $mHandler = _SetEventHandler(__TestHandlerFunc)
	Local $idBtn = 10

    Local $vReturn = _SetPageBtnOnClickEvent($mPage, $idBtn, $mHandler)

	_TestFmkAssert($vReturn = Null, "Does nothing for invalid page", $vReturn, Null)
EndFunc

Func _TestSetPageBtnOnClickEvent_InvalidHandler()
    _TestFmkHeader("Test: _SetPageBtnOnClickEvent() - does nothing for handler without hHandler key")

    Local $mPage = _NewPage()
    Local $mHandler[]
	Local $idBtn = 10

    _SetPageBtnOnClickEvent($mPage, $idBtn, $mHandler)

    _TestFmkAssert(Not MapExists($mPage["mBtnEvents"], $idBtn), "Does nothing for invalid handler", MapExists($mPage["mBtnEvents"], $idBtn), False)
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialInstallerEventsTest_GetSetInstallerEvent(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestGetInstallerEvent_ReturnsDefault,            $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetInstallerEvent_SetsCorrectly,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetInstallerEvent_DefaultParam,              $bAllPassed)
EndFunc

Func __RunCrucialInstallerEventsTest_IsValidArgs(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestIsValidArgs_NonArray,            $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsValidArgs_EmptyArray,          $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsValidArgs_InvalidFirstElement, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidArgs_ValidArgs,           $bAllPassed)
EndFunc

Func __RunCrucialInstallerEventsTest_HasArgs(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestHasArgs_ValidArgs,                           $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestHasArgs_InvalidArgs,                         $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestHasArgs_Default,                             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestHasArgs_NonArray,                            $bAllPassed)
EndFunc

Func __RunCrucialInstallerEventsTest_RunEventHandler(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestRunEventHandler_ValidHandler,                $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRunEventHandler_WithArgs,                    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRunEventHandler_InvalidHandler,              $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRunEventHandler_GuardsAgainstSelf,           $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRunEventHandler_WrongArgCount,           	$bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRunEventHandler_FewerArgsThanRequired,       $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRunEventHandler_MoreArgsThanRequired,        $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRunEventHandler_InvalidArgsArray,        	$bAllPassed)
EndFunc

Func __RunCrucialInstallerEventsTest_OnObjEvent(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestOnObjEvent_CallsHandler,                $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnObjEvent_InvalidMap,                  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnObjEvent_MissingEvent,                $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnObjEvent_MissingHandler,              $bAllPassed)
EndFunc

Func __RunCrucialInstallerEventsTest_OnObjBtnClick(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestOnObjBtnClick_CallsRegisteredHandler,   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnObjBtnClick_UnregisteredButton,       $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestOnObjBtnClick_InvalidPage,              $bAllPassed)
EndFunc

Func __RunCrucialInstallerEventsTest_HandlerArgs(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestHandlerArgs_NoArgs,                          $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestHandlerArgs_WithArgs,                        $bAllPassed)
EndFunc

Func __RunCrucialInstallerEventsTest_SetEventHandler(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestSetEventHandler_ValidHandler,                $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetEventHandler_WithArgs,                    $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetEventHandler_WithInvalidArgs,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetEventHandler_InvalidHandler,              $bAllPassed)
EndFunc

Func __RunCrucialInstallerEventsTest_SetPageBtnOnClickEvent(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestSetPageBtnOnClickEvent_RegistersHandler,     $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetPageBtnOnClickEvent_InvalidPage,          $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetPageBtnOnClickEvent_InvalidHandler,       $bAllPassed)
EndFunc

Func _RunCrucialInstallerEventsTests($bWriteSummary = True)
    Local $bAllPassed = True
	__RunCrucialInstallerEventsTest_GetSetInstallerEvent($bAllPassed)
	__RunCrucialInstallerEventsTest_IsValidArgs($bAllPassed)
	__RunCrucialInstallerEventsTest_HasArgs($bAllPassed)
	__RunCrucialInstallerEventsTest_RunEventHandler($bAllPassed)
	__RunCrucialInstallerEventsTest_OnObjEvent($bAllPassed)
	__RunCrucialInstallerEventsTest_OnObjBtnClick($bAllPassed)
	__RunCrucialInstallerEventsTest_HandlerArgs($bAllPassed)
	__RunCrucialInstallerEventsTest_SetEventHandler($bAllPassed)
	__RunCrucialInstallerEventsTest_SetPageBtnOnClickEvent($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerEventsTests, $sScriptName)
