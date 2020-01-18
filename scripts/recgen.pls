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
                SET    0.010,1,0       ;10 microseconds per step (DON'T CHANGE), fastest possible
                VAR    V2=0            ;V2 logs whether the sequencer is in use
0000            JUMP   NEXT
0001 LWAIT: 'X  MOVI   V2,1            ;Do not allow sequencer access
0002            DELAY  ms(50)          ;wait an appropriate time to allow PlayWaveCopy to finish
0003            MOVI   V2,0            ;Allow sequencer access
0004            JUMP   NEXT
0005 PLAYA0: 'a MOVI   V2,1            ;Do not allow sequencer access
0006            WAVEGO A               ;Play wave area A
0007 A0WAIT:    WAVEBR A0WAIT,T        ;Wait until area A begins playing
0008            MARK   1               ;Use digital marker as in long tone
0009            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
;0010 A1WAIT:    WAVEBR A1WAIT,S        ;Wait until area A STOPS playing
0010 A1WAIT:    WAVEBR A1WAIT,C        ;Wait until current cycle count changes
0011            DBNZ   V16,A1WAIT      ;Decrement V16 (total cycle count) and await next cycle
0012            MARK   0               ;Use digital marker as in long tone
0013            MOVI   V2,0            ;Allow sequencer access
0014            JUMP   NEXT
0015 PLAYA: 'A  MOVI   V2,1            ;Do not allow sequencer access
0016            WAVEGO A               ;Play wave area A
0017 AWAIT:     WAVEBR AWAIT,T         ;Wait until area A begins playing
0018            TICKS  V3              ;Place # of ticks at time of play into V3
0019            MOVI   V2,0            ;Allow sequencer access
0020            JUMP   NEXT
0021 PLAYB: 'B  MOVI   V2,1            ;See PLAYA
0022            WAVEGO B
0023 BWAIT:     WAVEBR BWAIT,T
0024            TICKS  V3
0025            MOVI   V2,0
0026            JUMP   NEXT
0027 PLAYC: 'C  MOVI   V2,1            ;See PLAYA
0028            WAVEGO C
0029 CWATT:     WAVEBR CWATT,T         ;note label "CWAIT" is reserved and disallowed
0030            TICKS  V3
0031            MOVI   V2,0
0032            JUMP   NEXT
0033 PLAYD: 'D  MOVI   V2,1            ;See PLAYA
0034            WAVEGO D
0035 DWATT:     WAVEBR DWATT,T         ;note label "DWAIT" is reserved and disallowed
0036            TICKS  V3
0037            MOVI   V2,0
0038            JUMP   NEXT
0039 PLAYE: 'E  MOVI   V2,1            ;See PLAYA
0040            WAVEGO E
0041 EWAIT:     WAVEBR EWAIT,T
0042            TICKS  V3
0043            MOVI   V2,0
0044            JUMP   NEXT
0045 PLAYF: 'F  MOVI   V2,1            ;See PLAYA
0046            WAVEGO F
0047 FWAIT:     WAVEBR FWAIT,T
0048            TICKS  V3
0049            MOVI   V2,0
0050            JUMP   NEXT
0051 PLAYS: 'G  MOVI   V2,1            ;See PLAYA
0052            WAVEGO G
0053 GWAIT:     WAVEBR GWAIT,T
0054            TICKS  V3
0055            MOVI   V2,0
0056            JUMP   NEXT
0057 PLAYH: 'H  MOVI   V2,1            ;See PLAYA
0058            WAVEGO H
0059 HWAIT:     WAVEBR HWAIT,T
0060            TICKS  V3
0061            MOVI   V2,0
0062            JUMP   NEXT
0063 PLAYI: 'I  MOVI   V2,1            ;See PLAYA
0064            WAVEGO I
0065 IWAIT:     WAVEBR IWAIT,T
0066            TICKS  V3
0067            MOVI   V2,0
0068            JUMP   NEXT
0069 PLAYJ: 'J  MOVI   V2,1            ;See PLAYA
0070            WAVEGO J
0071 JWAIT:     WAVEBR JWAIT,T
0072            TICKS  V3
0073            MOVI   V2,0
0074            JUMP   NEXT
;note that the precise output channel for CED reward is not determined pre-implementation
0075 REWARD: 'R MOVI   V2,1            ;Do not allow sequencer access
0076            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0077            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0078            TICKS  V3              ;Record time of reward
0079            DELAY  V1              ;wait required msec (v1), delay is in clock ticks
0080            DIGOUT [.......0]      ;Set output low (close solenoid)
0081            MOVI   V2,0            ;Allow sequencer access
0082            JUMP   NEXT
0083 STIM:  'Z  MOVI   V2,1            ;Do not allow sequencer access
0084            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0085            DELAY  V9              ;Delay stimulation
0086            DIGOUT [....11..]      ;Pulse output for stimulator(s), (DIGOUT 2/3)
0087            TICKS  V3              ;Record time of stimulation reward
0088            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0089            DIGOUT [....00..]      ;Set output low for stimulator(s)
0090            MOVI   V2,0            ;Allow sequencer access
0091            JUMP   NEXT
0092 STIMNJ: 'Y MOVI   V2,1            ;Do not allow sequencer access
0093            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0094            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0095            MULI   V10,ms(1)       ;Multiply V10 (ms) by #clock ticks/ms, put in V10
0096            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0097            TICKS  V3              ;Record time of juice reward, stim reward must be inferred
0098            BGT    V1,V9,DOZAP     ;If length of juice more than zap delay, go to zap
0099            DELAY  V1              ;otherwise wait required msec (v1), delay is in clock ticks
0100            DIGOUT [.......0]      ;Set output low (close solenoid)
0101            DELAY  V10             ;wait for zap
0102            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0103            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0104            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0105            MOVI   V2,0            ;Allow sequencer access
0106            JUMP   NEXT
0107 DOZAP:     DELAY  V9              ;Delay stimulation
0108            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0109            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0110            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0111            DELAY  V10             ;wait to turn off juice
0112            DIGOUT [.......0]      ;Set output low (close solenoid)
0113            MOVI   V2,0            ;Allow sequencer access
0114            JUMP   NEXT
0115 KILLRW: 'K MOVI   V2,1            ;Do not allow sequencer access
0116            DIGOUT [.......0]      ;Set output low for solenoid, in case
0117            MOVI   V2,0            ;Allow sequencer access
0118            JUMP   NEXT            ;Extra DIGOUT bit for solenoid monitor
0119 LEDON: 'L  MOVI   V2,1            ;Do not allow sequencer access
0120            DIGOUT [......1.]      ;Turn LED on, LED connects to Digital Outputs 1
0121            BGT    V4,0,FLOFFW     ;If FLASH sequence exists, jump to FLASH OFF WAIT
0122            JUMP   EXITLED
0123 LEDOFF: 'M MOVI   V2,1            ;Do not allow sequencer access
0124            DIGOUT [......0.]      ;Turn LED off
0125            BGT    V8,0,FLONW      ;If FLASH sequence exists, jump to FLASH ON WAIT
0126            JUMP   EXITLED
0127 FLON:      BEQ    V4,1,LEDON      ;Start point, if flashing LED, jump to LED on
0128            JUMP   EXITLED         ;If 0 or intended light not found above, give up
0129 FLOFF:     BEQ    V4,1,LEDOFF     ;If flashing LED, jump to LED off
0130            JUMP   EXITLED         ;Just in case, should not happen
0131 FLONW:     MOVI   V7,0            ;Make sure #clock tick delays is zero
0132            BEQ    V8,0,EXITLED    ;If Flash-Allow variable 0, exit because light is already off
0133            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0134            SUB    V7,V4,-9        ;subtract # of BEQ ticks and add -9 constant ticks
0135            DELAY  V7              ;Wait for next FLASH ON
0136            DBNZ   V5,FLON         ;Decrement #repeats, continue flashing if any remain
0137            JUMP   EXITLED
0138 FLOFFW:    MOVI   V7,0            ;Make sure #clock tick delays is zero
0139            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0140            SUB    V7,V4,-8        ;subtract # of BEQ ticks and add -8 constant ticks
0141            DELAY  V7              ;Wait for next FLASH OFF
0142            JUMP   FLOFF           ;Do not decrement, jump to FLASH OFF
0143 FLSTOP: 'S DIGOUT [......0.]      ;Turn LED off
0144            JUMP   EXITLED
0145 EXITLED:   MOVI   V4,0            ;Set which light to flash to NONE
0146            MOVI   V8,0            ;Set Flash-Allow Variable to 0, disallow flashing
0147            MOVI   V2,0            ;Allow sequencer access, now done only once at end
0148            JUMP   NEXT
0149 LONGTONE: 'T MOVI V14,98          ;Putting ramp step in a variable makes SZINC easier
0150            MOVI   V15,0           ;Current amplitude of tone
0151            SZ     0,0             ;Set amplitude of tone to zero, to start, will ramp
0152            PHASE  0,-90           ;Change to sine phase
0153            ANGLE  0,0             ;Reset tone to phase 0
0154            RATE   0,V12           ;Start the tone
0155            MARK   1               ;Mark onset of tone on digital marker channel
0156            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
0157 RAMPUP:    ADD    V15,V14         ;Increment current tone amplitude
0158            BGE    V15,V11,UPDONE  ;If we are finished with ramp, branch
0159            SZ     0,V15,RAMPUP    ;Increment amplitude of tone and repeat
0160 UPDONE:    SZ     0,V11           ;Set amplitude to correct value
0161            MOV    V15,V11         ;Keep actual value
0162            DELAY  V13             ;Wait through the requested duration
0163 RAMPDOWN: 't SUB  V15,V14         ;Decrement current tone amplitude
0164            BLE    V15,0,DOWNDONE  ;If we are finished with ramp, branch
0165            SZ     0,V15,RAMPDOWN  ;Decrement amplitude of tone and repeat
0166 DOWNDONE:  SZ     0,0             ;Set amplitude of tone to 0
0167            RATE   0,0             ;Stop tone
0168            MARK   0               ;Mark offset of tone on digital marker channel
0169 NEXT:      NOP