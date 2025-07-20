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
    d:          string[1];                           { head movement direction }
    qm:         byte;                                            { final state }
    sj:         string[1];                                       { read symbol }
    sk:         string[1];                              { symbol to be written }
  end;
  TTuring =     record                                    { Turing machine type}
    progdesc:   string[64];                           { description of program }
    progname:   string[8];                                   { name of program }
    qi:         byte;                                           { actual state }
    rules:      array[0..99,0..39] of T4tuple;  { actual state with its tuples }
    states:     byte;                                       { number of states }
    symbols:    string[40];                                     { symbolum set }
    tapepos:    byte;                                 { relative head position }
    tape:       string[255];                                            { tape }
  end;
  TCommand =    string[255];                   { different length string types }
  TFilename =   string[12];
  TSplitted =   string[64];
  TTwoDigit =   string[2];
var
  b:            byte;
  com:          TCommand;                               { command line content }
  machine:      TTuring;                        { Turing machine configuration }
  prg_counter:  byte;                                        { program counter }
  qb:           byte;                                     { breakpoint address }
  quit:         boolean;                                          { allow exit }
  splitted:     array[0..7] of TSplitted;                   { splitted command }
  t36com:       array[0..15] of TCommand;     { optional commands from t36file }
  trace:        boolean;                                       { turn tracking }
const
  COMMARRSIZE = 12;
  COMMENT =     #59;
  SPACE =       #95;
  HMD =         'LSR';                                { head moving directions }
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
  MESSAGE:      array[0..51] of string[61] = (
                'No such command!',
                'The STAT value is bad or missing.',
                'The STAT value is out of range.',
                'The SPOS value is bad.',
                'The SPOS value is out of range.',
                'The program file was successfully loaded.',
                'Description:      ',
                'Command parameter is bad or missing.',
                'Command parameter value is incorrect.',
                'No breakpoint state set.',
                'The breakpoint state is ',
                'The breakpoint state is deleted.',
                'The breakpoint state is set to ',
                'Number of states: ',
                'The number of states is set to ',
                'Set of symbols:   ',
                'The tape symbols are deleted.',
                'The tape symbols are set to ''',
                'Duplicate symbols have been deleted!',
                'The symbol list is too long and has been truncated!',
                'No loaded program!',
                'Cannot read ',
                'Program name:     ',
                'The tape is empty.',
                'Tape content:     ',
                'The tape content is deleted.',
                'The Turing machine has been reset.',
                'The tape data is too long and has been truncated!',
                'Run program from head position ',
                'Step-by-step execution head position ',
                'Trace on.',
                'Trace off.',
                'The initial state (qi) is bad or missing.',
                'The initial state value (qi) is not included in the set Q.',
                'The head moving direction value is not included in the set D.',
                'The final state (qm) is bad or missing.',
                'The final state value (qm) is not included in the set Q.',
                'The read symbol (sj) is not in the set S.',
                'The symbol to be written (sk) is not in the set S.',
                'Missing mandatory PROG BEGIN tag.',
                'Missing mandatory PROG END tag.',
                'Missing mandatory CARD BEGIN tag.',
                'Missing mandatory CARD END tag.',
                'Missing optional TAPE END tag.',
                'Missing optional COMM END tag.',
                'Missing mandatory CARD tag.',
                'Missing mandatory NAME tag.',
                'Missing mandatory STAT tag.',
                'Missing mandatory SYMB tag.',
                'Head position:    ',
                'Program:',
                'Commands:');
