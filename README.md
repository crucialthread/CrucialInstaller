# CrucialInstaller

A Claude Code skill and template system for generating Windows installer and uninstaller scripts using AutoIt.

## What It Does

CrucialInstaller guides you through creating a complete Windows installer and uninstaller for your project. It scans your project folder, figures out what needs to be installed and where, asks only what it cannot determine on its own, presents a summary for you to confirm, and generates ready-to-compile AutoIt scripts.

The result is a professional wizard-style installer with a clean GUI, progress tracking, Add/Remove Programs registration, upgrade detection, and a self-cleaning uninstaller.

## Usage

### With Claude Code

Clone this repository and open it in Claude Code. Then just describe what you want:

- *"Use CrucialInstaller to create an installer for my project"*
- *"Generate an installer and uninstaller for MyApp"*
- *"Create a setup wizard for this library"*

Claude Code will scan your project, ask a few focused questions, show you a summary to confirm, and generate the scripts.

### In Your Own Project

Copy the `.claude/` folder into your project root and keep the `templates/` folder accessible alongside it. Claude Code will detect the skill automatically.

## Compilation

After the scripts are generated:

1. Compile the **uninstaller** first with Aut2Exe
2. Place the compiled `UninstallerName.exe` alongside the installer `.au3`
3. Compile the **installer** - it embeds the uninstaller automatically

The compiled installer `.exe` is fully self-contained and can be distributed as a single file.

## Structure

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
