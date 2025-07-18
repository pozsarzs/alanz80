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
        if (ip1 >= 0) and (ip1 <= 99) then e := 0 else e := 7
      else e := 8;
      { - error messages or primary operation }
      if e > 0 then writeln(MESSAGE[e]) else
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
var
  qi, r: byte;
begin
  if length(machine.progname) = 0 then writeln(MESSAGE[20]) else
  begin
    { - name }
    writeln(MESSAGE[22] + machine.progname);
    { - short description }
    writeln(MESSAGE[6] + machine.progdesc);
    { - number of states }
    writeln(MESSAGE[49], machine.states);
    { - set of symbol}
    writeln(MESSAGE[50] + machine.symbols);
    { - initial tape content }
    write(MESSAGE[51]);
    for b := 1 to length(machine.tape) do
      if machine.tape[b] <> SPACE then write(machine.tape[b]);
    writeln;
    { - (relative) head start position }
    writeln(MESSAGE[52], machine.tapepos);
    { - program list }
    writeln(MESSAGE[53]);
    for qi := 1 to 99 do
    begin
      for r := 0 to 39 do
        if machine.rules[qi, r].sj <> ''
        then
          write(addzero(qi),
                  machine.rules[qi, r].sj,
                  machine.rules[qi, r].sk,
                  machine.rules[qi, r].d,
                  addzero(machine.rules[qi, r].qm), ' ');
      if machine.rules[qi, 0].sj <> '' then writeln;
    end;
  end;
end;

{ COMMAND 'load' }
procedure cmd_load(p1: TSplitted);
var
  b:              byte;
  e:              byte;
  ec, i:          integer;
  lab, seg:       byte;
  line:           byte;
  qi:             byte;
  s, ss:          string[255];
  stat_mandatory: byte;                      { status byte of mandatory labels }
  stat_segment:   byte;                      { status byte of program segments }
  t36file:        text;
const
  LSEGMENTS:      array[0..3] of string[4] = ('PROG', 'CARD', 'TAPE', 'COMM');
  LLABELS:        array[0..4] of string[4] = ('NAME', 'DESC', 'SYMB', 'STAT',
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
  if length(p1) = 0 then e := 7 else
  begin
    assign(t36file, p1);
    {$I-}
      reset(t36file);
    {$I+}
    if ioresult <> 0 then e := 21 else
    begin
      cmd_reset(false);
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
        if (s[1] <> COMMENT) and (length(s) > 0) then
        begin
          { search segment }
          seg := 255;
          for b := 0 to 3 do
            if s[1] + s[2] + s[3] + s[4] = LSEGMENTS[b] then seg := b;
          { - remove space and tabulator after label }
          while (s[5] = #32) or (s[5] = #9) do delete(s, 5, 1);
          if seg < 255 then
          begin
            { - segment is valid }
            case seg of
              0: { PROG found }
                 begin
                   { - PROG BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_segment := stat_segment or $01;
                   { - PROG END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_segment := stat_segment or $02;
                 end; 
              1: { CARD found }
                 begin
                   { - CARD BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_segment := stat_segment or $04;
                   { - CARD END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_segment := stat_segment or $08;
                 end;    
              2: { TAPE found }
                 begin
                   { - TAPE BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_segment := stat_segment or $10;
                   { - TAPE END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_segment := stat_segment or $20;
                 end;    
              3: { COMM found }
                 begin
                   { - COMM BEGIN found }
                   if s[5] + s[6] + s[7] + s[8] + s[9] = LBEGIN
                     then stat_segment := stat_segment or $40;
                   { - COMM END found }
                   if s[5] + s[6] + s[7] = LEND
                     then stat_segment := stat_segment or $80;
                 end;    
            end;            
          end;
          { search label }
          lab := 255;
          for b := 0 to 4 do
            if s[1] + s[2] + s[3] + s[4] = LLABELS[b] then lab := b;
          if lab < 255 then
          begin
            { - label is valid }
            case lab of
              0: { NAME found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $01;
                   for b := 5 to length(s) do
                       machine.progname := machine.progname + s[b];
                 end;
              1: { DESC found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $02;
                   for b := 5 to length(s) do
                     machine.progdesc := machine.progdesc + s[b];
                 end;
              2: { SYMB found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $04;
                   for b := 5 to length(s) do
                    machine.symbols := machine.symbols + s[b];
                 end else
                 begin
                   { - in the opened segment TAPE }
                   ss := '';
                   for b := 5 to length(s) do
                     ss := ss + s[b];
                   insert(ss, machine.tape, 100);
                 end;
              3: { STAT found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $08;
                   ss := '';
                   for b := 5 to length(s) do
                     ss := ss + s[b];
                   val(ss, i, ec);
                   { - minimum value is two: q00 and q01 }
                   if i < 2 then machine.states := 2;
                   { - error messages }
                   if ec > 0 then e := 1;
                   if i > 99 then e := 2;
                   if e > 0 then goto error else machine.states := i;
                 end;
              4: { SPOS found }
                 if stat_segment = $11 then
                 begin
                   { - in the opened segment PROG and TAPE }
                   ss := '';
                   for b := 5 to length(s) do
                     ss := ss + s[b];
                   val(ss, i, ec);
                   { - error messages }
                   if ec > 0 then e := 3;
                   if (i < 50) or (i > 200) then e := 4;
                   if e > 0 then goto error else machine.tapepos := i;
                 end;
            end;
          end;
          if (s[1] + s[2] = 'ST') and (stat_segment = $05) then
          begin
            { STnn found in the opened segment PROG and CARD }
            { - remove all spaces and tabulators }
            ss := '';
            for b := 1 to length(s) do
              if (s[b] <> #32) and (s[b] <> #9) then ss := ss + s[b];
            { - qi }
            val(ss[3] + ss[4], qi, ec);

            // !!! Érték és hiba kiértékelés ide !!!

            delete(ss, 1, 4);
            b := 0;
            while (length(ss) >= (b * 5 + 5)) and (b < 51) do
            begin
              { - and others }
              machine.rules[qi, b].sj := ss[b * 5 + 1];
              machine.rules[qi, b].sk := ss[b * 5 + 2];
              machine.rules[qi, b].D := ss[b * 5 + 3];
              // machine.rules[qi, b].qm := ss[b * 5 + 4] + ss[b * 5 + 5];

              // !!! Érték és hiba kiértékelés ide !!!

              b := b + 1;
            end;
            writeln;
          end;
        end;
      until (eof(t36file)) or (line = 255);
    error:  
      close(t36file);
      { error messages }
      { - missing mandatory tags }
      if (stat_segment and $01) <> $01 then writeln(MESSAGE[39]);
      if (stat_segment and $02) <> $02 then writeln(MESSAGE[40]);
      if (stat_segment and $04) <> $04 then writeln(MESSAGE[41]);
      if (stat_segment and $08) <> $08 then writeln(MESSAGE[42]);
      if (stat_mandatory and $01) <> $01 then writeln(MESSAGE[45]);
      if (stat_mandatory and $02) <> $02 then writeln(MESSAGE[46]);
      if (stat_mandatory and $04) <> $04 then writeln(MESSAGE[47]);
      if (stat_mandatory and $08) <> $08 then writeln(MESSAGE[48]);
      { - missing optional END tags }
      if (stat_segment and $10) = $10 then
        if (stat_segment and $20) <> $20 then writeln(MESSAGE[43]);
      if (stat_segment and $40) = $40 then
        if (stat_segment and $80) <> $80 then writeln(MESSAGE[44]);
      if e > 0 then cmd_reset(false);
    end;
  end;
  { error messages }
  case e of
     7: writeln(MESSAGE[e]);
    21: writeln(MESSAGE[e] + p1 + '.');
  else
    writeln(MESSAGE[5]);
  end;
end;

{ COMMAND 'prog' }
procedure cmd_prog;
begin
end;

{ COMMAND 'reset' }
procedure cmd_reset(v: boolean);
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
        rules[b, bb].D := 'R';
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
  if v then writeln(MESSAGE[26]);
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
      if (ip1 >= 2) and (ip1 <= 99) then e := 0 else e := 8
    else e := 7;
    { error message or primary operation }
    if e > 0 then writeln(MESSAGE[e]) else
    begin
      machine.states := ip1;
      writeln(MESSAGE[14], machine.states, '.');
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
      insert(s, machine.tape, 50);
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
      e := 8;
  { error message or primary operation }
  if e > 0 then writeln(MESSAGE[e]) else
    if trace then writeln(MESSAGE[30]) else writeln(MESSAGE[31]);
end;
