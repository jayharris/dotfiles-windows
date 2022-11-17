# Jay Harris's dotfiles for Windows

A collection of PowerShell files for Windows, including common application installation through `Win-Get` and `npm`, and developer-minded Windows configuration defaults.

Are you a Mac user? Check out my [dotfiles](https://github.com/jayharris/dotfiles) repository.

## Installation

### Using Git and the bootstrap script

You can clone the repository wherever you want. (I like to keep it in `~\Projects\dotfiles-windows`.) The bootstrapper script will copy the files to your PowerShell Profile folder.

From PowerShell:
```posh
git clone https://github.com/jayharris/dotfiles-windows.git; cd dotfiles-windows; . .\bootstrap.ps1
```

To update your settings, `cd` into your local `dotfiles-windows` repository within PowerShell and then:

```posh
. .\bootstrap.ps1
```

Note: You must have your execution policy set to unrestricted (or at least in bypass) for this to work: `Set-ExecutionPolicy Unrestricted`.

### Git-free install

> **Note:** You must have your execution policy set to unrestricted (or at least in bypass) for this to work. To set this, run `Set-ExecutionPolicy Unrestricted` from a PowerShell running as Administrator.

To install these dotfiles from PowerShell without Git:

```bash
iex ((new-object net.webclient).DownloadString('https://raw.github.com/jayharris/dotfiles-windows/master/setup/install.ps1'))
```

To update later on, just run that command again.

## Use & Configuration

### PowerShell Profile

The following commands are executed every time you launch a new
PowerShell window.

 - `.\components.ps1` : Load various PowerShell components and modules.
 - `.\functions.ps1` : Configure custom PowerShell functions.
 - `.\aliases.ps1` : Configure alias-based commands.
 - `.\exports.ps1` : Configure environment variables.
 - `.\extra.ps1` : Secrets and secret commands that are not tracked by the Git repository.

Also included are default configurations for Git, Mercurial, Ruby, NPM, and vim.

### Secrets

You may have scripts or commands that you want to execute when loading PowerShell that you do not want committed into your own `dotfiles` repository, such as a place to put tokens or credentials or even your Git commit email address. For such secret commands, use `.\extra.ps1`.

If `.\extra.ps1` exists, it will be sourced along with the other files.

My `.\extra.ps1` looks something like this:

```posh
# Hg credentials
# Not in the repository, to prevent people from accidentally committing under my name
Set-Environment "EMAIL" "Jay Harris <jay@aranasoft.com>"

# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
Set-Environment "GIT_AUTHOR_NAME" "Jay Harris","User"
Set-Environment "GIT_COMMITTER_NAME" $env:GIT_AUTHOR_NAME
git config --global user.name $env:GIT_AUTHOR_NAME
Set-Environment "GIT_AUTHOR_EMAIL" "jay@aranasoft.com"
Set-Environment "GIT_COMMITTER_EMAIL" $env:GIT_AUTHOR_EMAIL
git config --global user.email $env:GIT_AUTHOR_EMAIL
```

Extras is designed to augment the existing settings and configuration. You could also use `./extra.ps1` to override settings, functions and aliases from my dotfiles repository, but it is probably better to [fork this repository](#forking-your-own-version).

### Sensible Windows defaults

When setting up a new Windows PC, you may want to set some Windows defaults and features, such as showing hidden files in Windows Explorer, configuring privacy settings, installing IIS, and uninstalling Candy Crush. You are encouraged to browse through the file to understand all of the modifications and to modify these settings based on your own preferences.

```posh
.\windows.ps1
```

This script will also set your machine name, so you may want to modify this file before executing.
```posh
(Get-WmiObject Win32_ComputerSystem).Rename("MyMachineName") | Out-Null
```

### Dependencies: Tools, Utilities, and Packages

Setting up a new Windows machine often requires installation of common packages, utilities, and dependencies. These could include node.js packages via [NPM](https://www.npmjs.org), Win-Get packages, Windows Features and Tools, and Visual Studio Extensions.

```posh
.\deps.ps1
```

## Customization

## Forking your own version

These scripts are for my preferences; your preferences may be different.

This repository is built around how I use Windows, which is predominantly in a VM hosted on macOS. As such, things like VNC, FileZilla, or Skype are not installed, as they are available to me on the macOS side, installed by my [OS X dotfiles](https://github.com/jayharris/dotfiles). If you are using Windows as your primary OS, you may want a different configuration that reflects that, and I recommend you [fork this repository](https://github.com/jayharris/dotfiles-windows/fork).

If you do fork for your own custom configuration, you will need to touch a few files to reference your own repository, instead of mine.

Within `/setup/install.ps1`, modify the Repository variables.
```posh
$account = "jayharris"
$repo    = "dotfiles-windows"
$branch  = "master"
```

Finally, be sure to reference your own repository in the git-free installation command.
```bash
iex ((new-object net.webclient).DownloadString('https://raw.github.com/$account/$repo/$branch/setup/install.ps1'))
```

## Feedback

Suggestions/improvements are
[welcome and encouraged](https://github.com/jayharris/dotfiles-windows/issues)!

## Author

| [![twitter/jayharris](http://gravatar.com/avatar/1318668b99b2d5a3900f3f7758763a69?s=70)](http://twitter.com/jayharris "Follow @jayharris on Twitter") |
|---|
| [Jay Harris](http://twitter.com/jayharris/) |

## Thanks to…

* @[Mathias Bynens](http://mathiasbynens.be/) for his [OS X dotfiles](http://mths.be/dotfiles), which this repository is modeled after.
