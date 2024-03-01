# autosoap
A bash script that automates SOAP transfers done via a combination of [cleaninty](https://github.com/luigoalma/cleaninty) and donor files from unusuable consoles.

## Important Notes
First off, 95% of consoles need a donor to be SOAP transferred. This script accounts for the 5% of cases that don't, but you will almost always need donor files to run it. If you do not already have donor files, this script will likely be useless to you as **under no circumstances should a working console be used as a donor.**

Second, the folder structure inside `cleaninty` is not an accident and should not be modified.

## Compatibility
This script is not POSIX-compliant and relies on [PCRE](https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions) in grep. As a result, it is somewhat less portable than the average bash script - only Unix-based systems with `bash` v4 or higher and GNU `grep` are compatible.

Most Linux distros - including those ran through WSL - have both of these this out-of-the-box. Alpine Linux, *BSD, and macOS are more notable examples of ones that don't.

If your system does not have these, the easiest way to obtain them is by installing `bash` and `grep` through the [Homebrew](https://brew.sh/) package manager. However, be aware that if you do this, Homebrew will install `grep` as `ggrep`, which the script does not account for. Manually adding `PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"` to your profile file will be needed to reassign it back to `grep`.

## Usage
Clone this repo, put the `essential.exefs` for the console that will receive the SOAP transfer into the `Latest` folder, and put your donor `.json` files into the `Donors` folder.
Once your donors are ready, open a terminal directly inside the `Latest` folder and execute the script from there.

You must have already setup cleaninty's constants for this to work. Detailed information and instructions about the constants can be found on the [Nintendo Homebrew Wiki](https://wiki.hacks.guide/wiki/3DS:Cleaninty).

## Credits
* luigoalma, for creating [cleaninty](https://github.com/luigoalma/cleaninty) and generally being a 3DS wizard.
* danny8376, for [creative usage of dd](https://gist.github.com/danny8376/7003e69b7f608b03444d37370b592953). Why? Because that dd is the reason you don't need to install anything else for this script.
