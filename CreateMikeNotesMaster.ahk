/* ;======================================================================
Name:           Create MikeNotes Text File (v2.3)
Changes: 2.3 - 08/08/2019: Added array for supported filetypes, variable filename length via script name, easy customisation options and tidied code
                2.2 - 29/07/2019: ToolbarWindow322->323 updated for Win10 / Added support for m4a and aac just in-case / Tooltips on quit/end improved
				2.1 - 24/07/2019: Changed file loop to all with subsequent 'if' check for more filetypes mp3 only -> mp3 or flac
                1.x - 2017: Working script, mp3 only
Description:     Creates a fairly neat text file listing all the files of specified filetypes in the selected directory and/or sub-directories
ToDo:               idk
Notes:              An ".mp3" or ".flac" etc file causes an empty line, ignoring this for now
*/
;=======================================================================
;CUSTOMISATION, change these values (keep formatting):
  txtFileName				 := "MikeNotes"										;Name of text file. "MikeNotes" seems pretty self-involved but it helps to quickly identify my own notes from anything else
  SupportedFileTypes := ["mp3", "flac", "m4a", "aac"]			;Filetypes included in list
  spacingVar				 := "  "															;Gap before and after list item eg "__01 filename     __"
  defaultShortening    := 20															;Max characters in filenames eg "01 Shortened File Na" (20 chars) if no value found in filename

;=======================================================================
;SETTINGS

#NoEnv                                                  ;Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
SendMode Input                                   ;Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%			;Ensures a consistent starting directory.
SetTitleMatchMode, 2

;=======================================================================
;MAIN PROGRAM

RegExMatch(A_ScriptName, "\d+", filenameShortening)                         ;Checks script filename for any one or more digit number to use as max characters in list items
if  !((filenameShortening >= 0) and (filenameShortening <= 100))      ;checks for range 0-100 inclusive. 0=empty lines / 2=track numbers only /  20 = a good default
 filenameShortening := defaultShortening                                              ;40 = good for longer filenames eg remixes / 50 = already takes too long / 100+ would be stupid

Loop                                                    		;Wait for Launchy to close (Unnecessary but here out of habit/copypasta for convenience.. or nostalgia?)
 if !WinActive("Launchy")
  break

ToolTip Looking for destination folder...`nIndent: "%spacingVar%"		

Loop { ;GetDirLoop                                      							;Repeat until successful
 ControlGetText, currDir, ToolbarWindow323, A				;Get Filepath
 StringTrimLeft, currDir, currDir, 9				     					;Removes "Address: "
 if RegExMatch(currDir, "[A-Z]:\\")                     					;Range A-Z, literal ':', escaped literal '\', aka C:\ or X:\ etc
 {                                                      										;A valid one is found
  ToolTip                                               									;Clear tooltip
  Break                                                 									;Break dir grabbing loop
 }
}

;if then else on 4 lines with simple literal tooltips Vs working single line ternary if/then/else with tooltip using unnecessary and hard to read expression .. for practice I guess.
 if currDir
  ToolTip Looking for destination folder...`nIndent: "%spacingVar%"`nShortening: %filenameShortening%`nPlease click on a valid Windows Explorer window (folder)`n"%currDir%" doesn't look right`, keep trying!
 else 
  ToolTip Looking for destination folder...`nIndent: "%spacingVar%"`nShortening: %filenameShortening%`nPlease click on a valid Windows Explorer window (folder)
 
ToolTip Creating %txtFileName%.txt in:`n%currDir%`nIndent: "%spacingVar%"`nShortening: %filenameShortening%
 
FileAppend, %currDir%`n, %currDir%\%txtFileName%.txt			;creates .txt with dir path as first line

Loop, Files, %currDir%\*.*, FR ;D                                     ;For every file (F) in the current dir (%currDir%) then repeat for all sub-dirs (R)
 if InStr(A_LoopFileExt, "mp3") or InStr(A_LoopFileExt, "flac") or InStr(A_LoopFileExt, "m4a") or InStr(A_LoopFileExt, "aac")  ;InStr to avoid dealing with /r/n
 {	
  if (A_LoopFileDir != donePath)																					;If script has recursed into a new sub-directory
  {                                                                                                                                    ;MsgBox A_LoopFileLongPath`n%A_LoopFileLongPath%`n`npathOnly`n%pathOnly%`n`ndoes not equal`n`ndonePath`n%donePath%
   subPathOnly := StrReplace(A_LoopFileDir, currDir,"")											;X:\Downloads\Artist\2018 - Album\CD1  ->  2018 - Album\CD1\
   
   if !(subPathOnly = "")
   {
    FileAppend, `n`n%subPathOnly%`n`n, %currDir%\%txtFileName%.txt						;Writes 2018 - Album\CD1 with 2 new lines above and 1 below
   }
   donePath := A_LoopFileDir																								;Sets done variabe to current so only run once per dir
  }
  
  filenameShort := StrReplace(A_LoopFileName, "." A_LoopFileExt, "")							;eg: 01. Intro.mp3 -> 01. Intro		//	 previously: ".mp3","")
  filenameShort := SubStr(filenameShort,1,filenameShortening)									;eg 01. Intro Long Filename -> 01. Intro Long Filen
  
  extraSpace := filenameShortening - StrLen(filenameShort)											;Calculate number of spaces for uniform indentation of comments
  FileAppend, %spacingVar%%filenameShort%, %currDir%\%txtFileName%.txt			;eg "  01. Intro"
  Loop, %extraSpace%
   FileAppend, %A_Space%, %currDir%\%txtFileName%.txt												;eg " 01. Intro           "
  FileAppend, %spacingVar%`n, %currDir%\%txtFileName%.txt										;Add two more spaces for gap between truncated filename and intended space for comments then a new line
  
 } 

run, %currDir%\%txtFileName%.txt 

 Sleep 50
 ToolTip Created %txtFileName%.txt in:`n%currDir%`nIndent: "%spacingVar%"`nShortening: %filenameShortening%`nDone! :) BYE!
 Sleep 1000
 ExitApp
Return

;=======================================================================
; FUNCTIONS

;FoundPos := HasVal(Haystack, Needle) by AHK forum user jNizM
HasVal(haystack, needle) {
    for index, value in haystack
        if (value = needle)
            return index
    if !(IsObject(haystack))
        throw Exception("Bad haystack!", -1, haystack)
    return 0
}

;=======================================================================
; HOTKEY

$~Esc::   ;$~Hotkey sends original [ESC] keystroke to end renaming and closes app
 ToolTip Cancelled :( BYE!
 Sleep 1000
 ExitApp
Return

;=======================================================================