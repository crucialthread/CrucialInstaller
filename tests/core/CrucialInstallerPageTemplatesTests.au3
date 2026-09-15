#include-once

#include "..\src\core\TestFramework.au3"
#include "..\src\core\StubConstants.au3"
#include "..\src\installer\CrucialInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialInstallerPageTemplatesTests.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for the Page Templates and Helpers to Add Page Templates regions
;                  of CrucialInstaller.au3.
;                  Tests invalid GUI/config guards, control creation, event handler registration,
;                  and page index storage in the wizard map.
; ===============================================================================================================================
Local $sScriptName = "CrucialInstallerPageTemplatesTests.au3"

; ===============================================================================================================================
; Helpers
; ===============================================================================================================================
Func __SetupPageTemplateStubs()
    For $i = 1 To 14
        _SetStubReturn("IsHWnd", $i, True)
    Next
    _SetStubReturn("GUICtrlCreateButton", $_1st, 10)
    _SetStubReturn("GUICtrlCreateButton", $_2nd, 11)
    _SetStubReturn("GUICtrlCreateButton", $_3rd, 12)
EndFunc

Func __BuildTestWizard()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = _NewWizard($mCfg, "Test", "Test")
    Return $mWizard
EndFunc

Func __TestApplyFunc($idLblProgress, $idProgressbar)
    Return True
EndFunc

Func __TestInfoHndReady()
    Return "Info"
EndFunc

Func __TestUpdtSrcHndPath($idInputPath)
    Return True
EndFunc

; ===============================================================================================================================
; Tests - __ValidateTemplateArgs
; ===============================================================================================================================
Func _TestValidateTemplateArgs_InvalidGUI()
    _TestFmkHeader("Test: __ValidateTemplateArgs() - returns INST_ERR_INVALID_GUI for invalid GUI")

    _SetStubReturn("IsHWnd", $_1st, False)
    Local $mCfg = _NewInstallerCfg()

	Local $hGUI	   = 1
    Local $iResult = __ValidateTemplateArgs($hGUI, $mCfg)

    _TestFmkAssert($iResult = $INST_ERR_INVALID_GUI, "Returns INST_ERR_INVALID_GUI", $iResult, $INST_ERR_INVALID_GUI)
EndFunc

Func _TestValidateTemplateArgs_InvalidCfg()
    _TestFmkHeader("Test: __ValidateTemplateArgs() - returns INST_ERR_INVALID_CFG for invalid config")

    _SetStubReturn("IsHWnd", $_1st, True)
    Local $mCfg[]

	Local $hGUI	   = 1
    Local $iResult = __ValidateTemplateArgs($hGUI, $mCfg)

    _TestFmkAssert($iResult = $INST_ERR_INVALID_CFG, "Returns INST_ERR_INVALID_CFG", $iResult, $INST_ERR_INVALID_CFG)
EndFunc

Func _TestValidateTemplateArgs_Valid()
    _TestFmkHeader("Test: __ValidateTemplateArgs() - returns 0 when both GUI and config are valid")

    _SetStubReturn("IsHWnd", $_1st, True)
    Local $mCfg = _NewInstallerCfg()

	Local $hGUI	   = 1
    Local $iResult = __ValidateTemplateArgs($hGUI, $mCfg)

    _TestFmkAssert($iResult = 0, "Returns 0 for valid inputs", $iResult, 0)
EndFunc

; ===============================================================================================================================
; Tests - __SetIntroPage
; ===============================================================================================================================
Func _TestSetIntroPage_InvalidGUI()
    _TestFmkHeader("Test: __SetIntroPage() - returns Null and sets @error for invalid GUI")

    _SetStubReturn("IsHWnd", $_1st, False)
	Local $hGUI	   = 1
    Local $mPage   = _NewPage()
    Local $mCfg    = _NewInstallerCfg()

    Local $vResult = __SetIntroPage($hGUI, $mPage, $mCfg)
    Local $iErr    = @error

    _TestFmkAssert($vResult = Null,               "Returns Null", 			 $vResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_GUI, "Sets invalid GUI @error", $iErr,    $INST_ERR_INVALID_GUI)
EndFunc

Func _TestSetIntroPage_InvalidCfg()
    _TestFmkHeader("Test: __SetIntroPage() - returns Null and sets @error for invalid config")

	_SetStubReturn("IsHWnd", $_1st, True)
	Local $hGUI	 = 1
	Local $mPage = _NewPage()
    Local $mCfg[]

    Local $vResult = __SetIntroPage($hGUI, $mPage, $mCfg)
    Local $iErr    = @error

    _TestFmkAssert($vResult = Null,               "Returns Null", 				$vResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_CFG, "Sets invalid config @error", $iErr,    $INST_ERR_INVALID_CFG)
EndFunc

Func _TestSetIntroPage_WithAllParams()
    _TestFmkHeader("Test: __SetIntroPage() - sets up page correctly with all params")

	Local $idLblIntro   = 20
	Local $idLblVersion = 21
    _SetStubReturn("IsHWnd",            $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",$_1st, $idLblIntro)
    _SetStubReturn("GUICtrlCreateLabel",$_2nd, $idLblVersion)
    _SetStubReturn("GUICtrlGetHandle",  $_1st, $idLblIntro)
	_SetStubReturn("GUICtrlGetHandle",  $_2nd, $idLblVersion)

	Local $hGUI	 = 1
	Local $sIntroText = "Welcome text"
	Local $sSubHeading = "Choose options"
	Local $sVersion = "1.0.0"
    Local $mPage = _NewPage()
    Local $mCfg  = _NewInstallerCfg()
    __SetIntroPage($hGUI, $mPage, $mCfg, "Welcome text", "Choose options", "1.0.0")

    Local $sStubIntroTxt    = _GetStubCall("GUICtrlCreateLabel", $_1st, $Param_Text)
    Local $sStubVersionTxt  = _GetStubCall("GUICtrlCreateLabel", $_2nd, $Param_Text)
	Local $idCtrlLblIntro   = _GetPageCtrl($mPage, "LblIntro")
	Local $idCtrlLblVersion = _GetPageCtrl($mPage, "LblVersion")

    _TestFmkAssert($mPage.iStatus     = $eNormalPage,      		"Status is eNormalPage",       	 $mPage.iStatus,     $eNormalPage)
    _TestFmkAssert($mPage.sSubheading = $sSubHeading,  			"Subheading set correctly",    	 $mPage.sSubheading, $sSubHeading)
    _TestFmkAssert($sStubIntroTxt     = $sIntroText,    		"Intro label text correct",    	 $sStubIntroTxt,     $sIntroText)
    _TestFmkAssert($sStubVersionTxt   = "Version " & $sVersion, "Version label text correct",  	 $sStubVersionTxt,   "Version " & $sVersion)
	_TestFmkAssert($idCtrlLblIntro    = $idLblIntro,   			"LblIntro control registered",   $idCtrlLblIntro,    $idLblIntro)
	_TestFmkAssert($idCtrlLblVersion  = $idLblVersion, 			"LblVersion control registered", $idCtrlLblVersion,  $idLblVersion)
EndFunc

Func _TestSetIntroPage_WithReqParams()
    _TestFmkHeader("Test: __SetIntroPage() - sets up page correctly with required params only")

    Local $idLblIntro   = 20
    Local $idLblVersion = 21
    _SetStubReturn("IsHWnd",             $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel", $_1st, $idLblIntro)
    _SetStubReturn("GUICtrlCreateLabel", $_2nd, $idLblVersion)
    _SetStubReturn("GUICtrlGetHandle",   $_1st, $idLblIntro)
	_SetStubReturn("GUICtrlGetHandle",   $_2nd, $idLblVersion)

    Local $hGUI  = 1
    Local $mPage = _NewPage()
    Local $mCfg  = _NewInstallerCfg()

    __SetIntroPage($hGUI, $mPage, $mCfg)
    Local $iErr = @error

	Local $sEmpty           = ""
	Local $sVersion 		= $DEFAULT_VERSION
    Local $sStubIntroTxt    = _GetStubCall("GUICtrlCreateLabel", $_1st, $Param_Text)
    Local $sStubVersionTxt  = _GetStubCall("GUICtrlCreateLabel", $_2nd, $Param_Text)
    Local $idCtrlLblIntro   = _GetPageCtrl($mPage, "LblIntro")
    Local $idCtrlLblVersion = _GetPageCtrl($mPage, "LblVersion")

    _TestFmkAssert($iErr              = 0,             			"No error with default params",  $iErr,              0)
    _TestFmkAssert($mPage.iStatus     = $eNormalPage,  			"Status is eNormalPage",         $mPage.iStatus,     $eNormalPage)
	_TestFmkAssert($mPage.sSubheading = $sEmpty,       			"Subheading is empty",           $mPage.sSubheading, $sEmpty)
    _TestFmkAssert($sStubIntroTxt     = $sEmpty,       			"Intro label text is empty",     $sStubIntroTxt,     $sEmpty)
    _TestFmkAssert($sStubVersionTxt   = "Version " & $sVersion, "Version label text is default", $sStubVersionTxt,   "Version " & $sVersion)
    _TestFmkAssert($idCtrlLblIntro    = $idLblIntro,   			"LblIntro control registered",   $idCtrlLblIntro,    $idLblIntro)
    _TestFmkAssert($idCtrlLblVersion  = $idLblVersion, 			"LblVersion control registered", $idCtrlLblVersion,  $idLblVersion)
EndFunc

; ===============================================================================================================================
; Tests - __SetPathPage
; ===============================================================================================================================

Func _TestSetPathPage_InvalidGUI()
    _TestFmkHeader("Test: __SetPathPage() - returns Null and sets @error for invalid GUI")

    _SetStubReturn("IsHWnd", $_1st, False)
	Local $hGUI	 = 1
    Local $mPage = _NewPage()
    Local $mCfg  = _NewInstallerCfg()

    Local $vResult = __SetPathPage($hGUI, $mPage, $mCfg, "C:\Path", Default)
    Local $iErr    = @error

    _TestFmkAssert($vResult = Null,               "Returns Null", 			 $vResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_GUI, "Sets invalid GUI @error", $iErr,    $INST_ERR_INVALID_GUI)
EndFunc

Func _TestSetPathPage_InvalidCfg()
    _TestFmkHeader("Test: __SetPathPage() - returns Null and sets @error for invalid config")

	_SetStubReturn("IsHWnd", $_1st, True)
    Local $hGUI	 = 1
	Local $mPage = _NewPage()
    Local $mCfg[]

    Local $vResult = __SetPathPage(1, $mPage, $mCfg, "C:\Path", Default)
    Local $iErr    = @error

    _TestFmkAssert($vResult = Null,               "Returns Null", 				$vResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_CFG, "Sets invalid config @error", $iErr,    $INST_ERR_INVALID_CFG)
EndFunc

Func _TestSetPathPage_WithAllParams()
    _TestFmkHeader("Test: __SetPathPage() - sets up page correctly with all params")

    Local $idLblPathPageInfo = 20
    Local $idLblPath         = 21
    Local $idInputPath       = 22
    Local $idBtnBrowse       = 10
    _SetStubReturn("IsHWnd",              $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",  $_1st, $idLblPathPageInfo)
    _SetStubReturn("GUICtrlCreateLabel",  $_2nd, $idLblPath)
    _SetStubReturn("GUICtrlCreateInput",  $_1st, $idInputPath)
    _SetStubReturn("GUICtrlCreateButton", $_1st, $idBtnBrowse)
    _SetStubReturn("GUICtrlGetHandle",    $_1st, $idLblPathPageInfo)
    _SetStubReturn("GUICtrlGetHandle",    $_2nd, $idLblPath)
    _SetStubReturn("GUICtrlGetHandle",    $_3rd, $idInputPath)
    _SetStubReturn("GUICtrlGetHandle",    $_4th, $idBtnBrowse)

    Local $hGUI            = 1
    Local $sPath           = "C:\Install\Path"
	Local $hUpdateSrcFunc  = __TestUpdtSrcHndPath
    Local $sPathLabel      = "Install folder:"
    Local $sPathInfo       = "Choose where to install"
    Local $sSubHeading     = "Select folder"
    Local $mPage           = _NewPage()
    Local $mCfg            = _NewInstallerCfg()

    __SetPathPage($hGUI, $mPage, $mCfg, $sPath, $hUpdateSrcFunc, $sPathLabel, $sPathInfo, $sSubHeading)

    Local $sStubPathInfoTxt  = _GetStubCall("GUICtrlCreateLabel",  $_1st, $Param_Text)
    Local $sStubPathLblTxt   = _GetStubCall("GUICtrlCreateLabel",  $_2nd, $Param_Text)
    Local $sStubInputPath    = _GetStubCall("GUICtrlCreateInput",  $_1st, $Param_Text)
	Local $sStubBtnBrowse    = _GetStubCall("GUICtrlCreateButton", $_1st, $Param_Text)
    Local $idCtrlPathInfo    = _GetPageCtrl($mPage, "LblPathPageInfo")
    Local $idCtrlLblPath     = _GetPageCtrl($mPage, "LblPath")
    Local $idCtrlInputPath   = _GetPageCtrl($mPage, "InputPath")
    Local $idCtrlBtnBrowse   = _GetPageCtrl($mPage, "BtnBrowse")
    Local $bBrowseReg        = MapExists($mPage.mBtnEvents, $idBtnBrowse)
    Local $aArgs             = Not $bBrowseReg ? Null : _
                               Not MapExists($mPage.mBtnEvents[$idBtnBrowse], $ONCLICK) ? Null : _
                               Not MapExists($mPage.mBtnEvents[$idBtnBrowse][$ONCLICK], "aArgs") ? Null : _
                               $mPage.mBtnEvents[$idBtnBrowse][$ONCLICK].aArgs

    Local $vArgInputPath     = IsArray($aArgs) And UBound($aArgs) > 1 ? $aArgs[1] : Null
    Local $vArgPathLabel     = IsArray($aArgs) And UBound($aArgs) > 2 ? $aArgs[2] : Null
    Local $vArgUpdateSrcFunc = IsArray($aArgs) And UBound($aArgs) > 3 ? $aArgs[3] : Null

    _TestFmkAssert($mPage.iStatus      = $eNormalPage,       "Status is eNormalPage",                 $mPage.iStatus,      $eNormalPage)
    _TestFmkAssert($mPage.sSubheading  = $sSubHeading,       "Subheading set correctly",              $mPage.sSubheading,  $sSubHeading)
    _TestFmkAssert($sStubPathInfoTxt   = $sPathInfo,         "Path info label text correct",          $sStubPathInfoTxt,   $sPathInfo)
    _TestFmkAssert($sStubPathLblTxt    = $sPathLabel,        "Path label text correct",               $sStubPathLblTxt,    $sPathLabel)
    _TestFmkAssert($sStubInputPath     = $sPath,             "Input path text correct",               $sStubInputPath,     $sPath)
	_TestFmkAssert($sStubBtnBrowse     = "Browse...",        "Button Browse text correct",            $sStubBtnBrowse,     "Browse...")
    _TestFmkAssert($idCtrlPathInfo     = $idLblPathPageInfo, "LblPathPageInfo registered",            $idCtrlPathInfo,     $idLblPathPageInfo)
    _TestFmkAssert($idCtrlLblPath      = $idLblPath,         "LblPath registered",                    $idCtrlLblPath,      $idLblPath)
    _TestFmkAssert($idCtrlInputPath    = $idInputPath,       "InputPath registered",                  $idCtrlInputPath,    $idInputPath)
    _TestFmkAssert($idCtrlBtnBrowse    = $idBtnBrowse,       "BtnBrowse registered",                  $idCtrlBtnBrowse,    $idBtnBrowse)
    _TestFmkAssert($bBrowseReg,                              "BtnBrowse OnClick handler registered",  $bBrowseReg,         True)
    _TestFmkAssert($vArgInputPath      = $idInputPath,       "OnClick receives InputPath as arg",     $vArgInputPath,      $idInputPath)
    _TestFmkAssert($vArgPathLabel      = $sPathLabel,        "OnClick receives PathLabel as arg",     $vArgPathLabel,      $sPathLabel)
    _TestFmkAssert($vArgUpdateSrcFunc  = $hUpdateSrcFunc,    "OnClick receives UpdateSrcFunc as arg", $vArgUpdateSrcFunc,  $hUpdateSrcFunc)
EndFunc

Func _TestSetPathPage_WithReqParams()
    _TestFmkHeader("Test: __SetPathPage() - sets up page correctly with required params only")

    Local $idLblPathPageInfo = 20
    Local $idLblPath         = 21
    Local $idInputPath       = 22
    Local $idBtnBrowse       = 10
    _SetStubReturn("IsHWnd",              $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",  $_1st, $idLblPathPageInfo)
    _SetStubReturn("GUICtrlCreateLabel",  $_2nd, $idLblPath)
    _SetStubReturn("GUICtrlCreateInput",  $_1st, $idInputPath)
    _SetStubReturn("GUICtrlCreateButton", $_1st, $idBtnBrowse)
    _SetStubReturn("GUICtrlGetHandle",    $_1st, $idLblPathPageInfo)
    _SetStubReturn("GUICtrlGetHandle",    $_2nd, $idLblPath)
    _SetStubReturn("GUICtrlGetHandle",    $_3rd, $idInputPath)
    _SetStubReturn("GUICtrlGetHandle",    $_4th, $idBtnBrowse)

    Local $hGUI                 = 1
    Local $sPath                = "C:\Install\Path"
	Local $hDefaultAsSrcFunc 	= Default
    Local $sEmpty               = ""
    Local $sDefaultPathLabelTxt = "Install folder:"
    Local $mPage                = _NewPage()
    Local $mCfg                 = _NewInstallerCfg()

    __SetPathPage($hGUI, $mPage, $mCfg, $sPath, $hDefaultAsSrcFunc)
    Local $iErr = @error

    Local $sStubPathInfoTxt  = _GetStubCall("GUICtrlCreateLabel",  $_1st, $Param_Text)
    Local $sStubPathLblTxt   = _GetStubCall("GUICtrlCreateLabel",  $_2nd, $Param_Text)
    Local $sStubInputPath    = _GetStubCall("GUICtrlCreateInput",  $_1st, $Param_Text)
	Local $sStubBtnBrowse    = _GetStubCall("GUICtrlCreateButton", $_1st, $Param_Text)
    Local $idCtrlPathInfo    = _GetPageCtrl($mPage, "LblPathPageInfo")
    Local $idCtrlLblPath     = _GetPageCtrl($mPage, "LblPath")
    Local $idCtrlInputPath   = _GetPageCtrl($mPage, "InputPath")
    Local $idCtrlBtnBrowse   = _GetPageCtrl($mPage, "BtnBrowse")
    Local $bBrowseReg        = MapExists($mPage.mBtnEvents, $idBtnBrowse)
    Local $aArgs             = Not $bBrowseReg ? Null : _
                               Not MapExists($mPage.mBtnEvents[$idBtnBrowse], $ONCLICK) ? Null : _
                               Not MapExists($mPage.mBtnEvents[$idBtnBrowse][$ONCLICK], "aArgs") ? Null : _
                               $mPage.mBtnEvents[$idBtnBrowse][$ONCLICK].aArgs

    Local $vArgInputPath     = IsArray($aArgs) And UBound($aArgs) > 1 ? $aArgs[1] : Null
    Local $vArgPathLabel     = IsArray($aArgs) And UBound($aArgs) > 2 ? $aArgs[2] : Null
    Local $vArgUpdateSrcFunc = IsArray($aArgs) And UBound($aArgs) > 3 ? $aArgs[3] : Null

    _TestFmkAssert($iErr              = 0,                     "No error with required params only",        $iErr,               0)
    _TestFmkAssert($mPage.iStatus     = $eNormalPage,          "Status is eNormalPage",                     $mPage.iStatus,      $eNormalPage)
    _TestFmkAssert($mPage.sSubheading = $sEmpty,               "Subheading is empty",                       $mPage.sSubheading,  $sEmpty)
    _TestFmkAssert($sStubPathInfoTxt  = $sEmpty,               "Path info label text is empty",             $sStubPathInfoTxt,   $sEmpty)
    _TestFmkAssert($sStubPathLblTxt   = $sDefaultPathLabelTxt, "Path label text is default",                $sStubPathLblTxt,    $sDefaultPathLabelTxt)
    _TestFmkAssert($sStubInputPath    = $sPath,                "Input path text correct",                   $sStubInputPath,     $sPath)
	_TestFmkAssert($sStubBtnBrowse    = "Browse...",           "Button Browse text correct",                $sStubBtnBrowse,     "Browse...")
    _TestFmkAssert($idCtrlPathInfo    = $idLblPathPageInfo,    "LblPathPageInfo registered",                $idCtrlPathInfo,     $idLblPathPageInfo)
    _TestFmkAssert($idCtrlLblPath     = $idLblPath,            "LblPath registered",                        $idCtrlLblPath,      $idLblPath)
    _TestFmkAssert($idCtrlInputPath   = $idInputPath,          "InputPath registered",                      $idCtrlInputPath,    $idInputPath)
    _TestFmkAssert($idCtrlBtnBrowse   = $idBtnBrowse,          "BtnBrowse registered",                      $idCtrlBtnBrowse,    $idBtnBrowse)
    _TestFmkAssert($bBrowseReg,                                "BtnBrowse OnClick handler registered",      $bBrowseReg,         True)
    _TestFmkAssert($vArgInputPath     = $idInputPath,          "OnClick receives InputPath as arg",         $vArgInputPath,      $idInputPath)
    _TestFmkAssert($vArgPathLabel     = $sDefaultPathLabelTxt, "OnClick receives default PathLabel as arg", $vArgPathLabel,      $sDefaultPathLabelTxt)
    _TestFmkAssert($vArgUpdateSrcFunc = $hDefaultAsSrcFunc,    "OnClick receives Default as Func arg",  	$vArgUpdateSrcFunc,  $hDefaultAsSrcFunc)
EndFunc

; ===============================================================================================================================
; Tests - __SetReadyPage
; ===============================================================================================================================

Func _TestSetReadyPage_InvalidGUI()
    _TestFmkHeader("Test: __SetReadyPage() - returns Null and sets @error for invalid GUI")

    _SetStubReturn("IsHWnd", $_1st, False)
	Local $hGUI	 = 1
    Local $mPage = _NewPage()
    Local $mCfg  = _NewInstallerCfg()

    Local $vResult = __SetReadyPage($hGUI, $mPage, $mCfg)
    Local $iErr    = @error

    _TestFmkAssert($vResult = Null,               "Returns Null", 			 $vResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_GUI, "Sets invalid GUI @error", $iErr,    $INST_ERR_INVALID_GUI)
EndFunc

Func _TestSetReadyPage_InvalidCfg()
    _TestFmkHeader("Test: __SetReadyPage() - returns Null and sets @error for invalid config")

	_SetStubReturn("IsHWnd", $_1st, True)
	Local $hGUI	 = 1
    Local $mPage = _NewPage()
    Local $mCfg[]

    Local $vResult = __SetReadyPage($hGUI, $mPage, $mCfg)
    Local $iErr    = @error

    _TestFmkAssert($vResult = Null,               "Returns Null", 				$vResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_CFG, "Sets invalid config @error", $iErr,    $INST_ERR_INVALID_CFG)
EndFunc

Func _TestSetReadyPage_WithAllParams()
    _TestFmkHeader("Test: __SetReadyPage() - sets up page correctly with all params")

    Local $idLblCaption = 20
    Local $idLblInfo    = 21
    _SetStubReturn("IsHWnd",             $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel", $_1st, $idLblCaption)
    _SetStubReturn("GUICtrlCreateLabel", $_2nd, $idLblInfo)
    _SetStubReturn("GUICtrlGetHandle",   $_1st, $idLblCaption)
    _SetStubReturn("GUICtrlGetHandle",   $_2nd, $idLblInfo)


    Local $hGUI        = 1
    Local $sReadyInfo  = "Ready to install"
    Local $sSubHeading = "Review settings"
    Local $mPage       = _NewPage()
    Local $mCfg        = _NewInstallerCfg()

    __SetReadyPage($hGUI, $mPage, $mCfg, $sReadyInfo, $sSubHeading, __TestInfoHndReady)

	Local $sLblCaption 		  = "The following actions will be performed:"
    Local $sStubLblCaption    = _GetStubCall("GUICtrlCreateLabel", $_1st, $Param_Text)
	Local $sStubLblInfoTxt    = _GetStubCall("GUICtrlCreateLabel", $_2nd, $Param_Text)
    Local $idCtrlLblCaption   = _GetPageCtrl($mPage, "LblCaption")
    Local $idCtrlLblInfo      = _GetPageCtrl($mPage, "LblInfo")
    Local $bOnLoadRegistered  = MapExists($mPage, $ONLOAD)
	Local $vUpdateInfoFuncArg = Not $bOnLoadRegistered ? Null : _
								Not MapExists($mPage[$ONLOAD], "aArgs") ? Null : _
								UBound($mPage[$ONLOAD].aArgs) < 3 ? Null : $mPage[$ONLOAD].aArgs[2]

    _TestFmkAssert($mPage.iStatus      = $eProceedPage,      "Status is eProceedPage",                      $mPage.iStatus,       $eProceedPage)
    _TestFmkAssert($mPage.sSubheading  = $sSubHeading,       "Subheading set correctly",                    $mPage.sSubheading,   $sSubHeading)
	_TestFmkAssert($sStubLblCaption    = $sLblCaption,       "Label caption text correct",                  $sStubLblCaption,     $sLblCaption)
    _TestFmkAssert($sStubLblInfoTxt    = $sReadyInfo,        "Info label text correct",                     $sStubLblInfoTxt,     $sReadyInfo)
    _TestFmkAssert($idCtrlLblCaption   = $idLblCaption,      "LblCaption registered",                       $idCtrlLblCaption,    $idLblCaption)
    _TestFmkAssert($idCtrlLblInfo      = $idLblInfo,         "LblInfo registered",                          $idCtrlLblInfo,       $idLblInfo)
    _TestFmkAssert($bOnLoadRegistered  = True,               "OnLoad handler registered",                   $bOnLoadRegistered,   True)
    _TestFmkAssert($vUpdateInfoFuncArg = __TestInfoHndReady, "OnLoad handler receives update func as arg",  $vUpdateInfoFuncArg,  __TestInfoHndReady)
EndFunc

Func _TestSetReadyPage_WithReqParams()
    _TestFmkHeader("Test: __SetReadyPage() - sets up page correctly with required params only")

    Local $idLblCaption = 20
    Local $idLblInfo    = 21
    _SetStubReturn("IsHWnd",             $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel", $_1st, $idLblCaption)
    _SetStubReturn("GUICtrlCreateLabel", $_2nd, $idLblInfo)
    _SetStubReturn("GUICtrlGetHandle",   $_1st, $idLblCaption)
    _SetStubReturn("GUICtrlGetHandle",   $_2nd, $idLblInfo)

    Local $hGUI   = 1
    Local $sEmpty = ""
    Local $mPage  = _NewPage()
    Local $mCfg   = _NewInstallerCfg()

    __SetReadyPage($hGUI, $mPage, $mCfg)
    Local $iErr = @error

	Local $sLblCaption 		  = "The following actions will be performed:"
    Local $sStubLblCaption    = _GetStubCall("GUICtrlCreateLabel", $_1st, $Param_Text)
    Local $sStubLblInfoTxt    = _GetStubCall("GUICtrlCreateLabel", $_2nd, $Param_Text)
    Local $idCtrlLblCaption   = _GetPageCtrl($mPage, "LblCaption")
    Local $idCtrlLblInfo      = _GetPageCtrl($mPage, "LblInfo")
    Local $bOnLoadRegistered  = MapExists($mPage, $ONLOAD)
    Local $vUpdateInfoFuncArg = Not $bOnLoadRegistered ? Null : _
                                Not MapExists($mPage[$ONLOAD], "aArgs") ? Null : _
                                UBound($mPage[$ONLOAD].aArgs) < 3 ? Null : $mPage[$ONLOAD].aArgs[2]

    _TestFmkAssert($iErr              = 0,             "No error with default params",           $iErr,                0)
    _TestFmkAssert($mPage.iStatus     = $eProceedPage, "Status is eProceedPage",                 $mPage.iStatus,       $eProceedPage)
    _TestFmkAssert($mPage.sSubheading = $sEmpty,       "Subheading is empty",                    $mPage.sSubheading,   $sEmpty)
	_TestFmkAssert($sStubLblCaption   = $sLblCaption,  "Label caption text correct",             $sStubLblCaption,     $sLblCaption)
    _TestFmkAssert($sStubLblInfoTxt   = $sEmpty,       "Info label text is empty",               $sStubLblInfoTxt,     $sEmpty)
    _TestFmkAssert($idCtrlLblCaption  = $idLblCaption, "LblCaption registered",                  $idCtrlLblCaption,    $idLblCaption)
    _TestFmkAssert($idCtrlLblInfo     = $idLblInfo,    "LblInfo registered",                     $idCtrlLblInfo,       $idLblInfo)
    _TestFmkAssert($bOnLoadRegistered,                 "OnLoad handler registered",              $bOnLoadRegistered,   True)
    _TestFmkAssert($vUpdateInfoFuncArg = Default,      "OnLoad handler receives Default as arg", $vUpdateInfoFuncArg,  Default)
EndFunc

; ===============================================================================================================================
; Tests - __SetProgressPage
; ===============================================================================================================================
Func _TestSetProgressPage_InvalidGUI()
    _TestFmkHeader("Test: __SetProgressPage() - returns Null and sets @error for invalid GUI")

    _SetStubReturn("IsHWnd", $_1st, False)
    Local $mPage = _NewPage()
    Local $mCfg  = _NewInstallerCfg()

    Local $vResult = __SetProgressPage(1, $mPage, $mCfg, 12, __TestApplyFunc)
    Local $iErr    = @error

    _TestFmkAssert($vResult = Null,               "Returns Null", 			 $vResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_GUI, "Sets invalid GUI @error", $iErr,    $INST_ERR_INVALID_GUI)
EndFunc

Func _TestSetProgressPage_InvalidCfg()
    _TestFmkHeader("Test: __SetProgressPage() - returns Null and sets @error for invalid config")

    _SetStubReturn("IsHWnd", $_1st, True)
	Local $mPage = _NewPage()
    Local $mCfg[]

    Local $vResult = __SetProgressPage(1, $mPage, $mCfg, 12, __TestApplyFunc)
    Local $iErr    = @error

    _TestFmkAssert($vResult = Null,               "Returns Null", 				$vResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_CFG, "Sets invalid config @error", $iErr,    $INST_ERR_INVALID_CFG)
EndFunc

Func _TestSetProgressPage_WithAllParams()
    _TestFmkHeader("Test: __SetProgressPage() - sets up page correctly with all params")

    Local $idLblProgress = 20
    Local $idProgressbar = 21
    _SetStubReturn("IsHWnd",                $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",    $_1st, $idLblProgress)
    _SetStubReturn("GUICtrlCreateProgress", $_1st, $idProgressbar)
    _SetStubReturn("GUICtrlGetHandle",   	$_1st, $idLblProgress)
    _SetStubReturn("GUICtrlGetHandle",   	$_2nd, $idProgressbar)

    Local $hGUI            = 1
    Local $idBtnNext       = 12
    Local $sInstallerTitle = "Test Installer"
    Local $sFailureMsg     = "Install failed"
    Local $sSubHeading     = "Installing..."
    Local $mPage           = _NewPage()
    Local $mCfg            = _NewInstallerCfg()

    __SetProgressPage($hGUI, $mPage, $mCfg, $idBtnNext, __TestApplyFunc, $sInstallerTitle, $sFailureMsg, $sSubHeading)

	Local $sEmpty = ""
    Local $sStubLblProgress  = _GetStubCall("GUICtrlCreateLabel", $_1st, $Param_Text)
	Local $iProgressbarCount = _StubCallCount("GUICtrlCreateProgress")
	Local $idCtrlLblProgress = _GetPageCtrl($mPage, "LblProgress")
    Local $idCtrlProgressbar = _GetPageCtrl($mPage, "Progressbar")
    Local $bAfterLoadReg     = MapExists($mPage, $AFTERLOAD)
    Local $aArgs             = Not $bAfterLoadReg ? Null : _
                               Not MapExists($mPage[$AFTERLOAD], "aArgs") ? Null : $mPage[$AFTERLOAD].aArgs

    Local $vArgHWin          = IsArray($aArgs) And UBound($aArgs) > 1 ? $aArgs[1] : Null
    Local $vArgLblProgress   = IsArray($aArgs) And UBound($aArgs) > 2 ? $aArgs[2] : Null
    Local $vArgProgressbar   = IsArray($aArgs) And UBound($aArgs) > 3 ? $aArgs[3] : Null
    Local $vArgBtnNext       = IsArray($aArgs) And UBound($aArgs) > 4 ? $aArgs[4] : Null
    Local $vArgFunc          = IsArray($aArgs) And UBound($aArgs) > 5 ? $aArgs[5] : Null
    Local $vArgTitle         = IsArray($aArgs) And UBound($aArgs) > 6 ? $aArgs[6] : Null
    Local $vArgFailureMsg    = IsArray($aArgs) And UBound($aArgs) > 7 ? $aArgs[7] : Null

    _TestFmkAssert($mPage.iStatus     = $eProcessingPage,  "Status is eProcessingPage",            		$mPage.iStatus,      $eProcessingPage)
    _TestFmkAssert($mPage.sSubheading = $sSubHeading,      "Subheading set correctly",             		$mPage.sSubheading,  $sSubHeading)
	_TestFmkAssert($sStubLblProgress  = $sEmpty,       	   "Label progress is empty",                  	$sStubLblProgress,   $sEmpty)
	_TestFmkAssert($iProgressbarCount = 1,       		   "Progressbar was created",                  	$iProgressbarCount,  1)
    _TestFmkAssert($idCtrlLblProgress = $idLblProgress,    "LblProgress registered",               		$idCtrlLblProgress,  $idLblProgress)
    _TestFmkAssert($idCtrlProgressbar = $idProgressbar,    "Progressbar registered",               		$idCtrlProgressbar,  $idProgressbar)
    _TestFmkAssert($bAfterLoadReg,                         "AfterLoad handler registered",         		$bAfterLoadReg,      True)
    _TestFmkAssert($vArgHWin          = $hGUI,             "AfterLoad receives hGUI as arg",       		$vArgHWin,           $hGUI)
    _TestFmkAssert($vArgLblProgress   = $idLblProgress,    "AfterLoad receives LblProgress as arg",		$vArgLblProgress,    $idLblProgress)
    _TestFmkAssert($vArgProgressbar   = $idProgressbar,    "AfterLoad receives Progressbar as arg",		$vArgProgressbar,    $idProgressbar)
    _TestFmkAssert($vArgBtnNext       = $idBtnNext,        "AfterLoad receives BtnNext as arg",    		$vArgBtnNext,        $idBtnNext)
    _TestFmkAssert($vArgFunc          = __TestApplyFunc,   "AfterLoad receives apply func as arg", 		$vArgFunc,           __TestApplyFunc)
    _TestFmkAssert($vArgTitle         = $sInstallerTitle,  "AfterLoad receives installer title as arg", $vArgTitle,          $sInstallerTitle)
    _TestFmkAssert($vArgFailureMsg    = $sFailureMsg,      "AfterLoad receives failure msg as arg",	    $vArgFailureMsg,     $sFailureMsg)
EndFunc

Func _TestSetProgressPage_WithReqParams()
    _TestFmkHeader("Test: __SetProgressPage() - sets up page correctly with required params only")

    Local $idLblProgress = 20
    Local $idProgressbar = 21
    _SetStubReturn("IsHWnd",                $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",    $_1st, $idLblProgress)
    _SetStubReturn("GUICtrlCreateProgress", $_1st, $idProgressbar)
    _SetStubReturn("GUICtrlGetHandle",   	$_1st, $idLblProgress)
    _SetStubReturn("GUICtrlGetHandle",   	$_2nd, $idProgressbar)

    Local $hGUI                  = 1
    Local $idBtnNext             = 12
    Local $sEmpty                = ""
    Local $sDefaultTitle         = "Installer"
    Local $sDefaultFailureMsg    = "Process failed"
    Local $mPage                 = _NewPage()
    Local $mCfg                  = _NewInstallerCfg()

    __SetProgressPage($hGUI, $mPage, $mCfg, $idBtnNext, __TestApplyFunc)
    Local $iErr = @error

	Local $sEmpty = ""
    Local $sStubLblProgress  = _GetStubCall("GUICtrlCreateLabel", $_1st, $Param_Text)
	Local $iProgressbarCount = _StubCallCount("GUICtrlCreateProgress")
    Local $idCtrlLblProgress = _GetPageCtrl($mPage, "LblProgress")
    Local $idCtrlProgressbar = _GetPageCtrl($mPage, "Progressbar")
    Local $bAfterLoadReg     = MapExists($mPage, $AFTERLOAD)
    Local $aArgs             = Not $bAfterLoadReg ? Null : _
                               Not MapExists($mPage[$AFTERLOAD], "aArgs") ? Null : $mPage[$AFTERLOAD].aArgs

    Local $vArgHWin          = IsArray($aArgs) And UBound($aArgs) > 1 ? $aArgs[1] : Null
    Local $vArgLblProgress   = IsArray($aArgs) And UBound($aArgs) > 2 ? $aArgs[2] : Null
    Local $vArgProgressbar   = IsArray($aArgs) And UBound($aArgs) > 3 ? $aArgs[3] : Null
    Local $vArgBtnNext       = IsArray($aArgs) And UBound($aArgs) > 4 ? $aArgs[4] : Null
    Local $vArgFunc          = IsArray($aArgs) And UBound($aArgs) > 5 ? $aArgs[5] : Null
    Local $vArgTitle         = IsArray($aArgs) And UBound($aArgs) > 6 ? $aArgs[6] : Null
    Local $vArgFailureMsg    = IsArray($aArgs) And UBound($aArgs) > 7 ? $aArgs[7] : Null

    _TestFmkAssert($iErr              = 0,              	 "No error with default params",           	   $iErr,              0)
    _TestFmkAssert($mPage.iStatus     = $eProcessingPage, 	 "Status is eProcessingPage",              	   $mPage.iStatus,     $eProcessingPage)
    _TestFmkAssert($mPage.sSubheading = $sEmpty,        	 "Subheading is empty",                    	   $mPage.sSubheading, $sEmpty)
	_TestFmkAssert($sStubLblProgress  = $sEmpty,       	     "Label progress is empty",                  	$sStubLblProgress,   $sEmpty)
	_TestFmkAssert($iProgressbarCount = 1,       		     "Progressbar was created",                  	$iProgressbarCount,  1)
    _TestFmkAssert($idCtrlLblProgress = $idLblProgress, 	 "LblProgress registered",                 	   $idCtrlLblProgress, $idLblProgress)
    _TestFmkAssert($idCtrlProgressbar = $idProgressbar, 	 "Progressbar registered",                 	   $idCtrlProgressbar, $idProgressbar)
    _TestFmkAssert($bAfterLoadReg,                      	 "AfterLoad handler registered",           	   $bAfterLoadReg,     True)
    _TestFmkAssert($vArgHWin          = $hGUI,            	 "AfterLoad receives hGUI as arg",         	   $vArgHWin,          $hGUI)
    _TestFmkAssert($vArgLblProgress   = $idLblProgress,   	 "AfterLoad receives LblProgress as arg",  	   $vArgLblProgress,   $idLblProgress)
    _TestFmkAssert($vArgProgressbar   = $idProgressbar,   	 "AfterLoad receives Progressbar as arg",  	   $vArgProgressbar,   $idProgressbar)
    _TestFmkAssert($vArgBtnNext       = $idBtnNext,       	 "AfterLoad receives BtnNext as arg",      	   $vArgBtnNext,       $idBtnNext)
    _TestFmkAssert($vArgFunc          = __TestApplyFunc,  	 "AfterLoad receives apply func as arg",   	   $vArgFunc,          __TestApplyFunc)
    _TestFmkAssert($vArgTitle         = $sDefaultTitle,   	 "AfterLoad receives default installer title", $vArgTitle,         $sDefaultTitle)
    _TestFmkAssert($vArgFailureMsg    = $sDefaultFailureMsg, "AfterLoad receives default failure msg", 	   $vArgFailureMsg,    $sDefaultFailureMsg)
EndFunc

; ===============================================================================================================================
; Tests - __SetFinishPage
; ===============================================================================================================================
Func _TestSetFinishPage_InvalidGUI()
    _TestFmkHeader("Test: __SetFinishPage() - returns Null and sets @error for invalid GUI")

    _SetStubReturn("IsHWnd", $_1st, False)
    Local $mPage = _NewPage()
    Local $mCfg  = _NewInstallerCfg()

    Local $vResult = __SetFinishPage(1, $mPage, $mCfg, 10, 11, "Done")
    Local $iErr    = @error

    _TestFmkAssert($vResult = Null,               "Returns Null", 			 $vResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_GUI, "Sets invalid GUI @error", $iErr,    $INST_ERR_INVALID_GUI)
EndFunc

Func _TestSetFinishPage_InvalidCfg()
    _TestFmkHeader("Test: __SetFinishPage() - returns Null and sets @error for invalid config")

	_SetStubReturn("IsHWnd", $_1st, True)
    Local $mPage = _NewPage()
    Local $mCfg[]

    Local $vResult = __SetFinishPage(1, $mPage, $mCfg, 10, 11, "Done")
    Local $iErr    = @error

    _TestFmkAssert($vResult = Null,               "Returns Null", 				$vResult, Null)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_CFG, "Sets invalid config @error", $iErr,    $INST_ERR_INVALID_CFG)
EndFunc

Func _TestSetFinishPage_WithAllParams()
    _TestFmkHeader("Test: __SetFinishPage() - sets up page correctly with all params")

    Local $idLblProgress  = 10
    Local $idProgressbar  = 11
    Local $idLblFinishMsg = 20
    Local $idChkBoxDoc    = 21
    _SetStubReturn("IsHWnd",                $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel",    $_1st, $idLblFinishMsg)
    _SetStubReturn("GUICtrlCreateCheckbox", $_1st, $idChkBoxDoc)
    _SetStubReturn("GUICtrlGetHandle",   	$_1st, $idLblProgress)
    _SetStubReturn("GUICtrlGetHandle",   	$_2nd, $idProgressbar)
    _SetStubReturn("GUICtrlGetHandle",   	$_3rd, $idLblFinishMsg)
    _SetStubReturn("GUICtrlGetHandle",   	$_4th, $idChkBoxDoc)

    Local $hGUI        = 1
    Local $sFinishMsg  = "Installation complete"
    Local $sDocFile    = "C:\docs\TestFramework.chm"
    Local $sSubHeading = "Finished"
    Local $mPage       = _NewPage()
    Local $mCfg        = _NewInstallerCfg()

    __SetFinishPage($hGUI, $mPage, $mCfg, $idLblProgress, $idProgressbar, $sFinishMsg, $sDocFile, $sSubHeading)

    Local $sStubFinishMsg     = _GetStubCall("GUICtrlCreateLabel", $_1st, $Param_Text)
	Local $sStubChkBoxDoc     = _GetStubCall("GUICtrlCreateCheckbox", $_1st, $Param_Text)
    Local $idCtrlLblProgress  = _GetPageCtrl($mPage, "LblProgress")
    Local $idCtrlProgressbar  = _GetPageCtrl($mPage, "Progressbar")
    Local $idCtrlLblFinishMsg = _GetPageCtrl($mPage, "LblFinishMsg")
    Local $idCtrlChkBoxDoc    = _GetPageCtrl($mPage, "ChkBoxOpenDoc")
    Local $bAfterLoadReg      = MapExists($mPage, $AFTERLOAD)
    Local $bOnCloseReg        = MapExists($mPage, $ONCLOSE)
    Local $aOnCloseArgs       = Not $bOnCloseReg ? Null : _
                                Not MapExists($mPage[$ONCLOSE], "aArgs") ? Null : $mPage[$ONCLOSE].aArgs

    Local $vArgChkBoxDoc      = IsArray($aOnCloseArgs) And UBound($aOnCloseArgs) > 1 ? $aOnCloseArgs[1] : Null
    Local $vArgDocFile        = IsArray($aOnCloseArgs) And UBound($aOnCloseArgs) > 2 ? $aOnCloseArgs[2] : Null

    _TestFmkAssert($mPage.iStatus       = $eFinishPage,    		"Status is eFinishPage",              $mPage.iStatus,       $eFinishPage)
    _TestFmkAssert($mPage.sSubheading   = $sSubHeading,    		"Subheading set correctly",           $mPage.sSubheading,   $sSubHeading)
    _TestFmkAssert($sStubFinishMsg      = $sFinishMsg,     		"Finish msg label text correct",      $sStubFinishMsg,      $sFinishMsg)
    _TestFmkAssert($idCtrlLblProgress   = $idLblProgress,  		"LblProgress registered",             $idCtrlLblProgress,   $idLblProgress)
    _TestFmkAssert($idCtrlProgressbar   = $idProgressbar,  		"Progressbar registered",             $idCtrlProgressbar,   $idProgressbar)
    _TestFmkAssert($idCtrlLblFinishMsg  = $idLblFinishMsg, 		"LblFinishMsg registered",            $idCtrlLblFinishMsg,  $idLblFinishMsg)
	_TestFmkAssert($sStubChkBoxDoc  	= "Open documentation", "ChkBoxOpenDoc created",      		  $sStubChkBoxDoc,      "Open documentation")
    _TestFmkAssert($idCtrlChkBoxDoc     = $idChkBoxDoc,    		"ChkBoxOpenDoc registered",           $idCtrlChkBoxDoc,     $idChkBoxDoc)
    _TestFmkAssert($bAfterLoadReg,                         		"AfterLoad handler registered",       $bAfterLoadReg,       True)
    _TestFmkAssert($bOnCloseReg,                           		"OnClose handler registered",         $bOnCloseReg,         True)
    _TestFmkAssert($vArgChkBoxDoc = $idChkBoxDoc,          		"OnClose receives ChkBoxDoc as arg",  $vArgChkBoxDoc,       $idChkBoxDoc)
    _TestFmkAssert($vArgDocFile   = $sDocFile,             		"OnClose receives DocFile as arg",    $vArgDocFile,         $sDocFile)
EndFunc

Func _TestSetFinishPage_WithReqParams()
    _TestFmkHeader("Test: __SetFinishPage() - sets up page correctly with required params only")

    Local $idLblProgress  = 10
    Local $idProgressbar  = 11
    Local $idLblFinishMsg = 20
    _SetStubReturn("IsHWnd",             $_1st, True)
    _SetStubReturn("GUICtrlCreateLabel", $_1st, $idLblFinishMsg)
    _SetStubReturn("GUICtrlGetHandle",   	$_1st, $idLblProgress)
    _SetStubReturn("GUICtrlGetHandle",   	$_2nd, $idProgressbar)
    _SetStubReturn("GUICtrlGetHandle",   	$_3rd, $idLblFinishMsg)

    Local $hGUI   = 1
    Local $sEmpty = ""
    Local $mPage  = _NewPage()
    Local $mCfg   = _NewInstallerCfg()

    __SetFinishPage($hGUI, $mPage, $mCfg, $idLblProgress, $idProgressbar)
    Local $iErr = @error

    Local $sStubFinishMsg     = _GetStubCall("GUICtrlCreateLabel", $_1st, $Param_Text)
	Local $iChkBoxDocCount    = _StubCallCount("GUICtrlCreateCheckbox")
    Local $idCtrlLblProgress  = _GetPageCtrl($mPage, "LblProgress")
    Local $idCtrlProgressbar  = _GetPageCtrl($mPage, "Progressbar")
    Local $idCtrlLblFinishMsg = _GetPageCtrl($mPage, "LblFinishMsg")
    Local $idCtrlChkBoxDoc    = _GetPageCtrl($mPage, "ChkBoxOpenDoc")
    Local $bAfterLoadReg      = MapExists($mPage, $AFTERLOAD)
    Local $bOnCloseReg        = MapExists($mPage, $ONCLOSE)

    _TestFmkAssert($iErr               = 0,               "No error with required params only", $iErr,               0)
    _TestFmkAssert($mPage.iStatus      = $eFinishPage,    "Status is eFinishPage",              $mPage.iStatus,      $eFinishPage)
    _TestFmkAssert($mPage.sSubheading  = $sEmpty,         "Subheading is empty",                $mPage.sSubheading,  $sEmpty)
    _TestFmkAssert($sStubFinishMsg     = $sEmpty,         "Finish msg label text is empty",     $sStubFinishMsg,     $sEmpty)
	_TestFmkAssert($iChkBoxDocCount    = 0,       		  "ChkBoxOpenDoc was not created",      $iChkBoxDocCount,    0)
    _TestFmkAssert($idCtrlLblProgress  = $idLblProgress,  "LblProgress registered",             $idCtrlLblProgress,  $idLblProgress)
    _TestFmkAssert($idCtrlProgressbar  = $idProgressbar,  "Progressbar registered",             $idCtrlProgressbar,  $idProgressbar)
    _TestFmkAssert($idCtrlLblFinishMsg = $idLblFinishMsg, "LblFinishMsg registered",            $idCtrlLblFinishMsg, $idLblFinishMsg)
    _TestFmkAssert($idCtrlChkBoxDoc    = Null,            "ChkBoxOpenDoc not registered",       $idCtrlChkBoxDoc,    Null)
    _TestFmkAssert($bAfterLoadReg,                        "AfterLoad handler registered",       $bAfterLoadReg,      True)
    _TestFmkAssert(Not $bOnCloseReg,                      "OnClose handler not registered",     $bOnCloseReg,        False)
EndFunc

; ===============================================================================================================================
; Tests - _AddIntroPage
; ===============================================================================================================================
Func _TestAddIntroPage_InvalidWizard()
    _TestFmkHeader("Test: _AddIntroPage() - returns 0 and sets @error for invalid wizard")

    Local $mWizard[]
    Local $mCfg = _NewInstallerCfg()

    Local $iResult = _AddIntroPage($mWizard, $mCfg)
    Local $iErr    = @error

    _TestFmkAssert($iResult = 0,                     "Returns 0",   				 $iResult, 0)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_WIZARD, "Sets invalid wizard @error", $iErr,    $INST_ERR_INVALID_WIZARD)
EndFunc

Func _TestAddIntroPage_SetIntroPageFails()
    _TestFmkHeader("Test: _AddIntroPage() - returns 0 and sets @error when __SetIntroPage fails")

    __SetupPageTemplateStubs()
    Local $mInvalidCfg[]
    Local $mWizard = __BuildTestWizard()

    Local $iResult = _AddIntroPage($mWizard, $mInvalidCfg)
    Local $iErr    = @error

    _TestFmkAssert($iResult = 0,                     "Returns 0 on failure", $iResult,                    0)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_CFG,    "Sets @error",          $iErr,                       $INST_ERR_INVALID_CFG)
    _TestFmkAssert(__MaxPages($mWizard.mPages) = 0,  "No page added",        __MaxPages($mWizard.mPages), 0)
EndFunc

Func _TestAddIntroPage_AddsPageAndStoresIndex()
    _TestFmkHeader("Test: _AddIntroPage() - adds page and stores index in wizard map")

    __SetupPageTemplateStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = __BuildTestWizard()

    Local $iResult = _AddIntroPage($mWizard, $mCfg)

    _TestFmkAssert($iResult = 1,                    "Returns page index 1",         $iResult,              1)
    _TestFmkAssert($mWizard.iIntroPageId = 1,       "Stores index in wizard map",   $mWizard.iIntroPageId, 1)
    _TestFmkAssert(__MaxPages($mWizard.mPages) = 1, "Page added to wizard",       __MaxPages($mWizard.mPages), 1)
EndFunc

; ===============================================================================================================================
; Tests - _AddPathPage
; ===============================================================================================================================
Func _TestAddPathPage_InvalidWizard()
    _TestFmkHeader("Test: _AddPathPage() - returns 0 and sets @error for invalid wizard")

    Local $mWizard[]
    Local $mCfg = _NewInstallerCfg()

    Local $iResult = _AddPathPage($mWizard, $mCfg, "C:\Path", Default)
    Local $iErr    = @error

    _TestFmkAssert($iResult = 0,                     "Returns 0",   				 $iResult, 0)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_WIZARD, "Sets invalid wizard @error", $iErr,    $INST_ERR_INVALID_WIZARD)
EndFunc

Func _TestAddPathPage_SetPathPageFails()
    _TestFmkHeader("Test: _AddPathPage() - returns 0 and sets @error when __SetPathPage fails")

    __SetupPageTemplateStubs()
    Local $mCfg[]
    Local $mWizard = __BuildTestWizard()

    Local $iResult = _AddPathPage($mWizard, $mCfg, "C:\Path", Default)
    Local $iErr    = @error

    _TestFmkAssert($iResult = 0,                     "Returns 0 on failure", $iResult,                    0)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_CFG,    "Sets @error",          $iErr,                       $INST_ERR_INVALID_CFG)
    _TestFmkAssert(__MaxPages($mWizard.mPages) = 0,  "No page added",        __MaxPages($mWizard.mPages), 0)
EndFunc

Func _TestAddPathPage_AddsPageAndStoresIndex()
    _TestFmkHeader("Test: _AddPathPage() - adds page and stores index in wizard map")

    __SetupPageTemplateStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = __BuildTestWizard()

    Local $iResult = _AddPathPage($mWizard, $mCfg, "C:\Path", Default)

    _TestFmkAssert($iResult = 1,                 "Returns page index 1",       $iResult,             1)
    _TestFmkAssert($mWizard.iPathPageId = 1,     "Stores index in wizard map", $mWizard.iPathPageId, 1)
    _TestFmkAssert(__MaxPages($mWizard.mPages) = 1, "Page added to wizard",    __MaxPages($mWizard.mPages), 1)
EndFunc

; ===============================================================================================================================
; Tests - _AddReadyPage
; ===============================================================================================================================
Func _TestAddReadyPage_InvalidWizard()
    _TestFmkHeader("Test: _AddReadyPage() - returns 0 and sets @error for invalid wizard")

    Local $mWizard[]
    Local $mCfg = _NewInstallerCfg()

    Local $iResult = _AddReadyPage($mWizard, $mCfg)
    Local $iErr    = @error

    _TestFmkAssert($iResult = 0,                     "Returns 0",   				 $iResult, 0)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_WIZARD, "Sets invalid wizard @error", $iErr,    $INST_ERR_INVALID_WIZARD)
EndFunc

Func _TestAddReadyPage_SetReadyPageFails()
    _TestFmkHeader("Test: _AddReadyPage() - returns 0 and sets @error when __SetReadyPage fails")

    __SetupPageTemplateStubs()
    Local $mCfg[]
    Local $mWizard = __BuildTestWizard()

    Local $iResult = _AddReadyPage($mWizard, $mCfg)
    Local $iErr    = @error

    _TestFmkAssert($iResult = 0,                     "Returns 0 on failure", $iResult,                    0)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_CFG,    "Sets @error",          $iErr,                       $INST_ERR_INVALID_CFG)
    _TestFmkAssert(__MaxPages($mWizard.mPages) = 0,  "No page added",        __MaxPages($mWizard.mPages), 0)
EndFunc

Func _TestAddReadyPage_AddsPageAndStoresIndex()
    _TestFmkHeader("Test: _AddReadyPage() - adds page and stores index in wizard map")

    __SetupPageTemplateStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = __BuildTestWizard()

    Local $iResult = _AddReadyPage($mWizard, $mCfg)

    _TestFmkAssert($iResult = 1,                  "Returns page index 1",       $iResult,              1)
    _TestFmkAssert($mWizard.iReadyPageId = 1,     "Stores index in wizard map", $mWizard.iReadyPageId, 1)
    _TestFmkAssert(__MaxPages($mWizard.mPages) = 1, "Page added to wizard",     __MaxPages($mWizard.mPages), 1)
EndFunc

; ===============================================================================================================================
; Tests - _AddProgressPage
; ===============================================================================================================================
Func _TestAddProgressPage_InvalidWizard()
    _TestFmkHeader("Test: _AddProgressPage() - returns 0 and sets @error for invalid wizard")

    Local $mWizard[]
    Local $mCfg = _NewInstallerCfg()

    Local $iResult = _AddProgressPage($mWizard, $mCfg, __TestApplyFunc)
    Local $iErr    = @error

    _TestFmkAssert($iResult = 0,                     "Returns 0",   				 $iResult, 0)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_WIZARD, "Sets invalid wizard @error", $iErr,    $INST_ERR_INVALID_WIZARD)
EndFunc

Func _TestAddProgressPage_SetProgressPageFails()
    _TestFmkHeader("Test: _AddProgressPage() - returns 0 and sets @error when __SetProgressPage fails")

    __SetupPageTemplateStubs()
    Local $mCfg[]
    Local $mWizard = __BuildTestWizard()

    Local $iResult = _AddProgressPage($mWizard, $mCfg, __TestApplyFunc)
    Local $iErr    = @error

    _TestFmkAssert($iResult = 0,                     "Returns 0 on failure", $iResult,                    0)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_CFG,    "Sets @error",          $iErr,                       $INST_ERR_INVALID_CFG)
    _TestFmkAssert(__MaxPages($mWizard.mPages) = 0,  "No page added",        __MaxPages($mWizard.mPages), 0)
EndFunc

Func _TestAddProgressPage_AddsPageAndStoresIndex()
    _TestFmkHeader("Test: _AddProgressPage() - adds page and stores index in wizard map")

    __SetupPageTemplateStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = __BuildTestWizard()

    Local $iResult = _AddProgressPage($mWizard, $mCfg, __TestApplyFunc)

    _TestFmkAssert($iResult = 1,                     "Returns page index 1",       $iResult,                 1)
    _TestFmkAssert($mWizard.iProgressPageId = 1,     "Stores index in wizard map", $mWizard.iProgressPageId, 1)
    _TestFmkAssert(__MaxPages($mWizard.mPages) = 1,  "Page added to wizard",       __MaxPages($mWizard.mPages), 1)
EndFunc

; ===============================================================================================================================
; Tests - _AddFinishPage
; ===============================================================================================================================
Func _TestAddFinishPage_InvalidWizard()
    _TestFmkHeader("Test: _AddFinishPage() - returns 0 and sets @error for invalid wizard")

    Local $mWizard[]
    Local $mCfg = _NewInstallerCfg()

    Local $iResult = _AddFinishPage($mWizard, $mCfg, 10, 11, "Done")
    Local $iErr    = @error

    _TestFmkAssert($iResult = 0,                     "Returns 0",   				 $iResult, 0)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_WIZARD, "Sets invalid wizard @error", $iErr,    $INST_ERR_INVALID_WIZARD)
EndFunc

Func _TestAddFinishPage_SetFinishPageFails()
    _TestFmkHeader("Test: _AddFinishPage() - returns 0 and sets @error when __SetFinishPage fails")

    __SetupPageTemplateStubs()
    Local $mCfg[]
    Local $mWizard = __BuildTestWizard()

    Local $iResult = _AddFinishPage($mWizard, $mCfg, 10, 11, "Done")
    Local $iErr    = @error

    _TestFmkAssert($iResult = 0,                     "Returns 0 on failure", $iResult,                    0)
    _TestFmkAssert($iErr = $INST_ERR_INVALID_CFG,    "Sets @error",          $iErr,                       $INST_ERR_INVALID_CFG)
    _TestFmkAssert(__MaxPages($mWizard.mPages) = 0,  "No page added",        __MaxPages($mWizard.mPages), 0)
EndFunc

Func _TestAddFinishPage_AddsPageAndStoresIndex()
    _TestFmkHeader("Test: _AddFinishPage() - adds page and stores index in wizard map")

    __SetupPageTemplateStubs()
    Local $mCfg    = _NewInstallerCfg()
    Local $mWizard = __BuildTestWizard()

    Local $iResult = _AddFinishPage($mWizard, $mCfg, 10, 11, "Done")

    _TestFmkAssert($iResult = 1,                   "Returns page index 1",       $iResult,               1)
    _TestFmkAssert($mWizard.iFinishPageId = 1,     "Stores index in wizard map", $mWizard.iFinishPageId, 1)
    _TestFmkAssert(__MaxPages($mWizard.mPages) = 1, "Page added to wizard",      __MaxPages($mWizard.mPages), 1)
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialInstallerPageTemplatesTest_ValidateTemplateArgs(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestValidateTemplateArgs_InvalidGUI, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestValidateTemplateArgs_InvalidCfg, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestValidateTemplateArgs_Valid, 		$bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplatesTest_SetIntroPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestSetIntroPage_InvalidGUI,    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetIntroPage_InvalidCfg,    $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetIntroPage_WithAllParams, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetIntroPage_WithReqParams, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplatesTest_SetPathPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestSetPathPage_InvalidGUI,    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetPathPage_InvalidCfg,    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetPathPage_WithAllParams, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetPathPage_WithReqParams, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplatesTest_SetReadyPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestSetReadyPage_InvalidGUI,    $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetReadyPage_InvalidCfg,    $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetReadyPage_WithAllParams, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetReadyPage_WithReqParams, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplatesTest_SetProgressPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestSetProgressPage_InvalidGUI, 	  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetProgressPage_InvalidCfg, 	  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetProgressPage_WithAllParams, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetProgressPage_WithReqParams, $bAllPassed)

EndFunc

Func __RunCrucialInstallerPageTemplatesTest_SetFinishPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestSetFinishPage_InvalidGUI, 	$bAllPassed)
    $bAllPassed = _TestFmkRun(_TestSetFinishPage_InvalidCfg, 	$bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetFinishPage_WithAllParams, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestSetFinishPage_WithReqParams, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplatesTest_AddIntroPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestAddIntroPage_InvalidWizard,          $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestAddIntroPage_SetIntroPageFails,      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestAddIntroPage_AddsPageAndStoresIndex, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplatesTest_AddPathPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestAddPathPage_InvalidWizard,          $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestAddPathPage_SetPathPageFails,       $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestAddPathPage_AddsPageAndStoresIndex, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplatesTest_AddReadyPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestAddReadyPage_InvalidWizard,          $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestAddReadyPage_SetReadyPageFails,      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestAddReadyPage_AddsPageAndStoresIndex, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplatesTest_AddProgressPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestAddProgressPage_InvalidWizard,          $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestAddProgressPage_SetProgressPageFails,   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestAddProgressPage_AddsPageAndStoresIndex, $bAllPassed)
EndFunc

Func __RunCrucialInstallerPageTemplatesTest_AddFinishPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestAddFinishPage_InvalidWizard,          $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestAddFinishPage_SetFinishPageFails,     $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestAddFinishPage_AddsPageAndStoresIndex, $bAllPassed)
EndFunc

Func _RunCrucialInstallerPageTemplatesTests($bWriteSummary = True)
    Local $bAllPassed = True
	__RunCrucialInstallerPageTemplatesTest_ValidateTemplateArgs($bAllPassed)
    __RunCrucialInstallerPageTemplatesTest_SetIntroPage($bAllPassed)
    __RunCrucialInstallerPageTemplatesTest_SetPathPage($bAllPassed)
    __RunCrucialInstallerPageTemplatesTest_SetReadyPage($bAllPassed)
    __RunCrucialInstallerPageTemplatesTest_SetProgressPage($bAllPassed)
    __RunCrucialInstallerPageTemplatesTest_SetFinishPage($bAllPassed)
    __RunCrucialInstallerPageTemplatesTest_AddIntroPage($bAllPassed)
    __RunCrucialInstallerPageTemplatesTest_AddPathPage($bAllPassed)
    __RunCrucialInstallerPageTemplatesTest_AddReadyPage($bAllPassed)
    __RunCrucialInstallerPageTemplatesTest_AddProgressPage($bAllPassed)
    __RunCrucialInstallerPageTemplatesTest_AddFinishPage($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialInstallerPageTemplatesTests, $sScriptName)
