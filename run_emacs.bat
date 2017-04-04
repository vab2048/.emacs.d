:: Batch script to start emacs with HOME variable set to where .emacs.d folder is.
:: Script assumes:
:: i)  it is run from inside the .emacs.d directory
:: ii) the .emacs.d directory is placed in the extracted directory from the
::     pre-built emacs for windows archive. I.E. the parent directory of .emacs.d
::     contains bin/ (and the other directories that come with Emacs for Windows).
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
