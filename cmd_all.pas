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
        if (ip1 >= 0) and (ip1 <= 99) then err := 0 else err := 7
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

{ COMMAND 'load' }
procedure cmd_load(p1: TSplitted);
var
  bi, bj:         byte;
  comline:        byte;
  err:            byte;                                           { error code }
  ec, i:          integer;
  lab, seg:       byte;
  line:           byte;
  qi:             integer;
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
label
  error;

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

{ SET ERROR CODE AND WRITE ERROR MESSAGE }
procedure errmsg(b: byte);
begin
  err := b;
  writeln(MESSAGE[b]);
end;

begin
  err := 0;
  stat_mandatory := 0;
  stat_segment := 0;
  { check parameters }
  if length(p1) = 0 then err := 7 else
  begin
    assign(t36file, p1);
    {$I-}
      reset(t36file);
    {$I+}
    if ioresult <> 0 then err := 21 else
    begin
      cmd_reset(false);
      { read text file content }
      line := 0;
      comline := 0;
      repeat
        readln(t36file, s);
        line := line + 1;
        { - remove space and tabulator from start of line }
        while (s[1] = #32) or (s[1] = #9) do delete(s, 1, 1);
        { - remove space and tabulator from end of line }
        while (s[length(s)] = #32) or (s[1] = #9) do delete(s, length(s), 1);
        { - convert to uppercase and truncate to 40 }
        for bi := 1 to length(s) do s[bi] := upcase(s[bi]);
        { - check comment sign }
        if (s[1] <> COMMENT) and (length(s) > 0) then
        begin
          { search segment }
          seg := 255;
          for bi := 0 to 3 do
            if s[1] + s[2] + s[3] + s[4] = LSEGMENTS[bi] then seg := bi;
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
          for bi := 0 to 4 do
            if s[1] + s[2] + s[3] + s[4] = LLABELS[bi] then lab := bi;
          if lab < 255 then
          begin
            { - label is valid }
            case lab of
              0: { NAME found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $01;
                   for bi := 5 to length(s) do
                       machine.progname := machine.progname + s[bi];
                 end;
              1: { DESC found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $02;
                   for bi := 5 to length(s) do
                     machine.progdesc := machine.progdesc + s[bi];
                 end;
              2: { SYMB found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $04;
                   for bi := 5 to length(s) do
                    machine.symbols := machine.symbols + s[bi];                   
                 end else
                 begin
                   { - in the opened segment TAPE }
                   for bi := 5 to length(s) do
                     machine.tape[99 + bi - 5] := s[bi];
                 end;
              3: { STAT found }
                 if stat_segment = $01 then
                 begin
                   { - in the opened segment PROG }
                   stat_mandatory := stat_mandatory or $08;
                   ss := '';
                   for bi := 5 to length(s) do
                     ss := ss + s[bi];
                   val(ss, i, ec);
                   { - error messages }
                   if ec > 0 then err := 1 else
                     if i > 99 then err := 2;
                   if err > 0 then goto error else
                   begin
                     { - minimum value is two: q00 and q01 }
                     if i < 2 then machine.states := 2;
                     machine.states := i;
                   end;
                 end;
              4: { SPOS found }
                 if stat_segment = $11 then
                 begin
                   { - in the opened segment PROG and TAPE }
                   ss := '';
                   for bi := 5 to length(s) do
                     ss := ss + s[bi];
                   val(ss, i, ec);
                   { - error messages }
                   if ec > 0 then err := 3;
                   if err > 0 then goto error else
                   begin
                     if (i < 50) or (i > 200)
                       then err := 4
                       else machine.tapepos := i;
                   end;
                 end;
            end;
          end;
          { load program }
          if (s[1] + s[2] = 'ST') and (stat_segment = $05) then
          begin
            { STnn found in the opened segment PROG and CARD }
            { - remove all spaces and tabulators }
            ss := '';
            for bi := 1 to length(s) do
              if (s[bi] <> #32) and (s[bi] <> #9) then ss := ss + s[bi];
            { qi }
            val(ss[3] + ss[4], qi, ec);
            { - check value }
            if ec > 0 then err := 32 else
              if qi > 99 then err := 33;
            if err > 0 then goto error;
            delete(ss, 1, 4);
            bi := 0;
            while (length(ss) >= (bi * 5 + 5)) and (bi < 51) do
            begin
              { sj }
              machine.rules[qi, bi].sj := ss[bi * 5 + 1];
              { - check value }
              ec := 1;
              for bj := 1 to length(machine.symbols) do
                if machine.rules[qi, bi].sj = machine.symbols[bj] then ec := 0;
              if ec > 0 then err := 37;
              if err > 0 then goto error;
              { sk }
              machine.rules[qi, bi].sk := ss[bi * 5 + 2];
              { - check value }
              ec := 1;
              for bj := 1 to length(machine.symbols) do
                if machine.rules[qi, bi].sk = machine.symbols[bj] then ec := 0;
              if ec > 0 then err := 38;
              if err > 0 then goto error;
              { D }
              machine.rules[qi, bi].D := ss[bi * 5 + 3];
              { - check value }
              ec := 1;
              for bj := 1 to length(HMD) do
                if machine.rules[qi, bi].D = HMD[bj] then ec := 0;
              if ec > 0 then err := 34;
              if err > 0 then goto error;
              { qm }
              val(ss[bi * 5 + 4] + ss[bi * 5 + 5], i, ec);
              { - check value }
              if ec > 0 then err := 35 else
                if (i < 0) or (i > 99) then err := 36;
              if err > 0 then goto error;
              machine.rules[qi, bi].qm := i;
              bi := bi + 1;
            end;
          end;
          { load command line commands }
          if (stat_segment and $41 = $41) then
            if (s <> LSEGMENTS[3] + LBEGIN) and
               (s <> LSEGMENTS[3] + LEND) and
               (s <> LSEGMENTS[0] + LEND) then
            begin
              t36com[comline] := s;
              comline := comline + 1;
            end;
        end;
      until (eof(t36file)) or (line = 255);
    error:  
      close(t36file);
      { error messages }
      { - bad or missing values }
      if err > 0 then writeln(MESSAGE[err]);
      { - missing mandatory tags }
      if (stat_segment and $01) <> $01 then errmsg(39);
      if (stat_segment and $02) <> $02 then errmsg(40);
      if (stat_segment and $04) <> $04 then errmsg(41);
      if (stat_segment and $08) <> $08 then errmsg(42);
      if (stat_mandatory and $01) <> $01 then errmsg(45);
      if (stat_mandatory and $02) <> $02 then errmsg(46);
      if (stat_mandatory and $04) <> $04 then errmsg(47);
      if (stat_mandatory and $08) <> $08 then errmsg(48);
      { - missing optional END tags }
      if (stat_segment and $10) = $10 then
        if (stat_segment and $20) <> $20 then errmsg(43);
      if (stat_segment and $40) = $40 then
        if (stat_segment and $80) <> $80 then errmsg(44);
      if err > 0 then cmd_reset(false);
    end;
  end;
  { - file open errors }
  case err of
     7: writeln(MESSAGE[err]);
    21: writeln(MESSAGE[err] + p1 + '.');
  else
    begin
      { create backup }
      tapeposbak := machine.tapepos;
      tapebak := machine.tape;
      machine.aqi := 1;
      writeln(MESSAGE[5]);
      { convert commands to lowercase }
      for bi := 0 to 15 do
        if length(t36com[bi]) > 0 then
          for bj := 1 to length(t36com[bi]) do
            if (ord(t36com[bi][bj]) >= 65) and (ord(t36com[bi][bj]) <= 90) then
            t36com[bi][bj] := chr(ord(t36com[bi][bj]) + 32);
      { run commands }
      for bi := 0 to 15 do
        if length(t36com[bi]) > 0 then
          if parsingcommand(t36com[bi]) then halt;
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
    for qi := 1 to 99 do
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
      if (ip1 >= 2) and (ip1 <= 99) then err := 0 else err := 8
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
