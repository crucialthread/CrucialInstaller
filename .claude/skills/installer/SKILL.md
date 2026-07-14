---
name: CrucialInstaller
description: Generates Windows installer and uninstaller AutoIt scripts. Use when asked to create an installer, setup wizard, or uninstaller for any project.
---

# CrucialInstaller - AutoIt Installer Generation Skill

## Description

Generates complete AutoIt installer and uninstaller scripts (`.au3` files) following the CrucialInstaller conventions. The generated scripts are compiled by the developer with Aut2Exe into self-contained `.exe` files. The installer can install anything - applications, libraries, tools, drivers, configuration.

Supports both interactive mode (guided workflow with user confirmation) and agent mode (autonomous generation with assumptions log, no user interaction required).

Use this skill when asked to:
- "generate an installer", "create a setup wizard", "build an installer script"
- "create an installer for..."
- "use CrucialInstaller"
- "write an installer and uninstaller for..."
- "use CrucialInstaller in agent mode for..."
- "autonomously generate an installer for..."

---

## Guided Workflow

Always follow this workflow in order. Never skip to generation without completing discovery, inference, and confirmation first.

### Agent Mode Detection

Before starting the workflow, check if the request signals autonomous/agent mode. Agent mode is active when the initial request contains any of: `agent mode`, `autonomous`, `no user interaction`, or is clearly coming from an automated pipeline with no human present.

In agent mode: skip asking questions, make reasonable assumptions, skip waiting for confirmation, and output an assumptions log after generation.

In interactive mode (default): follow the full guided workflow with questions and confirmation.

### Step 1 - Discover

Ask the user for the project folder path or public GitHub repository URL if not already provided. Then scan the project:

**If a local folder path is provided:**
- List all files and subfolders
- Read relevant files directly from disk

**If a public GitHub repository URL is provided:**
- Fetch the repository file tree from the GitHub API: `https://api.github.com/repos/{owner}/{repo}/git/trees/HEAD?recursive=1`
- Fetch the raw content of relevant files using: `https://raw.githubusercontent.com/{owner}/{repo}/main/{path}`
- If `main` branch returns 404, try `master` instead

**In both cases, look for:**
- Candidate installable files (compiled outputs, libraries, docs, assets)
- Existing version numbers in source files, README, or any manifest
- Existing product name in README, source headers, or folder name
- Multiple categories of installable content that might suggest installation modes
- Documentation files (CHM, PDF, HTML)
- Existing registry constants or installer scripts that reveal the intended structure

Do this silently and efficiently. Do not narrate the scan step by step.

### Step 2 - Infer

From what was discovered, infer as much as possible without asking the user:

- **Product name** - from README title, folder name, or source file headers
- **Version** - from source files, README, or existing constants
- **Installer archetype** - simple (one way to install) or multi-mode (meaningful user choice about what to install)
- **What gets installed** - which files, to which locations
- **Default install paths** - based on what the product is
- **Progress/finish pattern** - combined page if finish message is always the same, separate pages with `__UpdateFinishPage` if it varies by runtime state
- **Open documentation checkbox** - yes if a CHM or doc file is being installed
- **Registry detection** - how to find default paths at install time

Keep a record of what was inferred vs what still needs to be asked.

### Step 3 - Ask

**Interactive mode:** Ask only what could not be inferred. Ask one topic at a time in plain language - not in technical installer terms. Never ask about implementation details the user would not understand or care about.

Things typically needing confirmation or input:
- Author name
- Whether multiple install modes are wanted (if unclear from structure)
- Whether the user wants an "Open documentation" option on the finish page
- Confirmation of default install paths if they were guessed

Things to never ask:
- Window sizes, fonts, button sizes - the SKILL decides these
- Whether to use combined or separate finish page - the SKILL decides this
- Registry key names - the SKILL generates these from the product name
- Page count or page structure - the SKILL decides this
- Any AutoIt-specific implementation detail

**Agent mode:** Skip asking entirely. Make reasonable assumptions for anything that could not be inferred:
- Author → `"Unknown"` if not found anywhere in the project
- Install mode → Simple installer if unclear from project structure
- Install path → `C:\Program Files\ProductName\`
- Open documentation checkbox → yes if a CHM or doc file is being installed, no otherwise
- Upgrade detection → always include

### Step 4 - Summary

**Interactive mode:** Present a clear confirmation summary and wait for explicit confirmation before generating. If the user corrects anything, update the summary and re-present before generating:

```
Here is what I will generate - please confirm or correct anything before I proceed:

Product:       {{PRODUCT_NAME}} v{{VERSION}}
Author:        {{AUTHOR}}
Type:          Simple installer / Multi-mode installer (Full: ... | Lite: ...)

INSTALLER
  Pages:       Welcome -> Install Path -> Ready -> Progress/Finish
  Installs:
    - ProductFile.dll    -> C:\Program Files\ProductName\
    - ProductDocs.chm   -> C:\Program Files\ProductName\
    - Uninstaller.exe   -> C:\Program Files\ProductName\
  Registry:
    - Install record at HKLM\SOFTWARE\ProductName
    - Add/Remove Programs entry
  Finish:      "Open documentation" checkbox -> opens ProductDocs.chm

UNINSTALLER
  Removes:
    - ProductFile.dll from C:\Program Files\ProductName\
    - ProductDocs.chm from C:\Program Files\ProductName\
    - Removes folder if empty
    - Cleans up registry entries
  Self-relaunch: yes (copies to %TEMP% to delete own folder)

Output files:
  - ProductNameInstaller.au3
  - ProductNameUninstaller.au3

Shall I generate these?
```

**Agent mode:** Output the same summary but replace "Shall I generate these?" with "Proceeding with generation based on the above." and continue immediately to Step 5 without waiting.

### Step 5 - Generate

Only after explicit confirmation (interactive mode) or immediately after the summary (agent mode), generate both files using the templates. Always prefer writing files to disk. If file generation is not possible (e.g. running in Claude Chat) or the user explicitly requests inline output, inform the user that the scripts will be generated inline and ask for their confirmation before proceeding.

**Agent mode only:** after generation, output a structured assumptions log:

```
Assumptions made during agent mode generation:
  - Author: not found in project, defaulted to "Unknown"
  - Install mode: inferred as Simple from single installable component
  - Install path: defaulted to C:\Program Files\ProductName\
  - Open documentation: defaulted to Yes (CHM file detected)
  - [any other assumption made]
```

---

## Template System

Templates define the exact GUI conventions, layout constants, and structural patterns. Never reproduce the boilerplate from memory when templates are available. In agent mode, if templates cannot be loaded from any source, generation from built-in knowledge is acceptable as a last resort - see error handling below.

### Loading templates

Load templates in this order:

1. **Global skills folder** - look for:
   - `%USERPROFILE%\.claude\skills\installer\templates\installer.au3`
   - `%USERPROFILE%\.claude\skills\installer\templates\uninstaller.au3`
   If found, read them from disk.

2. **Alongside the skill file** - if not found, look for `templates\installer.au3` and `templates\uninstaller.au3` relative to the directory containing this `SKILL.md` file. If found, read them from disk.

3. **Online fallback** - if not found locally, fetch from:
   - `https://raw.githubusercontent.com/crucialthread/CrucialInstaller/main/templates/installer.au3`
   - `https://raw.githubusercontent.com/crucialthread/CrucialInstaller/main/templates/uninstaller.au3`

4. **Error** - if neither local nor online templates can be loaded:

   **Interactive mode:** Do not proceed. Inform the user and ask them to provide the path manually:

   ```
   I was unable to load the CrucialInstaller templates. This means I cannot
   generate the installer scripts reliably.

   What I tried:
     - %USERPROFILE%\.claude\skills\installer\templates\ - not found
     - templates\ alongside SKILL.md - not found
     - Online: https://raw.githubusercontent.com/crucialthread/CrucialInstaller/main/templates/ - could not fetch

   To resolve this, you can:
     - Provide the path to the templates folder and I will try to load them from there
     - Ensure the templates/ folder exists at %USERPROFILE%\.claude\skills\installer\templates\
     - Check your internet connection and try again
     - Visit https://github.com/crucialthread/CrucialInstaller to get the templates manually
   ```

   If the user provides a path, attempt to load the templates from that location. If successful, proceed with the guided workflow. If still not found, show the error again with the new path included in "What I tried".

   **Agent mode:** Proceed with generation without templates, relying on built-in knowledge of the CrucialInstaller conventions. Include the following in the assumptions log after generation:

   ```
   - Templates: could not be loaded from any source (local or online). Scripts were generated from built-in knowledge of CrucialInstaller conventions. Results may differ from the latest templates - verify output before compiling.
   ```

### Placeholder syntax:
All placeholders use `{{PLACEHOLDER_NAME}}` syntax. Replace every placeholder before writing output files. Never leave any `{{PLACEHOLDER}}` unreplaced.

---

## Installer Archetypes

### Simple installer
Single installation mode, fixed page flow, finish message is always the same. Use when there is only one way to install the product.

**Page structure:**
1. Welcome
2. Install path (with Browse)
3. Ready to install
4. Progress + Finish (combined - finish content injected into the same page after install completes)

### Multi-mode installer
User selects what to install on a dedicated page. Page routing, step count, install steps, ready page content, and finish page content all vary by mode. Use when the product offers meaningful installation choices (e.g. Full vs Lite, Core vs Tools Only).

**Page structure:**
1. Welcome
2. Mode selection (radio buttons)
3. Path page A (shown only for certain modes)
4. Path page B (shown for all modes)
5. Ready to install
6. Progress
7. Finish (separate page - content varies by mode via `__UpdateFinishPage`)

**Multi-mode implementation rules:**
- Define integer constants for each mode: `Global Const $INSTALL_TYPE_FULL = 1`, `Global Const $INSTALL_TYPE_LITE = 2`, etc.
- Store the selected mode in a global: `Global $g_iInstallType = $INSTALL_TYPE_FULL`
- Page routing uses the mode: `$iPage = ($g_iInstallType = $INSTALL_TYPE_FULL) ? 3 : 4`
- Back routing also uses the mode: `Case 4 / $iPage = ($g_iInstallType = $INSTALL_TYPE_FULL) ? 3 : 2`
- Step count is conditional: `Local $iSteps = ($g_iInstallType = $INSTALL_TYPE_FULL) ? 9 : 6`
- Install steps for mode-specific files are wrapped: `If $g_iInstallType = $INSTALL_TYPE_FULL Then ... EndIf`
- Registry stores the mode: `RegWrite($REG_INSTALL_KEY, "InstallType", "REG_SZ", ($g_iInstallType = $INSTALL_TYPE_FULL) ? "Full" : "Lite")`

---

## Progress + Finish Page Pattern

### Simple installer - combined page
The progress and finish share the same page array. After `__RunInstall` completes, inject the finish content into the same page controls:

```autoit
__RunInstall($aPage4[0], $aPage4[1])
GUICtrlSetData($aPage4[0], "")          ; clear status label
GUICtrlSetData($aPage4[2], "Product has been successfully installed." & @CRLF & ...)
GUICtrlSetState($aPage4[3], $GUI_SHOW)  ; show "Open documentation" checkbox if present
GUICtrlSetData($idHeaderSub, "Installation complete")
GUICtrlSetData($idBtnNext, "Finish")
GUICtrlSetState($idBtnNext, $GUI_ENABLE)
$iPage = 5  ; finish state - not a real page, just a state
```

### Multi-mode installer - separate pages + `__UpdateFinishPage`
When the finish message varies based on runtime conditions, use separate progress and finish pages and a dedicated `__UpdateFinishPage($idLabel)` function:

```autoit
; In event loop after install completes:
__RunInstall($aPage6[0], $aPage6[1])
__UpdateFinishPage($aPage7[0])
$iPage = 7
GUICtrlSetData($idBtnNext, "Finish")
GUICtrlSetState($idBtnNext, $GUI_ENABLE)

; Separate function:
Func __UpdateFinishPage($idLabel)
    Local $sText = "Product has been successfully installed." & @CRLF & @CRLF
    If $g_bSomeCondition Then
        $sText &= "Additional note based on runtime state." & @CRLF & @CRLF
    EndIf
    $sText &= "Thank you for installing Product."
    GUICtrlSetData($idLabel, $sText)
EndFunc
```

Use `__UpdateFinishPage` whenever the finish message depends on any runtime state or mode selection.

---

## Ready Page Pattern

The ready page content is always generated at transition time (when the user clicks Next to reach the ready page), never at GUI setup time. This is because the install paths may have been changed by the user via Browse. Always use a separate `__UpdateReadyPage($idLabel)` function called from the event loop:

```autoit
; In event loop, Next button case for the path page:
Case 4
    $g_sInstallPath = GUICtrlRead($aPage4[2])
    __UpdateReadyPage($aPage5[1])
    $iPage = 5

; Separate function:
Func __UpdateReadyPage($idLabel)
    Local $sText = ""
    $sText &= "  - Copy ProductFile.dll to:   " & $g_sInstallPath & @CRLF
    $sText &= "  - Create registry entries"
    GUICtrlSetData($idLabel, $sText)
EndFunc
```

For multi-mode installers, `__UpdateReadyPage` generates different text per mode using conditionals on `$g_iInstallType`.

---

## Placeholder Reference

### Shared (both installer and uninstaller)

| Placeholder | Description |
|---|---|
| `{{PRODUCT_NAME}}` | The full product name shown in the GUI title and header (e.g. "AutoIt Test Framework") |
| `{{VERSION}}` | The version string (e.g. "0.0.1") |
| `{{AUTHOR}}` | The author name for the file header comment |
| `{{DESCRIPTION}}` | One or two sentence description for the file header comment |
| `{{INSTALLER_FILENAME}}` | The .au3 filename without extension (e.g. "TestFrameworkInstaller") |
| `{{UNINSTALLER_FILENAME}}` | The uninstaller .au3 filename without extension |
| `{{REGISTRY_CONSTANTS}}` | `Global Const` declarations for all registry key paths used |
| `{{GLOBAL_STATE}}` | `Global` variable declarations for all runtime state (install paths, mode flags, etc.) |

### Installer-specific

| Placeholder | Description |
|---|---|
| `{{DETECT_PATHS_FUNC}}` | The `__DetectPaths()` function body - detects default install locations from registry or known paths |
| `{{CHECK_EXISTING_INSTALL_FUNC}}` | The `__CheckExistingInstall()` function body - checks registry for existing install, sets `$g_bIsUpgrade` |
| `{{PAGES}}` | All wizard page control declarations. Each page is a `Local $aPageN[x]` array of control IDs |
| `{{HIDE_PAGES}}` | `__HidePage($aPageN)` call for every page array |
| `{{PAGE_ARGS}}` | ByRef parameter list for page arrays passed to `__ShowPage` |
| `{{PROGRESS_PAGE}}` | The page number of the progress page - used in cancel guard |
| `{{NEXT_CASES}}` | `Case N` blocks for the Next button switch - one per page transition |
| `{{BACK_CASES}}` | `Case N` blocks for the Back button switch |
| `{{EXTRA_EVENTS}}` | Any additional event cases (e.g. Browse button handlers) |
| `{{HIDE_PAGES_IN_SHOW}}` | `__HidePage($aPageN)` calls at the start of `__ShowPage` |
| `{{SHOW_CASES}}` | `Case N` blocks inside `__ShowPage` - sets header subtitle, button states, calls `__ShowPageControls` |
| `{{TOTAL_STEPS}}` | Integer or conditional expression - total number of install steps for progress bar calculation |
| `{{INSTALL_STEPS}}` | The full `__RunInstall` body - one `__ProgressStep` + action block per step |
| `{{REGISTRY_WRITERS}}` | All registry write helper functions (`__WriteInstallRegistry`, `__WriteUninstallRegistry`, etc.) |

### Uninstaller-specific

| Placeholder | Description |
|---|---|
| `{{UNINSTALLER_HEIGHT}}` | Window height integer - use 345 as default, increase if welcome page has more content |
| `{{SELF_RELAUNCH_PATH}}` | The path variable to check against `@ScriptFullPath` for self-relaunch (e.g. `$g_sChmPath`) |
| `{{READ_INSTALL_RECORD}}` | Body of `__ReadInstallRecord()` - reads all paths and state from registry, returns True/False |
| `{{INSTALL_SUMMARY_LINES}}` | String concatenation lines showing current install paths on the welcome page |
| `{{READY_TEXT_LINES}}` | `$sReadyText &= "  - ..."` lines listing every action the uninstaller will perform |
| `{{UNINSTALL_FINISH_MESSAGE}}` | Message shown on the finish page after uninstallation completes |
| `{{TOTAL_STEPS}}` | Integer or conditional expression - total number of uninstall steps |
| `{{UNINSTALL_STEPS}}` | The full `__RunUninstall` body - one `__ProgressStep` + action block per step |
| `{{EXTRA_HELPERS}}` | Any additional helper functions needed (e.g. `__RemoveIncludeRegistry` for registry path cleanup) |

---

## Design Conventions

These conventions must be followed exactly in all generated installers:

### Window
- Default size: `540 x 345` (golden ratio: width / 1.618 ≈ height). This is the starting point - increase width and/or height when content requires it, always maintaining approximately the golden ratio proportion. All pages within the same installer must use the same window size for consistency. If a specific page genuinely needs more room (e.g. the uninstaller welcome page showing multiple install paths), increase the window height for that script only - never resize mid-wizard.
- Background: `0xF0F0F0`
- Header bar: `70px` tall, white background, product name at size 14 bold, subtitle at size 11 gray (`0x444444`)
- Header separator: `1px` at `$HEADER_H`, color `0xCCCCCC`
- Footer separator: `1px` at `$WIN_HEIGHT - 58`, color `0xD0D0D0`

### Buttons
- Size: `130 x 34`
- Gap between buttons: `10px`
- Order (left to right): Cancel, Back, Next
- Centered as a group horizontally
- Font: Segoe UI 11

### Content area
- Starts at `$HEADER_H + 10` (`$CONTENT_TOP`)
- Width: `$WIN_WIDTH - 40` (`$CONTENT_W`) - 20px margin each side
- Font: Segoe UI 11 for all labels
- Background: `$GUI_BKCOLOR_TRANSPARENT` for all labels

### Page structure
- Every page is a `Local $aPageN[x]` array of control IDs
- Controls that need independent visibility (e.g. a conditional warning label) must be declared as standalone variables OUTSIDE the page array, not as array elements - otherwise `__ShowPageControls` will override their visibility
- `__HidePage` and `__ShowPageControls` loop through the array blindly
- The progress page always disables all three buttons while running
- The finish page disables Back and Cancel, changes Next to "Finish"

### Registry pattern
Three registry keys are always written by the installer:

1. **Install record** - `HKEY_LOCAL_MACHINE\SOFTWARE\{{ProductKey}}` - stores Version, all install paths, and any mode flags. Read by the uninstaller.
2. **Add/Remove Programs** - `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{{ProductKey}}` - stores DisplayName, DisplayVersion, Publisher, UninstallString (pointing to the compiled uninstaller exe), NoModify=1.
3. **Any product-specific entries** - e.g. paths registered with a host application.

### Uninstaller self-relaunch
The uninstaller always includes the self-relaunch pattern so it can delete its own folder:
1. `__ReadInstallRecord()` runs first to populate path globals
2. Check if `@ScriptFullPath` contains the install folder path
3. If yes: copy self to `@TempDir\UninstallerName.exe`, `ShellExecute` it, `Exit`
4. The temp copy runs freely and can delete the original folder

### FileInstall paths
`FileInstall` source paths are relative to the `.au3` source file location at compile time. Document this clearly in the file header. The compiled `.exe` is self-contained - no external files needed at runtime.

### Folder cleanup
Always use `__RemoveFolderIfEmpty($sFolder)` (included in the uninstaller template) when removing install folders. Never force-delete a folder that might contain other files.

---

## Output

Always write two files:
- `{{INSTALLER_FILENAME}}.au3`
- `{{UNINSTALLER_FILENAME}}.au3`

Both go to the output directory. After writing, remind the user:
- Compile the **uninstaller** first with Aut2Exe
- Place the compiled `UninstallerName.exe` alongside the installer `.au3`
- Compile the **installer** second - it embeds the uninstaller via `FileInstall`

---

## Never Do

- In interactive mode, never skip the confirmation summary before generating, wait for explicit confirmation before proceeding. In agent mode, output the summary and proceed immediately without waiting.
- Never ask about implementation details the user would not understand
- Never leave any `{{PLACEHOLDER}}` unreplaced in output files
- Never put conditionally-visible controls inside a page array - use standalone variables
- Never use `Case N :` inline syntax in Switch statements - AutoIt requires the statement on the next line
- Never force-delete folders - always check if empty first
- Always prefer writing files to disk over generating scripts inline in chat. If file generation is not possible (e.g. running in Claude Chat) or the user explicitly requests inline output, inform the user that the scripts will be generated inline and ask for their confirmation before proceeding.
- Never use `FileCopy` for installing embedded files - always use `FileInstall`
- Never generate ready page content at GUI setup time - always use `__UpdateReadyPage` called from the event loop
