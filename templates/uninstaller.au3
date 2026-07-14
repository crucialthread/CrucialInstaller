; #INDEX# =======================================================================================================================
; Title .........: {{UNINSTALLER_FILENAME}}.au3
; Version .......: {{VERSION}}
; AutoIt Version : 3.3.18.0
; Author ........: {{AUTHOR}}
; Description ...: Uninstaller for {{PRODUCT_NAME}}.
;                  Reads installation paths from the registry written by {{INSTALLER_FILENAME}}.au3,
;                  removes all installed files, cleans up registry entries, and removes the
;                  Add/Remove Programs entry.
;                  Removes install folders only if empty after uninstall.
;                  Self-relaunches from %TEMP% if running from an install folder so it can
;                  delete its own folder cleanly.
; Note ..........: Requires administrator rights to delete from Program Files.
; ===============================================================================================================================

#RequireAdmin
#include <FontConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <ProgressConstants.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>

; ===============================================================================================================================
; Constants
; ===============================================================================================================================

Global Const $UNINSTALLER_TITLE  = "{{PRODUCT_NAME}} Uninstall"

Global Const $WIN_WIDTH          = 540
Global Const $WIN_HEIGHT         = {{UNINSTALLER_HEIGHT}}
Global Const $FONT_FACE          = "Segoe UI"
Global Const $FONT_SIZE          = 11
Global Const $BTN_W              = 130
Global Const $BTN_H              = 34
Global Const $BTN_GAP            = 10
Global Const $BTN_Y              = $WIN_HEIGHT - 48
Global Const $FOOTER_SEP_Y       = $WIN_HEIGHT - 58
Global Const $HEADER_H           = 70
Global Const $CONTENT_TOP        = $HEADER_H + 10
Global Const $CONTENT_W          = $WIN_WIDTH - 40

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
    If Not __ReadInstallRecord() Then
        MsgBox($MB_OK + $MB_ICONERROR, $UNINSTALLER_TITLE, _
            "{{PRODUCT_NAME}} installation record was not found." & @CRLF & @CRLF & _
            "It may have already been uninstalled.")
        Exit
    EndIf

    ; Self-relaunch from temp so we can delete our own install folder
    If StringInStr(StringLower(@ScriptFullPath), StringLower({{SELF_RELAUNCH_PATH}})) Then
        Local $sTempExe = @TempDir & "\{{UNINSTALLER_FILENAME}}.exe"
        FileCopy(@ScriptFullPath, $sTempExe, $FC_OVERWRITE)
        ShellExecute($sTempExe)
        Exit
    EndIf

    __RunWizard()
EndFunc

; ===============================================================================================================================
; Read install record
; ===============================================================================================================================

Func __ReadInstallRecord()
{{READ_INSTALL_RECORD}}
EndFunc

; ===============================================================================================================================
; Wizard
; ===============================================================================================================================

Func __RunWizard()
    Local $hWin = GUICreate($UNINSTALLER_TITLE, $WIN_WIDTH, $WIN_HEIGHT, -1, -1, _
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
    ; Page 1 - Welcome / Confirm
    ; ===================================================================
    Local $aPage1[2]
    $aPage1[0] = GUICtrlCreateLabel( _
        "This wizard will remove {{PRODUCT_NAME}} from your computer." & @CRLF & @CRLF & _
        "Current installation:" & @CRLF & @CRLF & _
{{INSTALL_SUMMARY_LINES}}
        "Click Next to continue or Cancel to exit.", _
        15, $CONTENT_TOP, $CONTENT_W, $FOOTER_SEP_Y - $CONTENT_TOP - 10)
    GUICtrlSetFont($aPage1[0], $FONT_SIZE, $FW_NORMAL, $GUI_FONTNORMAL, $FONT_FACE)
    GUICtrlSetBkColor($aPage1[0], $GUI_BKCOLOR_TRANSPARENT)
    $aPage1[1] = GUICtrlCreateLabel("", 0, 0, 0, 0)

    ; ===================================================================
    ; Page 2 - Ready to Uninstall
    ; ===================================================================
    Local $aPage2[2]
    $aPage2[0] = GUICtrlCreateLabel("The following actions will be performed:", 10, $CONTENT_TOP, $WIN_WIDTH - 20, 22)
    GUICtrlSetFont($aPage2[0], $FONT_SIZE, $FW_NORMAL, $GUI_FONTNORMAL, $FONT_FACE)
    GUICtrlSetBkColor($aPage2[0], $GUI_BKCOLOR_TRANSPARENT)
    Local $sReadyText = ""
{{READY_TEXT_LINES}}
    $aPage2[1] = GUICtrlCreateLabel($sReadyText, 10, $CONTENT_TOP + 28, $WIN_WIDTH - 20, $FOOTER_SEP_Y - $CONTENT_TOP - 38)
    GUICtrlSetFont($aPage2[1], 10, $FW_NORMAL, $GUI_FONTNORMAL, $FONT_FACE)
    GUICtrlSetBkColor($aPage2[1], $GUI_BKCOLOR_TRANSPARENT)

    ; ===================================================================
    ; Page 3 - Progress
    ; ===================================================================
    Local $aPage3[2]
    $aPage3[0] = GUICtrlCreateLabel("", 15, $CONTENT_TOP, $CONTENT_W, 24)
    GUICtrlSetFont($aPage3[0], $FONT_SIZE, $FW_NORMAL, $GUI_FONTNORMAL, $FONT_FACE)
    GUICtrlSetBkColor($aPage3[0], $GUI_BKCOLOR_TRANSPARENT)
    $aPage3[1] = GUICtrlCreateProgress(15, $CONTENT_TOP + 32, $CONTENT_W, 24)

    ; ===================================================================
    ; Page 4 - Finish
    ; ===================================================================
    Local $aPage4[1]
    $aPage4[0] = GUICtrlCreateLabel( _
        "{{PRODUCT_NAME}} has been successfully uninstalled." & @CRLF & @CRLF & _
        "{{UNINSTALL_FINISH_MESSAGE}}", _
        15, $CONTENT_TOP, $CONTENT_W, $FOOTER_SEP_Y - $CONTENT_TOP - 10)
    GUICtrlSetFont($aPage4[0], $FONT_SIZE, $FW_NORMAL, $GUI_FONTNORMAL, $FONT_FACE)
    GUICtrlSetBkColor($aPage4[0], $GUI_BKCOLOR_TRANSPARENT)

    ; --- Hide all pages ---
    __HidePage($aPage1)
    __HidePage($aPage2)
    __HidePage($aPage3)
    __HidePage($aPage4)

    GUISetState(@SW_SHOW, $hWin)

    Local $iPage = 1
    __ShowPage($iPage, $aPage1, $aPage2, $aPage3, $aPage4, $idHeaderSub, $idBtnNext, $idBtnBack, $idBtnCancel)

    While True
        Local $iMsg = GUIGetMsg()
        Switch $iMsg
            Case $GUI_EVENT_CLOSE, $idBtnCancel
                If $iPage < 3 Then
                    If MsgBox($MB_YESNO + $MB_ICONQUESTION, $UNINSTALLER_TITLE, _
                        "Are you sure you want to cancel the uninstallation?") = $IDYES Then
                        GUIDelete($hWin)
                        Exit
                    EndIf
                EndIf

            Case $idBtnNext
                Switch $iPage
                    Case 1
                        $iPage = 2

                    Case 2
                        $iPage = 3
                        GUICtrlSetState($idBtnNext,   $GUI_DISABLE)
                        GUICtrlSetState($idBtnBack,   $GUI_DISABLE)
                        GUICtrlSetState($idBtnCancel, $GUI_DISABLE)
                        __ShowPage($iPage, $aPage1, $aPage2, $aPage3, $aPage4, $idHeaderSub, $idBtnNext, $idBtnBack, $idBtnCancel)
                        __RunUninstall($aPage3[0], $aPage3[1])
                        $iPage = 4
                        GUICtrlSetData($idBtnNext, "Finish")
                        GUICtrlSetState($idBtnNext, $GUI_ENABLE)

                    Case 4
                        GUIDelete($hWin)
                        Exit
                EndSwitch
                __ShowPage($iPage, $aPage1, $aPage2, $aPage3, $aPage4, $idHeaderSub, $idBtnNext, $idBtnBack, $idBtnCancel)

            Case $idBtnBack
                Switch $iPage
                    Case 2
                        $iPage = 1
                EndSwitch
                __ShowPage($iPage, $aPage1, $aPage2, $aPage3, $aPage4, $idHeaderSub, $idBtnNext, $idBtnBack, $idBtnCancel)
        EndSwitch
    WEnd
EndFunc

; ===============================================================================================================================
; Page helpers
; ===============================================================================================================================

Func __ShowPage($iPage, ByRef $aPage1, ByRef $aPage2, ByRef $aPage3, ByRef $aPage4, _
    $idHeaderSub, $idBtnNext, $idBtnBack, $idBtnCancel)

    __HidePage($aPage1)
    __HidePage($aPage2)
    __HidePage($aPage3)
    __HidePage($aPage4)

    Switch $iPage
        Case 1
            GUICtrlSetData($idHeaderSub, "Welcome to {{PRODUCT_NAME}} Uninstall")
            GUICtrlSetState($idBtnBack,   $GUI_DISABLE)
            GUICtrlSetState($idBtnNext,   $GUI_ENABLE)
            GUICtrlSetState($idBtnCancel, $GUI_ENABLE)
            GUICtrlSetData($idBtnNext, "Next >")
            __ShowPageControls($aPage1)

        Case 2
            GUICtrlSetData($idHeaderSub, "Ready to uninstall")
            GUICtrlSetState($idBtnBack,   $GUI_ENABLE)
            GUICtrlSetState($idBtnNext,   $GUI_ENABLE)
            GUICtrlSetState($idBtnCancel, $GUI_ENABLE)
            GUICtrlSetData($idBtnNext, "Uninstall")
            __ShowPageControls($aPage2)

        Case 3
            GUICtrlSetData($idHeaderSub, "Uninstalling, please wait...")
            GUICtrlSetState($idBtnBack,   $GUI_DISABLE)
            GUICtrlSetState($idBtnNext,   $GUI_DISABLE)
            GUICtrlSetState($idBtnCancel, $GUI_DISABLE)
            __ShowPageControls($aPage3)

        Case 4
            GUICtrlSetData($idHeaderSub, "Uninstallation complete")
            GUICtrlSetState($idBtnBack,   $GUI_DISABLE)
            GUICtrlSetState($idBtnNext,   $GUI_ENABLE)
            GUICtrlSetState($idBtnCancel, $GUI_DISABLE)
            GUICtrlSetData($idBtnNext, "Finish")
            __ShowPageControls($aPage4)
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
; Uninstall logic
; ===============================================================================================================================

Func __RunUninstall($idStatusLabel, $idProgress)
    Local $iStep  = 0
    Local $iSteps = {{TOTAL_STEPS}}

{{UNINSTALL_STEPS}}

    GUICtrlSetData($idProgress, 100)
EndFunc

; ===============================================================================================================================
; Helpers
; ===============================================================================================================================

Func __RemoveFolderIfEmpty($sFolder)
    If Not FileExists($sFolder) Then Return
    Local $aFiles = _FileListToArray($sFolder)
    If @error Or $aFiles[0] = 0 Then DirRemove($sFolder)
EndFunc

{{EXTRA_HELPERS}}
