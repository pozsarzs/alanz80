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
begin
end;

{ COMMAND 'prog' }
procedure cmd_prog;
begin
end;

{ COMMAND 'reset' }
procedure cmd_reset;
var
  b, bb: byte;
begin
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
    symbols := '_';
    tapepos := 1;
    for b := 1 to 200 do tape := tape + '_';
  end;
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
      11: writeln(MESSAGE[1] + MESSAGE[8]);
      12: writeln(MESSAGE[1] + MESSAGE[7]);
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
      machine.symbols := '_';
      writeln(MESSAGE[16])
    end else
    begin
      { set symbol list }
      { conversion to uppercase and truncate to 40 }
      for b := 1 to length(p1) do s := upcase(p1);
      { remove extra characters }
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
      machine.symbols := '_' + s;
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
      { remove _ from start of line }
      while s[1] = '_' do delete(s, 1, 1);
      { remove _ from end of line }
      while s[length(s)] = '_' do delete(s, length(s), 1);
      writeln(MESSAGE[24], s, '''.');
    end;
  end else
  begin
    for b := 1 to 200 do machine.tape[b] := '_';
    if p1 = '-' then
    begin
      { reset symbol list }
      writeln(MESSAGE[25])
    end else
    begin
      { set symbol list }
      { conversion to uppercase and truncate to 40 }
      for b := 1 to length(p1) do s := upcase(p1);
      { warning messages }
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
    then writeln(MESSAGE[1] + MESSAGE[8])
    else
      if trace then writeln(MESSAGE[30]) else writeln(MESSAGE[31]);
end;
