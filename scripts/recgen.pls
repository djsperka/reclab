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
;V11 is the amplitude of a "long tone" (0-32768)
;V12 is the frequency of the "long tone" (Degrees/step)
;V13 is the duration of the "long tone" (Clock ticks, subtract 2)
;V14 is the step size of the ramp for the "long tone", 98 corresponds to about 10 ms
;V15 is current amplitude of the "long tone", while ramping
;V16 is the number of cycles the "long noise" PWA will repeat
                SET      0.010 1 0     ;10 microseconds per step (DON'T CHANGE), fastest possible
                VAR    V2=0            ;V2 logs whether the sequencer is in use
0000            JUMP   NEXT
0001 LWAIT:  'X MOVI   V2,1            ;Do not allow sequencer access
0002            DELAY  ms(50)          ;wait an appropriate time to allow PlayWaveCopy to finish
0003            MOVI   V2,0            ;Allow sequencer access
0004            JUMP   NEXT
0005 PLAYN:  'N MOVI   V2,1            ;Do not allow sequencer access
0006            WAVEGO N               ;Play wave area N
0007 NWAIT:     WAVEBR NWAIT,T         ;Wait until area N begins playing
0008            MARK   1               ;Use digital marker as in long tone
0009            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
;0010 N1WAIT:    WAVEBR N1WAIT,S        ;Wait until area N STOPS playing
0010 N1WAIT:    WAVEBR N1WAIT,C        ;Wait until current cycle count changes
0011            DBNZ   V16,N1WAIT      ;Decrement V16 (total cycle count) and await next cycle
0012            DAC    0,0             ;Set DAC to 0
0013            MARK   0               ;Use digital marker as in long tone
0014            MOVI   V2,0            ;Allow sequencer access
0015            JUMP   NEXT
0016 PLAYA:  'A MOVI   V2,1            ;Do not allow sequencer access
0017            WAVEGO A               ;Play wave area A
0018 AWAIT:     WAVEBR AWAIT,T         ;Wait until area A begins playing
0019            TICKS  V3              ;Place # of ticks at time of play into V3
0020            MOVI   V2,0            ;Allow sequencer access
0021            JUMP   NEXT
0022 PLAYB:  'B MOVI   V2,1            ;See PLAYA
0023            WAVEGO B
0024 BWAIT:     WAVEBR BWAIT,T
0025            TICKS  V3
0026            MOVI   V2,0
0027            JUMP   NEXT
0028 PLAYC:  'C MOVI   V2,1            ;See PLAYA
0029            WAVEGO C
0030 CWATT:     WAVEBR CWATT,T         ;note label "CWAIT" is reserved and disallowed
0031            TICKS  V3
0032            MOVI   V2,0
0033            JUMP   NEXT
0034 PLAYD:  'D MOVI   V2,1            ;See PLAYA
0035            WAVEGO D
0036 DWATT:     WAVEBR DWATT,T         ;note label "DWAIT" is reserved and disallowed
0037            TICKS  V3
0038            MOVI   V2,0
0039            JUMP   NEXT
0040 PLAYE:  'E MOVI   V2,1            ;See PLAYA
0041            WAVEGO E
0042 EWAIT:     WAVEBR EWAIT,T
0043            TICKS  V3
0044            MOVI   V2,0
0045            JUMP   NEXT
0046 PLAYF:  'F MOVI   V2,1            ;See PLAYA
0047            WAVEGO F
0048 FWAIT:     WAVEBR FWAIT,T
0049            TICKS  V3
0050            MOVI   V2,0
0051            JUMP   NEXT
0052 PLAYS:  'G MOVI   V2,1            ;See PLAYA
0053            WAVEGO G
0054 GWAIT:     WAVEBR GWAIT,T
0055            TICKS  V3
0056            MOVI   V2,0
0057            JUMP   NEXT
0058 PLAYH:  'H MOVI   V2,1            ;See PLAYA
0059            WAVEGO H
0060 HWAIT:     WAVEBR HWAIT,T
0061            TICKS  V3
0062            MOVI   V2,0
0063            JUMP   NEXT
0064 PLAYI:  'I MOVI   V2,1            ;See PLAYA
0065            WAVEGO I
0066 IWAIT:     WAVEBR IWAIT,T
0067            TICKS  V3
0068            MOVI   V2,0
0069            JUMP   NEXT
0070 PLAYJ:  'J MOVI   V2,1            ;See PLAYA
0071            WAVEGO J
0072 JWAIT:     WAVEBR JWAIT,T
0073            TICKS  V3
0074            MOVI   V2,0
0075            JUMP   NEXT
;note that the precise output channel for CED reward is not determined pre-implementation
0076 REWARD: 'R MOVI   V2,1            ;Do not allow sequencer access
0077            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0078            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0079            TICKS  V3              ;Record time of reward
0080            DELAY  V1              ;wait required msec (v1), delay is in clock ticks
0081            DIGOUT [.......0]      ;Set output low (close solenoid)
0082            MOVI   V2,0            ;Allow sequencer access
0083            JUMP   NEXT
0084 STIM:   'Z MOVI   V2,1            ;Do not allow sequencer access
0085            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0086            DELAY  V9              ;Delay stimulation
0087            DIGOUT [....11..]      ;Pulse output for stimulator(s), (DIGOUT 2/3)
0088            TICKS  V3              ;Record time of stimulation reward
0089            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0090            DIGOUT [....00..]      ;Set output low for stimulator(s)
0091            MOVI   V2,0            ;Allow sequencer access
0092            JUMP   NEXT
0093 STIMNJ: 'Y MOVI   V2,1            ;Do not allow sequencer access
0094            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0095            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0096            MULI   V10,ms(1)       ;Multiply V10 (ms) by #clock ticks/ms, put in V10
0097            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0098            TICKS  V3              ;Record time of juice reward, stim reward must be inferred
0099            BGT    V1,V9,DOZAP     ;If length of juice more than zap delay, go to zap
0100            DELAY  V1              ;otherwise wait required msec (v1), delay is in clock ticks
0101            DIGOUT [.......0]      ;Set output low (close solenoid)
0102            DELAY  V10             ;wait for zap
0103            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0104            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0105            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0106            MOVI   V2,0            ;Allow sequencer access
0107            JUMP   NEXT
0108 DOZAP:     DELAY  V9              ;Delay stimulation
0109            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0110            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0111            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0112            DELAY  V10             ;wait to turn off juice
0113            DIGOUT [.......0]      ;Set output low (close solenoid)
0114            MOVI   V2,0            ;Allow sequencer access
0115            JUMP   NEXT
0116 KILLRW: 'K MOVI   V2,1            ;Do not allow sequencer access
0117            DIGOUT [.......0]      ;Set output low for solenoid, in case
0118            MOVI   V2,0            ;Allow sequencer access
0119            JUMP   NEXT            ;Extra DIGOUT bit for solenoid monitor
0120 LEDON:  'L MOVI   V2,1            ;Do not allow sequencer access
0121            DIGOUT [......1.]      ;Turn LED on, LED connects to Digital Outputs 1
0122            BGT    V4,0,FLOFFW     ;If FLASH sequence exists, jump to FLASH OFF WAIT
0123            JUMP   EXITLED
0124 LEDOFF: 'M MOVI   V2,1            ;Do not allow sequencer access
0125            DIGOUT [......0.]      ;Turn LED off
0126            BGT    V8,0,FLONW      ;If FLASH sequence exists, jump to FLASH ON WAIT
0127            JUMP   EXITLED
0128 FLON:      BEQ    V4,1,LEDON      ;Start point, if flashing LED, jump to LED on
0129            JUMP   EXITLED         ;If 0 or intended light not found above, give up
0130 FLOFF:     BEQ    V4,1,LEDOFF     ;If flashing LED, jump to LED off
0131            JUMP   EXITLED         ;Just in case, should not happen
0132 FLONW:     MOVI   V7,0            ;Make sure #clock tick delays is zero
0133            BEQ    V8,0,EXITLED    ;If Flash-Allow variable 0, exit because light is already off
0134            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0135            SUB    V7,V4,-9        ;subtract # of BEQ ticks and add -9 constant ticks
0136            DELAY  V7              ;Wait for next FLASH ON
0137            DBNZ   V5,FLON         ;Decrement #repeats, continue flashing if any remain
0138            JUMP   EXITLED
0139 FLOFFW:    MOVI   V7,0            ;Make sure #clock tick delays is zero
0140            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0141            SUB    V7,V4,-8        ;subtract # of BEQ ticks and add -8 constant ticks
0142            DELAY  V7              ;Wait for next FLASH OFF
0143            JUMP   FLOFF           ;Do not decrement, jump to FLASH OFF
0144 FLSTOP: 'S DIGOUT [......0.]      ;Turn LED off
0145            JUMP   EXITLED
0146 EXITLED:   MOVI   V4,0            ;Set which light to flash to NONE
0147            MOVI   V8,0            ;Set Flash-Allow Variable to 0, disallow flashing
0148            MOVI   V2,0            ;Allow sequencer access, now done only once at end
0149            JUMP   NEXT
0150 LONGTONE: 'T MOVI V14,98          ;Putting ramp step in a variable makes SZINC easier
0151            MOVI   V15,0           ;Current amplitude of tone
0152            SZ     0,0             ;Set amplitude of tone to zero, to start, will ramp
0153            PHASE  0,-90           ;Change to sine phase
0154            ANGLE  0,0             ;Reset tone to phase 0
0155            RATE   0,V12           ;Start the tone
0156            MARK   1               ;Mark onset of tone on digital marker channel
0157            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
0158 RAMPUP:    ADD    V15,V14         ;Increment current tone amplitude
0159            BGE    V15,V11,UPDONE  ;If we are finished with ramp, branch
0160            SZ     0,V15,RAMPUP    ;Increment amplitude of tone and repeat
0161 UPDONE:    SZ     0,V11           ;Set amplitude to correct value
0162            MOV    V15,V11         ;Keep actual value
0163            DELAY  V13             ;Wait through the requested duration
0164 RAMPDOWN: 't SUB  V15,V14         ;Decrement current tone amplitude
0165            BLE    V15,0,DOWNDONE  ;If we are finished with ramp, branch
0166            SZ     0,V15,RAMPDOWN  ;Decrement amplitude of tone and repeat
0167 DOWNDONE:  SZ     0,0             ;Set amplitude of tone to 0
0168            RATE   0,0             ;Stop tone
0169            MARK   0               ;Mark offset of tone on digital marker channel
0170 NEXT:      NOP    