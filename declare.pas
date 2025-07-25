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
    d:          char;                                { head movement direction }
    qm:         integer;                                         { final state }
    sj:         char;                                            { read symbol }
    sk:         char;                                   { symbol to be written }
  end;
  TTuring =     record                                   { Turing machine type }
    aqi:        byte;                                           { actual state }
    asj:        char;                                            { read symbol }
    ask:        char;                                   { symbol to be written }
    progcount:  integer;                                { program step counter }
    progdesc:   string[64];                           { description of program }
    progname:   string[8];                                   { name of program }
    rules:      array[0..49, 0..39] of T4tuple; { actual state with its tuples }
    states:     integer;                                    { number of states }
    symbols:    string[40];                                     { symbolum set }
    tape:       string[255];                                            { tape }
    tapepos:    integer;                              { relative head position }
  end;
  TCommand =    string[255];                   { different length string types }
  TFilename =   string[12];
  TSplitted =   string[64];
  TTwoDigit =   string[2];
var
  bk:           byte;
  com:          TCommand;                               { command line content }
  sl:           integer;                                  { program step limit }
  machine:      TTuring;                        { Turing machine configuration }
  qb:           byte;                                     { breakpoint address }
  quit:         boolean;                                          { allow exit }
  splitted:     array[0..7] of TSplitted;                   { splitted command }
  t36com:       array[0..15] of TCommand;     { optional commands from t36file }
  trace:        boolean;                                       { turn tracking }
  tapeposbak:   byte;                   { backup of the relative head position }
  tapebak:      string[255];             { backup of the original tape content }
const
  COMMARRSIZE = 14;
  COMMENT =     #59;
  SPACE =       #95;
  HMD:          string[3] = 'LSR';                    { head moving directions }
  { UNCOMMENT CORRESPONDING LINES: }
  HEADER1 =     'AlanZ80 v0.1 for CP/M';
  { HEADER1 =     'AlanZ80 v0.1 for DOS'; }
  { HEADER1 =     'AlanZ80 v0.1'; }
  HEADER2 =     '(C) 2025 Pozsar Zsolt <pozsarzs@gmail.com>';
  HEADER3 =     'Licence: EUPL v1.2';
  HINT =        'Type ''help [command]'' for more information.';
  PROMPT =      'TM>';
  COMMANDS:     array[0..COMMARRSIZE] of string[7] = ('break', 'help', 'info',
                'load', 'prog', 'quit', 'reset', 'run', 'state', 'step',
                'symbol', 'tape', 'trace', 'limit', 'restore');
  COMMANDS_INF: array[0..1, 0..COMMARRSIZE] of string[63] = ((
                'set, get and reset breakpoint state (qb)',
                'help with using the program',
                'show all information about this machine',
                'load program file',
                'show program',
                'exit the program',
                'reset program',
                'run program from head position',
                'set and get number of state (|Q|)',
                'run program step-by-step from head position',
                'set, get and reset symbol set (S)',
                'set, get and reset tape content',
                'turn tracking on and off',
                'set, get and reset number of steps',
                'restore Turing-machine to original state'), (
                'break [01..49|-]           ',
                'help [command]             ',
                'info                       ',
                'load filename.t36          ',
                'prog                       ',
                'quit                       ',
                'reset [tm]                 ',
                'run [head pos.: -50..+50]  ',
                'state [2..49]              ',
                'step [head pos.: -50..+50] ',
                'symbol [symbols|-]         ',
                'tape [content|-]           ',
                'trace [on|off]             ',
                'limit [10..32767|-]        ',
                'restore                    '));
  MESSAGE:      array[0..66] of string[61] = (
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
                'The program has been reset.',
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
                'Commands:',
                'The Turing machine has been restore.',
                'The Turing machine has started.',
                'The Turing machine has stopped.',
                'count  head  qi  sj  sk  D  qm',
                'The scanned symbol is not in the symbol set.',
                'The number of steps has reached the maximum.',
                'No program step limit set.',
                'The program step limit is ',
                'The program step limit is deleted.',
                'The program step limit is set to ',
                'Press any key to continue!',
                'The set breakpoint state has been reached.',
                'The specified head position is invalid, ignored.',
                'The specified head position is out of range, ignored.',
                'Temporary starting head position set: ');
