' BrightSign HTML app bootstrap for the extension workshop.
' Loads the webpack-bundled HTML app from the SD card and displays it full-screen.

Sub Main()
    msgPort = CreateObject("roMessagePort")

    ' Full-screen rectangle at 1080p.
    rect = { x: 0, y: 0, w: 1920, h: 1080 }

    config = CreateObject("roAssociativeArray")
    config.port = msgPort

    html = CreateObject("roHtmlWidget", rect, config)
    html.SetPort(msgPort)

    ' Enable SSH for debugging.
    shell = CreateObject("roShell")
    shell.EnableSSH(22)

    ' Enable the JavaScript inspector (open http://<player_ip>:2999 in Chrome DevTools).
    html.EnableJavaScriptInspector(2999)

    ' Load the bundled app from the SD card root.
    html.LoadURL("file:///sd:/dist/index.html")

    ' Event loop — keep the process alive.
    While True
        msg = Wait(0, msgPort)
    End While
End Sub
