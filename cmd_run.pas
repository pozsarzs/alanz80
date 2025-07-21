{ +--------------------------------------------------------------------------+ }
{ | AlanZ80 v0.1 * Turing machine                                            | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | cmd_run.pas                                                              | }
{ | 'RUN' command                                                            | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

{ COMMAND 'run' }
procedure cmd_run(p1: boolean; p2: TSplitted);
var
  b: byte;
  e: byte;
  ec: integer;
  ip2: integer;
  verbose: boolean;
label
  stop, error, found;
begin
  verbose := trace or p1;
  { set override initial head position }
  if length(p2) > 0 then
  begin
    val(p2, ip2, ec);
    if ec = 0
    then
      if (ip2 >= -50) and (ip2 <= 50) then e := 0 else e := 64
    else e := 65;
    { - error messages or set temporary head start position }
    if e > 0 then writeln(MESSAGE[e]) else
    begin
      machine.tapepos := ip2;
      writeln(MESSAGE[66], machine.tapepos, '.');
    end;
  end;
  e := 0;
  { show initial data }
  cmd_tape('');
  writeln(MESSAGE[53]);
  { start machine }
  if verbose then writeln;
  if verbose then writeln(MESSAGE[55]);
  machine.progcount := 0;
  repeat
    machine.progcount := machine.progcount + 1;
    if verbose then write(machine.progcount:5, '   ', addzero(machine.tapepos), '   ',
                        addzero(machine.aqi), '   ') else write('#');
    machine.asj := machine.tape[machine.tapepos + 99]; 
    if verbose then write(machine.asj, '   ');
    for b := 0 to 39 do
      if machine.rules[machine.aqi, b].sj = machine.asj then goto found;
    e := 56;
    goto error;
 found:
    machine.tape[machine.tapepos + 99] := machine.rules[machine.aqi, b].sk;
    if verbose then write(machine.tape[machine.tapepos + 99], '  ');
    case machine.rules[machine.aqi, b].D of
      'R': machine.tapepos := machine.tapepos + 1;
      'L': machine.tapepos := machine.tapepos - 1;
    end;
    if verbose then write(machine.rules[machine.aqi, b].D, '  ');
    machine.aqi := machine.rules[machine.aqi, b].qm;
    if verbose then writeln(addzero(machine.aqi));
    { - check program set limit}   
    if machine.progcount = sl then
    begin
      writeln(MESSAGE[57]);
      goto stop;
    end;
    { - check breakpoint }   
    if machine.aqi = qb then
    begin
      writeln(MESSAGE[63]);
      writeln(MESSAGE[62]);
      waitforkey;
    end;
    { - step-by-step running mode }   
    if p1 then
    begin
      writeln(MESSAGE[62]);
      waitforkey;
    end;
  until (machine.aqi = 0) or (machine.progcount = 32767);
  writeln;
  goto stop;
error:
  { machine is stopped }
  writeln(MESSAGE[e]);
stop:
  writeln(MESSAGE[54]);
  { show final data (result) }
  cmd_tape('');
end;
