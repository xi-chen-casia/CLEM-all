#cs ----------------------------------------------------------------------------

 AutoIt Version: 1.0.0.1
 Author:         Chen Xi

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include "CompInfo.au3"
#include "md5.au3"

Opt('MustDeclareVars', 1)

Func _GetEncryptComputerInfo()
	Local $var_HardDisk
	$var_HardDisk = Hex(DriveGetSerial("c:\"))
	;MsgBox(4096, "Serial Number: ", $var_HardDisk)

	Local $Motherboard, $var_MainBoard
	_ComputerGetMotherboard($Motherboard)
	$var_MainBoard = $Motherboard[1][19]                  ; SystemName &
	;MsgBox(4096, "Serial Number: ", $var_MainBoard)

	Local $BIOS, $var_BIOS
	_ComputerGetBIOS($BIOS)
	$var_BIOS = $BIOS[1][0] & $BIOS[1][16]             ; Name & Serial Number
	;MsgBox(4096, "Serial Number: ", $var_BIOS)

	Local $Processors, $var_Processors
	_ComputerGetProcessors($Processors)
	$var_Processors = $Processors[1][0] & $Processors[1][37]
	;MsgBox(4096, "Serial Number: ", $var_Processors)

	Local $var_Drive
	$var_Drive = _Read_DriveInfo()
	;MsgBox(4096, "Serial Number: ", $var_Drive)

	Local $EncodeData, $Hash
	$EncodeData = $var_HardDisk & $var_MainBoard & $var_BIOS & $var_Processors & $var_Drive
	;MsgBox(4096, "Serial Number: ", $EncodeData)

	$Hash = _MD5($EncodeData)
	;MsgBox(64, '主机标识', $Hash)
	Return $Hash

EndFunc

Func _Read_DriveInfo()
	Local $objWMIService, $objItem
	$objWMIService = ObjGet("winmgmts:{(RemoteShutdown)}//" & "localhost" & "\root\CIMV2")
    Local $colItems = ""
    $colItems = $objWMIService.ExecQuery ("SELECT * FROM Win32_DiskDrive", "WQL", 0x10 + 0x20)
    For $objItem in $colItems
        Local $item = $objItem.Model
		Return $item
        ;MsgBox(0,'Output','Drive Model : ' & $Item)
        ;Local $item = $objItem.Signature
        ;MsgBox(0,'Output','Drive Signature : ' & $Item)
     Next
EndFunc
