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
  i:  integer;
begin

  // *** Emlékeztető, ne felejtsd el törölni! ***
  //
  // Argumentumok:
  // p1: lépésenkénti végrehajtás
  // p2: kezdő fejpozíció, felülbírálja az spos machine.tapepos értékét, ehhez
  //     értékvizsgálat is kell
  //
  // Működése:
  // 0. A gép qi = 1 állapotban van.
  // 1. Beolvassa az machine.tapepos + 49 abszolút szalagpozícióban található
  //    szimbólumot.
  // 2. Megkeresi a machine.rules[qi, n].sj értékei között, ha nincs ilyen,
  //    akkor üzenettel megáll. Ha van, akkor kicseréli a szimbólumot a
  //    machine.rules[qi, n].sk értékre, módosítja a machine.tapepos-t a
  //    machine.rules[qi, n].D-nek megfelelően majd módosítja a gép állapotát
  //    machine.rules[qi, n].qm-re.
  //    Visszatér az 1. lépésre és mindaddig folytatja, amíg a qi <> 0.

  // Egyebek:
  // -  Ha trace = true, akkor minden lépésnél ki kell írni a műveleteket.
  // -  Ha a p1 = true, akkor minden lépés után várni kell a felhasználóra.
  // -  Ha a breakpoint be van állítva, akkor a megadott állapotnál várni kell
  //    a felhasználóra.
  

end;
