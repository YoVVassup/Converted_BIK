Set WshShell = CreateObject("WScript.Shell")
If WScript.Arguments.Count >= 1 Then
    cmdLine = """" & WScript.Arguments(0) & """"
    For i = 1 To WScript.Arguments.Count - 1
        arg = WScript.Arguments(i)
        If InStr(arg, " ") > 0 Then
            cmdLine = cmdLine & " """ & arg & """"
        Else
            cmdLine = cmdLine & " " & arg
        End If
    Next
    rc = WshShell.Run(cmdLine, 0, True)
    WScript.Quit rc
End If
WScript.Quit 1
