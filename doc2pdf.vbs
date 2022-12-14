' Convert2PDF.vbs script
' Part of PDFCreator
' License: GPL
' Homepage: http://www.pdfforge.org/products/pdfcreator
' Windows Scripting Host version: 5.1
' Version: 1.1.0.0
' Date: December, 24. 2007
' Author: Frank Heindörfer
' Comments: This script convert a printable file in a pdf-file using 
'           the com interface of PDFCreator.

Option Explicit

Const maxTime = 300    ' in seconds
Const sleepTime = 250 ' in milliseconds

Dim objArgs, ifname, fso, PDFCreator, DefaultPrinter, ReadyState, _
 i, c, AppTitle, Scriptname, ScriptBasename

Set fso = CreateObject("Scripting.FileSystemObject")

Scriptname = fso.GetFileName(Wscript.ScriptFullname)
ScriptBasename = fso.GetFileName(Wscript.ScriptFullname)

AppTitle = "PDFCreator - " & ScriptBaseName

If CDbl(Replace(WScript.Version,".",",")) < 5.1 then
 MsgBox "You need the ""Windows Scripting Host version 5.1"" or greater!", vbCritical + vbSystemModal, AppTitle
 Wscript.Quit
End if

Set objArgs = WScript.Arguments

If objArgs.Count = 0 Then
 MsgBox "Syntax: " & vbtab & Scriptname & " <Filename>" & vbcrlf & vbtab & "or use ""Drag and Drop""!", vbExclamation + vbSystemModal, AppTitle
 WScript.Quit
End If

Set PDFCreator = Wscript.CreateObject("PDFCreator.clsPDFCreator", "PDFCreator_")
PDFCreator.cStart "/NoProcessingAtStartup"
With PDFCreator
 .cOption("UseAutosave") = 1
 .cOption("UseAutosaveDirectory") = 1
 .cOption("AutosaveFormat") = 0                              ' 0 = PDF
 DefaultPrinter = .cDefaultprinter
 .cDefaultprinter = "PDFCreator"
 .cClearcache
 .cPrinterStop = false
End With

For i = 0 to objArgs.Count - 1 ' never used really as we pass only a single argument from the Worker Agent
 With PDFCreator
  ifname = objArgs(i)
  If Not fso.FileExists(ifname) Then
   MsgBox "Can't find the file: " & ifname, vbExclamation + vbSystemModal, AppTitle
   Exit For
  End If
  if Not .cIsPrintable(CStr(ifname)) Then
   MsgBox "Converting: " & ifname & vbcrlf & vbcrlf & _
    "An error is occured: File is not printable!", vbExclamation + vbSystemModal, AppTitle
   Exit For
  End if

  ReadyState = 0
  .cOption("AutosaveDirectory") = fso.GetParentFolderName(ifname)
  .cOption("AutosaveFilename") = fso.GetBaseName(ifname)
  .cPrintfile cStr(ifname)

  c = 0
  Do While (ReadyState = 0) and (c < (maxTime * 1000 / sleepTime))
   c = c + 1
   Wscript.Sleep sleepTime
  Loop
  If ReadyState = 0 then
   MsgBox "Converting: " & ifname & vbcrlf & vbcrlf & _
   "An error is occured: Time is up!", vbExclamation + vbSystemModal, AppTitle
   Exit For
  End If
 End With
Next

With PDFCreator
 .cDefaultprinter = DefaultPrinter
 .cClearcache
 WScript.Sleep 200
 .cClose
End With

'--- PDFCreator events ---

Public Sub PDFCreator_eReady()
 ReadyState = 1
End Sub

Public Sub PDFCreator_eError()
 MsgBox "An error is occured!" & vbcrlf & vbcrlf & _
  "Error [" & PDFCreator.cErrorDetail("Number") & "]: " & PDFcreator.cErrorDetail("Description"), vbCritical + vbSystemModal, AppTitle
 Wscript.Quit
End Sub
