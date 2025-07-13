{ +--------------------------------------------------------------------------+ }
{ | AlanZ80 v0.1 * Turing machine                                            | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_all.pas                                                              | }
{ | All command without 'RUN'                                                | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'break' }
procedure cmd_break(p1: TSplitted);
var
  e:   byte;
  ec:  integer;
  ip1: integer;
begin
  e := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get breakpoint address }
    if qb = 255
      then writeln(MESSAGE[9])
      else writeln(MESSAGE[10], addzero(qb), '.');
  end else
  begin
    if p1 = '-' then
    begin
      { reset breakpoint }
      qb := 255;
      writeln(MESSAGE[11])
    end else
    begin
      { set breakpoint address }
      val(p1, ip1, ec);
      if ec = 0
      then
        if (ip1 >= 0) and (ip1 <= 99) then e := 0 else e := 11
      else e := 12;
      { error messages }
      case e of
        11: writeln(MESSAGE[16]);
        12: writeln(MESSAGE[17]);
      else
        begin
          qb := ip1;
          writeln(MESSAGE[12], addzero(qb), '.');
        end;
      end;
    end;
  end;
end;

{ COMMAND 'help' }
procedure cmd_help(p1: TSplitted);
var
  l: boolean;
begin
  l := false;
  { show description about all or selected command(s) }
  for b := 0 to COMMARRSIZE do
    if (length(p1) = 0) or (COMMANDS[b] = p1) then
    begin 
      l := true; 
      writeln(COMMANDS_INF[1, b] + #9 + COMMANDS_INF[0, b]);
    end;    
  if not l then writeln(MESSAGE[0]);
end;

{ COMMAND 'info' }
procedure cmd_info;
begin
  if length(machine.progname) = 0 then writeln(MESSAGE[20]) else
  begin
    writeln(MESSAGE[22] + machine.progname + '''');
    writeln(machine.progdesc);
    cmd_tape('');
    cmd_prog;
  end;
end;

{ COMMAND 'load' }
procedure cmd_load(p1: TSplitted);
var
  b, l:           byte;
  stat_mandatory: byte;                      { status byte of mandatory labels }
  stat_segment:   byte;                      { status byte of program segments }
  t36file:        text;
  s:              string[255];
  line:           byte;

  // Töröld, ha nem kell!
  address, data:  byte;
  i1, i2:         integer;
  e:              byte;
  ec:             integer;
const
  LSEGMENTS:      array[0..3] of string[4] = ('PROG', 'CARD', 'TAPE', 'COMM');
  LLABELS:        array[0..4] of string[4] = ('NAME', 'DESC', 'STAT', 'SYMB',
                  'SPOS');
  LBEGIN =        'BEGIN';
  LEND =          'END';

{ 
    bit   stat_segment          stat_mandatory (in PROG)
    ----------------------------------------------------
    D0    'PROG BEGIN' found    'NAME' found
    D1    'PROG END' found      'DESC' found
    D2    'CARD BEGIN' found    'SYMB' found
    D3    'CARD END' found      'STAT' found
    D4    'TAPE BEGIN' found
    D5    'TAPE END' found
    D6    'COMM BEGIN' found
    D7    'COMM END' found
}
 
label
  error;
begin
  e := 0;
  stat_mandatory := 0;
  stat_segment := 0;
  { check parameters }
  if length(p1) = 0 then e := 12 else
  begin
    assign(t36file, p1);
    {$I-}
      reset(t36file);
    {$I+}
    if ioresult <> 0 then e := 2 else
    begin
      cmd_reset;
      { read text file content }
      line := 0;
      repeat
        readln(t36file, s);
        line := line + 1;
        { - remove space and tabulator from start of line }
        while (s[1] = #32) or (s[1] = #9) do delete(s, 1, 1);
        { - remove space and tabulator from end of line }
        while (s[length(s)] = #32) or (s[1] = #9) do delete(s, length(s), 1);
        { - convert to uppercase and truncate to 40 }
        for b := 1 to length(s) do s[b] := upcase(s[b]);
        { - check comment sign }
        if s[1] <> COMMENT then
        begin
          { search segment }
          l := 255;
          for b := 0 to 3 do
            if s[1] + s[2] + s[3] + s[4] = LSEGMENTS[b] then l := b;
          if l < 255 then
          begin
            { - segment is valid }
            { - remove space and tabulator after label }
            while (s[1] = #32) or (s[5] = #9) do delete(s, 5, 1);
            case l of
              0: { PROG found}
                 begin
                   { - PROG BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_mandatory := stat_mandatory or $01;
                   { - PROG END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_mandatory := stat_mandatory or $02;
                 end; 
              1: { CARD found}
                 begin
                   { - CARD BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_mandatory := stat_mandatory or $04;
                   { - CARD END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_mandatory := stat_mandatory or $08;
                 end;    
              2: { TAPE found}
                 begin
                   { - TAPE BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_mandatory := stat_mandatory or $10;
                   { - TAPE END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_mandatory := stat_mandatory or $20;
                 end;    
              3: { COMM found}
                 begin
                   { - COMM BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_mandatory := stat_mandatory or $40;
                   { - COMM END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_mandatory := stat_mandatory or $80;
                 end;    
            end;            
          end;
        end;
      until (eof(t36file)) or (line = 255);
        close(t36file);
    end;
  end;
error:  
{  case e of
     2: writeln(MESSAGE[21] + p1 + '.');
     3: writeln(MESSAGE[24], line);
     4: writeln(MESSAGE[25], line);
    12: writeln(MESSAGE[7]);
  else
    writeln(MESSAGE[23] + p1 + '.');
  end;}
end;

{ Töröld, ha már nem kell!
PROGBEGIN
NAMENUMSWAP
DESCSwapping numbers back and forth                                           
SYMB0123456789
STAT3

CARDBEGIN
ST0101R01 12R01 23R01 34R01 45R01 56R01 67R01 78R01 89R01 90R01 __S02
ST0209L02 10L02 21L02 32L02 43L02 54L02 65L02 76L02 87L02 98L02 __S00
CARDEND

TAPEBEGIN
DATA0123456789
SPOS1
TAPEEND
COMMBEGIN

COMMEND
PROGEND
}

{ COMMAND 'prog' }
procedure cmd_prog;
begin
end;

{ COMMAND 'reset' }
procedure cmd_reset;
var
  b, bb: byte;
begin
  { reset machine configuration }
  with machine do
  begin
    progdesc := '';
    progname := '';
    qi := 1;
    for b := 0 to 99 do
      for bb := 0 to 39 do
      begin
        rules[b, bb].D := 2;
        rules[b, bb].qm := 1; 
        rules[b, bb].Sj := ''; 
        rules[b, bb].Sk := '';
      end;
    states := 2;
    symbols := SPACE;
    tapepos := 1;
    for b := 1 to 200 do tape := tape + SPACE;
  end;
  { reset program status }
  qb := 255;
  prg_counter := 0;
  prg_status := 0;
  writeln(MESSAGE[26]);
end;

{ COMMAND 'state' }
procedure cmd_state(p1: TSplitted);
var
  e:   byte;
  ec:  integer;
  ip1: integer;
begin
  e := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get number of states }
    writeln(MESSAGE[13], machine.states, '.');
  end else
  begin
    { set number of states }
    val(p1, ip1, ec);
    if ec = 0
    then
      if (ip1 >= 2) and (ip1 <= 99) then e := 0 else e := 11
    else e := 12;
    case e of
      11: writeln(MESSAGE[8]);
      12: writeln(MESSAGE[7]);
    else
      begin
        machine.states := ip1;
        writeln(MESSAGE[14], machine.states, '.');
      end;
    end;
  end;
end;

{ COMMAND 'symbol' }
procedure cmd_symbol(p1: TSplitted);
var
  c: char;
  b, bb: byte;
  e:   byte;
  s: string[40];
label
  break1;
begin
  e := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get symbol list }
    writeln(MESSAGE[15], machine.symbols, '''.');
  end else
  begin
    if p1 = '-' then
    begin
      { reset symbol list }
      machine.symbols := SPACE;
      writeln(MESSAGE[16])
    end else
    begin
      { set symbol list }
      s := p1;
      { - convert to uppercase and truncate to 40 }
      for b := 1 to length(p1) do s[b] := upcase(s[b]);
      { - remove extra characters }
      for b := 1 to length(s) - 1 do
        for bb := 1 to length(s) - 1 do
          if s[bb] > s[bb + 1] then
          begin
            c := s[bb];
            s[bb] := s[bb + 1];
            s[bb + 1] := c;
          end;
      for b := 1 to 40 do
      begin
        if b = length(s) then goto break1;
        if s[b] = s[b + 1] then
        begin
         delete(s, b, 1);
         e := 18;
        end;
      end;
    break1:
      { warning messages }
      if length(p1) > 40 then writeln(MESSAGE[19]);
      if e = 18 then writeln(MESSAGE[18]);
      machine.symbols := SPACE + s;
      writeln(MESSAGE[17], machine.symbols, '''.');
    end;
  end;
end;

{ COMMAND 'tape' }
procedure cmd_tape(p1: TSplitted);
var
  b: byte;
  s: string;
begin
  { check parameters }
  if length(p1) = 0 then
  begin
    { get symbol list }
    if tapeisempty then writeln(MESSAGE[23]) else
    begin
      s := machine.tape;
      { - remove _ from start of line }
      while s[1] = SPACE do delete(s, 1, 1);
      { - remove _ from end of line }
      while s[length(s)] = SPACE do delete(s, length(s), 1);
      writeln(MESSAGE[24], s, '''.');
    end;
  end else
  begin
    for b := 1 to 200 do machine.tape[b] := SPACE;
    if p1 = '-' then
    begin
      { reset symbol list }
      writeln(MESSAGE[25])
    end else
    begin
      { set symbol list }
      { - conversion to uppercase and truncate to 40 }
      for b := 1 to length(p1) do s := upcase(p1);
      { - warning messages }
      if length(p1) > 50 then writeln(MESSAGE[27]);
      insert(s, machine.tape, 100);
      writeln(MESSAGE[24], s, '''.');
    end;
  end;  
end;

{ COMMAND 'trace' }
procedure cmd_trace(p1: TSplitted);
var
 e: byte;
begin
  e := 0;
  { check parameters and set value }
  if length(p1) = 0 then trace := not trace else
    if upcase(p1) = 'ON' then trace := true else
      if upcase(p1) = 'OFF' then trace := false else
      e := 11;
  if e = 11
    then writeln(MESSAGE[8])
    else
      if trace then writeln(MESSAGE[30]) else writeln(MESSAGE[31]);
end;
