; ====================================================================
; PureDent
;   author: @jrobb
;   Copyright 2011 Jon Robbins
;
; ====================================================================
;     This file is part of PureDent.
; 
;     PureDent is free software: you can redistribute it And/Or modify
;     it under the terms of the GNU Lesser General Public License As published by
;     the Free Software Foundation, either version 3 of the License, Or
;     (at your option) any later version.
; 
;     PureDent is distributed IN the hope that it will be useful,
;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;     MERCHANTABILITY Or FITNESS For A PARTICULAR PURPOSE.  See the
;     GNU Lesser General Public License For more details.
; 
;     You should have received a copy of the GNU Lesser General Public License
;     along With PureDent.  If Not, see <http://www.gnu.org/licenses/>.
; ====================================================================
; This code is hosted here on github: 
;   https://github.com/jfrobbins/PureDent
;
; The programming language used is PureBasic, vist purebasic.com for more info.
;   It is not a free or opensource compiler.
; ====================================================================
; StatusNet api:
;   http://status.net/docs/api/statusesupdate.html
; ====================================================================
XIncludeFile "RW_LibCurl_Res.pb"
XIncludeFile "RW_LibCurl_inc.pb" ;we need libcurl!

Enumeration
  #winMain
EndEnumeration

;- Gadgets
Enumeration
  #Panel1
  #scrDents
  #scrReplies
  #scrDM
  #strPost
  #bnPost
EndEnumeration

;- Tab Enumeration
Enumeration
  #tbPosts
  #tbReplies
  #tbDirect
  #tbSettings
  #tbAbout
EndEnumeration

Enumeration ;dent elements
  #dent_container
  #dent_image
  #dent_uname
  #dent_text
  #dent_date
  #dent_from
  #dent_id
  
  #dent_BNredent
  #dent_BNfavor
  #dent_BNcontext
  #dent_BNreply
EndEnumeration

;-===
;- Constants
#nNull = -999.000000000001

;-===
;- Structures
; ===
Structure AppType
  title.s
  
  vMajor.i
  vMinor.i
  vRev.i
  
  description.s
EndStructure

Structure UIStatus
  prevTab.i
  currentTab.i
  
  uname.s
  pw.s
  authHdr.s
  
  apiPath.s ;identi.ca
  
  lastID.i
  nNotices.i
  
  configPath.s
EndStructure

Structure gadgetInfo
  name.i ;dent element
  id.i  ;identica post id?
  
  x.i
  XtiedToID.i
  Xoffset.i
  
  y.i
  YtiedToID.i
  Yoffset.i
  
  w.i
  WidthFixed.i
  WidthTiedToID.i
  WidthOffset.i
  WidthMultiplier.f
  
  h.i
  HeightFixed.i
  HeightTiedToID.i
  HeightOffset.i
  HeightMultiplier.f
EndStructure

Structure DentInfo
  number.i
  image.i
  username.s
  date.s
  from.s
  dentText.s
  id.i
  List gList.gadgetInfo()
EndStructure

;-===
;- Global Vars
Global App.AppType
Global UIS.UIStatus
Global gblPanelSwitch.i
Global NewList Dents.DentInfo()

;-=======
;- App Info
; =======
With App
  \title = "api"
  ;\title = "PureDenter"
  \description = \title + " is an identi.ca/StatusNET client...not a sugarfree gum."
  
  ;-=====
  ;-Versioning
  ; =====
  \vMajor   = 0
  \vMinor   = 0
  \vRev     = 1
EndWith

;-=====
;- Includes
XIncludeFile "common.pb"


;-=======
;- Procedures
;-
Macro GetEXEpath()
  ;returns the path to where the EXE is running from
  GetPathPart(ProgramFilename())
EndMacro

Procedure.i getGadgetParams(List g.gadgetInfo(), defaultX.i=0, defaultY.i=0, defaultW.i=0, defaultH.i=0)
  If IsGadget(g()\id ) = 0
    ProcedureReturn 0
  EndIf
  
  If g()\XtiedToID
    g()\x = GadgetX(g()\XtiedToID) + GadgetWidth(g()\XtiedToID) + g()\Xoffset
  Else
    g()\x = defaultX
  EndIf
  
  If g()\YtiedToID
    g()\y = GadgetY(g()\YtiedToID) + GadgetHeight(g()\YtiedToID) + g()\Yoffset
  Else
    g()\y = defaultY
  EndIf
  
  If g()\WidthFixed
    g()\w = g()\WidthFixed
  ElseIf g()\WidthTiedToID
    If g()\WidthMultiplier
      g()\w = GadgetWidth(g()\WidthTiedToID) * g()\WidthMultiplier
    EndIf
    If g()\WidthOffset
      g()\w = g()\w + g()\WidthOffset
    EndIf
  Else
    g()\w = defaultW
  EndIf
  
  If g()\HeightFixed
    g()\h = g()\HeightFixed
  ElseIf g()\HeightTiedToID
    If g()\HeightMultiplier
      g()\h = GadgetHeight(g()\HeightTiedToID) * g()\heightMultiplier
    EndIf
    If g()\HeightOffset
      g()\h = g()\h + g()\heightOffset
    EndIf
  Else
    g()\h = defaultH
  EndIf
  
  ProcedureReturn 1
EndProcedure

Procedure.i AddNewDent(List d.DentInfo(),Tab.i, position.i, closeGadgetList.i = #False)
  Protected scrArea.i
  Protected containerH.i = 120
  Protected N.i
  Protected pad.i = 4
  
  Select Tab
  Case #tbPosts
    scrArea = #scrDents  
  EndSelect  
  
  AddElement(d())
  n = ListIndex(d())
  
  OpenGadgetList(scrArea)
    
  AddElement(d()\gList())
  
  d()\gList()\WidthTiedToID = scrArea
  d()\gList()\WidthMultiplier = 0.98
  d()\gList()\HeightFixed = containerH
  getGadgetParams(d()\gList(),0,n * containerH + n * pad,0,containerH)
  d()\gList()\id = ContainerGadget(#PB_Any, d()\gList()\x, d()\gList()\y,d()\gList()\w,d()\gList()\h, #PB_Container_Raised)
  d()\gList()\name = #dent_container
  
  AddElement(d()\gList())
  d()\gList()\id = TextGadget(#PB_Any, 100, 25, 385, 65, "Gadget_7", #PB_Text_Border)
  d()\gList()\name = #dent_text
  
  AddElement(d()\gList())
  d()\gList()\id = ImageGadget(#PB_Any, 15, 5, 85, 105, 0, #PB_Image_Border)
  d()\gList()\name = #dent_image
  
  AddElement(d()\gList())
  d()\gList()\id = ButtonGadget(#PB_Any, 105, 90, 45, 20, "redent")
  d()\gList()\name = #dent_BNredent
  
  AddElement(d()\gList())
  d()\gList()\id = ButtonGadget(#PB_Any, 155, 90, 50, 20, "favor")
  d()\gList()\name = #dent_BNfavor
  
  AddElement(d()\gList())
  d()\gList()\id = ButtonGadget(#PB_Any, 210, 90, 60, 20, "context")
  d()\gList()\name = #dent_BNcontext  
  
  AddElement(d()\gList())
  d()\gList()\id = ButtonGadget(#PB_Any, 410, 90, 75, 20, "Reply")
  d()\gList()\name = #dent_BNreply
  
  AddElement(d()\gList())
  d()\gList()\id = TextGadget(#PB_Any, 105, 0, 60, 20, "UserName")
  d()\gList()\name = #dent_uname
  
  AddElement(d()\gList())
  d()\gList()\id = TextGadget(#PB_Any, 165, 0, 140, 20, "Date")
  d()\gList()\name = #dent_date
  
  AddElement(d()\gList())
  d()\gList()\id = TextGadget(#PB_Any, 310, 0, 140, 20, "from ...web?")
  d()\gList()\name = #dent_from
  
  If closeGadgetList
    CloseGadgetList()
  EndIf
EndProcedure

Procedure.i OpenWindow_winMain()
  Protected scrAreaWidth.i  = 485
  Protected scrAreaHeight.i = 945
  Protected scrStep.i       = 10
  
  If OpenWindow(#winMain, 522, 115, 497, 565, "PureDent", #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_TitleBar|#PB_Window_MaximizeGadget|#PB_Window_Invisible)
    SmartWindowRefresh(#winMain, #True)
    StringGadget(#strPost,0,WindowHeight(#winMain) - 55,WindowWidth(#winMain) * 0.8,55,"") ;0, 510, 465, 55, "")
    ButtonGadget(#bnPost, 465, 510, 33, 55, "Post", #PB_Button_Default)
    PanelGadget(#Panel1, 0, 0, 500, 510)
      ; Dents
      AddGadgetItem(#Panel1, -1, "Dents")
        ScrollAreaGadget(#scrDents, 0, 0, 495, 481, scrAreaHeight, scrAreaWidth, scrStep, #PB_ScrollArea_Single)
          ;inject dent stuff          
        CloseGadgetList()   
      AddGadgetItem(#Panel1, -1, "Replies")
        ScrollAreaGadget(#scrReplies, 0, 0, 495, 481, scrAreaHeight, scrAreaWidth, scrStep, #PB_ScrollArea_Single)
      CloseGadgetList()
      AddGadgetItem(#Panel1, -1, "Direct Msgs")
        ScrollAreaGadget(#scrDM, 0, 0, 495, 481, scrAreaHeight, scrAreaWidth, scrStep, #PB_ScrollArea_Single)
      CloseGadgetList()
      AddGadgetItem(#Panel1, -1, "Settings")
      AddGadgetItem(#Panel1, -1, "About")
      
    CloseGadgetList()
    HideWindow(#winMain,0) ;show window
  Else
    ProcedureReturn 0
  EndIf
  
  
  AddNewDent(Dents(),#tbPosts,0)
  
  ProcedureReturn 1
EndProcedure

Procedure resizeUI()
  Protected w.i = #winMain
  Protected wH.i = WindowHeight(w)
  Protected wW.i = WindowWidth(w)
  Protected wX.i = WindowX(w)
  Protected wY.i = WindowY(w)
  
  Protected pad.i = 10
  
  ResizeGadget(#strPost,0,wH - GadgetHeight(#strPost),wW * 0.8,55)
  ResizeGadget(#bnPost,GadgetX(#strPost) + GadgetWidth(#strPost),GadgetY(#strPost),wW -GadgetWidth(#strPost),GadgetHeight(#strPost))
  ResizeGadget(#Panel1,0,0,wW,wH - GadgetHeight(#strPost))
  ResizeGadget(#scrDents,0,0,GadgetWidth(#Panel1) - pad,wH - GadgetHeight(#strPost) - pad)
    SetGadgetAttribute(#scrDents,#PB_ScrollArea_InnerWidth, GadgetWidth(#scrDents) - pad)  
  ResizeGadget(#scrReplies,0,0,GadgetWidth(#Panel1) - pad,wH - GadgetHeight(#strPost) - pad)
    SetGadgetAttribute(#scrReplies,#PB_ScrollArea_InnerWidth, GadgetWidth(#scrReplies) - pad)
  ResizeGadget(#scrDM,0,0,GadgetWidth(#Panel1) - pad,wH - GadgetHeight(#strPost) - pad)
    SetGadgetAttribute(#scrDM,#PB_ScrollArea_InnerWidth, GadgetWidth(#scrDM) - pad)
EndProcedure

Macro Panel_Event(Event, pSwitch)
  ;Panel Events
  ; Keep in mind that PanelGadgets do not support EventType()
  ; so this may break in future versions of PB
  Select Event
  Case 0  ;"Different Tab"                   
    pSwitch = #True  
    TabChange()  
  Case 1                        
    pSwitch = #False
    ;if Not panelSwitch : Debug "Same Tab" : EndIf                
  EndSelect
EndMacro

Procedure TabChange(forceTab.i = -1)
  UIS\prevTab = UIS\currentTab
  UIS\currentTab = GetGadgetState(#Panel1)
  
  Select UIS\currentTab
  Case #tbPosts    
  EndSelect
  Delay(1)
EndProcedure

Procedure.s getAuthString(name.s, password.s, encode.i = #False)
  Protected authS.s
  Protected len.i = 1024
  Protected encodedAuth.s = Space(len)
  
  authS = name + ":" + password
  If encode
    Base64Encoder(@authS, StringByteLength(authS), @encodedAuth, len)
    ProcedureReturn encodedAuth
  EndIf
  
  ProcedureReturn authS
EndProcedure

Procedure.i loadSettings(*u.UIStatus)
  If Not *u\configPath
    *u\configPath = GetEXEpath() + "/puredenter.conf"
  EndIf
  OpenPreferences(*u\configPath)  
    *u\uname  = ReadPreferenceString("username","username")   
  	*u\pw     = b64decode(ReadPreferenceString("password","password")) ;simple encoded
  	*u\authHdr  = getAuthString(*u\uname, *u\pw,#False)
  	
  	*u\apiPath  = ReadPreferenceString("apipath","https://" + "identi.ca" + "/api")
  	*u\nNotices = ReadPreferenceInteger("nNoticesToFetch",20)
  	*u\lastID   = 0;
	ClosePreferences()
EndProcedure

Procedure.i saveSettings(*u.UIStatus)
  If Not *u\configPath
    *u\configPath = GetEXEpath() + "/puredenter.conf"
  EndIf
  OpenPreferences(*u\configPath)  
    WritePreferenceString("username",*u\uname)   
  	WritePreferenceString("password",b64encode(*u\pw)) ;simple encoded
 	  
  	WritePreferenceString("apipath",*u\apiPath)
  	WritePreferenceInteger("nNoticesToFetch",*u\nNotices)
	ClosePreferences()
EndProcedure

Procedure verifyCredentials(*u.UIStatus)
  Protected url.s = *u\apiPath + "/account/verify_credentials.xml"
  url = SetURLPart(url,#PB_URL_User,*u\uname)
  url = SetURLPart(url,#PB_URL_Password,*u\pw)
  
  Protected vFile.s = GetTemporaryDirectory() + "verify" + now() + ".xml"
  If ReceiveHTTPFile(url,vFile)
    DeleteFile(vFile)
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure.s verifyApiPath(url.s)  
	If GetURLPart(URL$, #PB_URL_Protocol) = "http"
	  url = SetURLPart(URL$, #PB_URL_Protocol, "https")
	ElseIf Left(url,4) <> "http"
	  url = "https://" + url	  
	EndIf
	If Right(url,1) <> "/"
	  url + "/"
	EndIf
	If Right(url,4) <> "api/"
	  url + "api/"
	EndIf
	ProcedureReturn url
EndProcedure

Procedure.s getStatuses(*u.UIStatus)
;   //retrieve statuses from service.
; 	//	this is hardcoded For now, As it is just a TEST using libsoup
; 	//	of course will allow variables of all these things, all user-settable And such
; 	//	
	Protected of.s = GetTemporaryDirectory() + App\title + "_" + now() + ".xml"
	
	Protected cID.i
	
	Protected url.s = *u\apiPath + "/statuses/friends_timeline/" + *u\uname + ".xml?count=" + Str(*u\nNotices) 
	If lastID
	  url + "&since_id=" + Str(lastID)
	EndIf
	
	If ReceiveHTTPFile(url, of)
    ProcedureReturn of
  Else
    ProcedureReturn #NUL$
  EndIf
EndProcedure

Procedure.s postDent(*u.UIStatus, statusText.s, latitude.f = 0, longitude.f = 0)
  ;Returns the path of the server response stored locally. Needed for XML parsing.
  ;
  ;http://status.net/wiki/HOWTO_Use_the_API
  ;username:password http://example.com/api/statuses/update.xml -d status='Howdy!' -d lat='30.468' -d long='-94.743' 
  ;#####################################################
  ; this does not work.  try this:
  ;   http://www.purebasic.fr/english/viewtopic.php?f=13&t=43786&hilit=curl
  ; libcurl on windows would be an easy solution.
  ;
  Protected url.s
  Protected update.s
  Protected loginpwd.s = getAuthString(*u\uname,*u\pw,#False)
  Protected err.l
  ;#####################################################
  Protected curl.i  = curl_easy_init()	
	If Not curl
	  Debug "could not connect to curl"
	  ProcedureReturn ""
	EndIf
	
	*u\apiPath = verifyApiPath(*u\apiPath)
	url = *u\apiPath + "statuses/update.xml"
	Debug url
	
	curl_easy_setopt(curl, #CURLOPT_URL, @url)		
	curl_easy_setopt(curl, #CURLOPT_USERPWD, @loginpwd)
	
	update = "status=" + statusText
	curl_easy_setopt(curl, #CURLOPT_POSTFIELDS, @update)
	
;   update = "source=" + App\title
;   curl_easy_setopt(curl, #CURLOPT_POSTFIELDS, @update)
;   
;   If latitude And longitude
;     update = "lat=" + StrF(latitude) 
;     curl_easy_setopt(curl, #CURLOPT_POSTFIELDS, @update)
;     
;     update = "long=" + StrF(longitude)
;     curl_easy_setopt(curl, #CURLOPT_POSTFIELDS, @update)
;   EndIf
	curl_easy_setopt(curl, #CURLOPT_WRITEFUNCTION, @RW_LibCurl_WriteFunction())
	
	curl_easy_perform(curl)
	curl_easy_strerror(@err)
	If err
	  Debug err
	EndIf
	curl_easy_cleanup(curl)   
EndProcedure

Procedure main()
  If Not OpenWindow_winMain()
    MessageRequester("Error","Could not open main window")
    End
  EndIf
  InitNetwork()
  loadSettings(UIS)
  
  Repeat
    Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_SizeWindow
      resizeUI()
    Case #PB_Event_Gadget
      Select EventGadget()
      Case #Panel1                   : Panel_Event(EventType(), gblPanelSwitch)  
      Case #bnPost
        postDent(UIS,GetGadgetText(#strPost))
      EndSelect
    EndSelect
  ForEver
  saveSettings(UIS)
  End
EndProcedure








;- ========
;- MAIN
;- ========

main()
End