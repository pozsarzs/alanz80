{ +--------------------------------------------------------------------------+ }
{ | AlanZ80 v0.1 * Turing machine                                            | }
{ | Copyright (C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>                     | }
{ | declare.pas                                                              | }
{ | Main program (Turbo Pascal 3.0 CP/M and DOS)                             | }
{ +--------------------------------------------------------------------------+ }

{ This program is free software: you can redistribute it and/or modify it
  under the terms of the European Union Public License 1.2 version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. }

type
  T4tuple =     record                                            { tuple type }
    D:          byte;                                { head movement direction }
    qm:         byte;                                            { final state }
    Sj:         string[1];                                       { read symbol }
    Sk:         string[1];                              { symbol to be written }
  end;
  TTuring =     record                                    { Turing machine type}
    progdesc:   string[64];                           { description of program }
    progname:   string[8];                                   { name of program }
    qi:         byte;                                           { actual state }
    rules:      array[0..99,0..39] of T4tuple;  { actual state with its tuples }
    states:     byte;                                       { number of states }
    symbols:    string[40];                                     { symbolum set }
    tapepos:    byte;                                          { head position }
    tape:       string[200];                                            { tape }
  end;
  TCommand =    string[255];
  TFilename =   string[12];
  TSplitted =   string[64];
  TTwoDigit =   string[2];
var
  b:            byte;
  com:          TCommand;                               { command line content }
  machine:      TTuring;
  prg_counter:  byte;                                        { program counter }
  prg_status:   byte;                   { program status 0/1/2 stop/run/paused }
  qb:           byte;                                     { breakpoint address }
  quit:         boolean;
  splitted:     array[0..7] of TSplitted;                   { splitted command }
  trace:        boolean;                                       { turn tracking }
const
  COMMARRSIZE = 12;
  COMMENT =     ';';
  { UNCOMMENT CORRESPONDING LINES: }
  HEADER1 =     'AlanZ80 v0.1 for CP/M';
  { HEADER1 =     'AlanZ80 v0.1 for DOS'; }
  { HEADER1 =     'AlanZ80 v0.1'; }
  HEADER2 =     '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>';
  HEADER3 =     'Licence: EUPL v1.2';
  HINT =        'Type ''help [command]'' for more information.';
  PROMPT =      'TM>';
  COMMANDS:     array[0..COMMARRSIZE] of string[6] = ('break', 'help', 'info',
                'load', 'prog', 'quit', 'reset', 'run', 'state', 'step',
                'symbol', 'tape', 'trace');
  COMMANDS_INF: array[0..1,0..COMMARRSIZE] of string[63] = ((
                'set, get and reset breakpoint state (qb)',
                'help with using the program',
                'show all information about this machine',
                'load program file',
                'show program',
                'exit the program',
                'reset Turing-machine',
                'run program from head position',
                'set and get number of state (|Q|)',
                'run program step-by-step from head position',
                'set, get and reset symbol set (S)',
                'set, get and reset tape content',
                'turn tracking on and off'),(
                'break [01..99|-]         ',
                'help [command]           ',
                'info                     ',
                'load filename.t36        ',
                'prog                     ',
                'quit                     ',
                'reset                    ',
                'run [head position]      ',
                'state [2..99]            ',
                'step [head position]     ',
                'symbol [symbols|-]       ',
                'tape [content|-]         ',
                'trace [on|off]           '));
  MESSAGE:      array[0..31] of string[51] = (
                'No such command!', //*
                'The 1st ',//*
                'The 2nd ',//*
                'The 3rd ',//*
                'The 4th ',//*
                'The 5th ',//*
                'The 6th ',//*
                'parameter is bad or missing.',//*
                'parameter value is incorrect.',//*
                'No breakpoint state set.',//*
                'The breakpoint state is ', //*
                'The breakpoint state is deleted.',  //*
                'The breakpoint state is set to ',  //*
                'The number of states is ', //*
                'The number of states is set to ',  //*
                'The tape symbols are ''', //*
                'The tape symbols are deleted.',//*
                'The tape symbols are set to ''',//*
                'Duplicate symbols have been deleted!', //*
                'The symbol list is too long and has been truncated!', //*
                'No loaded program!', //*
                'Cannot read ', //*
                'Program ''',  //*
                'The tape is empty.', //*
                'The tape content is ''', //*
                'The tape content is deleted.',//*
                'The Turing machine has been reset.', //*
                'The tape data is too long and has been truncated!', //*
                'Run program from head position ',  //*
                'Step-by-step execution head position ',//*
                'Trace on.',//*
                'Trace off.');//*

