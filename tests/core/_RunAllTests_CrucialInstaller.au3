#include "CrucialInstallerErrorTests.au3"
#include "CrucialInstallerConfigTests.au3"
#include "CrucialInstallerEventsTests.au3"
#include "CrucialInstallerPageHelpersTests.au3"
#include "CrucialInstallerPageCtrlTests.au3"
#include "CrucialInstallerButtonsTests.au3"
#include "CrucialInstallerPageOpsTests.au3"
#include "CrucialInstallerNavTests.au3"
#include "CrucialInstallerPageTemplateEventsTests.au3"
#include "CrucialInstallerPageTemplatesTests.au3"
#include "CrucialInstallerHeaderTests.au3"
#include "CrucialInstallerWizardTests.au3"
#include "CrucialInstallerInitTests.au3"

; #INDEX# =======================================================================================================================
; Title .........: Crucial Installer - _RunAllTests_CrucialInstaller.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Runner script that executes all Crucial Installer test suites.
; ===============================================================================================================================

Func _RunAllTests_CrucialInstaller()

	Local $bWriteSummary = False

	_RunCrucialInstallerErrorTests($bWriteSummary)
	_RunCrucialInstallerConfigTests($bWriteSummary)
	_RunCrucialInstallerEventsTests($bWriteSummary)
	_RunCrucialInstallerPageHelpersTests($bWriteSummary)
	_RunCrucialInstallerPageCtrlTests($bWriteSummary)
	_RunCrucialInstallerButtonsTests($bWriteSummary)
	_RunCrucialInstallerPageOpsTests($bWriteSummary)
	_RunCrucialInstallerNavTests($bWriteSummary)
	_RunCrucialInstallerPageTemplateEventsTests($bWriteSummary)
	_RunCrucialInstallerPageTemplatesTests($bWriteSummary)
	_RunCrucialInstallerHeaderTests($bWriteSummary)
	_RunCrucialInstallerWizardTests($bWriteSummary)
	_RunCrucialInstallerInitTests($bWriteSummary)

	_TestFmkSeparator(80, "=")
	ConsoleWrite("+ Summary")
	_TestFmkSummary()
EndFunc
_RunAllTests_CrucialInstaller()