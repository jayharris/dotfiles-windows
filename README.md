# JayHarris's dotfiles for Windows

A collection of PowerShell Profile and dotfiles for Windows.

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

### Git-free install

To install these dotfiles from PowerShell without Git:

```bash
iex ((new-object net.webclient).DownloadString('https://raw.github.com/jayharris/dotfiles-windows/master/setup/install.ps1'))
```

To update later on, just run that command again.

### Add custom commands without creating a new fork

If `.\extra.ps1` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don't want to commit to a public repository.

My `.\extra.ps1` looks something like this:

```posh
# Hg credentials
# Not in the repository, to prevent people from accidentally committing under my name
Set-Environment("EMAIL", "Jay Harris <jay@aranasoft.com>", "User")

# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
Set-Environment("GIT_AUTHOR_NAME","Jay Harris","User")
Set-Environment("GIT_COMMITTER_NAME", $env:GIT_AUTHOR_NAME, "User")
git config --global user.name $env:GIT_AUTHOR_NAME
Set-Environment("GIT_AUTHOR_EMAIL","jay@aranasoft.com", "User")
Set-Environment("GIT_COMMITTER_EMAIL",$env:GIT_AUTHOR_EMAIL, "User")
git config --global user.email $env:GIT_AUTHOR_EMAIL
```

You could also use `./extra.ps1` to override settings, functions and aliases from my dotfiles repository. It’s probably better to [fork this repository](https://github.com/jayharris/dotfiles-windows/fork) instead, though.

### Configure Windows defaults

When setting up a new Windows PC, you may want to set some Windows defaults and features, such as showing hidden files in Windows Explorer and installing IIS. This will also set your machine name and full user name, so you may want to modify this file before executing.

```post
. .\windows.ps1
```

### Install Chocolatey packages

When setting up a new Windows box, you may want to install some common [Chocolatey](http://http://chocolatey.org/) packages (it will also install chocolatey, if it isn't already).

```posh
. .\chocolatey.ps1
```

## Feedback

Suggestions/improvements
[welcome](https://github.com/jayharris/dotfiles/issues)!

## Author

| [![twitter/mathias](http://gravatar.com/avatar/1318668b99b2d5a3900f3f7758763a69?s=70)](http://twitter.com/jayharris "Follow @jayharris on Twitter") |
|---|
| [Jay Harris](http://twitter.com/jayharris/) |

## Thanks to…

* @[Mathias Bynens](http://mathiasbynens.be/) for his [dotfiles](http://mths.be/dotfiles), which this repository is modeled after.