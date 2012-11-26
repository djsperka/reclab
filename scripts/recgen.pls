                SET      0.010 1 0     ;10 microseconds per step (DON'T CHANGE), fastest possible
                VAR    V2=0            ;V2 logs whether the sequencer is in use
0000            JUMP   next
0001 PLAYA:  'A MOVI   V2,1            ;Do not allow sequencer access
0002            WAVEGO A               ;Play wave area A
0003 AWAIT:     WAVEBR AWAIT,T         ;Wait until area A begins playing
0004            TICKS  V3              ;Place # of ticks at time of play into V3
0005            MOVI   V2,0            ;Allow sequencer access
0006            JUMP   next
0007 PLAYB:  'B MOVI   V2,1            ;See PLAYA
0008            WAVEGO B
0009 BWAIT:     WAVEBR BWAIT,T
0010            TICKS  V3
0011            MOVI   V2,0
0012            JUMP   next
0013 PLAYC:  'C MOVI   V2,1            ;See PLAYA
0014            WAVEGO C
0015 CWATT:     WAVEBR CWATT,T         ;note label "CWAIT" is reserved and disallowed
0016            TICKS  V3
0017            MOVI   V2,0
0018            JUMP   next
0019 PLAYD:  'D MOVI   V2,1            ;See PLAYA
0020            WAVEGO D
0021 DWATT:     WAVEBR DWATT,T         ;note label "DWAIT" is reserved and disallowed
0022            TICKS  V3
0023            MOVI   V2,0
0024            JUMP   next
0025 PLAYE:  'E MOVI   V2,1            ;See PLAYA
0026            WAVEGO E
0027 EWAIT:     WAVEBR EWAIT,T
0028            TICKS  V3
0029            MOVI   V2,0
0030            JUMP   next
0031 PLAYF:  'F MOVI   V2,1            ;See PLAYA
0032            WAVEGO F
0033 FWAIT:     WAVEBR FWAIT,T
0034            TICKS  V3
0035            MOVI   V2,0
0036            JUMP   next
0037 PLAYS:  'G MOVI   V2,1            ;See PLAYA
0038            WAVEGO G
0039 GWAIT:     WAVEBR GWAIT,T
0040            TICKS  V3
0041            MOVI   V2,0
0042            JUMP   next
0043 PLAYH:  'H MOVI   V2,1            ;See PLAYA
0044            WAVEGO H
0045 HWAIT:     WAVEBR HWAIT,T
0046            TICKS  V3
0047            MOVI   V2,0
0048            JUMP   next
0049 PLAYI:  'I MOVI   V2,1            ;See PLAYA
0050            WAVEGO I
0051 IWAIT:     WAVEBR IWAIT,T
0052            TICKS  V3
0053            MOVI   V2,0
0054            JUMP   next
0055 PLAYJ:  'J MOVI   V2,1            ;See PLAYA
0056            WAVEGO J
0057 JWAIT:     WAVEBR JWAIT,T
0058            TICKS  V3
0059            MOVI   V2,0
0060            JUMP   next
;note that the precise output channel for CED reward is not determined pre-implementation
0061 REWARD: 'R MOVI   V2,1            ;Do not allow sequencer access
0062            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0063            DIGOUT [....11..]      ;Pulse output for reward solenoid, (E2, patch panel)
0064            DELAY  V1              ;wait required msec (v1), delay is in clock ticks
0065            DIGOUT [....00..]      ;Set output low (close solenoid)
0066            MOVI   V2,0            ;Allow sequencer access
0067            JUMP   next
0068 KILLRW: 'K MOVI   V2,1            ;Do not allow sequencer access
0069            DIGOUT [....00..]      ;Set output low for solenoid, in case
0070            MOVI   V2,0            ;Allow sequencer access
0071            JUMP   next            ;Extra DIGOUT bit for solenoid monitor
0072 NEXT:      NOP    

