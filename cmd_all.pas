{ +--------------------------------------------------------------------------+ }
{ | AlanZ80 v0.1 * Turing machine                                            | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_all.pas                                                              | }
{ | All command without 'LOAD' and 'RUN'                                     | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }


{ COMMAND 'break' }
procedure cmd_break(p1: TSplitted);
var
  err: byte;                                                      { error code }
  ec:  integer;
  ip1: integer;
begin
  err := 0;
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
        if (ip1 >= 0) and (ip1 <= 49) then err := 0 else err := 7
      else err := 8;
      { - error messages or primary operation }
      if err > 0 then writeln(MESSAGE[err]) else
      begin
        qb := ip1;
        writeln(MESSAGE[12], addzero(qb), '.');
      end;
    end;
  end;
end;

{ COMMAND 'help' }
procedure cmd_help(p1: TSplitted);
var
  l:  boolean;
  bi: byte;
begin
  l := false;
  { show description about all or selected command(s) }
  for bi := 0 to COMMARRSIZE do
    if (length(p1) = 0) or (COMMANDS[bi] = p1) then
    begin 
      l := true; 
      writeln(COMMANDS_INF[1, bi] + '  ' + COMMANDS_INF[0, bi]);
    end;    
  if not l then writeln(MESSAGE[0]);
end;


{ COMMAND 'limit' }
procedure cmd_limit(p1: TSplitted);
var
  err: byte;                                                      { error code }
  ec:  integer;
  ip1: integer;
begin
  err := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get step limit }
    if sl = 32767
      then writeln(MESSAGE[58])
      else writeln(MESSAGE[59], addzero(sl), '.');
  end else
  begin
    if p1 = '-' then
    begin
      { reset step limit }
      sl := 32767;
      writeln(MESSAGE[60])
    end else
    begin
      { set step limit }
      val(p1, ip1, ec);
      if ec = 0
      then
        if ((ip1 >= 0) and (ip1 <= 32767)) then err := 0 else err := 7
      else err := 8;
      { - error messages or primary operation }
      if err > 0 then writeln(MESSAGE[err]) else
      begin
        sl := ip1;
        writeln(MESSAGE[61], addzero(sl), '.');
      end;
    end;
  end;
end;

{ COMMAND 'prog' }
procedure cmd_prog;
var
 qi, r: byte;
begin
  if length(machine.progname) = 0 then writeln(MESSAGE[20]) else
  begin
    writeln(MESSAGE[50]);
    for qi := 1 to 49 do
    begin
      for r := 0 to 39 do
        if machine.rules[qi, r].sj <> #0
        then
          write(addzero(qi), machine.rules[qi, r].sj, machine.rules[qi, r].sk,
                machine.rules[qi, r].d, addzero(machine.rules[qi, r].qm), ' ');
        if machine.rules[qi, 0].sj <> #0 then writeln;
    end;
  end;
end;

{ COMMAND 'restore' }
procedure cmd_restore(verbose: boolean);
begin
  { restore Turing machine to original state }
  with machine do
  begin
    aqi := 1;
    progcount := 1;
    tapepos := tapeposbak;
    tape := tapebak;
  end;
  if verbose then writeln(MESSAGE[52]);
end;

{ COMMAND 'state' }
procedure cmd_state(p1: TSplitted);
var
  err:   byte;                                                    { error code }
  ec:    integer;
  ip1:   integer;
begin
  err := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get number of states }
    writeln(MESSAGE[13], machine.states);
  end else
  begin
    { set number of states }
    val(p1, ip1, ec);
    if ec = 0
    then
      if (ip1 >= 2) and (ip1 <= 49) then err := 0 else err := 8
    else err := 7;
    { error message or primary operation }
    if err > 0 then writeln(MESSAGE[err]) else
    begin
      machine.states := ip1;
      writeln(MESSAGE[14], machine.states, '.');
    end;
  end;
end;

{ COMMAND 'symbol' }
procedure cmd_symbol(p1: TSplitted);
var
  c:      char;
  bi, bj: byte;
  err:    byte;                                                   { error code }
  s:      string[40];
label
  break1;
begin
  err := 0;
  { check parameters }
  if length(p1) = 0 then
  begin
    { get symbol list }
    writeln(MESSAGE[15] + machine.symbols);
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
      for bi := 1 to length(p1) do s[bi] := upcase(s[bi]);
      { - remove extra characters }
      for bi := 1 to length(s) - 1 do
        for bj := 1 to length(s) - 1 do
          if s[bj] > s[bj + 1] then
          begin
            c := s[bj];
            s[bj] := s[bj + 1];
            s[bj + 1] := c;
          end;
      for bi := 1 to 40 do
      begin
        if bi = length(s) then goto break1;
        if s[bi] = s[bi + 1] then
        begin
         delete(s, bi, 1);
         err := 18;
        end;
      end;
    break1:
      { warning messages }
      if length(p1) > 40 then writeln(MESSAGE[19]);
      if err = 18 then writeln(MESSAGE[18]);
      machine.symbols := SPACE + s;
      writeln(MESSAGE[17], machine.symbols, '''.');
    end;
  end;
end;

{ COMMAND 'tape' }
procedure cmd_tape(p1: TSplitted);
var
  bi: byte;
  s:  string[255];
begin
  { check parameters }
  if length(p1) = 0 then
  begin
    { get symbol list }
    if tapeisempty then writeln(MESSAGE[23]) else
    begin
      s := machine.tape;
      { - remove blank symbol from start of line }
      while (s[1] = #95) do delete(s, 1, 1);
      { - remover emove blank symbol from end of line }
      while (s[length(s)] = #95) do delete(s, length(s), 1);
      writeln(MESSAGE[24], s);
      writeln(MESSAGE[49], machine.tapepos);
    end;
  end else
  begin
   if p1 = '-' then
    begin
      for bi := 1 to 255 do machine.tape[bi] := SPACE;
      { reset symbol list }
      writeln(MESSAGE[25])
    end else
    begin
      { set symbol list }
      { - conversion to uppercase and truncate to 40 }
      for bi := 1 to length(p1) do s := upcase(p1[bi]);
      { - warning messages }
      if length(p1) > 50 then writeln(MESSAGE[27]);
      for bi := 1 to 255 do machine.tape[bi] := SPACE;
      for bi := 1 to length(s) do
        machine.tape[99 + bi] := s[bi];
      writeln(MESSAGE[24], s, '.');
    end;
  end;  
end;

{ COMMAND 'trace' }
procedure cmd_trace(p1: TSplitted);
var
  err: byte;                                                      { error code }
begin
  err := 0;
  { check parameters and set value }
  if length(p1) = 0 then trace := not trace else
    if upcase(p1[1]) + upcase(p1[2])  = 'ON' then trace := true else
      if upcase(p1[1]) + upcase(p1[2]) = 'OFF' then trace := false else
      err := 8;
  { error message or primary operation }
  if err > 0 then writeln(MESSAGE[err]) else
    if trace then writeln(MESSAGE[30]) else writeln(MESSAGE[31]);
end;

{ COMMAND 'info' }
procedure cmd_info;
var
  bi: byte;
begin
  if length(machine.progname) = 0 then writeln(MESSAGE[20]) else
  begin
    { - name }
    writeln(MESSAGE[22] + machine.progname);
    { - short description }
    writeln(MESSAGE[6] + machine.progdesc);
    { - number of states }
    cmd_state('');
    { - set of symbol}
    cmd_symbol('');
    { - initial tape content and (relative) head start position }
    cmd_tape('');
    { - program list }
    if length(machine.progname) > 0 then writeln;
    cmd_prog;
    { - optional commands from t36 file }
    if length(t36com[0]) > 0 then
    begin
      writeln;
      writeln(MESSAGE[51]);
      for bi := 0 to 15 do
        if length(t36com[bi]) > 0 then writeln(t36com[bi]);
    end;
  end;
end;
