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
  count: integer;
  e: byte;
  b: byte;
label
  stop, error, found;
begin

  // *** Emlékeztető, ne felejtsd el törölni! ***
  //
  // Argumentumok:
  // p1: lépésenkénti végrehajtás
  // p2: kezdő fejpozíció, felülbírálja az spos machine.tapepos értékét, ehhez
  //     értékvizsgálat is kell
  //
  // Működése:
  // + A gép qi = 1 állapotban van.
  // + Beolvassa az machine.tapepos + 49 abszolút szalagpozícióban található
  //   szimbólumot.
  // + Megkeresi a machine.rules[qi, n].sj értékei között, ha nincs ilyen,
  //   akkor üzenettel megáll. Ha van, akkor kicseréli a szimbólumot a
  //   machine.rules[qi, n].sk értékre, módosítja a machine.tapepos-t a
  //   machine.rules[qi, n].D-nek megfelelően majd módosítja a gép állapotát
  //   machine.rules[qi, n].qm-re.
  // + Visszatér az 1. lépésre és mindaddig folytatja, amíg a qi <> 0.

  // Egyebek:
  // + Ha trace = true, akkor minden lépésnél ki kell írni a műveleteket.
  // - Ha a p1 = true, akkor minden lépés után várni kell a felhasználóra.
  // - Ha a breakpoint be van állítva, akkor a megadott állapotnál várni kell
  //   a felhasználóra.

  e := 0;
  { create backup }
  tapeposbak := machine.tapepos;
  tapebak := machine.tape;
  machine.aqi := 1;
  { show initial data }
  cmd_tape('');
  writeln(MESSAGE[53]);
  { start machine }
  if trace then writeln;
  if trace then writeln(MESSAGE[55]);
  count := 1;
  repeat
    if trace then write(count:5, '   ', addzero(machine.tapepos), '   ',
                        addzero(machine.aqi), '   ') else write('#');
    machine.asj := machine.tape[machine.tapepos + 49]; 
    if trace then write(machine.asj, '   ');
    for b := 0 to 39 do
      if machine.rules[machine.aqi, b].sj = machine.asj then goto found;
    e := 56;
    goto error;
 found:
    machine.tape[machine.tapepos + 49] := machine.rules[machine.aqi, b].sk;
    if trace then write(machine.tape[machine.tapepos + 49], '  ');
    case machine.rules[machine.aqi, b].D of
      'R': machine.tapepos := machine.tapepos + 1;
      'L': machine.tapepos := machine.tapepos - 1;
    end;
    if trace then write(machine.rules[machine.aqi, b].D, '  ');
    machine.aqi := machine.rules[machine.aqi, b].qm;
    if trace then writeln(addzero(machine.aqi));
    count := count + 1;
    if count = 32767 then e := 57;
  until (machine.aqi = 0) or (count = 32767);
  writeln;
  writeln(MESSAGE[54]);
  goto stop;
error:
  { machine is stopped }
  writeln(MESSAGE[e]);
stop:
  { show final data (result) }
  cmd_tape('');
  { restore Turing machine initial state }
//  cmd_reset(true);
end;
