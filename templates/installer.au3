; #INDEX# =======================================================================================================================
; Title .........: {{INSTALLER_FILENAME}}.au3
; Version .......: {{VERSION}}
; AutoIt Version : 3.3.18.0
; Author ........: {{AUTHOR}}
; Description ...: {{DESCRIPTION}}
; Note ..........: Requires administrator rights to write to Program Files.
; Note ..........: All files are embedded into the compiled .exe via FileInstall at compile
;                  time. The compiled .exe is fully self-contained and can be run from any
;                  location.
; ===============================================================================================================================

#RequireAdmin
#include <FontConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <ProgressConstants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>

; ===============================================================================================================================
; Constants
; ===============================================================================================================================

Global Const $INSTALLER_TITLE   = "{{PRODUCT_NAME}} Setup"
Global Const $INSTALLER_VERSION = "{{VERSION}}"

Global Const $WIN_WIDTH         = 540
Global Const $WIN_HEIGHT        = 345
Global Const $FONT_FACE         = "Segoe UI"
Global Const $FONT_SIZE         = 11
Global Const $BTN_W             = 130
Global Const $BTN_H             = 34
Global Const $BTN_GAP           = 10
Global Const $BTN_Y             = $WIN_HEIGHT - 48
Global Const $FOOTER_SEP_Y      = $WIN_HEIGHT - 58
Global Const $HEADER_H          = 70
Global Const $CONTENT_TOP       = $HEADER_H + 10
Global Const $CONTENT_W         = $WIN_WIDTH - 40

{{REGISTRY_CONSTANTS}}

; ===============================================================================================================================
; Global state
; ===============================================================================================================================

{{GLOBAL_STATE}}

; ===============================================================================================================================
; Entry point
; ===============================================================================================================================

_Main()

Func _Main()
    __DetectPaths()
    __CheckExistingInstall()
    __RunWizard()
EndFunc

; ===============================================================================================================================
; Detection
; ===============================================================================================================================

{{DETECT_PATHS_FUNC}}

{{CHECK_EXISTING_INSTALL_FUNC}}

; ===============================================================================================================================
; Wizard
; ===============================================================================================================================

Func __RunWizard()
    Local $hWin = GUICreate($INSTALLER_TITLE, $WIN_WIDTH, $WIN_HEIGHT, -1, -1, _
        BitOR($WS_CAPTION, $WS_SYSMENU, $WS_MINIMIZEBOX))
    GUISetBkColor(0xF0F0F0)

    ; --- Header bar ---
    Local $idHeader = GUICtrlCreateLabel("", 0, 0, $WIN_WIDTH, $HEADER_H)
    GUICtrlSetBkColor($idHeader, 0xFFFFFF)
    Local $idHeaderTitle = GUICtrlCreateLabel("{{PRODUCT_NAME}}", 15, 12, $WIN_WIDTH - 30, 26)
    GUICtrlSetFont($idHeaderTitle, 14, $FW_BOLD, $GUI_FONTNORMAL, $FONT_FACE)
    GUICtrlSetBkColor($idHeaderTitle, 0xFFFFFF)
    Local $idHeaderSub = GUICtrlCreateLabel("", 15, 38, $WIN_WIDTH - 30, 22)
    GUICtrlSetFont($idHeaderSub, $FONT_SIZE, $FW_NORMAL, $GUI_FONTNORMAL, $FONT_FACE)
    GUICtrlSetColor($idHeaderSub, 0x444444)
    GUICtrlSetBkColor($idHeaderSub, 0xFFFFFF)
    Local $idHeaderSep = GUICtrlCreateLabel("", 0, $HEADER_H, $WIN_WIDTH, 1)
    GUICtrlSetBkColor($idHeaderSep, 0xCCCCCC)

    ; --- Footer separator ---
    Local $idFooterSep = GUICtrlCreateLabel("", 0, $FOOTER_SEP_Y, $WIN_WIDTH, 1)
    GUICtrlSetBkColor($idFooterSep, 0xD0D0D0)

    ; --- Footer buttons (centered: Cancel | Back | Next) ---
    Local $iTotalBtnW  = (3 * $BTN_W) + (2 * $BTN_GAP)
    Local $iBtnStartX  = ($WIN_WIDTH - $iTotalBtnW) / 2
    Local $idBtnCancel = GUICtrlCreateButton("Cancel",  $iBtnStartX,                           $BTN_Y, $BTN_W, $BTN_H)
    Local $idBtnBack   = GUICtrlCreateButton("< Back",  $iBtnStartX + $BTN_W + $BTN_GAP,       $BTN_Y, $BTN_W, $BTN_H)
    Local $idBtnNext   = GUICtrlCreateButton("Next >",  $iBtnStartX + 2 * ($BTN_W + $BTN_GAP), $BTN_Y, $BTN_W, $BTN_H)
    GUICtrlSetFont($idBtnCancel, $FONT_SIZE, $FW_NORMAL, $GUI_FONTNORMAL, $FONT_FACE)
    GUICtrlSetFont($idBtnBack,   $FONT_SIZE, $FW_NORMAL, $GUI_FONTNORMAL, $FONT_FACE)
    GUICtrlSetFont($idBtnNext,   $FONT_SIZE, $FW_NORMAL, $GUI_FONTNORMAL, $FONT_FACE)

    ; ===================================================================
    ; Pages
    ; ===================================================================
{{PAGES}}

    ; --- Hide all pages initially ---
{{HIDE_PAGES}}

    GUISetState(@SW_SHOW, $hWin)

    Local $iPage = 1
    __ShowPage($iPage, {{PAGE_ARGS}}, $idHeaderSub, $idBtnNext, $idBtnBack, $idBtnCancel)

    ; ===================================================================
    ; Event loop
    ; ===================================================================
    While True
        Local $iMsg = GUIGetMsg()
        Switch $iMsg
            Case $GUI_EVENT_CLOSE, $idBtnCancel
                If $iPage < {{PROGRESS_PAGE}} Then
                    If MsgBox($MB_YESNO + $MB_ICONQUESTION, $INSTALLER_TITLE, _
                        "Are you sure you want to cancel the installation?") = $IDYES Then
                        GUIDelete($hWin)
                        Exit
                    EndIf
                EndIf

            Case $idBtnNext
                Switch $iPage
{{NEXT_CASES}}
                EndSwitch
                __ShowPage($iPage, {{PAGE_ARGS}}, $idHeaderSub, $idBtnNext, $idBtnBack, $idBtnCancel)

            Case $idBtnBack
                Switch $iPage
{{BACK_CASES}}
                EndSwitch
                __ShowPage($iPage, {{PAGE_ARGS}}, $idHeaderSub, $idBtnNext, $idBtnBack, $idBtnCancel)

{{EXTRA_EVENTS}}
        EndSwitch
    WEnd
EndFunc

; ===============================================================================================================================
; Page helpers
; ===============================================================================================================================

Func __ShowPage($iPage, {{PAGE_ARGS}}, $idHeaderSub, $idBtnNext, $idBtnBack, $idBtnCancel)
{{HIDE_PAGES_IN_SHOW}}

    Local $sWelcome = $g_bIsUpgrade ? "Upgrading {{PRODUCT_NAME}}" : "Welcome to {{PRODUCT_NAME}} Setup"

    Switch $iPage
{{SHOW_CASES}}
    EndSwitch
EndFunc

Func __HidePage(ByRef $aPage)
    For $i = 0 To UBound($aPage) - 1
        GUICtrlSetState($aPage[$i], $GUI_HIDE)
    Next
EndFunc

Func __ShowPageControls(ByRef $aPage)
    For $i = 0 To UBound($aPage) - 1
        GUICtrlSetState($aPage[$i], $GUI_SHOW)
    Next
EndFunc

Func __ProgressStep($idLabel, $idProgress, $iStep, $iSteps, $sStatus)
    GUICtrlSetData($idLabel, $sStatus)
    GUICtrlSetData($idProgress, Int(($iStep / $iSteps) * 100))
EndFunc

; ===============================================================================================================================
; Installation logic
; ===============================================================================================================================

Func __RunInstall($idStatusLabel, $idProgress)
    Local $iStep  = 0
    Local $iSteps = {{TOTAL_STEPS}}

{{INSTALL_STEPS}}

    GUICtrlSetData($idProgress, 100)
EndFunc

; ===============================================================================================================================
; Registry writers
; ===============================================================================================================================

{{REGISTRY_WRITERS}}
