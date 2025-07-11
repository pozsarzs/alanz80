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

{ UNCOMMENT THIS IF YOU COMPILE THIS WITH TURBO PASCAL > 3.X OR FREEPASCAL: }
uses crt;

{$I declare.pas }

{ WAIT FOR A KEY - UNCOMMENT CORRESPONDING LINES: }

{ TURBO PASCAL > 3.X OR FREEPASCAL }
procedure waitforkey;
begin
  readkey;
end;

{ TURBO PASCAL 3.X ON DOS }
{ procedure waitforkey;
  type
    TRegPack = record
                 AX, BX, CX, DX, BP, SI, DI, DS, ES, Flags: integer;
               end;
  var
    regs:    TRegPack;
  begin
    regs.AX := $0100;
    msdos(regs);
    writeln;
  end; }

{ TURBO PASCAL 3.X ON CP/M }
{ procedure waitforkey;
  begin
    bdos(1);
    writeln;
  end;}

{ INSERT ZERO BEFORE [0-9] }
function addzero(v: integer): TTwoDigit;
var
  u: TTwoDigit;
begin
  str(v:0, u);
  if length(u) = 1 then u := '0' + u;
   addzero := u;
end;

{$i cmd_all.pas}
{ $i cmd_run.pas}

{ PARSING COMMANDS }
function parsingcommand(command: TCommand): boolean;
var
  a, b: byte;
  s:    string[255];
  o:    boolean;
label
  break1, break2, break3, break4;
begin
  parsingcommand := false;
  if (length(command) > 0) then
  begin
    { remove space and tab from start of line }
    while (command[1] = #32) or (command[1] = #9) do
      delete(command, 1, 1);
    { remove space and tab from end of line }
    while (command[length(command)] = #32) or (command[length(command)] = #9) do
      delete(command, length(command), 1);
    { remove extra space and tab from line }
    for b := 1 to 255 do
    begin
      if b = length(command) then goto break1;
      if command[b] <> #32 then o := false;
      if (command[b] = #32) and o then command[b] :='@';
      if command[b] = #32 then o := true;
    end;
  break1:
    s := '';
    for b := 1 to length(command) do
      if command[b] <> '@' then s := s + command[b];
    command := s;
    { split command to 8 slices }
    for b := 0 to 7 do
      splitted[b] := '';
    for a := 1 to length(command) do
      if (command[a] = #32) and (command[a - 1] <> #92)
        then goto break2
        else splitted[0] := splitted[0] + command[a];
  break2:
    for b:= 1 to 7 do
    begin
      for a := a + 1 to length(command) do
        if (command[a] = #32) and (command[a - 1] <> #92)
          then goto break3
          else splitted[b] := splitted[b] + command[a];
    break3:
    end;
    { parse command }
    o := false;
    if splitted[0][1] <> COMMENT then
    begin
      for b := 0 to COMMARRSIZE do
        if splitted[0] = COMMANDS[b] then
        begin
          o := true;
          goto break4;
        end;
    break4:
      if o then
      begin
        case b of
           0: cmd_break(splitted[1]);
           1: cmd_help(splitted[1]);
           5: parsingcommand := true;
           6: cmd_reset;
           8: cmd_state(splitted[1]);
          12: cmd_trace(splitted[1]);


//  COMMANDS:     array[0..COMMARRSIZE] of string[5] = ('break', 'help',info 'load',
//                'prog', 'quit', 'reset', 'run', state 'step',symbol 'tape', 'trace');



        
{           2: cmd_deposit(splitted[1], splitted[2], splitted[3],
                          splitted[4], splitted[5]);
           3: cmd_dump(splitted[1], splitted[2]);
           4: cmd_examine(splitted[1]);
           5: cmd_export(splitted[1]);
           6: cmd_fill(splitted[1], splitted[2], splitted[3],
                       splitted[4], splitted[5], splitted[6]);
           8: cmd_import(splitted[1]);
           9: cmd_load(splitted[1]);
          12: cmd_run(false, splitted[1]);
          13: cmd_save(splitted[1]);
          14: cmd_run(true, splitted[1]);}
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
  for b := 1 to length(HEADER2) do write('-');
  writeln;
  { initialize program memory, program tape, program status and breakpoint }
  cmd_reset;
  trace := false;
  writeln(HINT);
  { main operation }
  repeat
    write(PROMPT); readln(com);
    quit := parsingcommand(com);
  until quit = true;
  halt;
end.
