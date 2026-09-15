#include-once

#include <FontConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <ColorConstants.au3>
#include <Array.au3>
#include "..\core\Testable.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstaller.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: A reusable wizard framework for building installer and uninstaller GUIs.
;                  Provides page-based navigation, configurable layouts, event handling,
;                  and ready-made page templates (intro, path, ready, progress, finish).
;
;                  Usage pattern:
;                  1. Create a config:   _NewInstallerCfg()
;                  2. Create a wizard:   _NewWizard($mCfg, $sTitle, $sHeaderTitle)
;                  3. Add pages:         _AddIntroPage(), _AddPathPage(), _AddReadyPage(),
;                                        _AddProgressPage(), _AddFinishPage()
;                  4. Start the wizard:  _InitWizard($mWizard)
;
;                  Each page template accepts optional event handlers for custom behavior
;                  (e.g. updating the ready page text, running the install process,
;                  opening documentation on finish).
; ===============================================================================================================================

;#CURRENT# ======================================================================================================================
;
;[CONFIGS]
; _NewWndCfg
; _NewFontCfg
; _NewBtnDim
; _NewBtnCaptions
; _NewBtnCfg
; _NewInstallerCfg
;
;[INSTALLER EVENTS]
; _GetInstallerEvent
; _SetInstallerEvent
;
;[PAGE HELPERS]
; _CreatePages
; _NewPage
; _AddPage
;
;[PAGE CONTROLS]
; _SetPageCtrl
; _GetPageCtrl
;
;[EVENTS HANDLER]
; _HandlerArgs
; _SetEventHandler
; _SetPageBtnOnClickEvent
;
;[WIZZARD BUTONS]
; _CreateButtons
;
;[PROGRESSBAR]
; _ProgressStep
;
;[ON PAGE TEMPLATE EVENTS]
; _OnLoad_ReadyPage
; _AfterLoad_ProgressPage
; _AfterLoad_FinishPage
; _OnClose_FinishPage
; _OnClick_SetFolder
;
;[HELPERS TO ADD PAGE TEMPLATES TO WIZARD]
; _AddIntroPage
; _AddPathPage
; _AddReadyPage
; _AddProgressPage
; _AddFinishPage
;
;[HEADER CONSTRUCTORS HELPERS]
; _CreateSeparator
; _CreateHeaderTitle
; _CreateHeaderSub
; _CreateHeader
;
;[WIZARD HELPERS]
; _NewWizard
; _GetWizardPage
;
;[WIZARD INIT]
; _InitWizard
;
; ===============================================================================================================================

;#INTERNAL_USE_ONLY# ============================================================================================================
;
;[ERROR MANAGEMENT]
; __CrucialInstErrMsg
; __DebugErrorInfo
;
;[CONFIGS]
; __IsValidInstallerCfg
;
;[PAGE HELPERS]
; __IsPageStatusValid
; __SetPageEvent
; __GetPageStatus
; __IsValidPagePosition
; __GetPagePosition
; __MaxPages
; __GetPage
;
;[PAGE CONTROLS]
; __CreatePageCtrls
; __ArrayInMapReplace
; __PageCtrlName
; __GetPageCtrlIndex
;
;[EVENTS HANDLER]
; __IsValidArgs
; __HasArgs
; __CallFuncDebugErrorInfo
; __RunEventHandler
; __OnObjEvent
; __OnObjBtnClick
;
;[WIZZARD BUTONS]
; __BtnCaptionsUpdate
; __GetButton
; __GetBtnCancel
; __GetBtnBack
; __GetBtnNext
; __SetButtons
;
;[PAGE OPERATIONS]
; __HidePage
; __HidePages
; __ShowPageControls
; __SetPageSubHeader
; __PageLoad
; __ClosePage
; __SetPage
;
;[PAGE NAVIGATION]
; __NextPage
; __BackPage
; __PageMove
; __NavPage
;
;[PAGE TEMPLATE EVENTS HANDLERS]
; __RunUpdateInfoFunc
; __RunApplyFunc
; __RunUpdateSrcFunc
;
;[PAGE TEMPLATES]
; __ValidateTemplateArgs
; __SetIntroPage
; __SetPathPage
; __SetReadyPage
; __SetProgressPage
; __SetFinishPage
;
;[WIZARD HELPERS]
; __IsValidWizardHeader
; __IsValidWizardButtons
; __IsValidWizard
; __IsWizardReady
; __MsgCloseInstall
;
;[WIZARD INIT]
; __OnInit_Wizard
;
; ===============================================================================================================================

;================================================================================================================================
#Region ; >>> [GLOBALS: CONSTANTS, VARIABLES, AND ENUMS]
;================================================================================================================================

; Default version string used when no version is specified in page templates
Global Const $DEFAULT_VERSION = "0.0.1"

; Default Window dimensions
Global Const $WIN_WIDTH     = 540
Global Const $WIN_HEIGHT    = 345

; Default Font configs
Global Const $FONT_NAME     = "Segoe UI"
Global Const $FONT_SIZE     = 11

; Default Button dimensions and position
Global Const $BTN_W         = 130
Global Const $BTN_H         = 34
Global Const $BTN_GAP       = 10
Global Const $BTN_Y         = $WIN_HEIGHT - 48

; Default Layout metrics
Global Const $FOOTER_SEP_Y  = $WIN_HEIGHT - 58
Global Const $HEADER_H      = 70
Global Const $CONTENT_TOP   = $HEADER_H + 10
Global Const $CONTENT_W     = $WIN_WIDTH - 40

; Default button captions - overridable via _NewBtnCaptions()
Global Const $BTN_CAPTION_NEXT    = "Next >"
Global Const $BTN_CAPTION_BACK    = "< Back"
Global Const $BTN_CAPTION_CANCEL  = "Cancel"
Global Const $BTN_CAPTION_FINISH  = "Finish"
Global Const $BTN_CAPTION_APPLY   = "Install"

; Active button captions
; updated at runtime via __BtnCaptionsUpdate() from the wizard config
Global $__g_BTN_CAPTION_NEXT    = $BTN_CAPTION_NEXT
Global $__g_BTN_CAPTION_BACK    = $BTN_CAPTION_BACK
Global $__g_BTN_CAPTION_CANCEL  = $BTN_CAPTION_CANCEL
Global $__g_BTN_CAPTION_FINISH  = $BTN_CAPTION_FINISH
Global $__g_BTN_CAPTION_APPLY   = $BTN_CAPTION_APPLY

; Button map key constants
; used with __GetButton() to retrieve button control IDs from the wizard map
Global Const $BTN_CANCEL  = "idBtnCancel"
Global Const $BTN_BACK    = "idBtnBack"
Global Const $BTN_NEXT    = "idBtnNext"

; Page navigation direction
; passed to __PageMove() to control which way the page wizard moves
Global Enum $ePageBack = -1, $ePageStay, $ePageNext

; Page position within the wizard - mainly used to configure button states per page
Global Enum $eInvalidPage = -1, $eSinglePage, $eFirstPage, $eMidPage, $eLastPage

; Page type/status - controls button layout and event flow for each page
Global Enum $eClosePage, $eNormalPage, $eProceedPage, $eProcessingPage, $eFinishPage

; Page event aliases - same values as page types
; used as event identifiers in __SetButtons()
Global Enum $eOnClosePage      = $eClosePage, _
			$eOnDefault        = $eNormalPage, _
			$eOnReadyToProceed = $eProceedPage, _
			$eOnProcessing     = $eProcessingPage, _
			$eOnFinish         = $eFinishPage

; Events Constants (Alias for Page Events)
Global Const $EVENT_CLOSE_PAGE       = $eOnClosePage
Global Const $EVENT_DEFAULT          = $eOnDefault
Global Const $EVENT_READY_TO_PROCEED = $eOnReadyToProceed
Global Const $EVENT_PROCESSING       = $eOnProcessing
Global Const $EVENT_FINISH_PROCESS   = $eOnFinish

; Event name/Type
; keys used in page maps to store event handlers
Global Const $ONLOAD    = "OnLoad"
Global Const $AFTERLOAD = "AfterLoad"
Global Const $ONCLOSE   = "OnClose"
Global Const $ONCLICK   = "OnClick"

; Signal to Terminate Wizard (exit main loop and delete GUI)
Global Const $EXIT_WIZARD_SIGNAL = -9

; Hold the current event state
; set via _SetInstallerEvent(), read via _GetInstallerEvent()
Global $g_iEventInstaller = $EVENT_DEFAULT

; Error codes returned via SetError() by functions that validate their inputs
Global Const $INST_ERR_INVALID_WIZARD  = 1  ; wizard map is missing required keys
Global Const $INST_ERR_INVALID_CFG     = 2  ; config map is missing or has invalid values
Global Const $INST_ERR_INVALID_GUI     = 3  ; GUI handle is not a valid window
Global Const $INST_ERR_INVALID_CTRL    = 4  ; control ID or index is invalid
Global Const $INST_ERR_INVALID_AIMR    = 5  ; array replace received invalid parameters

; Error messages for error codes
Global Const $INST_ERR_MSG_WIZARD  = "Wizard map is missing required keys"
Global Const $INST_ERR_MSG_CFG     = "Config map is missing or has invalid values"
Global Const $INST_ERR_MSG_GUI     = "GUI handle is not a valid window"
Global Const $INST_ERR_MSG_CTRL    = "Control ID or index is invalid"
Global Const $INST_ERR_MSG_AIMR    = "Invalid array or index in Array Map Replace"
Global Const $INST_ERR_MSG_UNKNOWN = "Unknown error"

;================================================================================================================================
#EndRegion <<< [GLOBALS: CONSTANTS, VARIABLES, AND ENUMS]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [ERROR MANAGEMENT] (OK) (TODO shorten $INST_ERR* consts)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Translates an error code into a human-readable error message string.
Func __CrucialInstErrMsg($iError)
    Switch $iError
        Case $INST_ERR_INVALID_WIZARD
            Return $INST_ERR_MSG_WIZARD

        Case $INST_ERR_INVALID_CFG
            Return $INST_ERR_MSG_CFG

        Case $INST_ERR_INVALID_GUI
            Return $INST_ERR_MSG_GUI

		Case $INST_ERR_INVALID_CTRL
            Return $INST_ERR_MSG_CTRL

		Case $INST_ERR_INVALID_AIMR
            Return $INST_ERR_MSG_AIMR

        Case Else
            Return $INST_ERR_MSG_UNKNOWN
    EndSwitch
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Logs a runtime error to the console (interpreted mode only) and returns SetError
; with the given error code, extended value, and return value.
; Used as a consistent error return pattern across all functions that validate inputs.
; $hFuncCaller - reference to the calling function for error context in the log
; $iError      - error code (one of the $INST_ERR_* constants)
; $iExtend     - extended error value passed to SetError
; $vReturn     - value to return after setting the error
Func __DebugErrorInfo($hFuncCaller, $iError, $iExtend, $vReturn)
	If IsFunc($hFuncCaller) And Not @Compiled And Not IsDeclared("__TFW_TEST_MODE") Then
		Local $sErrorMsg = "!RUNTIME ERROR > " & FuncName($hFuncCaller) & ": ## " & __CrucialInstErrMsg($iError) & " ##"
		_Tstbl_ConsoleWrite($sErrorMsg & @CRLF)
	EndIf
	Return SetError($iError, $iExtend, $vReturn)
EndFunc

;================================================================================================================================
#EndRegion <<< [ERROR MANAGEMENT]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [CONFIGS] (OK) (TODO Abs() rather than Int() for numeric)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns True if the given config map contains all required keys with valid types.
; Used as a guard at the start of functions that depend on a fully built config.
Func __IsValidInstallerCfg(Const ByRef $mCfg)
	If Not IsMap($mCfg) Then Return False

	If Not MapExists($mCfg, "iWndWidth") Then Return False
	If Not MapExists($mCfg, "iWndHeight") Then Return False
	If Not MapExists($mCfg, "iFooterSepY") Then Return False
	If Not MapExists($mCfg, "iHeaderHeight") Then Return False
	If Not MapExists($mCfg, "iContentTop") Then Return False
	If Not MapExists($mCfg, "iContentWidth") Then Return False
	If Not MapExists($mCfg, "sFontName") Then Return False
	If Not MapExists($mCfg, "iFontSize") Then Return False
	If Not MapExists($mCfg, "iBtnWidth") Then Return False
	If Not MapExists($mCfg, "iBtnHeight") Then Return False
	If Not MapExists($mCfg, "iBtnGap") Then Return False
	If Not MapExists($mCfg, "iBtnY") Then Return False
	If Not MapExists($mCfg, "sBtnCaptNext") Then Return False
	If Not MapExists($mCfg, "sBtnCaptBack") Then Return False
	If Not MapExists($mCfg, "sBtnCaptCancel") Then Return False
	If Not MapExists($mCfg, "sBtnCaptFinish") Then Return False
	If Not MapExists($mCfg, "sBtnCaptApply") Then Return False

	If Not IsInt($mCfg.iWndWidth) Then Return False
	If Not IsInt($mCfg.iWndHeight) Then Return False
	If Not IsInt($mCfg.iFooterSepY) Then Return False
	If Not IsInt($mCfg.iHeaderHeight) Then Return False
	If Not IsInt($mCfg.iContentTop) Then Return False
	If Not IsInt($mCfg.iContentWidth) Then Return False
	If Not IsInt($mCfg.iFontSize) Then Return False
	If Not IsInt($mCfg.iBtnWidth) Then Return False
	If Not IsInt($mCfg.iBtnHeight) Then Return False
	If Not IsInt($mCfg.iBtnGap) Then Return False
	If Not IsInt($mCfg.iBtnY) Then Return False

	If Not IsString($mCfg.sFontName) Then Return False
	If Not IsString($mCfg.sBtnCaptNext) Then Return False
	If Not IsString($mCfg.sBtnCaptBack) Then Return False
	If Not IsString($mCfg.sBtnCaptCancel) Then Return False
	If Not IsString($mCfg.sBtnCaptFinish) Then Return False
	If Not IsString($mCfg.sBtnCaptApply) Then Return False

	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates a window dimension config map with layout metrics.
; All parameters have defaults matching the library constants.
Func _NewWndCfg($iWidth = $WIN_WIDTH, $iHeight = $WIN_HEIGHT, $iFooterSepY = $FOOTER_SEP_Y, _
				$iHeaderHeight = $HEADER_H, $iContentTop = $CONTENT_TOP, $iContentWidth = $CONTENT_W)
	Local $mWndCfg[]
	$mWndCfg.iWidth	       = Int($iWidth)
	$mWndCfg.iHeight 	   = Int($iHeight)
	$mWndCfg.iFooterSepY   = Int($iFooterSepY)
	$mWndCfg.iHeaderHeight = Int($iHeaderHeight)
	$mWndCfg.iContentTop   = Int($iContentTop)
	$mWndCfg.iContentWidth = Int($iContentWidth)
	Return $mWndCfg
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates a font config map with name and size.
; All parameters have defaults matching the library constants.
Func _NewFontCfg($sName = $FONT_NAME, $iSize = $FONT_SIZE)
	Local $mFontCfg[]
	$mFontCfg.sName = String($sName)
	$mFontCfg.iSize = Int($iSize)
	Return $mFontCfg
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates a button dimension config map with width, height, gap and Y position.
; All parameters have defaults matching the library constants.
Func _NewBtnDim($iWidth = $BTN_W, $iHeight = $BTN_H, $iGap = $BTN_GAP, $iYaxis = $BTN_Y)
	Local $mBtnDim[]
	$mBtnDim.iWidth  = Int($iWidth)
	$mBtnDim.iHeight = Int($iHeight)
	$mBtnDim.iGap    = Int($iGap)
	$mBtnDim.iYaxis  = Int($iYaxis)
	Return $mBtnDim
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates a button captions config map with labels for each button.
; All parameters have defaults matching the library constants.
; Pass custom captions to override the defaults for a specific wizard.
Func _NewBtnCaptions($sNext = $BTN_CAPTION_NEXT, $sBack = $BTN_CAPTION_BACK, $sCancel = $BTN_CAPTION_CANCEL, _
					 $sFinish = $BTN_CAPTION_FINISH, $sApply = $BTN_CAPTION_APPLY)
	Local $mBtnCapt[]
	$mBtnCapt.sNext   = String($sNext)
	$mBtnCapt.sBack   = String($sBack)
	$mBtnCapt.sCancel = String($sCancel)
	$mBtnCapt.sFinish = String($sFinish)
	$mBtnCapt.sApply  = String($sApply)
	Return $mBtnCapt
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates a button config map combining dimensions and captions.
; Falls back to defaults if invalid maps are provided.
Func _NewBtnCfg($mBtnDim = _NewBtnDim(), $mBtnCapt = _NewBtnCaptions())
	If Not IsMap($mBtnDim) Then $mBtnDim = _NewBtnDim()
	If Not IsMap($mBtnCapt) Then $mBtnCapt = _NewBtnCaptions()

	Local $mBtnCfg[]
	$mBtnCfg.mDim  = $mBtnDim
	$mBtnCfg.mCapt = $mBtnCapt
	Return $mBtnCfg
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates a flat installer config map by combining window, font and button configs.
; This is the single config object passed throughout the wizard - all layout, font
; and button settings are read from it. Falls back to defaults if invalid maps provided.
Func _NewInstallerCfg($mWndCfg = _NewWndCfg(), $mFontCfg = _NewFontCfg, $mBtnCfg = _NewBtnCfg())

	If Not IsMap($mWndCfg)  Then $mWndCfg  = _NewWndCfg()
	If Not IsMap($mFontCfg) Then $mFontCfg = _NewFontCfg()
	If Not IsMap($mBtnCfg)  Then $mBtnCfg  = _NewBtnCfg()

	Local $mCfg[]

	$mCfg.iWndWidth   	 = $mWndCfg.iWidth			;Global Const $WIN_WIDTH
	$mCfg.iWndHeight  	 = $mWndCfg.iHeight			;Global Const $WIN_HEIGHT
	$mCfg.iFooterSepY 	 = $mWndCfg.iFooterSepY		;Global Const $FOOTER_SEP_Y
	$mCfg.iHeaderHeight  = $mWndCfg.iHeaderHeight	;Global Const $HEADER_H
	$mCfg.iContentTop    = $mWndCfg.iContentTop		;Global Const $CONTENT_TOP
	$mCfg.iContentWidth  = $mWndCfg.iContentWidth	;Global Const $CONTENT_W

	$mCfg.sFontName   	 = $mFontCfg.sName			;Global Const $FONT_NAME
	$mCfg.iFontSize   	 = $mFontCfg.iSize			;Global Const $FONT_SIZE

	$mCfg.iBtnWidth   	 = $mBtnCfg.mDim.iWidth		;Global Const $BTN_W
	$mCfg.iBtnHeight  	 = $mBtnCfg.mDim.iHeight	;Global Const $BTN_H
	$mCfg.iBtnGap     	 = $mBtnCfg.mDim.iGap		;Global Const $BTN_GAP
	$mCfg.iBtnY 	  	 = $mBtnCfg.mDim.iYaxis		;Global Const $BTN_Y
	$mCfg.sBtnCaptNext   = $mBtnCfg.mCapt.sNext		;Global Const $BTN_CAPTION_NEXT
	$mCfg.sBtnCaptBack   = $mBtnCfg.mCapt.sBack		;Global Const $BTN_CAPTION_BACK
	$mCfg.sBtnCaptCancel = $mBtnCfg.mCapt.sCancel	;Global Const $BTN_CAPTION_CANCEL
	$mCfg.sBtnCaptFinish = $mBtnCfg.mCapt.sFinish	;Global Const $BTN_CAPTION_FINISH
	$mCfg.sBtnCaptApply	 = $mBtnCfg.mCapt.sApply	;Global Const $BTN_CAPTION_APPLY

	Return $mCfg

EndFunc

;================================================================================================================================
#EndRegion <<< [CONFIGS]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [INSTALLER EVENTS] (OK) (TODO: validate event and fallback to default)
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Returns the current installer event state.
Func _GetInstallerEvent()
	Return $g_iEventInstaller
EndFunc

; #FUNCTION# ====================================================================================================================
; Sets the current installer event state.
; $iEvent - one of the $EVENT_* constants (default: $EVENT_DEFAULT)
Func _SetInstallerEvent($iEvent = $EVENT_DEFAULT)
	$g_iEventInstaller = $iEvent
EndFunc

;================================================================================================================================
#EndRegion <<< [INSTALLER EVENTS]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [PAGE HELPERS] (OK)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns True if $iStatus is a valid page status value (within the $eClosePage to $eFinishPage range).
Func __IsPageStatusValid($iStatus)
	Return $iStatus >= $eClosePage And $iStatus <= $eFinishPage
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Sets the current page event from a page status value.
; Falls back to $eNormalPage if the status is invalid.
Func __SetPageEvent($iStatus)
	Return __IsPageStatusValid($iStatus) ? $iStatus : $eNormalPage
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the page status from a page map, or $eNormalPage if the map is invalid or status is missing.
; Called during page load to sync the event state with the page type.
Func __GetPageStatus(Const ByRef $mPage)
	If Not IsMap($mPage) Then Return $eNormalPage
	If Not MapExists($mPage, "iStatus") Then Return $eNormalPage
	Return __IsPageStatusValid($mPage.iStatus) ? $mPage.iStatus : $eNormalPage
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns True if $iPagePosition is a valid page position (different than $eInvalidPage).
Func __IsValidPagePosition($iPagePosition)
	Return $iPagePosition > $eInvalidPage And $iPagePosition <= $eLastPage
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the position of $iPage within the wizard ($eFirstPage, $eMidPage, $eLastPage, etc.)
; based on the total number of pages.
Func __GetPagePosition($iPage, $iMaxPages)
	If $iPage <= 0 Or $iPage > $iMaxPages Then Return $eInvalidPage
	If $eFirstPage = $iMaxPages Then Return $eSinglePage
	If $iPage = $eFirstPage Then Return $eFirstPage
	If $iPage = $iMaxPages  Then Return $eLastPage
	Return $eMidPage
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the total number of pages in the pages map.
Func __MaxPages(Const ByRef $mPages)
	If Not IsMap($mPages) Then Return 0
	Return Ubound($mPages)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the page map for a given page index, or Null if not found.
Func __GetPage(ByRef $mPages, $iPage)
	If Not IsMap($mPages) Then Return Null
	If Not MapExists($mPages, $iPage) Then Return Null
	Return $mPages[$iPage]
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates and returns an empty pages map to hold wizard pages.
Func _CreatePages()
	Local $mPages[]
	Return $mPages
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates and returns a new page map with a subheading, status and empty controls array.
; $sSubheading - text shown in the header subtitle when this page is active
; $iStatus     - page type (one of the $e*Page constants, default: $eNormalPage)
Func _NewPage($sSubheading = "", $iStatus = $eNormalPage)
	Local $oEmpty[]
	Local $mPage[]
	$mPage.sSubheading = String($sSubheading)
	$mPage.iStatus     = __SetPageEvent($iStatus)
	$mPage.aControls   = __CreatePageCtrls()
	$mPage.mBtnEvents  = $oEmpty
	Return $mPage
EndFunc

; #FUNCTION# ====================================================================================================================
; Adds a page to the pages map and returns its 1-based index.
; Both $mPages and $mPage must be valid maps.
Func _AddPage(ByRef $mPages, ByRef $mPage)
	If Not IsMap($mPages) And Not IsMap($mPage) Then Return
	Local $iPage = __MaxPages($mPages) + 1
	$mPages[$iPage] = $mPage
	Return $iPage
EndFunc

;================================================================================================================================
#EndRegion <<< [PAGE HELPERS]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [PAGE CONTROLS] (OK)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Creates and returns an empty controls array for a page.
; $iSize - initial array size (default: 0)
Func __CreatePageCtrls($iSize = 0)
	If Int($iSize) < 0 Then $iSize = 0
	Local $aControls[$iSize]
	Return $aControls
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Replaces a value at $iIndex in an array stored inside a map.
; Returns SetError($INST_ERR_INVALID_AIMR) if the array or index is invalid.
; Used internally by _SetPageCtrl() to update an existing control entry.
Func __ArrayInMapReplace(ByRef $aArray, $iIndex, $vNewValue)
	If Not IsArray($aArray) Then
		__DebugErrorInfo(__ArrayInMapReplace, $INST_ERR_INVALID_AIMR, 0 , Null)
		Return SetError(@error, @extended, Null)
	ElseIf Not IsInt($iIndex) Or IsInt($iIndex) < 0 Or $iIndex > UBound($aArray) Then
		__DebugErrorInfo(__ArrayInMapReplace, $INST_ERR_INVALID_AIMR, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf
	$aArray[Int($iIndex)] = $vNewValue
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Normalizes a control name to the standard key format used in page maps.
; Ensures the name starts with "i" and ends with "Id" (e.g. "BtnNext" -> "iBtnNextId").
Func __PageCtrlName($sCtrlName)
    If StringLeft($sCtrlName, 1) <> "i" Then $sCtrlName = "i" & $sCtrlName
    If StringRight($sCtrlName, 2) <> "Id" Then $sCtrlName = $sCtrlName & "Id"
    Return $sCtrlName
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the index of a named control in the page's controls array, or Null if not found.
; $sCtrlName - the control name (normalized via __PageCtrlName())
Func __GetPageCtrlIndex(Const ByRef $mPage, $sCtrlName)
	If Not IsMap($mPage) Then Return Null

	Local $sKey = __PageCtrlName($sCtrlName)
	If Not MapExists($mPage, $sKey) Then Return Null

	Local $iCtrlIdx = $mPage[$sKey]
	If Not IsInt($iCtrlIdx) Then $iCtrlIdx = -1

	If Not IsArray($mPage.aControls) Then Return Null
	If $iCtrlIdx < 0 Or $iCtrlIdx > UBound($mPage.aControls) Then Return Null

	Return $iCtrlIdx
EndFunc

; #FUNCTION# ====================================================================================================================
; Registers a control ID under a named key in the page map and stores it in the controls array.
; If the named control already exists its entry is updated in place, otherwise a new entry is added.
; Returns the control's index in the controls array, or Null on error.
; $idCtrl    - the AutoIt control ID returned by GUICtrlCreate*
; $sCtrlName - a descriptive name used to retrieve the control later via _GetPageCtrl()
Func _SetPageCtrl(ByRef $mPage, $idCtrl, $sCtrlName)
	If Not IsMap($mPage) Or Not _Tstbl_GUICtrlGetHandle($idCtrl) Then
		__DebugErrorInfo(_SetPageCtrl, $INST_ERR_INVALID_CTRL, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	If Not MapExists($mPage, "aControls") Or Not IsArray($mPage.aControls) Then
		$mPage.aControls = __CreatePageCtrls()
	EndIf

	$sCtrlName = __PageCtrlName($sCtrlName)
	Local $iCtrlIdx = __GetPageCtrlIndex($mPage, $sCtrlName)

	If $iCtrlIdx = Null Then
		$iCtrlIdx = _ArrayAdd($mPage.aControls, $idCtrl)
		If @error Then
			__DebugErrorInfo(_SetPageCtrl, $INST_ERR_INVALID_CTRL, 0 , Null)
			Return SetError(@error, @extended, Null)
		EndIf
		$mPage[$sCtrlName] = $iCtrlIdx
	Else
		__ArrayInMapReplace($mPage.aControls, $iCtrlIdx, $idCtrl)
		If @error Then
			__DebugErrorInfo(_SetPageCtrl, $INST_ERR_INVALID_CTRL, 0 , Null)
			Return SetError(@error, @extended, Null)
		EndIf
	EndIf

	Return $iCtrlIdx
EndFunc

; #FUNCTION# ====================================================================================================================
; Returns the control ID registered under $sCtrlName in the page map, or Null if not found.
Func _GetPageCtrl(ByRef $mPage, $sCtrlName)
	Local $iCtrlIdx = __GetPageCtrlIndex($mPage, __PageCtrlName($sCtrlName))
	If $iCtrlIdx = Null Then Return Null
	Return $mPage.aControls[$iCtrlIdx]
EndFunc

;================================================================================================================================
#EndRegion <<< [PAGE CONTROLS]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [EVENTS HANDLER] (OK)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns true if it is a valid array args (with first element set to "CallArgArray")
Func __IsValidArgs(Const ByRef $aArgs)
	If Not IsArray($aArgs) Then Return False
	If Not UBound($aArgs) Then Return False
	If $aArgs[0] <> "CallArgArray" Then Return False
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns True if $aArgs is a valid non-Default array.
; Used to distinguish between "no args" (Default) and an actual valid args array.
Func __HasArgs(Const ByRef $aArgs)
	Return ($aArgs <> Default And __IsValidArgs($aArgs))
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Logs a runtime error to the console (interpreted mode only) when an event handler _
; call fails due to an invalid function or wrong number of parameters.
; $hFuncCaller - the function that attempted to call the handler
; $hHandler    - the handler that failed (function reference or invalid value)
; $aArgs       - the arguments that were passed to the handler
Func __CallFuncDebugErrorInfo($hFuncCaller, $hHandler, $aArgs)
	If IsDeclared("__TFW_TEST_MODE") Then Return
	If Not IsFunc($hFuncCaller) Then Return
	local $sArgs = __HasArgs($aArgs) ? _ArrayToString($aArgs, ", ", 1) : ""
	Local $sHandler = IsFunc($hHandler) ? FuncName($hHandler) : "Invalid Function Handler """ & String($hHandler) & """"
	Local $sErrorMsg = "!RUNTIME ERROR > " & FuncName($hFuncCaller) & ": ## Invalid function, function does not exist, or invalid number of parameters ##" & @CRLF & _
					   "!RUNTIME ERROR > Handler: " & $sHandler & @CRLF & _
					   "!RUNTIME ERROR > Args: (" & $sArgs & ")"
	ConsoleWrite($sErrorMsg & @CRLF)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Calls $hHandler with optional $aArgs and returns its result.
; If the call fails (0xDEAD/0xBEEF error), shows the error info in interpreted mode
; and returns SetError with the same codes.
; Guards against recursive calls by checking the handler is not itself.
Func __RunEventHandler($hHandler, $aArgs = Default)
	Local $vHandlerReturn = Null
    If IsFunc($hHandler) And Not ($hHandler = __RunEventHandler) Then
		$vHandlerReturn = __HasArgs($aArgs) ? Call(FuncName($hHandler), $aArgs) : Call(FuncName($hHandler))
		If @error = 0xDEAD And @extended = 0xBEEF Then
			Local $vError = @error, $vExtended = @extended
			If Not @Compiled Then __CallFuncDebugErrorInfo(__RunEventHandler, $hHandler, $aArgs)
			Return SetError($vError, $vExtended, Null)
		EndIf
    EndIf
	Return $vHandlerReturn
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Fires a named event on an object map if the event key exists and has a valid handler.
; $mObj   - a map containing event keys (e.g. a page map)
; $sEvent - the event name to fire (one of event name/type constants: $ONLOAD, $AFTERLOAD, $ONCLOSE, $ONCLICK)
Func __OnObjEvent(Const ByRef $mObj, $sEvent)
	If Not IsMap($mObj) Then Return Null
	If Not IsMap($mObj[$sEvent]) Then Return Null
	If Not MapExists($mObj[$sEvent], "hHandler") Then Return Null
	Local $aArgs = MapExists($mObj[$sEvent], "aArgs") ? $mObj[$sEvent]["aArgs"] : Default
	Return __RunEventHandler($mObj[$sEvent]["hHandler"], $aArgs)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Fires the OnClick event for a specific button control on a page.
; Does nothing if the page has no button events or the button has no handler registered.
; $mObj  - the current page map
; $idBtn - the control ID of the button that was clicked
Func __OnObjBtnClick(ByRef $mObj, $idBtn)
	If Not IsMap($mObj) Then Return
	If Not IsMap($mObj.mBtnEvents) Then Return
	If Not MapExists($mObj.mBtnEvents, $idBtn) Then Return
	__OnObjEvent($mObj["mBtnEvents"][$idBtn], $OnClick)
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates a CallArgArray-style args array from up to 10 values for use with Call().
; Only includes the arguments actually passed - trailing defaults are excluded.
; Used to build the args array passed to _SetEventHandler().
Func _HandlerArgs($v01 = Default, $v02 = Default, $v03 = Default, $v04 = Default, $v05 = Default, _
                  $v06 = Default, $v07 = Default, $v08 = Default, $v09 = Default, $v10 = Default)
    Local $aAll[11] = ["CallArgArray", $v01, $v02, $v03, $v04, $v05, $v06, $v07, $v08, $v09, $v10]
    Local $aArgs[@NumParams + 1]

    For $i = 0 To @NumParams
        $aArgs[$i] = $aAll[$i]
    Next
    Return $aArgs
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates an event handler map holding a function reference and optional args.
; Returns an empty map if $hHandler is not a valid function.
; $hHandler - function reference to call when the event fires
; $aArgs    - optional args array built with _HandlerArgs()
Func _SetEventHandler($hHandler, $aArgs = Default)
	Local $mEventHandler[]
	If IsFunc($hHandler) Then
		$mEventHandler.hHandler = $hHandler
		If __HasArgs($aArgs) Then $mEventHandler.aArgs = $aArgs
	EndIf
	Return $mEventHandler
EndFunc

; #FUNCTION# ====================================================================================================================
; Registers an OnClick event handler for a specific button control on a page.
; Does nothing if $mPage or $mEventHandler is invalid or has no handler key.
; $idBtnControl  - the control ID of the button to attach the event to
; $mEventHandler - event handler map created with _SetEventHandler()
Func _SetPageBtnOnClickEvent(ByRef $mPage, $idBtnControl, $mEventHandler)
	If Not IsMap($mPage) Then Return Null
	If Not IsMap($mEventHandler) Then Return Null
	If Not MapExists($mEventHandler, "hHandler") Then Return Null

	Local $oEmpty[]
	$mPage["mBtnEvents"][$idBtnControl] = $oEmpty
	$mPage["mBtnEvents"][$idBtnControl].OnClick = $mEventHandler
EndFunc

;================================================================================================================================
#EndRegion <<< [EVENTS HANDLER]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [WIZZARD BUTONS] (OK) (TODO $mCfg validation on _CreateButtons)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Updates the active button caption globals from the wizard config.
; Called once during wizard creation so all button labels reflect the configured captions.
Func __BtnCaptionsUpdate(Const ByRef $mCfg)
	If Not __IsValidInstallerCfg($mCfg) Then Return
	$__g_BTN_CAPTION_NEXT    = $mCfg.sBtnCaptNext
	$__g_BTN_CAPTION_BACK    = $mCfg.sBtnCaptBack
	$__g_BTN_CAPTION_CANCEL  = $mCfg.sBtnCaptCancel
	$__g_BTN_CAPTION_FINISH  = $mCfg.sBtnCaptFinish
	$__g_BTN_CAPTION_APPLY   = $mCfg.sBtnCaptApply
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the control ID of the requested button from the wizard buttons map.
; $sButton - one of the $BTN_* constants
; Returns 0 if the wizard is invalid or the button key is not recognized.
Func __GetButton(Const ByRef $mWizard, $sButton)
	If Not __IsValidWizard($mWizard) Then Return 0

	Switch $sButton
		Case $BTN_CANCEL
			Return $mWizard["mButtons"]["idBtnCancel"]
		Case $BTN_BACK
			Return $mWizard["mButtons"]["idBtnBack"]
		Case $BTN_NEXT
			Return $mWizard["mButtons"]["idBtnNext"]
		Case Else
			Return 0
	EndSwitch
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the Cancel button control ID from the wizard map, or 0 if invalid.
Func __GetBtnCancel(Const ByRef $mWizard)
	Return __GetButton($mWizard, $BTN_CANCEL)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the Back button control ID from the wizard map, or 0 if invalid.
Func __GetBtnBack(Const ByRef $mWizard)
	Return __GetButton($mWizard, $BTN_BACK)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the Next button control ID from the wizard map, or 0 if invalid.
Func __GetBtnNext(Const ByRef $mWizard)
	Return __GetButton($mWizard, $BTN_NEXT)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Sets button states and captions based on the current page position and installer event.
; The event takes priority over page position for special states (processing, finish, etc.).
; $iPagePosition - one of the $e*Page position constants
; $mButtons      - the wizard buttons map containing idBtnCancel, idBtnBack, idBtnNext
; $iEvent        - current installer event (default: reads from _GetInstallerEvent())
Func __SetButtons($iPagePosition, ByRef $mButtons, $iEvent = _GetInstallerEvent())
	If Not IsMap($mButtons) Then Return

	Switch $iEvent
		Case $eOnReadyToProceed
			_Tstbl_GUICtrlSetData($mButtons.idBtnNext, $__g_BTN_CAPTION_APPLY)
		Case $eOnProcessing
			_Tstbl_GUICtrlSetState($mButtons.idBtnCancel, $GUI_DISABLE)
			_Tstbl_GUICtrlSetState($mButtons.idBtnBack,   $GUI_DISABLE)
			_Tstbl_GUICtrlSetState($mButtons.idBtnNext,   $GUI_DISABLE)
			Return
		Case $eOnFinish
			_Tstbl_GUICtrlSetData($mButtons.idBtnNext, $__g_BTN_CAPTION_FINISH)
			_Tstbl_GUICtrlSetState($mButtons.idBtnCancel, $GUI_DISABLE)
			_Tstbl_GUICtrlSetState($mButtons.idBtnBack,   $GUI_DISABLE)
			_Tstbl_GUICtrlSetState($mButtons.idBtnNext,   $GUI_ENABLE)
			Return
		Case Else
			_Tstbl_GUICtrlSetData($mButtons.idBtnNext, $__g_BTN_CAPTION_NEXT)
	EndSwitch

	Switch $iPagePosition
		Case $eSinglePage
			_Tstbl_GUICtrlSetState($mButtons.idBtnCancel, $GUI_ENABLE)
			_Tstbl_GUICtrlSetState($mButtons.idBtnBack,   $GUI_DISABLE)
            _Tstbl_GUICtrlSetState($mButtons.idBtnNext,   $GUI_ENABLE)
			_Tstbl_GUICtrlSetData($mButtons.idBtnNext, 	  $__g_BTN_CAPTION_FINISH)
		Case $eFirstPage
			_Tstbl_GUICtrlSetState($mButtons.idBtnCancel, $GUI_ENABLE)
			_Tstbl_GUICtrlSetState($mButtons.idBtnBack,   $GUI_DISABLE)
            _Tstbl_GUICtrlSetState($mButtons.idBtnNext,   $GUI_ENABLE)
		Case $eMidPage
			_Tstbl_GUICtrlSetState($mButtons.idBtnCancel, $GUI_ENABLE)
			_Tstbl_GUICtrlSetState($mButtons.idBtnBack,   $GUI_ENABLE)
            _Tstbl_GUICtrlSetState($mButtons.idBtnNext,   $GUI_ENABLE)
		Case $eLastPage
			_Tstbl_GUICtrlSetState($mButtons.idBtnCancel, $GUI_ENABLE)
			_Tstbl_GUICtrlSetState($mButtons.idBtnBack,   $GUI_ENABLE)
            _Tstbl_GUICtrlSetState($mButtons.idBtnNext,   $GUI_DISABLE)
		Case Else
			_Tstbl_GUICtrlSetState($mButtons.idBtnCancel, $GUI_DISABLE)
			_Tstbl_GUICtrlSetState($mButtons.idBtnBack,   $GUI_DISABLE)
			_Tstbl_GUICtrlSetState($mButtons.idBtnNext,   $GUI_DISABLE)
	EndSwitch
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates the three main buttons (Cancel, Back, Next) on $hGUI and returns a buttons map _
; with keys: idBtnCancel, idBtnBack, idBtnNext.
; Returns Null and SetError($INST_ERR_INVALID_GUI) if the window handle is invalid.
; $hGUI - the wizard window handle
; $mCfg - the installer config map (provides dimensions, Y position and captions)
Func _CreateButtons($hGUI, Const ByRef $mCfg)
	If Not _Tstbl_IsHWnd($hGUI) Then
		__DebugErrorInfo(_CreateButtons, $INST_ERR_INVALID_GUI, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	_Tstbl_GUISwitch($hGUI)

	Local $mButtons[]

    Local $iTotalBtnW  = (3 * $mCfg.iBtnWidth) + (2 * $mCfg.iBtnGap)
    Local $iBtnStartX  = ($mCfg.iWndWidth - $iTotalBtnW) / 2
	Local $iBtnBackLeft = $iBtnStartX + $mCfg.iBtnWidth + $mCfg.iBtnGap
	Local $iBtnNextLeft = $iBtnStartX + 2 * ($mCfg.iBtnWidth + $mCfg.iBtnGap)

    Local $idBtnCancel = _Tstbl_GUICtrlCreateButton($mCfg.sBtnCaptCancel, $iBtnStartX, $mCfg.iBtnY, $mCfg.iBtnWidth, $mCfg.iBtnHeight)
    Local $idBtnBack   = _Tstbl_GUICtrlCreateButton($mCfg.sBtnCaptBack, $iBtnBackLeft, $mCfg.iBtnY, $mCfg.iBtnWidth, $mCfg.iBtnHeight)
    Local $idBtnNext   = _Tstbl_GUICtrlCreateButton($mCfg.sBtnCaptNext, $iBtnNextLeft, $mCfg.iBtnY, $mCfg.iBtnWidth, $mCfg.iBtnHeight)
    _Tstbl_GUICtrlSetFont($idBtnCancel, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
    _Tstbl_GUICtrlSetFont($idBtnBack,   $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
    _Tstbl_GUICtrlSetFont($idBtnNext,   $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)

	$mButtons[$BTN_CANCEL] = $idBtnCancel
	$mButtons[$BTN_BACK]   = $idBtnBack
	$mButtons[$BTN_NEXT]   = $idBtnNext

	Return $mButtons
EndFunc

;================================================================================================================================
#EndRegion <<< [WIZZARD BUTONS]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [PAGE OPERATIONS] (OK)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Hides all controls in a page's controls array or a plain controls array.
Func __HidePage(ByRef $aPage)
	If Not IsArray($aPage) And Not IsMap($aPage) Then Return
    For $idCtrl In $aPage
        _Tstbl_GUICtrlSetState($idCtrl, $GUI_HIDE)
    Next
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Hides all controls across all pages in the pages map.
Func __HidePages(ByRef $mPages)
	If Not IsMap($mPages) Then Return
    For $mPage In $mPages
		__HidePage($mPage.aControls)
    Next
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Shows all controls in a page's controls array.
Func __ShowPageControls(ByRef $mPage)
	If Not IsMap($mPage) Then Return
	If Not IsMap($mPage.aControls) And Not IsArray($mPage.aControls) Then Return
    For $idCtrl In $mPage.aControls
        _Tstbl_GUICtrlSetState($idCtrl, $GUI_SHOW)
    Next
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Sets the header subtitle text for the current page.
Func __SetPageSubHeader($idHeaderSub, $sSubheading)
	_Tstbl_GUICtrlSetData($idHeaderSub, $sSubheading)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Loads a page   - fires OnLoad, sets the subheader, shows controls, updates buttons, fires AfterLoad.
; $mPage         - the page map to load
; $mButtons      - the wizard buttons map
; $idHeaderSub   - the header subtitle control ID
; $iPagePosition - position of this page within the wizard (one of the $e*Page constants)
Func __PageLoad(ByRef $mPage, ByRef $mButtons, $idHeaderSub, $iPagePosition)
	If Not IsMap($mPage) Then Return
	If Not __IsValidPagePosition($iPagePosition) Then Return

	Local $sSubheading = MapExists($mPage, "sSubheading") ? $mPage.sSubheading : ""

	_SetInstallerEvent(__GetPageStatus($mPage))
	__OnObjEvent($mPage, $OnLoad)
	__SetPageSubHeader($idHeaderSub, $sSubheading)
	__ShowPageControls($mPage)
	__SetButtons($iPagePosition, $mButtons)
	__OnObjEvent($mPage, $AfterLoad)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Fires the OnClose event for the page at $iPage index, if one is registered.
Func __ClosePage($iPage, ByRef $mPages)
	If Not IsMap($mPages) Then Return
	__OnObjEvent(__GetPage($mPages, $iPage), $OnClose)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Hides all pages, then loads the page at $iPage - setting subheader, controls and buttons.
Func __SetPage($iPage, $idHeaderSub, ByRef $mPages, ByRef $mButtons)
	Local $iPagePosition = __GetPagePosition($iPage, __MaxPages($mPages))
	__HidePages($mPages)
	__PageLoad(__GetPage($mPages, $iPage), $mButtons, $idHeaderSub, $iPagePosition)
EndFunc

;================================================================================================================================
#EndRegion <<< [PAGE OPERATIONS]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [PAGE NAVIGATION] (OK)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the next page index if the current position allows forward navigation,
; otherwise returns the current page unchanged.
Func __NextPage($iPage, $iPagePos)
	Return ($iPagePos > $eSinglePage And $iPagePos < $eLastPage) ? $iPage + 1 : $iPage
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the previous page index if the current position allows backward navigation,
; otherwise returns the current page unchanged.
Func __BackPage($iPage, $iPagePos)
	Return $iPagePos > $eFirstPage ? $iPage - 1 : $iPage
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns the new page index after moving in $iDirection from the current position.
; $iDirection - $ePageNext, $ePageBack, or $ePageStay. Values outside that range are treated as $ePageStay.
Func __PageMove($iPage, $iPagePosition, $iDirection)

	; Page direction should be +1 or -1, otherwise it is 0
	$iDirection = (Abs($iDirection) > 1) ? $ePageStay : Int($iDirection)

	If $iDirection = $ePageBack Then
		Return __BackPage($iPage, $iPagePosition)
	ElseIf  $iDirection = $ePageNext Then
		Return __NextPage($iPage, $iPagePosition)
	Else
		Return $iPage
	EndIf
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Moves the wizard to the next or previous page and updates the display.
; If the current page event is $EVENT_CLOSE_PAGE, triggers OnClose and returns $EXIT_WIZARD_SIGNAL.
; $mWizard    - the wizard map (iPage is updated in place)
; $iDirection - $ePageNext, $ePageBack, or $ePageStay
Func __NavPage(ByRef $mWizard, $iDirection = $ePageStay)
	If Not IsMap($mWizard) Then Return Null

	Local $iPage = MapExists($mWizard, "iPage") ? $mWizard.iPage : 0
	Local $iPagePosition = __GetPagePosition($iPage, __MaxPages($mWizard.mPages))

	If Not __IsValidPagePosition($iPagePosition) Then Return $iPage

	$iPage = __PageMove($iPage, $iPagePosition, $iDirection)
	$mWizard.iPage = $iPage

	If _GetInstallerEvent() = $EVENT_CLOSE_PAGE Then
		__ClosePage($mWizard.iPage, $mWizard.mPages)
		Return $EXIT_WIZARD_SIGNAL
	Else
		__SetPage($mWizard.iPage, $mWizard.mHeader.idSubheading, $mWizard.mPages, $mWizard.mButtons)
		Return $iPage
	EndIf
EndFunc

;================================================================================================================================
#EndRegion <<< [PAGE NAVIGATION]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [PROGRESSBAR] (OK) (TODO _Tstbl_Sleep)
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Updates the progress bar and status label for a single installer step.
; Calculates the percentage from $iStep/$iSteps and applies a short delay before and _
; after updating so the progress is visible to the user.
; $idLabel    - the status label control ID
; $idProgress - the progress bar control ID
; $iStep      - the current step number (0-based)
; $iSteps     - the total number of steps
; $sStatus    - the status message to display
Func _ProgressStep($idLabel, $idProgress, $iStep, $iSteps, $sStatus)
	Local $iProgress = Int(($iStep / $iSteps) * 100)
	Local $iDelay = $iProgress >= 100 ? 500 : 250
	If IsDeclared("__TFW_TEST_MODE") Then $iDelay = 0

	Sleep($iDelay)
	_Tstbl_GUICtrlSetData($idProgress, $iProgress)
	Sleep($iDelay)

	_Tstbl_GUICtrlSetData($idLabel, $sStatus)
EndFunc

;================================================================================================================================
#EndRegion <<< [PROGRESSBAR]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [PAGE TEMPLATE EVENTS HANDLERS] (OK)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Calls $hFuncHandler with no arguments and returns the string result.
; Used by the ready page OnLoad event to retrieve dynamic info text.
; Returns an empty string and SetError(0xDEAD, 0xBEEF) if the handler is invalid _
; or does not return a string.
; Guards against recursive calls by checking the handler is not itself.
Func __RunUpdateInfoFunc($hFuncHandler)
	Local $vText = Null

	If IsFunc($hFuncHandler) And Not ($hFuncHandler = __RunUpdateInfoFunc) Then
		$vText = Call($hFuncHandler)
		If @error = 0xDEAD And @extended = 0xBEEF Then
			Local $vError = @error, $vExtended = @extended
			If Not @Compiled Then __CallFuncDebugErrorInfo(__RunUpdateInfoFunc, $hFuncHandler, Default)
			Return SetError($vError, $vExtended, "")
		EndIf
	EndIf

	If Not IsString($vText) Then
		If Not @Compiled Then __CallFuncDebugErrorInfo(__RunUpdateInfoFunc, $hFuncHandler, Default)
		Return SetError(0xDEAD, 0xBEEF, "")
	EndIf

	Return String($vText)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Calls $hFuncHandler with $idLblProgress and $idProgressbar as arguments.
; Used by the progress page AfterLoad event to run the install/uninstall process.
; Returns False and SetError(0xDEAD, 0xBEEF) if the handler is invalid or call fails.
; Guards against recursive calls by checking the handler is not itself.
; $idLblProgress - the progress label control ID passed to the handler
; $idProgressbar - the progress bar control ID passed to the handler
Func __RunApplyFunc($hFuncHandler, $idLblProgress, $idProgressbar)
	Local $bReturn = False
	Local $aArgs   = _HandlerArgs("$idLblProgress", "$idProgressbar")	; used only for debug info
	If IsFunc($hFuncHandler) And Not ($hFuncHandler = __RunApplyFunc) Then
		$bReturn = Call($hFuncHandler, $idLblProgress, $idProgressbar)
		If @error = 0xDEAD And @extended = 0xBEEF Then
			Local $vError = @error, $vExtended = @extended
			If Not @Compiled Then __CallFuncDebugErrorInfo(__RunApplyFunc, $hFuncHandler, $aArgs)
			Return SetError($vError, $vExtended, False)
		EndIf
	Else
		If Not @Compiled Then __CallFuncDebugErrorInfo(__RunApplyFunc, $hFuncHandler, $aArgs)
		Return SetError(0xDEAD, 0xBEEF, False)
	EndIf
	Return $bReturn
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Calls $hFuncHandler with $idInputPath as argument.
; Used by the path page browse button OnClick event to update the source path global _
; after the user selects a folder.
; Returns False and SetError(0xDEAD, 0xBEEF) if the handler is invalid or call fails.
; Guards against recursive calls by checking the handler is not itself.
; $idInputPath - the input control ID containing the current path, passed to the handler
Func __RunUpdateSrcFunc($hFuncHandler, $idInputPath)
	Local $aArgs = _HandlerArgs("$idInputPath")		; used only for debug info
	If IsFunc($hFuncHandler) And Not ($hFuncHandler = __RunUpdateSrcFunc) Then
		Call($hFuncHandler, $idInputPath)
		If @error = 0xDEAD And @extended = 0xBEEF Then
			Local $vError = @error, $vExtended = @extended
			If Not @Compiled Then __CallFuncDebugErrorInfo(__RunUpdateSrcFunc, $hFuncHandler, $aArgs)
			Return SetError($vError, $vExtended, False)
		EndIf
	Else
		If Not @Compiled Then __CallFuncDebugErrorInfo(__RunUpdateSrcFunc, $hFuncHandler, $aArgs)
		Return SetError(0xDEAD, 0xBEEF, False)
	EndIf
	Return True
EndFunc

;================================================================================================================================
#EndRegion <<< [PAGE TEMPLATE EVENTS HANDLERS]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [ON PAGE TEMPLATE EVENTS] (OK) (TODO check _Tstbl_ShellExecute on _OnClose_FinishPage)
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; OnLoad handler for the ready page - calls $hUpdateInfoFunc() and sets the result _
; as the text of $idLblInfo. Does nothing if $hUpdateInfoFunc is Default.
; $idLblInfo       - the info label control ID to update
; $hUpdateInfoFunc - function that returns the ready page info text
Func _OnLoad_ReadyPage($idLblInfo, $hUpdateInfoFunc)
	If $hUpdateInfoFunc = Default Then Return
	Local $sText = __RunUpdateInfoFunc($hUpdateInfoFunc)
	_Tstbl_GUICtrlSetData($idLblInfo, $sText)
EndFunc

; #FUNCTION# ====================================================================================================================
; AfterLoad handler for the progress page - runs the install/uninstall process via $hFunction.
; If the process fails, shows an error MsgBox and sets the event to $EVENT_CLOSE_PAGE _
; so the wizard exits on the next navigation. On success or failure, triggers a _
; programmatic Next button click via BM_CLICK to advance the wizard automatically.
; $hWin            - the wizard window handle, used as MsgBox parent
; $idLblProgress   - the progress label control ID passed to the process function
; $idProgressbar   - the progress bar control ID passed to the process function
; $idBtnNext       - the Next button control ID used to advance the wizard automatically
; $hFunction       - the install/uninstall function to run
; $sInstallerTitle - the wizard title used in the error MsgBox
; $sFailureMsg     - the error message shown when the process fails
Func _AfterLoad_ProgressPage($hWin, $idLblProgress, $idProgressbar, $idBtnNext, $hFunction, $sInstallerTitle, $sFailureMsg)
	If Not __RunApplyFunc($hFunction, $idLblProgress, $idProgressbar) Then
		_Tstbl_MsgBox($MB_OK + $MB_ICONERROR, $sInstallerTitle, $sFailureMsg, 0, $hWin)
		_SetInstallerEvent($EVENT_CLOSE_PAGE)
	EndIf
	_Tstbl_GUICtrlSetState($idBtnNext, $GUI_ENABLE)
	_Tstbl_GUICtrlSendMsg($idBtnNext, $BM_CLICK, 0, 0)
EndFunc

; #FUNCTION# ====================================================================================================================
; AfterLoad handler for the finish page - sets the event to $EVENT_CLOSE_PAGE
; so the wizard exits when the user clicks Next/Finish.
Func _AfterLoad_FinishPage()
	_SetInstallerEvent($EVENT_CLOSE_PAGE)
EndFunc

; #FUNCTION# ====================================================================================================================
; OnClose handler for the finish page - opens the documentation file if the
; "Open documentation" checkbox is checked.
; $idChkBoxOpenDoc - the checkbox control ID
; $sDocFile        - the path to the documentation file to open
Func _OnClose_FinishPage($idChkBoxOpenDoc, $sDocFile)
	If _Tstbl_GUICtrlRead($idChkBoxOpenDoc) = $GUI_CHECKED Then
		_Tstbl_ShellExecute($sDocFile)
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; OnClick handler for the Browse button on the path page - opens a folder selection _
; dialog and updates the path input and source path global when a folder is selected.
; $idInputPath    - the input control ID to update with the selected folder
; $sPathLabel     - the label text used as the folder selector dialog title
; $hUpdateSrcFunc - optional function called after the path input is updated
Func _OnClick_SetFolder($idInputPath, $sPathLabel, $hUpdateSrcFunc)
	Local $sLbLFileSelector = "Select " & String($sPathLabel)
	Local $sFolder = _Tstbl_FileSelectFolder($sLbLFileSelector, _Tstbl_GUICtrlRead($idInputPath))
	If Not @error Then
		_Tstbl_GUICtrlSetData($idInputPath, $sFolder)
		__RunUpdateSrcFunc($hUpdateSrcFunc, $idInputPath)
	EndIf
EndFunc

;================================================================================================================================
#EndRegion <<< [ON PAGE TEMPLATE EVENTS]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [PAGE TEMPLATES] (OK)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Validates the common arguments required by all page template functions.
; Returns $INST_ERR_INVALID_GUI if $hGUI is not a valid window handle,
; $INST_ERR_INVALID_CFG if $mCfg is not a valid installer config,
; or 0 if both are valid.
Func __ValidateTemplateArgs($hGUI, Const ByRef $mCfg)
	Return Not _Tstbl_IsHWnd($hGUI) ? $INST_ERR_INVALID_GUI : _
		   Not __IsValidInstallerCfg($mCfg) ? $INST_ERR_INVALID_CFG : 0
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Builds the intro/welcome page controls on $hGUI and configures $mPage.
; Creates a label for the intro text and a version label at the bottom.
; $hGUI        - the wizard window handle
; $mPage       - the page map to configure (modified in place)
; $mCfg        - the installer config map
; $sIntroText  - the welcome text shown on the page
; $sSubHeading - the header subtitle shown when this page is active
; $sVersion    - the version string shown at the bottom of the page
Func __SetIntroPage($hGUI, ByRef $mPage, Const ByRef $mCfg, $sIntroText = "", $sSubHeading = "", $sVersion = $DEFAULT_VERSION)

	; Validation
	Local $iErr = __ValidateTemplateArgs($hGUI, $mCfg)
	If $iErr Then
		__DebugErrorInfo(__SetIntroPage, $iErr, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	_Tstbl_GUISwitch($hGUI)

	Local $iPaddingLeft = 15

	Local $iLblIntroHeight = $mCfg.iFooterSepY - $mCfg.iContentTop - 30

	Local $iLblVersionTop = $mCfg.iFooterSepY - 25
	Local $iLblVersionWidth = 200
	Local $iLblVersionHeight = 20

	Local $idLblIntro = _Tstbl_GUICtrlCreateLabel($sIntroText, $iPaddingLeft, $mCfg.iContentTop, $mCfg.iContentWidth, $iLblIntroHeight)
    _Tstbl_GUICtrlSetFont($idLblIntro, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
    _Tstbl_GUICtrlSetBkColor($idLblIntro, $GUI_BKCOLOR_TRANSPARENT)

	$sVersion = $sVersion <> "" ? "Version " & $sVersion : $sVersion
	Local $idLblVersion = _Tstbl_GUICtrlCreateLabel($sVersion, $iPaddingLeft, $iLblVersionTop, $iLblVersionWidth, $iLblVersionHeight)
    _Tstbl_GUICtrlSetFont($idLblVersion, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
    _Tstbl_GUICtrlSetColor($idLblVersion, 0x888888)
    _Tstbl_GUICtrlSetBkColor($idLblVersion, $GUI_BKCOLOR_TRANSPARENT)

	_SetPageCtrl($mPage, $idLblIntro, 	"LblIntro")
	_SetPageCtrl($mPage, $idLblVersion, "LblVersion")

	$mPage.iStatus     = $eNormalPage
	$mPage.sSubheading = $sSubHeading
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Builds the path selection page controls on $hGUI and configures $mPage.
; Creates an info label, a path label, a folder input, and a Browse button.
; Registers an OnClick handler on the Browse button via _OnClick_SetFolder.
; $hGUI            - the wizard window handle
; $mPage           - the page map to configure (modified in place)
; $mCfg            - the installer config map
; $sPath           - the initial path shown in the folder input
; $hUpdateSrcFunc  - called after the path input is updated via Browse
; $sPathLabel      - the label text above the folder input
; $sPathPageInfo   - the descriptive text shown at the top of the page
; $sSubHeading     - the header subtitle shown when this page is active
Func __SetPathPage($hGUI, ByRef $mPage, Const ByRef $mCfg, $sPath, $hUpdateSrcFunc, $sPathLabel = "Install folder:", $sPathPageInfo = "", $sSubHeading = "")

	; Validation
	Local $iErr = __ValidateTemplateArgs($hGUI, $mCfg)
	If $iErr Then
		__DebugErrorInfo(__SetPathPage, $iErr, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	_Tstbl_GUISwitch($hGUI)

	Local $iPaddingLeft = 15

	Local $iLblPathPageInfoHeight = 90

	Local $iLblPathTop = $mCfg.iContentTop + 105
	Local $iLblPathWidth = 200
	Local $iLblPathHeight = 22

	Local $iInputPathTop = $mCfg.iContentTop + 128
	Local $iInputPathWidth = $mCfg.iWndWidth - 115
	Local $iInputPathHeight = 28

	Local $iBtnBrowseLeft = $iPaddingLeft + $iInputPathWidth + 5
	Local $iBtnBrowseTop = $mCfg.iContentTop + 127
	Local $iBtnBrowseWidth = 80
	Local $iBtnBrowseHeight = 30

	Local $idLblPathPageInfo = _Tstbl_GUICtrlCreateLabel($sPathPageInfo, $iPaddingLeft, $mCfg.iContentTop, $mCfg.iContentWidth, $iLblPathPageInfoHeight)
    _Tstbl_GUICtrlSetFont($idLblPathPageInfo, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
    _Tstbl_GUICtrlSetBkColor($idLblPathPageInfo, $GUI_BKCOLOR_TRANSPARENT)

	Local $idLblPath = _Tstbl_GUICtrlCreateLabel($sPathLabel, $iPaddingLeft, $iLblPathTop, $iLblPathWidth, $iLblPathHeight)
    _Tstbl_GUICtrlSetFont($idLblPath, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
    _Tstbl_GUICtrlSetBkColor($idLblPath, $GUI_BKCOLOR_TRANSPARENT)

	Local $idInputPath = _Tstbl_GUICtrlCreateInput($sPath, $iPaddingLeft, $iInputPathTop, $iInputPathWidth, $iInputPathHeight)
    _Tstbl_GUICtrlSetFont($idInputPath, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)

	Local $idBtnBrowse = _Tstbl_GUICtrlCreateButton("Browse...", $iBtnBrowseLeft, $iBtnBrowseTop, $iBtnBrowseWidth, $iBtnBrowseHeight)
    _Tstbl_GUICtrlSetFont($idBtnBrowse, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)

	Local $aArgs = _HandlerArgs($idInputPath, $sPathLabel, $hUpdateSrcFunc)
	_SetPageBtnOnClickEvent($mPage, $idBtnBrowse, _SetEventHandler(_OnClick_SetFolder, $aArgs))

	_SetPageCtrl($mPage, $idLblPathPageInfo, "LblPathPageInfo")
	_SetPageCtrl($mPage, $idLblPath, 		 "LblPath")
	_SetPageCtrl($mPage, $idInputPath, 		 "InputPath")
	_SetPageCtrl($mPage, $idBtnBrowse, 		 "BtnBrowse")

	$mPage.iStatus     = $eNormalPage
	$mPage.sSubheading = $sSubHeading
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Builds the ready/confirm page controls on $hGUI and configures $mPage.
; Creates a caption label and an info label updated dynamically via $hUpdateInfoFunc on load.
; Sets the page status to $eProceedPage so the Apply button caption is shown.
; $hGUI            - the wizard window handle
; $mPage           - the page map to configure (modified in place)
; $mCfg            - the installer config map
; $sReadyInfo      - static info text (used when $hUpdateInfoFunc is Default)
; $sSubHeading     - the header subtitle shown when this page is active
; $hUpdateInfoFunc - optional function that returns dynamic info text on page load
Func __SetReadyPage($hGUI, ByRef $mPage, Const ByRef $mCfg, $sReadyInfo = "", $sSubHeading = "", $hUpdateInfoFunc = Default)

	; Validation
	Local $iErr = __ValidateTemplateArgs($hGUI, $mCfg)
	If $iErr Then
		__DebugErrorInfo(__SetReadyPage, $iErr, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	_Tstbl_GUISwitch($hGUI)

	Local $iPaddingLeft = 10

	Local $iLblCaptionWidth = $mCfg.iWndWidth - 20
	Local $iLblCaptionHeight = 22

	Local $iLblInfoTop = $mCfg.iContentTop + 30
	Local $iLblInfoWidth = $mCfg.iWndWidth - 20
	Local $iLblInfoHeight = $mCfg.iFooterSepY - $mCfg.iContentTop - 40

	Local $iLblInfoFontSize = 10

	Local Const $__LBL_CAPTION = "The following actions will be performed:"
	Local $idLblCaption = _Tstbl_GUICtrlCreateLabel($__LBL_CAPTION, $iPaddingLeft, $mCfg.iContentTop, $iLblCaptionWidth, $iLblCaptionHeight)
    _Tstbl_GUICtrlSetFont($idLblCaption, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
    _Tstbl_GUICtrlSetBkColor($idLblCaption, $GUI_BKCOLOR_TRANSPARENT)

	Local $idLblInfo = _Tstbl_GUICtrlCreateLabel($sReadyInfo, $iPaddingLeft, $iLblInfoTop, $iLblInfoWidth, $iLblInfoHeight)
    _Tstbl_GUICtrlSetFont($idLblInfo, $iLblInfoFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
    _Tstbl_GUICtrlSetBkColor($idLblInfo, $GUI_BKCOLOR_TRANSPARENT)

	_SetPageCtrl($mPage, $idLblCaption, "LblCaption")
	_SetPageCtrl($mPage, $idLblInfo, 	"LblInfo")

	$mPage.iStatus     = $eProceedPage
	$mPage.sSubheading = $sSubHeading
	$mPage.OnLoad 	   = _SetEventHandler(_OnLoad_ReadyPage, _HandlerArgs($idLblInfo, $hUpdateInfoFunc))
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Builds the progress page controls on $hGUI and configures $mPage.
; Creates a status label and a progress bar. Registers an AfterLoad handler that _
; runs $hFunction automatically when the page loads and advances to the next page _
; via a programmatic Next button click on completion.
; $hGUI            - the wizard window handle (which is also passed to the AfterLoad handler)
; $mPage           - the page map to configure (modified in place)
; $mCfg            - the installer config map
; $idBtnNext       - the Next button control ID used to advance the wizard automatically
; $hFunction       - the install/uninstall function to run (receives $idLblProgress, $idProgressbar)
; $sInstallerTitle - the wizard title used in the failure MsgBox
; $sFailureMsg     - the error message shown when $hFunction returns False
; $sSubHeading     - the header subtitle shown when this page is active
Func __SetProgressPage($hGUI, ByRef $mPage, Const ByRef $mCfg, $idBtnNext, $hFunction, $sInstallerTitle = "Installer", $sFailureMsg = "Process failed", $sSubHeading = "")

	; Validation
	Local $iErr = __ValidateTemplateArgs($hGUI, $mCfg)
	If $iErr Then
		__DebugErrorInfo(__SetProgressPage, $iErr, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	_Tstbl_GUISwitch($hGUI)

	Local $iPaddingLeft = 15
	Local $iPaddingHeight = 24
	Local $iProgressbarTop = $mCfg.iContentTop + 32

	Local $idLblProgress = _Tstbl_GUICtrlCreateLabel("", $iPaddingLeft, $mCfg.iContentTop, $mCfg.iContentWidth, $iPaddingHeight)
    _Tstbl_GUICtrlSetFont($idLblProgress, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
    _Tstbl_GUICtrlSetBkColor($idLblProgress, $GUI_BKCOLOR_TRANSPARENT)

	Local $idProgressbar = _Tstbl_GUICtrlCreateProgress($iPaddingLeft, $iProgressbarTop, $mCfg.iContentWidth, $iPaddingHeight)

	_SetPageCtrl($mPage, $idLblProgress, "LblProgress")
	_SetPageCtrl($mPage, $idProgressbar, "Progressbar")

	$mPage.iStatus     = $eProcessingPage
	$mPage.sSubheading = $sSubHeading

	Local $aArgs 	   = _HandlerArgs($hGUI, $idLblProgress, $idProgressbar, $idBtnNext, $hFunction, $sInstallerTitle, $sFailureMsg)
	$mPage.AfterLoad   = _SetEventHandler(_AfterLoad_ProgressPage, $aArgs)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Builds the finish page controls on $hGUI and configures $mPage.
; Reuses the progress label and progress bar from the progress page.
; Optionally adds an "Open documentation" checkbox when $sDocFile is provided.
; Registers an AfterLoad handler that sets $EVENT_CLOSE_PAGE so the wizard _
; exits when the user clicks Finish.
; $hGUI          - the wizard window handle
; $mPage         - the page map to configure (modified in place)
; $mCfg          - the installer config map
; $idLblProgress - the progress label control ID from the progress page
; $idProgressbar - the progress bar control ID from the progress page
; $sFinishMsg    - the completion message shown on the page
; $sDocFile      - optional path to a documentation file; when provided adds the open docs checkbox
; $sSubHeading   - the header subtitle shown when this page is active
Func __SetFinishPage($hGUI, ByRef $mPage, Const ByRef $mCfg, $idLblProgress, $idProgressbar, $sFinishMsg = "", $sDocFile = Default, $sSubHeading = "")

	; Validation
	Local $iErr = __ValidateTemplateArgs($hGUI, $mCfg)
	If $iErr Then
		__DebugErrorInfo(__SetFinishPage, $iErr, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	_Tstbl_GUISwitch($hGUI)

	Local $iPaddingLeft = 15

	Local $iLblFinishMsgTop = $mCfg.iContentTop + 70
	Local $iLblFinishMsgHeight = $mCfg.iFooterSepY - ($mCfg.iContentTop + 70) - 40

	Local $iChkBoxOpenDocTop = $mCfg.iFooterSepY - 32
	Local $iChkBoxOpenDocWidth = 220
	Local $iChkBoxOpenDocHeight = 24

	Local $idLblFinishMsg = _Tstbl_GUICtrlCreateLabel($sFinishMsg, $iPaddingLeft, $iLblFinishMsgTop, $mCfg.iContentWidth, $iLblFinishMsgHeight)
	_Tstbl_GUICtrlSetFont($idLblFinishMsg, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
	_Tstbl_GUICtrlSetBkColor($idLblFinishMsg, $GUI_BKCOLOR_TRANSPARENT)

	If $sDocFile <> Default Then
		Local Const $__OPEN_DOC = "Open documentation"
		Local $idChkBoxOpenDoc = _Tstbl_GUICtrlCreateCheckbox($__OPEN_DOC, $iPaddingLeft, $iChkBoxOpenDocTop, $iChkBoxOpenDocWidth, $iChkBoxOpenDocHeight)
		_Tstbl_GUICtrlSetFont($idChkBoxOpenDoc, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
		_Tstbl_GUICtrlSetBkColor($idChkBoxOpenDoc, $GUI_BKCOLOR_TRANSPARENT)
	EndIf

	_SetPageCtrl($mPage, $idLblProgress,   "LblProgress")
	_SetPageCtrl($mPage, $idProgressbar,   "Progressbar")
	_SetPageCtrl($mPage, $idLblFinishMsg,  "LblFinishMsg")
	If $sDocFile <> Default Then _SetPageCtrl($mPage, $idChkBoxOpenDoc, "ChkBoxOpenDoc")

	$mPage.iStatus = $eFinishPage
	$mPage.sSubheading = $sSubHeading

	$mPage.AfterLoad = _SetEventHandler(_AfterLoad_FinishPage)
	If $sDocFile <> Default Then $mPage.OnClose = _SetEventHandler(_OnClose_FinishPage, _HandlerArgs($idChkBoxOpenDoc, $sDocFile))
EndFunc

;================================================================================================================================
#EndRegion <<< [PAGE TEMPLATES]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [HELPERS TO ADD PAGE TEMPLATES TO WIZARD] (OK)
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Creates an intro page, adds it to the wizard and returns its page index.
; Stores the page index in $mWizard.iIntroPageId for later reference.
; Returns 0 and SetError($INST_ERR_INVALID_WIZARD) if the wizard is invalid.
; $mWizard          - the wizard map (modified in place)
; $mCfg             - the installer config map
; $sIntroText       - the welcome text shown on the page
; $sIntroSubHeading - the header subtitle shown when this page is active
; $sIntroVersion    - the version string shown at the bottom of the page
Func _AddIntroPage(ByRef $mWizard, Const ByRef $mCfg, $sIntroText = "", $sIntroSubHeading = "", $sIntroVersion = $DEFAULT_VERSION)
	If Not __IsValidWizard($mWizard) Then
		__DebugErrorInfo(_AddIntroPage, $INST_ERR_INVALID_WIZARD, 0 , 0)
		Return SetError(@error, @extended, 0)
	EndIf

	Local $mIntroPage = _NewPage()

	__SetIntroPage($mWizard.hWin, $mIntroPage, $mCfg, $sIntroText, $sIntroSubHeading, $sIntroVersion)
	If @error Then Return SetError(@error, 0, 0)

	Local $iIntroPageId = _AddPage($mWizard.mPages, $mIntroPage)
	$mWizard.iIntroPageId = $iIntroPageId
	Return $iIntroPageId
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates a path page, adds it to the wizard and returns its page index.
; Stores the page index in $mWizard.iPathPageId for later reference.
; Returns 0 and SetError($INST_ERR_INVALID_WIZARD) if the wizard is invalid.
; $mWizard         - the wizard map (modified in place)
; $mCfg            - the installer config map
; $sPath           - the initial path shown in the folder input
; $hUpdateSrcFunc  - called after the path input is updated via Browse
; $sPathLabel      - the label text above the folder input
; $sPathPageInfo   - the descriptive text shown at the top of the page
; $sPathSubHeading - the header subtitle shown when this page is active
Func _AddPathPage(ByRef $mWizard, Const ByRef $mCfg, $sPath, $hUpdateSrcFunc, $sPathLabel = "Install folder:", $sPathPageInfo = "", $sPathSubHeading = "")
	If Not __IsValidWizard($mWizard) Then
		__DebugErrorInfo(_AddPathPage, $INST_ERR_INVALID_WIZARD, 0 , 0)
		Return SetError(@error, @extended, 0)
	EndIf

	Local $mPathPage = _NewPage()

	__SetPathPage($mWizard.hWin, $mPathPage, $mCfg, $sPath, $hUpdateSrcFunc, $sPathLabel, $sPathPageInfo, $sPathSubHeading)
	If @error Then Return SetError(@error, 0, 0)

	Local $iPathPageId = _AddPage($mWizard.mPages, $mPathPage)
	$mWizard.iPathPageId = $iPathPageId
	Return $iPathPageId
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates a ready page, adds it to the wizard and returns its page index.
; Stores the page index in $mWizard.iReadyPageId for later reference.
; Returns 0 and SetError($INST_ERR_INVALID_WIZARD) if the wizard is invalid.
; $mWizard               - the wizard map (modified in place)
; $mCfg                  - the installer config map
; $sReadyInfo            - static info text (used when $hUpdateReadyPageFunc is Default)
; $sReadySubHeading      - the header subtitle shown when this page is active
; $hUpdateReadyPageFunc  - optional function that returns dynamic info text on page load
Func _AddReadyPage(ByRef $mWizard, Const ByRef $mCfg, $sReadyInfo = "", $sReadySubHeading = "", $hUpdateReadyPageFunc = Default)
	If Not __IsValidWizard($mWizard) Then
		__DebugErrorInfo(_AddReadyPage, $INST_ERR_INVALID_WIZARD, 0 , 0)
		Return SetError(@error, @extended, 0)
	EndIf

	Local $mReadyPage = _NewPage()

	__SetReadyPage($mWizard.hWin, $mReadyPage, $mCfg, $sReadyInfo, $sReadySubHeading, $hUpdateReadyPageFunc)
	If @error Then Return SetError(@error, 0, 0)

	Local $iReadyPageId = _AddPage($mWizard.mPages, $mReadyPage)
	$mWizard.iReadyPageId = $iReadyPageId
	Return $iReadyPageId
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates a progress page, adds it to the wizard and returns its page index.
; Stores the page index in $mWizard.iProgressPageId for later reference.
; Returns 0 and SetError($INST_ERR_INVALID_WIZARD) if the wizard is invalid.
; $mWizard              - the wizard map (modified in place)
; $mCfg                 - the installer config map
; $hFunction            - the install/uninstall function to run (receives $idLblProgress, $idProgressbar)
; $sFailureMsg          - the error message shown when $hFunction returns False
; $sProgressSubHeading  - the header subtitle shown when this page is active
Func _AddProgressPage(ByRef $mWizard, Const ByRef $mCfg, $hFunction, $sFailureMsg = "Process failed", $sProgressSubHeading = "")
	If Not __IsValidWizard($mWizard) Then
		__DebugErrorInfo(_AddProgressPage, $INST_ERR_INVALID_WIZARD, 0 , 0)
		Return SetError(@error, @extended, 0)
	EndIf

	Local $mProgressPage = _NewPage()
	Local $idBtnNext     = __GetBtnNext($mWizard)

	__SetProgressPage($mWizard.hWin, $mProgressPage, $mCfg, $idBtnNext, $hFunction, $mWizard.sTitle, $sFailureMsg, $sProgressSubHeading)
	If @error Then Return SetError(@error, 0, 0)

	Local $iProgressPageId = _AddPage($mWizard.mPages, $mProgressPage)
	$mWizard.iProgressPageId = $iProgressPageId
	Return $iProgressPageId
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates a finish page, adds it to the wizard and returns its page index.
; Stores the page index in $mWizard.iFinishPageId for later reference.
; Returns 0 and SetError($INST_ERR_INVALID_WIZARD) if the wizard is invalid.
; $mWizard          - the wizard map (modified in place)
; $mCfg             - the installer config map
; $idLblProgress    - the progress label control ID from the progress page
; $idProgressbar    - the progress bar control ID from the progress page
; $sFinishMsg       - the completion message shown on the page
; $sDocFile         - optional path to a documentation file; when provided adds the open docs checkbox
; $sFinishSubHeading - the header subtitle shown when this page is active
Func _AddFinishPage(ByRef $mWizard, Const ByRef $mCfg, $idLblProgress, $idProgressbar, $sFinishMsg, $sDocFile = Default, $sFinishSubHeading = "")
	If Not __IsValidWizard($mWizard) Then
		__DebugErrorInfo(_AddFinishPage, $INST_ERR_INVALID_WIZARD, 0 , 0)
		Return SetError(@error, @extended, 0)
	EndIf

	Local $mFinishPage = _NewPage()

	__SetFinishPage($mWizard.hWin, $mFinishPage, $mCfg, $idLblProgress, $idProgressbar, $sFinishMsg, $sDocFile, $sFinishSubHeading)
	If @error Then Return SetError(@error, 0, 0)

	Local $iFinishPageId = _AddPage($mWizard.mPages, $mFinishPage)
	$mWizard.iFinishPageId = $iFinishPageId
	Return $iFinishPageId
EndFunc

;================================================================================================================================
#EndRegion <<< [HELPERS TO ADD PAGE TEMPLATES TO WIZARD]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [HEADER CONSTRUCTORS HELPERS] (OK)
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Creates a 1-pixel horizontal separator label on $hGUI and sets its background color.
; Returns the control ID or Null and SetError($INST_ERR_INVALID_GUI) if the window handle is invalid.
; $hGUI     - the wizard window handle
; $iTop     - the Y position of the separator
; $iWidth   - the width of the separator
; $vBkColor - the background color of the separator
Func _CreateSeparator($hGUI, $iTop, $iWidth, $vBkColor)
	If Not _Tstbl_IsHWnd($hGUI) Then
		__DebugErrorInfo(_CreateSeparator, $INST_ERR_INVALID_GUI, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	_Tstbl_GUISwitch($hGUI)

	Local $idSeparator = _Tstbl_GUICtrlCreateLabel("", 0, $iTop, $iWidth, 1)
	_Tstbl_GUICtrlSetBkColor($idSeparator, $vBkColor)
	Return $idSeparator
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates the header title label on $hGUI and returns its control ID.
; Returns Null and SetError($INST_ERR_INVALID_GUI) if the window handle is invalid.
; $hGUI  - the wizard window handle
; $mCfg  - the installer config map
; $sText - the title text
Func _CreateHeaderTitle($hGUI, Const ByRef $mCfg, $sText = "")
	If Not _Tstbl_IsHWnd($hGUI) Then
		__DebugErrorInfo(_CreateHeaderTitle, $INST_ERR_INVALID_GUI, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	_Tstbl_GUISwitch($hGUI)

	Local $iLeft = 15, $iTop = 12, $iHeight = 26, $iFontSize = 14
	Local $iWidth = $mCfg.iWndWidth - 30
	Local $idHeaderTitle = _Tstbl_GUICtrlCreateLabel($sText, $iLeft, $iTop, $iWidth, $iHeight)
    _Tstbl_GUICtrlSetFont($idHeaderTitle, $iFontSize, $FW_BOLD, $GUI_FONTNORMAL, $mCfg.sFontName)
    _Tstbl_GUICtrlSetBkColor($idHeaderTitle, $COLOR_WHITE)
	Return $idHeaderTitle
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates the header subtitle label on $hGUI and returns its control ID.
; Updated on each page load via __SetPageSubHeader() to show the current page subtitle.
; Returns Null and SetError($INST_ERR_INVALID_GUI) if the window handle is invalid.
; $hGUI  - the wizard window handle
; $mCfg  - the installer config map
; $sText - the initial subtitle text (usually empty, set per page on load)
Func _CreateHeaderSub($hGUI, Const ByRef $mCfg, $sText = "")
	If Not _Tstbl_IsHWnd($hGUI) Then
		__DebugErrorInfo(_CreateHeaderSub, $INST_ERR_INVALID_GUI, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	_Tstbl_GUISwitch($hGUI)

	Local $iLeft = 15, $iTop = 38, $iHeight = 22
	Local $iWidth = $mCfg.iWndWidth - 30
    Local $idHeaderSub = _Tstbl_GUICtrlCreateLabel($sText, $iLeft, $iTop, $iWidth, $iHeight)
    _Tstbl_GUICtrlSetFont($idHeaderSub, $mCfg.iFontSize, $FW_NORMAL, $GUI_FONTNORMAL, $mCfg.sFontName)
    _Tstbl_GUICtrlSetColor($idHeaderSub, 0x444444)
    _Tstbl_GUICtrlSetBkColor($idHeaderSub, $COLOR_WHITE)
	Return $idHeaderSub
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates the header bar on $hGUI including the background label, title, subtitle and separator.
; Returns a header map with keys: id, idTitle, idSubheading, idSeparator.
; Returns Null and SetError($INST_ERR_INVALID_GUI) if the window handle is invalid.
; $hGUI  - the wizard window handle
; $mCfg  - the installer config map
; $sText - the title text shown in the header
Func _CreateHeader($hGUI, Const ByRef $mCfg, $sText = "")
	If Not _Tstbl_IsHWnd($hGUI) Then
		__DebugErrorInfo(_CreateHeader, $INST_ERR_INVALID_GUI, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	_Tstbl_GUISwitch($hGUI)

	Local $mHeader[]

	; Header section container with background color
	$mHeader.id = _Tstbl_GUICtrlCreateLabel("", 0, 0, $mCfg.iWndWidth, $mCfg.iHeaderHeight)
	_Tstbl_GUICtrlSetBkColor($mHeader.id, $COLOR_WHITE)

    $mHeader.idTitle 	  = _CreateHeaderTitle($hGUI, $mCfg, $sText)
	$mHeader.idSubheading = _CreateHeaderSub($hGUI, $mCfg)
	$mHeader.idSeparator  = _CreateSeparator($hGUI, $mCfg.iHeaderHeight, $mCfg.iWndWidth, 0xCCCCCC)

	Return $mHeader
EndFunc

;================================================================================================================================
#EndRegion <<< [HEADER CONSTRUCTORS HELPERS]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [WIZARD HELPERS] (OK) (TODO test to ensure _NewWizard calls __BtnCaptionsUpdate)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns True if the wizard map contains a valid header map with all required keys
; (id, idTitle, idSubheading, idSeparator).
Func __IsValidWizardHeader(Const ByRef $mWizard)
	If Not IsMap($mWizard.mHeader) Then Return False
	If Not MapExists($mWizard.mHeader, "id") Then Return False
	If Not MapExists($mWizard.mHeader, "idTitle") Then Return False
	If Not MapExists($mWizard.mHeader, "idSubheading") Then Return False
	If Not MapExists($mWizard.mHeader, "idSeparator") Then Return False
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns True if the wizard map contains a valid buttons map with all required keys
; (idBtnCancel, idBtnBack, idBtnNext) and exactly 3 entries.
Func __IsValidWizardButtons(Const ByRef $mWizard)
	If Not IsMap($mWizard.mButtons) Then Return False
	If UBound($mWizard.mButtons) <> 3 Then Return False
	If Not MapExists($mWizard.mButtons, $BTN_CANCEL) Then Return False
	If Not MapExists($mWizard.mButtons, $BTN_BACK) Then Return False
	If Not MapExists($mWizard.mButtons, $BTN_NEXT) Then Return False
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns True if the wizard map is fully valid - has a valid header, buttons, pages map,
; a valid window handle, a footer separator and a page index.
Func __IsValidWizard(Const ByRef $mWizard)
	If Not IsMap($mWizard) Then Return False
	If Not __IsValidWizardHeader($mWizard) Then Return False
	If Not __IsValidWizardButtons($mWizard) Then Return False
	If Not IsMap($mWizard.mPages) Then Return False

	If Not MapExists($mWizard, "hWin") Then Return False
	If Not MapExists($mWizard, "idFooterSep") Then Return False
	If Not MapExists($mWizard, "iPage") Then Return False

	If Not _Tstbl_IsHWnd($mWizard.hWin) Then Return False

	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Returns True if the wizard is valid and has at least one page added.
; Used as the final check before starting the event loop in _InitWizard().
Func __IsWizardReady(Const ByRef $mWizard)
	If Not __IsValidWizard($mWizard) Then Return False
	If __MaxPages($mWizard.mPages) = 0 Then Return False
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Shows a cancel confirmation MsgBox if the current page is a normal or proceed page.
; Returns $EXIT_WIZARD_SIGNAL if the user confirms, $IDNO otherwise.
; Does nothing and returns $IDNO for processing or finish pages.
Func __MsgCloseInstall(ByRef $mWizard)
	Local $iStatus = __GetPageStatus(_GetWizardPage($mWizard, $mWizard.iPage))
	If $iStatus = $eNormalPage Or $iStatus = $eProceedPage Then
		Local Const $__MSG = "Are you sure you want to cancel the process?"
		If _Tstbl_MsgBox($MB_YESNO + $MB_ICONQUESTION, $mWizard.sTitle, $__MSG, 0, $mWizard.hWin) = $IDYES Then
			Return $EXIT_WIZARD_SIGNAL
		EndIf
	EndIf
	Return $IDNO
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates and returns a new wizard map with a window, header, footer separator, buttons _
; and an empty pages collection. Updates button captions from the config.
; Shows an error MsgBox and returns Null if the config is invalid.
; $mCfg         - the installer config map
; $sTitle       - the window title and MsgBox title
; $sHeaderTitle - the text shown in the header title label
Func _NewWizard(Const ByRef $mCfg, $sTitle, $sHeaderTitle)
	If Not __IsValidInstallerCfg($mCfg) Then
		_Tstbl_MsgBox($MB_OK + $MB_ICONERROR, $sTitle, __CrucialInstErrMsg($INST_ERR_INVALID_CFG))
		__DebugErrorInfo(_NewWizard, $INST_ERR_INVALID_CFG, 0 , Null)
		Return SetError(@error, @extended, Null)
	EndIf

	__BtnCaptionsUpdate($mCfg)

	Local $mThis[]
	$mThis.hWin = _Tstbl_GUICreate($sTitle, $mCfg.iWndWidth, $mCfg.iWndHeight, -1, -1, BitOR($WS_CAPTION, $WS_SYSMENU, $WS_MINIMIZEBOX))
	_Tstbl_GUISetBkColor(0xF0F0F0, $mThis.hWin)

	$mThis.sTitle      = String($sTitle)
	$mThis.mHeader     = _CreateHeader($mThis.hWin, $mCfg, $sHeaderTitle)
	$mThis.idFooterSep = _CreateSeparator($mThis.hWin, $mCfg.iFooterSepY, $mCfg.iWndWidth, 0xD0D0D0)
	$mThis.mButtons    = _CreateButtons($mThis.hWin, $mCfg)
	$mThis.mPages      = _CreatePages()
	$mThis.iPage	   = 0

	Return $mThis
EndFunc

; #FUNCTION# ====================================================================================================================
; Returns the page map at $iPage from the wizard's pages collection, or Null if not found.
Func _GetWizardPage(ByRef $mWizard, $iPage)
	If Not MapExists($mWizard, "mPages") Then Return Null
	Return __GetPage($mWizard.mPages, $iPage)
EndFunc

;================================================================================================================================
#EndRegion <<< [WIZARD HELPERS]
;================================================================================================================================

;================================================================================================================================
#Region ; >>> [WIZARD INIT] (OK)
;================================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Initializes and runs the wizard event loop.
; Hides all pages, shows the window, loads the first page, then enters the event loop.
; The loop handles Cancel/Close (with confirmation), Next/Back navigation via __NavPage(), _
; and button OnClick events on the current page via __OnObjBtnClick().
; Exits the loop and deletes the window when __NavPage() or __MsgCloseInstall() _
; returns $EXIT_WIZARD_SIGNAL.
Func __OnInit_Wizard(ByRef $mWizard)
	If Not __IsWizardReady($mWizard) Then Return

	; --- Main Buttons Handlers ---
	Local $idBtnCancel = __GetBtnCancel($mWizard)
    Local $idBtnBack   = __GetBtnBack($mWizard)
    Local $idBtnNext   = __GetBtnNext($mWizard)

    ; --- Hide all pages ---
	__HidePages($mWizard.mPages)

    ; --- Show Wizard ---
	_Tstbl_GUISwitch($mWizard.hWin)
	_Tstbl_GUISetState(@SW_SHOW, $mWizard.hWin)

    ; --- Set First Page ---
	$mWizard.iPage = 1
	__NavPage($mWizard, $ePageStay)

    ; ===================================================================
    ; Event loop
    ; ===================================================================
    While True
        Local $iMsg = _Tstbl_GUIGetMsg()
        Switch $iMsg
			Case $GUI_EVENT_CLOSE, $idBtnCancel
				If __MsgCloseInstall($mWizard) = $EXIT_WIZARD_SIGNAL Then ExitLoop
			Case $idBtnNext, $idBtnBack
				Local $iPageMove = ($iMsg = $idBtnNext) ? $ePageNext : $ePageBack
				If __NavPage($mWizard, $iPageMove) = $EXIT_WIZARD_SIGNAL Then ExitLoop
			Case Else
				If $iMsg > 0 Then
					__OnObjBtnClick(__GetPage($mWizard.mPages, $mWizard.iPage), $iMsg)
				EndIf
		EndSwitch
    WEnd

    ; --- Tear down ---
	_Tstbl_GUIDelete($mWizard.hWin)

EndFunc

; #FUNCTION# ====================================================================================================================
; Entry point for starting the wizard. Validates the wizard is ready, shows an error _
; MsgBox if not, then delegates to __OnInit_Wizard() to run the event loop.
; $mWizard - the fully configured wizard map returned by _NewWizard() with pages added
Func _InitWizard(ByRef $mWizard)
	If Not __IsWizardReady($mWizard) Then
		_Tstbl_MsgBox($MB_OK + $MB_ICONERROR, "Crucial Installer Setup", __CrucialInstErrMsg($INST_ERR_INVALID_WIZARD))
		Return
	Else
		__OnInit_Wizard($mWizard)
	EndIf
EndFunc

;================================================================================================================================
#EndRegion <<< [WIZARD INIT]
;================================================================================================================================
