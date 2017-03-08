;V1 is the open time for the solenoid (reward)
;V2 is the sequencer access/deny variable (SafeSampleKey)
;V3 is the time of sound onset, in ticks, read by CED
;V4 is the Which LED Flashing indicator (0 = none, 1 = LED)
;V5 is the number of flashes
;V6 will be the duration of each on/off half-cycle, in clock steps (i.e. one period = 2*V6)
;V7 allows me to calculate a delay accounting for known clock steps
;V8 is a flash-allow variable - allows early kill of a flash sequence from CED when LED is next off
;V9 is a stimulator-delay variable which allows the stim to be delayed relative to the juice
;V10 is the difference between V1 and V9 (absolute, code will use it properly)
                SET    0.010,1,0       ;10 microseconds per step (DON'T CHANGE), fastest possible
                VAR    V2=0            ;V2 logs whether the sequencer is in use
0000            JUMP   next
0001 PLAYA: 'A  MOVI   V2,1            ;Do not allow sequencer access
0002            WAVEGO A               ;Play wave area A
0003 AWAIT:     WAVEBR AWAIT,T         ;Wait until area A begins playing
0004            TICKS  V3              ;Place # of ticks at time of play into V3
0005            MOVI   V2,0            ;Allow sequencer access
0006            JUMP   next
0007 PLAYB: 'B  MOVI   V2,1            ;See PLAYA
0008            WAVEGO B
0009 BWAIT:     WAVEBR BWAIT,T
0010            TICKS  V3
0011            MOVI   V2,0
0012            JUMP   next
0013 PLAYC: 'C  MOVI   V2,1            ;See PLAYA
0014            WAVEGO C
0015 CWATT:     WAVEBR CWATT,T         ;note label "CWAIT" is reserved and disallowed
0016            TICKS  V3
0017            MOVI   V2,0
0018            JUMP   next
0019 PLAYD: 'D  MOVI   V2,1            ;See PLAYA
0020            WAVEGO D
0021 DWATT:     WAVEBR DWATT,T         ;note label "DWAIT" is reserved and disallowed
0022            TICKS  V3
0023            MOVI   V2,0
0024            JUMP   next
0025 PLAYE: 'E  MOVI   V2,1            ;See PLAYA
0026            WAVEGO E
0027 EWAIT:     WAVEBR EWAIT,T
0028            TICKS  V3
0029            MOVI   V2,0
0030            JUMP   next
0031 PLAYF: 'F  MOVI   V2,1            ;See PLAYA
0032            WAVEGO F
0033 FWAIT:     WAVEBR FWAIT,T
0034            TICKS  V3
0035            MOVI   V2,0
0036            JUMP   next
0037 PLAYS: 'G  MOVI   V2,1            ;See PLAYA
0038            WAVEGO G
0039 GWAIT:     WAVEBR GWAIT,T
0040            TICKS  V3
0041            MOVI   V2,0
0042            JUMP   next
0043 PLAYH: 'H  MOVI   V2,1            ;See PLAYA
0044            WAVEGO H
0045 HWAIT:     WAVEBR HWAIT,T
0046            TICKS  V3
0047            MOVI   V2,0
0048            JUMP   next
0049 PLAYI: 'I  MOVI   V2,1            ;See PLAYA
0050            WAVEGO I
0051 IWAIT:     WAVEBR IWAIT,T
0052            TICKS  V3
0053            MOVI   V2,0
0054            JUMP   next
0055 PLAYJ: 'J  MOVI   V2,1            ;See PLAYA
0056            WAVEGO J
0057 JWAIT:     WAVEBR JWAIT,T
0058            TICKS  V3
0059            MOVI   V2,0
0060            JUMP   next
;note that the precise output channel for CED reward is not determined pre-implementation
0061 REWARD: 'R MOVI   V2,1            ;Do not allow sequencer access
0062            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0063            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0064            DELAY  V1              ;wait required msec (v1), delay is in clock ticks
0065            DIGOUT [.......0]      ;Set output low (close solenoid)
0066            MOVI   V2,0            ;Allow sequencer access
0067            JUMP   next
0068 STIM:  'Z  MOVI   V2,1            ;Do not allow sequencer access
0069            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0070            DELAY  V9              ;Delay stimulation
0071            DIGOUT [....11..]      ;Pulse output for stimulator(s), (DIGOUT 2/3)
0072            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0073            DIGOUT [....00..]      ;Set output low for stimulator(s)
0074            MOVI   V2,0            ;Allow sequencer access
0075            JUMP   next
0076 STIMNJ: 'Y MOVI   V2,1            ;Do not allow sequencer access
0077            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0078            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0079            MULI   V10,ms(1)       ;Multiply V10 (ms) by #clock ticks/ms, put in V10
0080            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0081            BGT    V1,V9,DOZAP     ;If length of juice more than zap delay, go to zap
0082            DELAY  V1              ;otherwise wait required msec (v1), delay is in clock ticks
0083            DIGOUT [.......0]      ;Set output low (close solenoid)
0084            DELAY  V10             ;wait for zap
0085            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0086            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0087            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0088            MOVI   V2,0            ;Allow sequencer access
0089            JUMP   next
0090 DOZAP:     DELAY  V9              ;Delay stimulation
0091            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0092            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0093            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0094            DELAY  V10             ;wait to turn off juice
0095            DIGOUT [.......0]      ;Set output low (close solenoid)
0096            MOVI   V2,0            ;Allow sequencer access
0097            JUMP   next
0098 KILLRW: 'K MOVI   V2,1            ;Do not allow sequencer access
0099            DIGOUT [.......0]      ;Set output low for solenoid, in case
0100            MOVI   V2,0            ;Allow sequencer access
0101            JUMP   next            ;Extra DIGOUT bit for solenoid monitor
0102 LEDON: 'L  MOVI   V2,1            ;Do not allow sequencer access
0103            DIGOUT [......1.]      ;Turn LED on, LED connects to Digital Outputs 1
0104            BGT    V4,0,FLOFFW     ;If FLASH sequence exists, jump to FLASH OFF WAIT
0105            JUMP   EXITLED
0106 LEDOFF: 'M MOVI   V2,1            ;Do not allow sequencer access
0107            DIGOUT [......0.]      ;Turn LED off
0108            BGT    V8,0,FLONW      ;If FLASH sequence exists, jump to FLASH ON WAIT
0109            JUMP   EXITLED
0110 FLON:      BEQ    V4,1,LEDON      ;Start point, if flashing LED, jump to LED on
0111            JUMP   EXITLED         ;If 0 or intended light not found above, give up
0112 FLOFF:     BEQ    V4,1,LEDOFF     ;If flashing LED, jump to LED off
0113            JUMP   EXITLED         ;Just in case, should not happen
0114 FLONW:     MOVI   V7,0            ;Make sure #clock tick delays is zero
0115            BEQ    V8,0,EXITLED    ;If Flash-Allow variable 0, exit because light is already off
0116            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0117            SUB    V7,V4,-9        ;subtract # of BEQ ticks and add -9 constant ticks
0118            DELAY  V7              ;Wait for next FLASH ON
0119            DBNZ   V5,FLON         ;Decrement #repeats, continue flashing if any remain
0120            JUMP   EXITLED
0121 FLOFFW:    MOVI   V7,0            ;Make sure #clock tick delays is zero
0122            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0123            SUB    V7,V4,-8        ;subtract # of BEQ ticks and add -8 constant ticks
0124            DELAY  V7              ;Wait for next FLASH OFF
0125            JUMP   FLOFF           ;Do not decrement, jump to FLASH OFF
0126 FLSTOP: 'S DIGOUT [......0.]      ;Turn LED off
0127            JUMP   EXITLED
0128 EXITLED:   MOVI   V4,0            ;Set which light to flash to NONE
0129            MOVI   V8,0            ;Set Flash-Allow Variable to 0, disallow flashing
0130            MOVI   V2,0            ;Allow sequencer access, now done only once at end
0131 NEXT:      NOP