## Description

This repository contains a collection of login initialization files. Each
file is a POSIX compliant shell script that was verified with the
[ShellCheck](https://www.shellcheck.net) linter. Together they build the
login process.

## Preparation

Make sure that a required proxy configuration (`http_proxy`, `https_proxy`,
and `no_proxy`) is done in either the _/etc/environment_ (AIX) or the
_/etc/profile.d/http\_proxy.sh_ (WSL with CentOS or Ubuntu) file.

The login process uses the FULL_NAME and EMAIL environment variables.
It extracts your full name (space separated first name and last name) from
the 1st and your email address from the 5th GECOS field. Execute `chfn`
to verify and adjust your GECOS information.

We expect that the login process works for the **ksh93** and the **bash**
login shell. Both shells load _~/.profile_. If your shell is **bash**
and if the file _~/.bash_profile_ exists, this file takes precedence over
_~/.profile_ and the login process would not run. Execute `chsh` to verify
and adjust your shell.  The recommended shell is **ksh93**.

## Installing profile.d

Execute the following commands to enable the login process

```sh
cd
mv ./.bash_profile ./.bash_profile.bak
cp ./.profile ./.profile.bak
rm -fr ./.profile ./profile.d
# GitHub does not support the git-archive protocol
git clone git@github.com:XSven/sh-profile.d.git profile.d
rm -fr profile.d/.git
ln -sf ./profile.d/.profile .
```

Logout, login again, and execute the function

```sh
github_archive -x -t profile.d XSven sh-profile.d master
```

## Customization

To customize the login process, create a _~/customizations.sh_ file with read
and write permissions for the user owner only. The file should contain POSIX
compliant shell code only. The file should start with a shebang line that
refers to the **sh** shell. This helps to simplify ShellCheck verifications.

This _~/customizations.sh_ example file

```sh
#!/usr/bin/env sh

# Change command-line editing mode from vi (the default) to emacs
set -o emacs
```

changes the command-line editing mode.

## Some words about perlbrew and local::lib

To benefit from the [perlbrew](https://metacpan.org/pod/perlbrew) perl
environment manager your login shell has to be **bash**. If your default
shell is not **bash**, call the `use_bash` function to switch to **bash**
in your current session. Call `exit` to return to your default shell.

Because the [local::lib](https://metacpan.org/pod/local::lib) module will be
automatically installed once, you can use the `perlll` function to install perl
modules in different directories. If you call `perlll` without arguments, a
list of installation directories will be provided. You may choose a directory
to prepend it to `@INC`.

Due to the open issue [609](https://github.com/gugod/App-perlbrew/issues/609),
I would not recommend to use the **lib** perlbrew command as an alternative to
the `local::lib` module.

