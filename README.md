# PSMD.OpenAI

Welcome to the AI-Empowered code development toolkit of the PSFramework project.
This project aims to provide assistance tools, using AI, to help accelerate coding.

## Installation

To install this module, run the following line in your console:

```powershell
Install-Module PSMD.OpenAI -Scope CurrentUser
```

## Connect

To do anything, you first need to connect to an Azure OpenAI deployment:

```powershell
Connect-PsmdOpenAI -Resource "resourcename" -Deployment "mydeployment" -ApiKey $key
```

The `$key` can be either a string, a securestring or a PSCredential object.

> Other authentication options are planned for, but not yet implemented.

## Profit

> Adding help to your commands

This will add help to all functions in all ps1 files in the current folder:

```powershell
Get-ChildItem -Recurse -File -Filter *.ps1 | Add-PsmdOaiFunctionHelp
```

Functions that already have existing help are not modified (even if the help is not complete yet).
