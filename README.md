# CrucialInstaller

A Claude Code skill and template system for generating Windows installer and uninstaller scripts using AutoIt.

## What It Does

CrucialInstaller guides you through creating a complete Windows installer and uninstaller for your project. It scans your project folder, figures out what needs to be installed and where, asks only what it cannot determine on its own, presents a summary for you to confirm, and generates ready-to-compile AutoIt scripts.

The result is a professional wizard-style installer with a clean GUI, progress tracking, Add/Remove Programs registration, upgrade detection, and a self-cleaning uninstaller.

## Installation

### Manual (Recommended)

Copy the `.claude/skills/installer/` folder and the `templates/` folder to your skills directory:

- **Windows:** `%USERPROFILE%\.claude\skills\installer\`
  (the `.claude` folder is hidden - enable hidden items in Explorer or paste the path directly into the address bar)
- **macOS/Linux:** `~/.claude/skills/installer/`
  > **Note:** the generated scripts are Windows-only and must be compiled on a Windows machine. Using this skill on macOS/Linux is fine - just transfer the generated `.au3` files to a Windows machine to compile them.

The skill becomes available in both Claude Code and Cowork automatically.

### Via Claude Desktop UI

Download the `SKILL.md` file from this repository, then go to Settings, select Skills from the left menu, click Add at the top right, and choose Upload a Skill. Select the downloaded `SKILL.md` file. The skill becomes available in both Claude Code and Cowork automatically.

## Usage

### Interactive Mode (Claude Code and Claude Cowork)

Once installed, describe what you want and include your project folder path or public GitHub repository URL:

- *"Use CrucialInstaller to create an installer for the project at C:\Projects\MyApp"*
- *"Generate an installer for https://github.com/youruser/YourProject"*
- *"Create a setup wizard for this library"* (the skill will ask for the path if not provided)

The skill will scan the folder or repository, ask a few focused questions, show you a summary to confirm, and generate the scripts once you approve.

In Claude Code, the folder is accessed directly from the filesystem. In Cowork, make sure the project folder is mounted in your Cowork project, or the skill will request access to it when needed.

### Agent Mode (Autonomous Pipelines)

CrucialInstaller can also be used by autonomous agents or automated pipelines without any user interaction. To activate agent mode, include one of the following in the request: `agent mode`, `autonomous`, or `no user interaction`.

In agent mode the skill:
- Makes reasonable assumptions for anything it cannot infer from the project (author, install paths, install mode, etc.)
- Skips asking questions and waiting for confirmation
- Still outputs the generation summary so the calling agent can review what was decided
- Proceeds directly to file generation
- Outputs a structured assumptions log after generation listing every default that was applied

Example agent mode request:
- *"Use CrucialInstaller in agent mode to generate an installer for https://github.com/youruser/YourProject"*

### Claude Chat

Share the link to this skill with Claude in a chat conversation:

```
https://github.com/crucialthread/CrucialInstaller/blob/main/.claude/skills/installer/SKILL.md
```

Claude will read the skill, follow the guided workflow, and fetch the templates from GitHub automatically. Since file generation is not available in Claude Chat, the scripts will be generated inline in the conversation after your confirmation.

## Compiling the Generated Scripts

This skill generates AutoIt scripts (`.au3` files). AutoIt is a free scripting language for Windows that can compile scripts into standalone `.exe` files. If you are not familiar with AutoIt, download and install it from https://www.autoitscript.com - the installer includes everything needed, including Aut2Exe which is the tool used to compile the generated scripts.

Once AutoIt is installed:

1. Compile the **uninstaller** first with Aut2Exe
2. Place the compiled `UninstallerName.exe` alongside the installer `.au3`
3. Compile the **installer** - it embeds the uninstaller automatically

> **Note:** for detailed instructions on how to use Aut2Exe to compile AutoIt scripts, refer to the official AutoIt documentation:
> https://www.autoitscript.com/autoit3/docs/intro/compiler.htm

The compiled installer `.exe` is fully self-contained and can be distributed as a single file.

## Project Structure

```
CrucialInstaller/
├── templates/
│   ├── installer.au3      - Base installer template
│   └── uninstaller.au3    - Base uninstaller template
└── .claude/
    └── skills/
        └── installer/
            └── SKILL.md   - The Claude Code skill definition
```

## Requirements

- AutoIt 3.3.18.0 or later
- Aut2Exe (included with AutoIt) to compile the generated scripts

## License

MIT
