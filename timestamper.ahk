#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance, force
; -----------------------------------------------------------------
; -----------------------------------------------------------------
; TimeStamper
; -----------------------------------------------------------------
; -----------------------------------------------------------------
; 
; Functionality: 
; Press WIN key + Y to insert a timestamp
; Double Right Click in certain apps for a popup button that inserts a timestamp
; 
; -----------------------------------------------------------------

; -----------------------------------------------------------------
; tray icon
; -----------------------------------------------------------------
Menu, Tray, Icon, %A_ScriptDir%\icons\timestamp.png

; -----------------------------------------------------------------
; Title and parameters
; -----------------------------------------------------------------
windowtitle := "TimeStamper"
doubeclick_timing = t0.15

; -----------------------------------------------------------------
; ----- right click functionality only in these apps 
; -----------------------------------------------------------------
GroupAdd, TimestampApps, ahk_exe Firefox.exe
GroupAdd, TimestampApps, ahk_exe notepad.exe 
GroupAdd, TimestampApps, ahk_exe explorer.exe 
GroupAdd, TimestampApps, ahk_exe PaintDotNet.exe
GroupAdd, TimestampApps, ahk_exe mspaint.exe
GroupAdd, TimestampApps, ahk_exe Evernote.exe

#IfWinActive ahk_group TimestampApps
; -----------------------------------------------------------------
; right click functionality
; -----------------------------------------------------------------
Rbutton::
; get the mouse coordinates for menu popup
CoordMode, mouse, Screen ; Coordinates are relative to the desktop (entire screen).
MouseGetPos, MousePosX, MousePosY

; This registers a 'press-n-hold' on the right mouse button.
keywait, rbutton, %doubeclick_timing%
if errorlevel = 1
{
    ; do nothing
    return
}

; this registers a 'double click' on the right mouse button.
else
keywait, rbutton, d, %doubeclick_timing%
if errorlevel = 0
{
    timestamp_menu() ; open timestamp popup button
    return
}

; if neither of the above heppen, send a regular single click
else 
    mouseclick, right 
return
#IfWinActive 

; -----------------------------------------------------------------
; hot key functionality
; -----------------------------------------------------------------
#y:: ; WIN key + Y
    stamp_thetime()
return

; -----------------------------------------------------------------
; insert a timestamp
; -----------------------------------------------------------------
stamp_thetime()
{
    Space := " "
    FormatTime, timestring,, yyyy_MM_dd_HHmmss
    Send, %timestring%%A_MSec%%Space%
}

; -----------------------------------------------------------------
; create a GUI popup button to call timestamp function
; -----------------------------------------------------------------
timestamp_menu(){
    global MousePosX, MousePosY, windowtitle
    static OKButton
    
    ; create a colored window with no titlebar
    gui, new, -MinimizeBox -MaximizeBox -Caption 
    Gui, Color, EEAA99
    
    ; add a timestamp button at mouse position
    gui, add, button, gokbutton_action vOKButton, Timestamp
    gui, show, x%MousePosX% y%MousePosY%, %windowtitle%
    
    ; move the window so it is centered at the mouse position
    WinGetPos , , , Width, Height, %windowtitle%
    WinMove, %windowtitle%, ,MousePosX-Width/2, MousePosY-Height/2
    
    ; close the button popup if clicked away from it
    WinWaitNotActive, %windowtitle%
    IfWinNotActive, %windowtitle%
    {
        gui,destroy
    }
    return winexist()

    ; call the timestamp function and close the popup
    okbutton_action:
    {
        gui,destroy
        CoordMode, mouse, Screen 
        mouseclick, Left, %OutputVarX%, %OutputVarY%,
        stamp_thetime()
        return
    }
}