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
                SET    0.010,1,0       ;10 microseconds per step (DON'T CHANGE), fastest possible
                VAR    V2=0            ;V2 logs whether the sequencer is in use
0000            JUMP   NEXT
0001 LWAIT: 'X  MOVI   V2,1            ;Do not allow sequencer access
0002            DELAY  ms(50)          ;wait an appropriate time to allow PlayWaveCopy to finish
0003            MOVI   V2,0            ;Allow sequencer access
0004            JUMP   NEXT
0005 PLAYA: 'A  MOVI   V2,1            ;Do not allow sequencer access
0006            WAVEGO A               ;Play wave area A
0007 AWAIT:     WAVEBR AWAIT,T         ;Wait until area A begins playing
0008            TICKS  V3              ;Place # of ticks at time of play into V3
0009            MOVI   V2,0            ;Allow sequencer access
0010            JUMP   NEXT
0011 PLAYB: 'B  MOVI   V2,1            ;See PLAYA
0012            WAVEGO B
0013 BWAIT:     WAVEBR BWAIT,T
0014            TICKS  V3
0015            MOVI   V2,0
0016            JUMP   NEXT
0017 PLAYC: 'C  MOVI   V2,1            ;See PLAYA
0018            WAVEGO C
0019 CWATT:     WAVEBR CWATT,T         ;note label "CWAIT" is reserved and disallowed
0020            TICKS  V3
0021            MOVI   V2,0
0022            JUMP   NEXT
0023 PLAYD: 'D  MOVI   V2,1            ;See PLAYA
0024            WAVEGO D
0025 DWATT:     WAVEBR DWATT,T         ;note label "DWAIT" is reserved and disallowed
0026            TICKS  V3
0027            MOVI   V2,0
0028            JUMP   NEXT
0029 PLAYE: 'E  MOVI   V2,1            ;See PLAYA
0030            WAVEGO E
0031 EWAIT:     WAVEBR EWAIT,T
0032            TICKS  V3
0033            MOVI   V2,0
0034            JUMP   NEXT
0035 PLAYF: 'F  MOVI   V2,1            ;See PLAYA
0036            WAVEGO F
0037 FWAIT:     WAVEBR FWAIT,T
0038            TICKS  V3
0039            MOVI   V2,0
0040            JUMP   NEXT
0041 PLAYS: 'G  MOVI   V2,1            ;See PLAYA
0042            WAVEGO G
0043 GWAIT:     WAVEBR GWAIT,T
0044            TICKS  V3
0045            MOVI   V2,0
0046            JUMP   NEXT
0047 PLAYH: 'H  MOVI   V2,1            ;See PLAYA
0048            WAVEGO H
0049 HWAIT:     WAVEBR HWAIT,T
0050            TICKS  V3
0051            MOVI   V2,0
0052            JUMP   NEXT
0053 PLAYI: 'I  MOVI   V2,1            ;See PLAYA
0054            WAVEGO I
0055 IWAIT:     WAVEBR IWAIT,T
0056            TICKS  V3
0057            MOVI   V2,0
0058            JUMP   NEXT
0059 PLAYJ: 'J  MOVI   V2,1            ;See PLAYA
0060            WAVEGO J
0061 JWAIT:     WAVEBR JWAIT,T
0062            TICKS  V3
0063            MOVI   V2,0
0064            JUMP   NEXT
;note that the precise output channel for CED reward is not determined pre-implementation
0065 REWARD: 'R MOVI   V2,1            ;Do not allow sequencer access
0066            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0067            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0068            TICKS  V3              ;Record time of reward
0069            DELAY  V1              ;wait required msec (v1), delay is in clock ticks
0070            DIGOUT [.......0]      ;Set output low (close solenoid)
0071            MOVI   V2,0            ;Allow sequencer access
0072            JUMP   NEXT
0073 STIM:  'Z  MOVI   V2,1            ;Do not allow sequencer access
0074            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0075            DELAY  V9              ;Delay stimulation
0076            DIGOUT [....11..]      ;Pulse output for stimulator(s), (DIGOUT 2/3)
0077            TICKS  V3              ;Record time of stimulation reward
0078            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0079            DIGOUT [....00..]      ;Set output low for stimulator(s)
0080            MOVI   V2,0            ;Allow sequencer access
0081            JUMP   NEXT
0082 STIMNJ: 'Y MOVI   V2,1            ;Do not allow sequencer access
0083            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0084            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0085            MULI   V10,ms(1)       ;Multiply V10 (ms) by #clock ticks/ms, put in V10
0086            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0087            TICKS  V3              ;Record time of juice reward, stim reward must be inferred
0088            BGT    V1,V9,DOZAP     ;If length of juice more than zap delay, go to zap
0089            DELAY  V1              ;otherwise wait required msec (v1), delay is in clock ticks
0090            DIGOUT [.......0]      ;Set output low (close solenoid)
0091            DELAY  V10             ;wait for zap
0092            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0093            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0094            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0095            MOVI   V2,0            ;Allow sequencer access
0096            JUMP   NEXT
0097 DOZAP:     DELAY  V9              ;Delay stimulation
0098            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0099            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0100            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0101            DELAY  V10             ;wait to turn off juice
0102            DIGOUT [.......0]      ;Set output low (close solenoid)
0103            MOVI   V2,0            ;Allow sequencer access
0104            JUMP   NEXT
0105 KILLRW: 'K MOVI   V2,1            ;Do not allow sequencer access
0106            DIGOUT [.......0]      ;Set output low for solenoid, in case
0107            MOVI   V2,0            ;Allow sequencer access
0108            JUMP   NEXT            ;Extra DIGOUT bit for solenoid monitor
0109 LEDON: 'L  MOVI   V2,1            ;Do not allow sequencer access
0110            DIGOUT [......1.]      ;Turn LED on, LED connects to Digital Outputs 1
0111            BGT    V4,0,FLOFFW     ;If FLASH sequence exists, jump to FLASH OFF WAIT
0112            JUMP   EXITLED
0113 LEDOFF: 'M MOVI   V2,1            ;Do not allow sequencer access
0114            DIGOUT [......0.]      ;Turn LED off
0115            BGT    V8,0,FLONW      ;If FLASH sequence exists, jump to FLASH ON WAIT
0116            JUMP   EXITLED
0117 FLON:      BEQ    V4,1,LEDON      ;Start point, if flashing LED, jump to LED on
0118            JUMP   EXITLED         ;If 0 or intended light not found above, give up
0119 FLOFF:     BEQ    V4,1,LEDOFF     ;If flashing LED, jump to LED off
0120            JUMP   EXITLED         ;Just in case, should not happen
0121 FLONW:     MOVI   V7,0            ;Make sure #clock tick delays is zero
0122            BEQ    V8,0,EXITLED    ;If Flash-Allow variable 0, exit because light is already off
0123            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0124            SUB    V7,V4,-9        ;subtract # of BEQ ticks and add -9 constant ticks
0125            DELAY  V7              ;Wait for next FLASH ON
0126            DBNZ   V5,FLON         ;Decrement #repeats, continue flashing if any remain
0127            JUMP   EXITLED
0128 FLOFFW:    MOVI   V7,0            ;Make sure #clock tick delays is zero
0129            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0130            SUB    V7,V4,-8        ;subtract # of BEQ ticks and add -8 constant ticks
0131            DELAY  V7              ;Wait for next FLASH OFF
0132            JUMP   FLOFF           ;Do not decrement, jump to FLASH OFF
0133 FLSTOP: 'S DIGOUT [......0.]      ;Turn LED off
0134            JUMP   EXITLED
0135 EXITLED:   MOVI   V4,0            ;Set which light to flash to NONE
0136            MOVI   V8,0            ;Set Flash-Allow Variable to 0, disallow flashing
0137            MOVI   V2,0            ;Allow sequencer access, now done only once at end
0138            JUMP   NEXT
0139 LONGTONE: 'T MOVI V14,98          ;Putting ramp step in a variable makes SZINC easier
0140            MOVI   V15,0           ;Current amplitude of tone
0141            SZ     0,0             ;Set amplitude of tone to zero, to start, will ramp
0142            PHASE  0,-90           ;Change to sine phase
0143            ANGLE  0,0             ;Reset tone to phase 0
0144            RATE   0,V12           ;Start the tone
0145            MARK   1               ;Mark onset of tone on digital marker channel
0146            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
0147 RAMPUP:    ADD    V15,V14         ;Increment current tone amplitude
0148            BGE    V15,V11,UPDONE  ;If we are finished with ramp, branch
0149            SZ     0,V15,RAMPUP    ;Increment amplitude of tone and repeat
0150 UPDONE:    SZ     0,V11           ;Set amplitude to correct value
0151            MOV    V15,V11         ;Keep actual value
0152            DELAY  V13             ;Wait through the requested duration
0153 RAMPDOWN: 't SUB  V15,V14         ;Decrement current tone amplitude
0154            BLE    V15,0,DOWNDONE  ;If we are finished with ramp, branch
0155            SZ     0,V15,RAMPDOWN  ;Decrement amplitude of tone and repeat
0156 DOWNDONE:  SZ     0,0             ;Set amplitude of tone to 0
0157            RATE   0,0             ;Stop tone
0158            MARK   0               ;Mark offset of tone on digital marker channel
0159 NEXT:      NOP