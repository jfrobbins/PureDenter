; ====================================================================
; PureDenter
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

Macro MidFast(String, StartPos, Length)
  ;faster Mid() function.  
  ; *** no bound checking!!! ***
  ;
  ; http://forums.purebasic.com/english/viewtopic.php?f=12&t=45294
  ;
  ; String passed in MUST either be a variable or static string.  A procedure which returns a string will not work.
  ;   if this is an issue, perhaps should be procedure.  Or use Mid()
   PeekS(@String + ((StartPos - 1) * SizeOf(Character)), Length)
EndMacro

Procedure.s Now(mode.s = "TSTAMP") 
  Select UCase(mode)  
  Case "YYMMDD"
    ProcedureReturn FormatDate("%yy%mm%dd",Date())
  Case "YYYYMMDD"
    ProcedureReturn FormatDate("%yyyy%mm%dd",Date())
  Case "YYYY.MM.DD"
    ProcedureReturn FormatDate("%yyyy.%mm.%dd",Date())
  Case "YY.MM.DD"
    ProcedureReturn FormatDate("%yy.%mm.%dd",Date())
  Case "MM-DD-YY"
    ProcedureReturn FormatDate("%mm-%dd-%yy",Date())
  Case "MM/DD/YY"
    ProcedureReturn FormatDate("%mm/%dd/%yy",Date())
  Case "NOW" ;4/26/2010 1:20:47    
    ProcedureReturn FormatDate("%mm/%dd/%yy %hh:%ii:%ss",Date())
  Default ;"time stamp"
    ;yymmddhhiiss
    ;due to PB 4.6 bug %yy returns "20" instead of "11" (%yyyy = "2011")    
    mode = FormatDate("%yyyy",Date())
    ProcedureReturn MidFast(mode,3,2) + FormatDate("%mm%DD%hh%ii%ss",Date()) 
  EndSelect  
EndProcedure


;-========
;- Base Functions
;-========
Procedure.s b64encode(strToEncode.s, bufLen.i = 1024)
  Protected encoded.s = Space(bufLen)
 
  Base64Encoder(@strToEncode, StringByteLength(strToEncode), @encoded, bufLen)
  
  ProcedureReturn encoded
EndProcedure

Procedure.s b64decode(strToDecode.s, bufLen.i = 1024)
  Protected decoded.s = Space(bufLen)
 
  Base64Decoder(@strToDecode, StringByteLength(strToDecode), @decoded, bufLen)
  
  ProcedureReturn decoded
EndProcedure