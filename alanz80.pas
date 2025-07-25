{ +--------------------------------------------------------------------------+ }
{ | AlanZ80 v0.1 * Turing machine                                            | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | alanz80.pas                                                              | }
{ | Main program (Turbo Pascal 3.0 CP/M and DOS)                             | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

program alanz80;
{ Uncomment the next lines if you are compiling with TP > 3.x or Freepascal }
{ uses crt; }

{$I declare.pas }

{ WAIT FOR A KEY }
procedure waitforkey;
{ Uncomment the next lines if you are compiling with Turbo Pascal 3.x on DOS }
{ type
    TRegPack = record
                 AX, BX, CX, DX, BP, SI, DI, DS, ES, Flags: integer;
               end;
  var
    regs:      TRegPack; }

begin
  { Uncomment the next lines if you are compiling with TP > 3.x or Freepascal }
  { readkey; }

  { Uncomment the next lines if you are compiling with Turbo Pascal 3.x on DOS }
  { regs.AX := $0100;
    msdos(regs);
    writeln; }

  { Uncomment the next lines if you are compiling with Turbo Pascal 3.x on CP/M }
  bdos(1);
  writeln;
end;

{ INSERT ZERO BEFORE [0-9] }
function addzero(value: integer): TTwoDigit;
var
  result: TTwoDigit;
begin
  str(value:0, result);
  if length(result) = 1 then result := '0' + result;
    addzero := result;
end;

{ CHECK TAPE CONTENT }
function tapeisempty: boolean;
var
  bi: byte;
begin
  tapeisempty := true;
  for bi := 1 to 200 do
    if machine.tape[bi] <> SPACE then tapeisempty := false;
end;

{ COMMAND 'reset' }
procedure cmd_reset(verbose: boolean);
var
  bi, bj: byte;
begin
  { reset machine configuration }
  with machine do
  begin
    progdesc := '';
    progname := '';
    progcount := 0;
    aqi := 1;
    for bi := 0 to 49 do
      for bj := 0 to 39 do
      begin
        rules[bi, bj].D := 'R';
        rules[bi, bj].qm := 1; 
        rules[bi, bj].Sj := #0; 
        rules[bi, bj].Sk := #0;
      end;
    states := 2;
    symbols := SPACE;
    tapepos := 1;
    tape := '';
    tapeposbak := tapepos;
    tapebak := tape;
    for bi := 1 to 255 do tape := tape + SPACE;
  end;
  { reset t36 command buffer } 
  for bi := 0 to 15 do t36com[bi] := '';
  { reset program others }
  qb := 255;
  sl := 32767;
  if verbose then writeln(MESSAGE[26]);
end;

{ PARSING COMMANDS }
function parsingcommand(command: TCommand): boolean;
var
  bi, bj: byte;
  s:      string[255];
  o:      boolean;
label
  break1, break2, break3, break4;

{$i cmd_load.pas}
{$i cmd_all.pas}
{$i cmd_run.pas}

begin
  parsingcommand := false;
  if (length(command) > 0) then
  begin
    { - remove space and tab from start of line }
    while (command[1] = #32) or (command[1] = #9) do
      delete(command, 1, 1);
    { - remove space and tab from end of line }
    while (command[length(command)] = #32) or (command[length(command)] = #9) do
      delete(command, length(command), 1);
    { - remove extra space and tab from line }
    for bi := 1 to 255 do
    begin
      if bi = length(command) then goto break1;
      if command[bi] <> #32 then o := false;
      if (command[bi] = #32) and o then command[bi] :='@';
      if command[bi] = #32 then o := true;
    end;
  break1:
    s := '';
    for bi := 1 to length(command) do
      if command[bi] <> '@' then s := s + command[bi];
    command := s;
    { - split command to 8 slices }
    for bi := 0 to 7 do
      splitted[bi] := '';
    for bj := 1 to length(command) do
      if (command[bj] = #32) and (command[bj - 1] <> #92)
        then goto break2
        else splitted[0] := splitted[0] + command[bj];
  break2:
    for bi:= 1 to 7 do
    begin
      for bj := bj + 1 to length(command) do
        if (command[bj] = #32) and (command[bj - 1] <> #92)
          then goto break3
          else splitted[bi] := splitted[bi] + command[bj];
    break3:
    end;
    { parse command }
    o := false;
    if splitted[0][1] <> COMMENT then
    begin
      for bi := 0 to COMMARRSIZE do
        if splitted[0] = COMMANDS[bi] then
        begin
          o := true;
          goto break4;
        end;
    break4:
      if o then
      begin
        case bi of
           0: cmd_break(splitted[1]);
           1: cmd_help(splitted[1]);
           2: cmd_info;
           3: cmd_load(splitted[1]);
           4: cmd_prog;
           5: parsingcommand := true;
           6: cmd_reset(true);
           7: cmd_run(false, splitted[1]);
           8: cmd_state(splitted[1]);
           9: cmd_run(true, splitted[1]);
          10: cmd_symbol(splitted[1]);
          11: cmd_tape(splitted[1]);
          12: cmd_trace(splitted[1]);
          13: cmd_limit(splitted[1]);
          14: cmd_restore(true);
        end;
      end else writeln(MESSAGE[0]);
    end;
  end;
end;

begin
  { show program information }
  writeln(HEADER1);
  writeln(HEADER2);
  writeln(HEADER3);
  for bk := 1 to length(HEADER2) do write('-');
  writeln;
  { initialize program memory, program tape, program status and breakpoint }
  cmd_reset(false);
  trace := false;
  writeln(HINT);
  { main operation }
  repeat
    write(PROMPT); readln(com);
    quit := parsingcommand(com);
  until quit = true;
  halt;
end.
