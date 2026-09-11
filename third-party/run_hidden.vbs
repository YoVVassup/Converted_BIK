Set WshShell = CreateObject("WScript.Shell")
If WScript.Arguments.Count >= 1 Then
    cmdLine = WScript.Arguments(0)
    For i = 1 To WScript.Arguments.Count - 1
        cmdLine = cmdLine & " " & WScript.Arguments(i)
    Next
    rc = WshShell.Run(cmdLine, 0, True)
    WScript.Quit rc
End If
WScript.Quit 1
