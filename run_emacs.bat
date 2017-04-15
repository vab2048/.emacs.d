:: This script is not needed anymore. The proper way to get emacs on the taskbar is the following
:: (taken from https://superuser.com/a/283150):
::
:: 1. Run runemacs.exe with no pre-existing icon in the taskbar.
:: 2. Right click on the running Emacs icon in the taskbar, and click on "pin this program to taskbar."
:: 3. Close Emacs
:: 4. Shift right-click on the pinned Emacs icon on the taskbar, click on Properties, and change the target from emacs.exe to runemacs.exe.
::
:: After opening files associated with runemacs (such as org files) then the icon on the taskbar will
:: also show these files in the 'recent' list. This is the desired behaviour and way of achieving it -
:: not what is shown below (which remains just for reference in the future).
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::: Below has been retired and is just kept as reference ::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Example batch script to start emacs.
:: Script assumes:
:: i)  it is run from inside the .emacs.d directory
:: ii) the .emacs.d directory is placed in the extracted directory from the
::     pre-built emacs for windows archive. I.E. the parent directory of .emacs.d
::     contains bin/ (and the other directories that come with Emacs for Windows).
:: -----------------------
:: This is just an example so it is easy to see how you could create an icon launcher
:: for emacs on the taskbar. In reality it is better to set the HOME environment variable
:: to the location of the .emacs.d directory and just have the batch script run bin/runemacs.exe
:: -----------------------
:: To pin a shortcut to this batch file to the taskbar:
:: 
:: 1. Create a shortcut to your batch file.
:: 2. Get into shortcut property and change target to something like: 
::    cmd.exe /C "path-to-your-batch"
::    example using (optional) absolute path to cmd.exe
::    C:\Windows\System32\cmd.exe /C "C:\Users\v\emacs-24.5-bin-i686-mingw32\run_emacs.bat"
:: 3. Simply drag your new shortcut to the taskbar. It should now be pinnable.
:: 4. Optionally, "right click -> properties -> change icon" to change the icon to the emacs icon.
::    Choose an emacs binary (e.g. bin\emacs-25.1.exe) to pull the icon from the binary.
:: See: http://superuser.com/a/193255
:: -----------------------

:: Set HOME to parent directory because it is what contains .emacs.d
pushd ..
set HOME=%cd%
bin\runemacs.exe %*
