#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=E:\电镜图像采集\AutoIt\works\电镜测试\ZEISS-AUTO2.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 2.0.0.1
 Author:         Chen Xi
Edited by Xit, 2020-02-26
 Script Function:
	Auto grab image for Carl Zeiss SEM supra55.
    与原有版本相比，每次换行的平台等待时间单独设定

Edited by Chenx, 2016-12-14 v3
与v3相比，主要是面向电镜讨论班

去掉jpg，tif选择
换成设置图像尺寸和pixelsize

点击acquire自动保存
等待一段时间后自动存图
这个时候点击delete键删图

Send Stage Pos发送图像采集信息，包括起始位置x,y，总行，总列，图像尺寸，pixelsize，步进
#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Math.au3>
#include <GuiListBox.au3>
#include "CompInfo4Encpy.au3"

Opt('MustDeclareVars', 1)
;Opt("GUIOnEventMode", 1)
Opt("WinTitleMatchMode", 1)     ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
;Opt("PixelCoordMode",2)

Local $register_data, $register_num
$register_data = _GetEncryptComputerInfo()
;MsgBox(0,"",$register_data)

Local $valid_computer = False
Local $register_lib[3] = ["0xB8DA57E683FDA113D753B8F0AC6DABFD","0x5139A4252488289D5E71BE98A0AB3586","0x71673EBEB875CD7C5E48737C77E5D0E9"]
for $register_num = 0 To 3-1 Step 1
	If $register_data = $register_lib[$register_num] Then
		$valid_computer = True
		ExitLoop;
	EndIf
Next

;If $valid_computer = False Then
;	Exit
;EndIf

Global $DlgWnd, $Input_EndPointX, $Button_GetEndPoint, $Input_EndPointY, $Label_EndPointX, $Label_EndPointY, $Group_EndPoint
Global $Group_StartPoint, $Input_StartPointX, $Button_GetStartPoint, $Input_StartPointY, $Label_StartPointX, $Label_StartPointY
Global $Input_SetStepX, $Label_SetStepX, $Label_SetStepY, $Input_SetStepY, $Group_SetStep
Global $Button_StartPause, $Label_TotalRow, $Label_TotalCol, $Label_CurrentRow, $Label_CurrentCol, $Input_TotalRow, $Input_TotalCol
Global $Input_CurrentRow, $Input_CurrentCol, $Label_CurrentPosX, $Input_CurrentPosX, $Label_CurrentPosY, $Input_CurrentPosY, $Group_Status
Global $Input_pixelsize, $Label_pixelsize,$Input_imgsize, $Label_imgsize, $Label_VerInfo, $Label_MailBox, $hwnd_SmartSEM
Global $title_SmartSEM, $buttonID_freeze, $buttonID_saveImg, $buttonID_rescan
Global $Button_GotoEP,$Button_GotoSP,$Group_SpecPos, $Label_SpecRow, $Label_SpecCol ,$Input_SpecRow , $Input_SpecCol ,$Button_GotoSpecPos ,$Button_Photo
Global $Label_StartRow, $Label_StartCol, $Input_StartRow, $Input_StartCol, $Label_EmailInfo
;Global $jpg, $tif, $Group1
Global $strTempSaveDir, $stageOKTime,$stageChangeRowOKTime, $imageSaveTime, $str_Su_Title, $Edit_Status, $Button_SendStagePos

#Region ### START Koda GUI section ### Form=c:\documents and settings\xit\桌面\forms\sem-guiv2.kxf
$DlgWnd = GUICreate("AutoCaptureImage registered by CASIA", 454, 559, 267, 149)
GUISetIcon("E:\电镜图像采集\AutoIt\works\ogg.ico")
$Input_EndPointX = GUICtrlCreateInput("", 93, 23, 101, 21)
$Button_GetEndPoint = GUICtrlCreateButton("get", 200, 23, 48, 20)
$Input_EndPointY = GUICtrlCreateInput("", 93, 52, 101, 21)
$Label_EndPointX = GUICtrlCreateLabel("x (um)", 42, 28, 48, 17)
$Label_EndPointY = GUICtrlCreateLabel("y (um)", 42, 54, 48, 17)
$Group_EndPoint = GUICtrlCreateGroup("End Point", 18, 7, 241, 72)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group_StartPoint = GUICtrlCreateGroup("Start Point", 18, 85, 241, 72)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Input_StartPointX = GUICtrlCreateInput("", 91, 104, 103, 21)
$Button_GetStartPoint = GUICtrlCreateButton("get", 200, 101, 48, 20)
$Input_StartPointY = GUICtrlCreateInput("", 91, 130, 103, 21)
$Label_StartPointX = GUICtrlCreateLabel("x (um)", 42, 106, 48, 17)
$Label_StartPointY = GUICtrlCreateLabel("y (um)", 42, 132, 48, 17)
$Input_SetStepX = GUICtrlCreateInput("", 127, 189, 98, 21)
$Label_SetStepX = GUICtrlCreateLabel("Step X (nm)", 44, 191, 66, 17)
$Input_SetStepY = GUICtrlCreateInput("", 127, 214, 98, 21)
$Label_SetStepY = GUICtrlCreateLabel("Step Y (nm)", 44, 216, 66, 17)
$Group_SetStep = GUICtrlCreateGroup("Set Step", 18, 169, 409, 79)
$Label_StartRow = GUICtrlCreateLabel("Start Row", 256, 194, 65, 17)
$Label_StartCol = GUICtrlCreateLabel("Start Col", 256, 216, 65, 17)
$Input_StartRow = GUICtrlCreateInput("1", 328, 189, 65, 21)
$Input_StartCol = GUICtrlCreateInput("1", 328, 214, 65, 21)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Button_StartPause = GUICtrlCreateButton("Start", 306, 415, 100, 33)
$Label_TotalRow = GUICtrlCreateLabel("Total Row", 76, 300, 66, 17)
$Label_TotalCol = GUICtrlCreateLabel("Total Col", 77, 326, 66, 17)
$Label_CurrentRow = GUICtrlCreateLabel("Cur. Row", 79, 352, 66, 17)
$Label_CurrentCol = GUICtrlCreateLabel("Cur. Col", 79, 378, 66, 17)
$Input_TotalRow = GUICtrlCreateInput("", 148, 298, 85, 21)
$Input_TotalCol = GUICtrlCreateInput("", 148, 324, 85, 21)
$Input_CurrentRow = GUICtrlCreateInput("", 148, 350, 85, 21)
$Input_CurrentCol = GUICtrlCreateInput("", 148, 376, 85, 21)
$Label_CurrentPosX = GUICtrlCreateLabel("Cur. Pos X (um)", 53, 404, 95, 17)
$Input_CurrentPosX = GUICtrlCreateInput("", 148, 402, 85, 21)
$Label_CurrentPosY = GUICtrlCreateLabel("Cur. Pos Y (um)", 53, 430, 95, 17)
$Input_CurrentPosY = GUICtrlCreateInput("", 148, 428, 85, 21)
$Group_Status = GUICtrlCreateGroup("Status", 28, 280, 238, 189)
GUICtrlCreateGroup("", -99, -99, 1, 1)
;$Input_imgsize = GUICtrlCreateInput("", 352, 305, 57, 21)
;$Label_imgsize = GUICtrlCreateLabel("image size:", 264, 307, 72, 17)
$Input_pixelsize = GUICtrlCreateInput("", 352, 345, 57, 21)
$Label_pixelsize = GUICtrlCreateLabel("pixelsize:", 264, 347, 72, 17)
$Label_VerInfo = GUICtrlCreateLabel("Version:3.0.0.1", 32, 496, 110, 24)
GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
$Label_EmailInfo = GUICtrlCreateLabel("xi.chen@ia.ac.cn", 32, 516, 120, 24)
GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
$Button_GotoEP = GUICtrlCreateButton("goto", 200, 55, 48, 20)
$Button_GotoSP = GUICtrlCreateButton("goto", 200, 133, 48, 20)
$Group_SpecPos = GUICtrlCreateGroup("Specify Pos.", 272, 16, 169, 129)
$Label_SpecRow = GUICtrlCreateLabel("Row", 304, 42, 26, 17)
$Label_SpecCol = GUICtrlCreateLabel("Col", 304, 72, 19, 17)
$Input_SpecRow = GUICtrlCreateInput("", 336, 40, 65, 21)
$Input_SpecCol = GUICtrlCreateInput("", 336, 70, 65, 21)
$Button_GotoSpecPos = GUICtrlCreateButton("goto", 304, 104, 41, 25)
$Button_Photo = GUICtrlCreateButton("photo", 368, 104, 41, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
;$jpg = GUICtrlCreateRadio("jpg", 304, 304, 33, 33)
;$tif = GUICtrlCreateRadio("tif", 360, 304, 33, 33)
;GUICtrlSetState($tif, $GUI_CHECKED)
;$Group1 = GUICtrlCreateGroup("select image format", 288, 280, 129, 65)
;GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateButton("logo", 160, 480, 53, 53, $BS_BITMAP)
GUICtrlSetImage(-1, "logo.bmp")
$Edit_Status = GUICtrlCreateInput("", 230, 520, 200, 21)
$Button_SendStagePos = GUICtrlCreateButton("Send Stage Pos", 230, 475, 100, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

GreyOutAllInput()
UnGreyOutPartInput()

Global $g_bRun    ; 程序运行标识符
Global $g_bEnd    ; 采样结束标识符
Global $g_nTolRow   ; 总行数
Global $g_nTolCol   ;  总列数
Global $g_nCurRow   ;  当前行
Global $g_nCurCol   ;  当前列
Global $g_nCurPosX  ;  当前x坐标
Global $g_nCurPosY  ;  当前y坐标
Global $g_nStartPosX   ;  起始点x坐标
Global $g_nStartPosY   ;  起始点y坐标
Global $g_nEndPosX     ;  终止点x坐标
Global $g_nEndPosY     ;  终止点y坐标
Global $g_nStepX       ;  x步进
Global $g_nStepY       ;  y步进
Global $g_sPrefix      ;  前缀
Global $g_nStartRow    ;  起始行
Global $g_nStartCol    ;  起始列
Global $g_bChangeRow   ;  是否换行
Global $g_nformat = "tif"     ;save image format

Global $historyfilename = @WorkingDir &"\sem_server_setup_v3.ini"
Global $sectionname = "preval"

GUICtrlSetData ($Input_pixelsize,	"14.9")
;GUICtrlSetData ($Input_imgsize,	"2048")
LoadHistory()
; start tcp service
Global $bServerStart = False
Global $bConnected = False
Global $listenSocket = 0    ; socket for listening
Global $connectedSocket = -1    ; socket for current connection
Global $local_IP = SelectLocalIP();  "192.168.100.100" ;
Global $nPort = 65432
WinMain()

Func WinMain()
	;参数初始化
	$g_bRun = False
	$g_bEnd = False
	$g_nTolRow = 0
	$g_nTolCol = 0
	$g_nCurRow = 0
	$g_nCurCol = 0
	$g_nCurPosX = 0
	$g_nCurPosY = 0
	$g_nStartPosX = 0
	$g_nStartPosY = 0
	$g_nEndPosX = 0
	$g_nEndPosY = 0
	$g_nStepX = 1      ; 步进不能为0
	$g_nStepY = 1      ; 步进不能为0
	$g_sPrefix = ""
	$g_nStartRow = 1
	$g_nStartCol = 1
	$g_bChangeRow = False

	;LoadHistory()
	;$title_SmartSEM = "SmartSEM - [SERVICE]"
	;$buttonID_freeze = "Button10"
	;$buttonID_saveImg = "Button21"
	;$buttonID_rescan = "Button11"
	$hwnd_SmartSEM = WinGetHandle($title_SmartSEM)
	$bServerStart = start_TCp()
	If Not $bServerStart Then
	  MsgBox(BitOR($MB_ICONERROR, $MB_OK), "Error", "Could not start server, it will be closed after few seconds!")
	  Sleep(5000)
	  WinExit()
    EndIf

    Local $nMsg, $iError, $sgn_msg_rev, $msg_rec, $str
	While 1
	   $nMsg = GUIGetMsg(1)
	   Switch $nMsg[0]
	   Case $GUI_EVENT_CLOSE
		  WinExit()
	   Case $Button_GetEndPoint
		  OnButtonGetEnd()
	   Case $Button_GetStartPoint
		  OnButtonGetStart()
	   Case $Button_StartPause
		  OnButtonStartPause()
	   Case $Button_GotoEP
		  OnButtonGotoEP()
	   Case $Button_GotoSP
		  OnButtonGotoSP()
	   Case $Button_GotoSpecPos
		  OnButtonGotoSpecPos()
	   Case $Button_Photo
		  OnButtonPhoto()
	   Case $Button_SendStagePos
		  OnButtonSendStagePos()
	   EndSwitch

	   ; accept for new connection
	  Local $tmpSocket = TCPAccept($listenSocket)
	  If $tmpSocket <> -1 Then
		 If $connectedSocket <> -1 Then
			TCPSend($tmpSocket, "dey1_there is already a connection!")
			TCPCloseSocket($tmpSocket)
		 Else
			$connectedSocket = $tmpSocket
			$bConnected = True
			GUICtrlSetState($Button_SendStagePos, $GUI_ENABLE)
			Local $sClientIPAddress = SocketToIP($connectedSocket)
			AddStatusMsg("a connection from " & $sClientIPAddress & " is stablished" )
		 EndIf
	  EndIf

	  If $bConnected Then ; a connection already stablished, it can receive msg

		 Local $sReceived = TCPRecv($connectedSocket, 2048)
		 Local $iError = @error
		 If $sReceived = "" Then  ; nothing received
			;MsgBox(1,"sem error report",@error & @CRLF &$sReceived)
			If $iError = 10054 Then    ; connection lost
			   TCPCloseSocket($connectedSocket)   ; close connection for next new arrival
			   $connectedSocket = -1
			   $bConnected = False
			   AddStatusMsg("Connection lost" )
			   GUICtrlSetState($Button_SendStagePos, $GUI_DISABLE)
			EndIf
		 Else   ; receive new msg, need to be analysis
			;MsgBox(1,"test",$sReceived)
			$sgn_msg_rev = StringLeft( $sReceived, 5 )
			$msg_rec = StringRight( $sReceived, StringLen($sReceived)-5 )
			Local $x, $y

			Switch $sgn_msg_rev
			Case "clo1_"     ; connection stopped by observer
			   TCPCloseSocket($connectedSocket)   ; close connection for next new arrival
			   $connectedSocket = -1
			   $bConnected = False
			   AddStatusMsg($msg_rec )
			   GUICtrlSetState($Button_SendStagePos, $GUI_DISABLE)
			Case "goto_"    ; goto
			   AnalysisGotoPos($x, $y, $msg_rec)
			   ;MoveStage($x,$y,False)
			   Local $str = "trup_" & $x & ":" & $y
			   MsgBox(0,"",$str)
			   AddStatusMsg("move stage to x:" & $x & " y:" & $y )
			EndSwitch
		 EndIf

	  EndIf

		If $g_bRun And (Not $g_bEnd) Then
			RunAutoGrabProg()
		EndIf
	WEnd
EndFunc


Func RunAutoGrabProg()
	CalcNextPos($g_nCurRow,$g_nCurCol,$g_nCurPosX,$g_nCurPosY, $g_nTolRow, $g_nTolCol, $g_nStepX, $g_nStepY, $g_nStartPosX,$g_nStartPosY)
	If Not $g_bEnd Then
		UpdateInfo()
		Sleep(200)
		;MsgBox(0, "pleases select jpeg", $g_nCurPosX & " " & $g_nCurPosY)
		;MoveStage($g_nCurPosX,$g_nCurPosY)
		MoveStage($g_nCurPosX,$g_nCurPosY, $g_bChangeRow)
		Sleep(200)
		SaveImgDetail($g_sPrefix,$g_nCurRow,$g_nCurCol)
		Sleep(1000)
	Else
		$g_bRun = False
		GUICtrlSetData($Button_StartPause,"Start")     ; 终止程序运行
		UnGreyOutPartInput()
	EndIf
EndFunc


Func WinExit()
    exit_TCp()
	SaveHistory()
	Exit
EndFunc

Func OnSetJPEGFormat()

EndFunc

Func OnSetTIFFormat()

EndFunc


Func OnButtonGetEnd()     ; 获取采样终止点坐标
	Local $x, $y
	GetStagePos($x, $y)
	sleep(200)
	GUICtrlSetData($Input_EndPointX, $x)
	GUICtrlSetData($Input_EndPointY, $y)
EndFunc


Func OnButtonGotoEP()    ; goto终止点
	Local $x, $y
	$x = GUICtrlRead ($Input_EndPointX)
	$y = GUICtrlRead ($Input_EndPointY)
	Sleep(200)
	MoveStage($x, $y, False)
EndFunc


Func OnButtonGetStart()     ; 获取采样起点坐标
	Local $x, $y
	GetStagePos($x, $y)
	sleep(200)
	GUICtrlSetData($Input_StartPointX, $x)
	GUICtrlSetData($Input_StartPointY, $y)
EndFunc


Func OnButtonGotoSP()     ; goto起始点
	Local $x, $y
	$x = GUICtrlRead ($Input_StartPointX)
	$y = GUICtrlRead ($Input_StartPointY)
	Sleep(200)
	MoveStage($x, $y, False)
EndFunc


Func OnButtonGotoSpecPos()     ; goto指定点
	Local $row, $col, $x, $y, $stepx, $stepy, $xs, $ys
	$row = GUICtrlRead ($Input_SpecRow)
	$col = GUICtrlRead ($Input_SpecCol)
	$stepx = GUICtrlRead ($Input_SetStepX)
	$stepy = GUICtrlRead ($Input_SetStepY)
	$xs = GUICtrlRead ($Input_StartPointX)
	$ys = GUICtrlRead ($Input_StartPointY)
	$y = $ys + ($row-1)*$stepY/1000
	$x = $xs + ($col-1)*$stepX/1000
	Sleep(200)
	MoveStage($x, $y, False)
EndFunc


Func OnButtonPhoto()    ;  对指定行列号进行拍照
	Local $row, $col, $prefix
	$row = GUICtrlRead ($Input_SpecRow)
	$col = GUICtrlRead ($Input_SpecCol)
	$prefix = GUICtrlRead ($Input_prefix)
	Sleep(200)
	SaveImgDetail($prefix,$row,$col)
	Sleep(200)
EndFunc


Func OnButtonStartPause()      ; 响应按钮消息
	$g_bRun = Not $g_bRun
	;SaveHistory()
	If $g_bRun Then
		GUICtrlSetData($Button_StartPause,"Pause")     ; 开始程序运行 或恢复程序运行
		GreyOutAllInput()
		Local $xs,$xe,$ys,$ye,$stepx,$stepy,$row_start,$col_start
		$xs = GUICtrlRead ($Input_StartPointX)          ; 检测
		$xe = GUICtrlRead ($Input_EndPointX)
		$ys = GUICtrlRead ($Input_StartPointY)
		$ye = GUICtrlRead ($Input_EndPointY)
		$stepx = GUICtrlRead ($Input_SetStepX)
		$stepy = GUICtrlRead ($Input_SetStepY)
		;$prefix = GUICtrlRead ($Input_prefix)
		$row_start = GUICtrlRead ($Input_StartRow)
		$col_start = GUICtrlRead ($Input_StartCol)
		If $xs=$g_nStartPosX And $ys=$g_nStartPosY And $xe=$g_nEndPosX And $ye=$g_nEndPosY And $stepx=$g_nStepX And $stepy=$g_nStepY And $row_start=$g_nStartRow And $col_start=$g_nStartCol Then
			sleep(200)
			$g_bEnd = False
		Else                          ; 检测到数据更新，重新开始采样
			$g_nStartPosX = $xs
			$g_nStartPosY = $ys
			$g_nEndPosX = $xe
			$g_nEndPosY = $ye
			$g_nStepX = $stepx
			$g_nStepY = $stepy
			$g_sPrefix = $prefix
			$g_nStartRow = $row_start
			$g_nStartCol = $col_start
			CalcAutoGrabInfo($g_nStartPosX, $g_nEndPosX, $g_nStartPosY, $g_nEndPosY, $g_nStepX, $g_nStepY, $g_nTolRow, $g_nTolCol)  ; 更新采样行列数目
			GUICtrlSetData($Input_TotalRow, $g_nTolRow)
			GUICtrlSetData ($Input_TotalCol, $g_nTolCol)
			$g_nCurRow = $g_nStartRow
			$g_nCurCol = $g_nStartCol - 1
			$g_bEnd = False
		EndIf
	Else
		GUICtrlSetData($Button_StartPause,"Start")     ; 暂停程序运行
		UnGreyOutPartInput()
	EndIf
EndFunc

#cs
Func MoveStage($x,$y)      ; 移动平台至指定位置
   WinActivate($str_Su_Title)
   sleep(100)
   MouseClick("left",109,87)
   Sleep(200)
   ControlSetText($str_Su_Title,"Stage","TMemo1",$x)
   Sleep(200)
   ControlSetText($str_Su_Title,"Stage","TMemo2",$y)
   Sleep(200)
   ControlSetText($str_Su_Title,"Stage","TMemo3",0)
   Sleep(200)
   ControlClick($str_Su_Title,"Stage","TButton9")    ; click goto
   Sleep(100)
   ControlClick($str_Su_Title,"Stage","TButton9")    ; one more to guarantee
   Sleep(100)
   WaitStageMoveComplete($x,$y)
EndFunc
#ce


Func MoveStage($x,$y, $bChangeRow)      ; 移动平台至指定位置
   WinActivate($str_Su_Title)
   sleep(100)
   MouseClick("left",109,87)
   Sleep(200)
   ControlSetText($str_Su_Title,"Stage","TMemo1",$x)
   Sleep(200)
   ControlSetText($str_Su_Title,"Stage","TMemo2",$y)
   ;Sleep(200)
   ;ControlSetText($str_Su_Title,"Stage","TMemo3",0)
   Sleep(200)
   ControlClick($str_Su_Title,"Stage","TButton9")    ; click goto
   Sleep(100)
   ControlClick($str_Su_Title,"Stage","TButton9")    ; one more to guarantee
   Sleep(100)
   If $bChangeRow Then
	  WaitStageChangeRowMoveComplete($x,$y)
	  $g_bChangeRow = False
   Else
	  WaitStageMoveComplete($x,$y)
   EndIf
EndFunc



Func WaitStageMoveComplete($x,$y)         ; 等待平台移动完毕
	Sleep($stageOKTime)
EndFunc


Func WaitStageChangeRowMoveComplete($x,$y)         ; 等待平台移动完毕
	Sleep($stageChangeRowOKTime)
EndFunc



Func GetStagePos(ByRef $x, ByRef $y)            ; 获取平台当前位置
   ;WinActivate($str_Su_Title)
   ;Sleep(100)
   Local $handle, $num, $str
   Local $mark1_l, $mark1_r, $mark2_l, $mark2_r
   $handle = ControlGetHandle($str_Su_Title,"Stage","TListBox1")
   $num = _GUICtrlListBox_GetListBoxInfo($handle)
   Do
	  Sleep(500)
	  ControlClick($str_Su_Title,"Stage","TButton5")   ; add button
   Until _GUICtrlListBox_GetListBoxInfo($handle) = $num + 1
   Sleep(500)
   $str = _GUICtrlListBox_GetText($handle,$num)
   Do
	  Sleep(500)
	  ControlClick($str_Su_Title,"Stage","TButton4")   ; delete button
   Until _GUICtrlListBox_GetListBoxInfo($handle) = $num
   $mark1_l = StringInStr($str,"(")
   $mark1_r = StringInStr($str,")")
   $mark2_l = StringInStr($str,"(",0,1,$mark1_r+1)
   $mark2_r = StringInStr($str,")",0,1,$mark2_l+1)
   ;$x = StringLeft($str,$mark1_r-1)
   ;$x = StringRight($x,$mark1_r-$mark1_l-1)
   ;$y = StringLeft($str,$mark2_r-1)
   ;$y = StringRight($y,$mark2_r-$mark2_l-1)
   $x = StringLeft($str,$mark1_r-1)
   $x = StringRight($x,$mark1_r-$mark1_l-1)
   $y = StringLeft($str,$mark2_r-1)
   $y = StringRight($y,$mark2_r-$mark2_l-1)
EndFunc


Func SaveImgQuick()        ; 左键点击savetiff，快捷模式保存图像
	if NOT WinActive($title_SmartSEM) Then
		WinActivate($title_SmartSEM, "")
	EndIf
	Sleep(200)
	ControlClick($title_SmartSEM,"",$buttonID_saveImg)
EndFunc

#cs
Func SaveImgDetail($prefix, $Row, $Col)      ; 中键点击savetiff，详细设置图像保存信息
	;acquire image
   WinActivate("CCD/TV Camera")
   Sleep(200)
   ControlClick("CCD/TV Camera","","Button3")
   Sleep($imageSaveTime)

   ; save image
   Local $savedir = $strTempSaveDir
   WinActivate("TEM Imaging & Analysis ")
   Sleep(200)
   ControlClick("TEM Imaging & Analysis ","","[Class:AfxFrameOrView42]","left")
   Sleep(200)
   ControlClick("TEM Imaging & Analysis ","","[Class:AfxFrameOrView42]","right")
   for $i = 1 to 13
    sleep(50)
    send("{DOWN}")
   next
   sleep(100)
   send("{ENTER}")
   WinWait("Save As")
   sleep(100)
   if NOT WinActive("Save As") Then
		WinActivate("Save As", "")
	 EndIf
	 Sleep(200)
	ControlSetText("Save As","","Edit1",$savedir & $prefix & $Row & "_" & $Col & ".tif")
	Sleep(200)
	ControlClick("Save As","","Button2")    ; 单击ok键
	Sleep(1000)
	ControlClick("TEM Imaging & Analysis ","","[Class:AfxFrameOrView42]","left")
	Sleep(200)
	ControlClick("TEM Imaging & Analysis ","","[Class:AfxFrameOrView42]","left")
	Sleep(200)
   send("{DEL}")
   Return $savedir
EndFunc
#ce


Func SaveImgDetail($prefix, $Row, $Col)      ; 讨论班版本，点击acquire键后，自动保存图像，然后del键删除
	;acquire image
   WinActivate("CCD/TV Camera")
   Sleep(200)
   ControlClick("CCD/TV Camera","","Button3")
   Sleep($imageSaveTime)

   send("{DEL}")

EndFunc


Func CalcAutoGrabInfo($xs, $xe, $ys, $ye, $stepX, $stepY, ByRef $TolRow, ByRef $TolCol)   ; 计算自动采集所需要的总行数和总列数
	;  $xs  起始点x坐标      $xe   终止点x坐标     $ys  起始点y坐标      $ye   终止点y坐标
	;  $stepX  x步长（微米）          $stepY  y步长（微米）
	$TolCol = _Max( Ceiling(Abs(($xe-$xs))*1000/Abs($stepX))+1, 1)
	$TolRow = _Max( Ceiling(Abs(($ye-$ys))*1000/Abs($stepY))+1, 1)
EndFunc


Func CalcNextPos(ByRef $CurRow, ByRef $CurCol, ByRef $CurPosX, ByRef $CurPosY, $TolRow, $TolCol, $stepX, $stepY, $xs, $ys)  ; 计算下一幅图像的行列号和位置
	If $CurRow < $TolRow Then
		If $CurCol < $TolCol Then
			$CurPosY = $ys + ($CurRow-1)*$stepY/1000
			$CurCol += 1
			$CurPosX = $xs + ($CurCol-1)*$stepX/1000
		Else
			$CurRow += 1
			$CurPosY = $ys + ($CurRow-1)*$stepY/1000
			$CurCol = 1
			$CurPosX = $xs + ($CurCol-1)*$stepX/1000
			$g_bChangeRow = True
		EndIf
	Else
		If $CurCol < $TolCol Then
			$CurPosY = $ys + ($CurRow-1)*$stepY/1000
			$CurCol += 1
			$CurPosX = $xs + ($CurCol-1)*$stepX/1000
		Else
			$g_bEnd = True
		EndIf
	 EndIf
	 ;MsgBox(0, "pleases select jpeg", $CurPosX & " " & $CurPosY)
EndFunc


Func GreyOutAllInput()     ; 程序运行时输入框状态都成灰色
	GUICtrlSetState ( $Input_EndPointX, $GUI_DISABLE )
	GUICtrlSetState ( $Input_EndPointY, $GUI_DISABLE )
	GUICtrlSetState ( $Input_StartPointX, $GUI_DISABLE )
	GUICtrlSetState ( $Input_StartPointY, $GUI_DISABLE )
	GUICtrlSetState ( $Input_SetStepX, $GUI_DISABLE )
	GUICtrlSetState ( $Input_SetStepY, $GUI_DISABLE )
	;GUICtrlSetState ( $Input_prefix, $GUI_DISABLE )
	GUICtrlSetState ( $Input_TotalRow, $GUI_DISABLE )
	GUICtrlSetState ( $Input_TotalCol, $GUI_DISABLE )
	GUICtrlSetState ( $Input_CurrentRow, $GUI_DISABLE )
	GUICtrlSetState ( $Input_CurrentCol, $GUI_DISABLE )
	GUICtrlSetState ( $Input_CurrentPosX, $GUI_DISABLE )
	GUICtrlSetState ( $Input_CurrentPosY, $GUI_DISABLE )
	GUICtrlSetState ( $Input_StartRow, $GUI_DISABLE )
	GUICtrlSetState ( $Input_StartCol, $GUI_DISABLE )
	GUICtrlSetState ( $Input_SpecRow, $GUI_DISABLE )
	GUICtrlSetState ( $Input_SpecCol, $GUI_DISABLE )
EndFunc


Func UnGreyOutPartInput()     ;; 程序暂停时部分输入框呈可编辑状态
	GUICtrlSetState ( $Input_EndPointX, $GUI_ENABLE )
	GUICtrlSetState ( $Input_EndPointY, $GUI_ENABLE )
	GUICtrlSetState ( $Input_StartPointX, $GUI_ENABLE )
	GUICtrlSetState ( $Input_StartPointY, $GUI_ENABLE )
	GUICtrlSetState ( $Input_SetStepX, $GUI_ENABLE )
	GUICtrlSetState ( $Input_SetStepY, $GUI_ENABLE )
	;GUICtrlSetState ( $Input_prefix, $GUI_ENABLE )
	GUICtrlSetState ( $Input_StartRow, $GUI_ENABLE )
	GUICtrlSetState ( $Input_StartCol, $GUI_ENABLE )
	GUICtrlSetState ( $Input_SpecRow, $GUI_ENABLE )
	GUICtrlSetState ( $Input_SpecCol, $GUI_ENABLE )
EndFunc


Func UpdateInfo()      ; 更新 status 信息
	GUICtrlSetData($Input_TotalRow, $g_nTolRow)
	GUICtrlSetData ($Input_TotalCol, $g_nTolCol)
	GUICtrlSetData($Input_CurrentRow, $g_nCurRow)
	GUICtrlSetData($Input_CurrentCol, $g_nCurCol)
	GUICtrlSetData($Input_CurrentPosX, $g_nCurPosX)
	GUICtrlSetData($Input_CurrentPosY, $g_nCurPosY)
EndFunc


Func LoadHistory()
	Local $xs,$xe,$ys,$ye,$stepx,$stepy,$prefix,$row_start,$col_start
	Local $total_row, $total_col, $cur_row, $cur_col,$cur_x,$cur_y, $spec_row, $spec_col

	;MsgBox(0, "xs", $xs)
	Local $var = IniReadSection( $historyfilename,$sectionname)
	If @error Then
	   $str_Su_Title= "[Class:#32770]"
	  $strTempSaveDir = "c:\"
	  $stageOKTime = 1500
	  $stageChangeRowOKTime = 3000
	  $imageSaveTime = 2000
		Return
	EndIf
	$xs= $var[1][1]
	$xe=$var[2][1]
	$ys=$var[3][1]
	$ye=$var[4][1]
	If $var[5][1] <> "" Then
	   $stepx=$var[5][1]
    Else
	   $stepx=7488.5
    EndIf
	If $var[6][1] <> "" Then
	   $stepy=$var[6][1]
    Else
	   $stepy=7488.5
    EndIf
	$row_start= $var[7][1]
	$col_start= $var[8][1]
	$total_row=$var[9][1]
	$total_col=$var[10][1]
	$cur_row=$var[11][1]
	$cur_col=$var[12][1]
	$cur_x=$var[13][1]
	$cur_y=$var[14][1]
	$spec_row=$var[15][1]
	$spec_col=$var[16][1]
	$str_Su_Title= $var[17][1]
   $strTempSaveDir = $var[18][1]
   $stageOKTime = $var[19][1]
   $stageChangeRowOKTime = $var[20][1]
   $imageSaveTime = $var[21][1]

	;show data
    GUICtrlSetData ($Input_StartPointX,	$xs)
	GUICtrlSetData ($Input_EndPointX, $xe)
	GUICtrlSetData ($Input_StartPointY, $ys)
	GUICtrlSetData ($Input_EndPointY,$ye)
	GUICtrlSetData ($Input_SetStepX,$stepx)
	GUICtrlSetData ($Input_SetStepY,$stepy)
	;GUICtrlSetData ($Input_prefix,$prefix)
	GUICtrlSetData ($Input_StartRow ,$row_start)
	GUICtrlSetData ($Input_StartCol,$col_start)
	GUICtrlSetData($Input_TotalRow,$total_row)
	GUICtrlSetData($Input_TotalCol,$total_col)
	GUICtrlSetData($Input_CurrentRow ,$cur_row)
	GUICtrlSetData($Input_CurrentCol,$cur_col)
	GUICtrlSetData($Input_CurrentPosX,$cur_x)
	GUICtrlSetData($Input_CurrentPosY ,$cur_y)
	GUICtrlSetData($Input_SpecRow ,$spec_row)
	GUICtrlSetData($Input_SpecCol,$spec_col)

EndFunc

Func SaveHistory()
	FileDelete ($historyfilename)
	;Local $sectionname = "preval"
	Local $xs,$xe,$ys,$ye,$stepx,$stepy,$prefix,$row_start,$col_start
	Local $total_row, $total_col, $cur_row, $cur_col,$cur_x,$cur_y, $spec_row, $spec_col
		$xs = GUICtrlRead ($Input_StartPointX)
		$xe = GUICtrlRead ($Input_EndPointX)
		$ys = GUICtrlRead ($Input_StartPointY)
		$ye = GUICtrlRead ($Input_EndPointY)
		$stepx = GUICtrlRead ($Input_SetStepX)
		$stepy = GUICtrlRead ($Input_SetStepY)
		;$prefix = GUICtrlRead ($Input_prefix)
		$row_start = GUICtrlRead ($Input_StartRow)
		$col_start = GUICtrlRead ($Input_StartCol)
		$total_row = GUICtrlRead($Input_TotalRow)
		$total_col = GUICtrlRead($Input_TotalCol)
		$cur_row = GUICtrlRead($Input_CurrentRow)
		$cur_col = GUICtrlRead($Input_CurrentCol)
		$cur_x = GUICtrlRead($Input_CurrentPosX)
		$cur_y = GUICtrlRead($Input_CurrentPosY)
		$spec_row = GUICtrlRead($Input_SpecRow)
		$spec_col = GUICtrlRead($Input_SpecCol)
	IniWrite($historyfilename, $sectionname, "xs",$xs )
	IniWrite ($historyfilename, $sectionname, "xe",$xe )
	IniWrite ($historyfilename, $sectionname, "ys",$ys )
	IniWrite ($historyfilename, $sectionname, "ye",$ye )
	IniWrite ($historyfilename, $sectionname, "stepx",$stepx )
	IniWrite ($historyfilename, $sectionname,"stepy", $stepy)
	;IniWrite ($historyfilename, $sectionname,"prefix", $prefix)
	IniWrite ($historyfilename, $sectionname,"row_start",$row_start )
	IniWrite ($historyfilename, $sectionname,"col_start", $col_start)
	IniWrite ($historyfilename, $sectionname,"total_row", $total_row)
	IniWrite ($historyfilename, $sectionname,"total_col", $total_col)
	IniWrite ($historyfilename, $sectionname,"cur_row", $cur_row)
	IniWrite ($historyfilename, $sectionname,"cur_col", $cur_col)
	IniWrite ($historyfilename, $sectionname,"cur_x", $cur_x)
	IniWrite ($historyfilename, $sectionname,"cur_y", $cur_y)
	IniWrite ($historyfilename, $sectionname,"spec_row", $spec_row)
	IniWrite ($historyfilename, $sectionname,"spec_col", $spec_col)
	IniWrite ($historyfilename, $sectionname, "title",$str_Su_Title )
	IniWrite ($historyfilename, $sectionname, "tempdir",$strTempSaveDir )
	IniWrite ($historyfilename, $sectionname, "stageOKTime",$stageOKTime )
	IniWrite ($historyfilename, $sectionname, "stageChangeRowOKTime",$stageChangeRowOKTime )
	IniWrite ($historyfilename, $sectionname, "imageSaveTime",$imageSaveTime )
	Return
EndFunc



Func SelectLocalIP()
	; Add additional items to the combobox.
	Local $str = ""
	If @IPAddress2 <> "0.0.0.0" Then
	   If $str = "" Then
		 $str = @IPAddress2
	   Else
		 $str = $str & "|" & @IPAddress2
	  EndIf
   EndIf
   If @IPAddress3 <> "0.0.0.0" Then
	   If $str = "" Then
		 $str = @IPAddress3
	  Else
		 $str = $str & "|" & @IPAddress3
	  EndIf
   EndIf
   ;$str = "0.0.0.0|1.1.1.1"

   If $str == "" Then
	  Return @IPAddress1
   EndIf

   ; Create a GUI with various controls.
	Local $hGUI = GUICreate("Select Local IP for server", 300, 80)

	; Create a combobox control.
	Local $idComboBox = GUICtrlCreateCombo(@IPAddress1, 10, 10, 150, 20)
	Local $idClose = GUICtrlCreateButton("OK", 200, 30, 85, 40)

   If $str <> "" Then
	   GUICtrlSetData($idComboBox, $str)
   EndIf

	; Display the GUI.
	GUISetState(@SW_SHOW, $hGUI)

	Local $sComboRead = ""

	; Loop until the user exits.
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $idClose
				ExitLoop
			Case $idComboBox
				$sComboRead = GUICtrlRead($idComboBox)
		EndSwitch
	WEnd
   $sComboRead = GUICtrlRead($idComboBox)
   ;MsgBox($MB_SYSTEMMODAL, "", "The combobox is currently displaying: " & $sComboRead, 0, $hGUI)
	; Delete the previous GUI and all controls.
	GUIDelete($hGUI)
	Return $sComboRead
 EndFunc



 Func start_TCp()
	TCPStartup() ; Start the TCP service.
	$listenSocket = TCPListen($local_IP, $nPort, 100)
   Local $iError = 0
   If @error Then
	  ; Someone is probably already listening on this IP Address and Port (script already running?).
	  $iError = @error
	  AddStatusMsg("Could not start server for IP:" & $local_IP & " Port:" & $nPort & ", Error code: " & $iError)
	  Return False
   Else
	  AddStatusMsg("Server started for IP:" & $local_IP & " Port:" & $nPort)
	  Return True
   EndIf
EndFunc


Func exit_TCp()
   If $connectedSocket <> -1 Then
	  TCPSend($connectedSocket, "clo1_connection closed by sem")
   EndIf
   TCPCloseSocket($connectedSocket)
   $connectedSocket = -1
   TCPCloseSocket($listenSocket)
   $listenSocket = 0
   TCPShutdown()
EndFunc


Func AddStatusMsg($msg)
   GUICtrlSetData($Edit_Status, $msg, 1)
EndFunc

Func SocketToIP($iSocket)
    Local $tSockAddr = 0, $aRet = 0
    $tSockAddr = DllStructCreate("short;ushort;uint;char[8]")
    $aRet = DllCall("Ws2_32.dll", "int", "getpeername", "int", $iSocket, "ptr", DllStructGetPtr($tSockAddr), "int*", DllStructGetSize($tSockAddr))
    If Not @error And $aRet[0] = 0 Then
        $aRet = DllCall("Ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($tSockAddr, 3))
        If Not @error Then Return $aRet[0]
    EndIf
    Return 0
 EndFunc   ;==>SocketToIP


 Func AnalysisGotoPos(ByRef $x, ByRef $y, $msg)            ; acess stage target pos
   Local $aData = StringSplit($msg,":")
   $x = $aData[1]
   $y = $aData[2]
EndFunc

#cs
Func OnButtonSendStagePos()
   Local $x, $y
	GetStagePos($x, $y)
	Local $str = "trup_" & $x & ":" & $y
   TCPSend($connectedSocket, $str)
EndFunc
#ce


; 讨论版
Func OnButtonSendStagePos()
   Local $xs,$ys,$stepx,$stepy,$pixelsize,$imgsize
	Local $total_row, $total_col
		$xs = GUICtrlRead ($Input_StartPointX)
		$ys = GUICtrlRead ($Input_StartPointY)
		$stepx = GUICtrlRead ($Input_SetStepX)
		$stepy = GUICtrlRead ($Input_SetStepY)
		$total_row = GUICtrlRead($Input_TotalRow)
		$total_col = GUICtrlRead($Input_TotalCol)
		$pixelsize = GUICtrlRead($Input_pixelsize)
		;$imgsize = GUICtrlRead($Input_imgsize)
	Local $str = "trup_" & $xs & ":" & $ys & ":" & $stepx & ":" & $stepy & ":" & $total_row & ":" & $total_col & ":" & $pixelsize ;& ":" & $imgsize
   TCPSend($connectedSocket, $str)
   ;MsgBox(0,"",$str)
EndFunc