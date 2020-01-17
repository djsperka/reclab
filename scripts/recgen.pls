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
0005 PLAYA0: 'a MOVI   V2,1            ;Do not allow sequencer access
0006            WAVEGO A               ;Play wave area A
0007 A0WAIT:    WAVEBR A0WAIT,T        ;Wait until area A begins playing
0008            MARK   1               ;Use digital marker as in long tone
0009            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
0010 A1WAIT:    WAVEBR A1WAIT,S        ;Wait until area A STOPS playing
0011            MARK   0               ;Use digital marker as in long tone
0012            MOVI   V2,0            ;Allow sequencer access
0013            JUMP   NEXT
0014 PLAYA: 'A  MOVI   V2,1            ;Do not allow sequencer access
0015            WAVEGO A               ;Play wave area A
0016 AWAIT:     WAVEBR AWAIT,T         ;Wait until area A begins playing
0017            TICKS  V3              ;Place # of ticks at time of play into V3
0018            MOVI   V2,0            ;Allow sequencer access
0019            JUMP   NEXT
0020 PLAYB: 'B  MOVI   V2,1            ;See PLAYA
0021            WAVEGO B
0022 BWAIT:     WAVEBR BWAIT,T
0023            TICKS  V3
0024            MOVI   V2,0
0025            JUMP   NEXT
0026 PLAYC: 'C  MOVI   V2,1            ;See PLAYA
0027            WAVEGO C
0028 CWATT:     WAVEBR CWATT,T         ;note label "CWAIT" is reserved and disallowed
0029            TICKS  V3
0030            MOVI   V2,0
0031            JUMP   NEXT
0032 PLAYD: 'D  MOVI   V2,1            ;See PLAYA
0033            WAVEGO D
0034 DWATT:     WAVEBR DWATT,T         ;note label "DWAIT" is reserved and disallowed
0035            TICKS  V3
0036            MOVI   V2,0
0037            JUMP   NEXT
0038 PLAYE: 'E  MOVI   V2,1            ;See PLAYA
0039            WAVEGO E
0040 EWAIT:     WAVEBR EWAIT,T
0041            TICKS  V3
0042            MOVI   V2,0
0043            JUMP   NEXT
0044 PLAYF: 'F  MOVI   V2,1            ;See PLAYA
0045            WAVEGO F
0046 FWAIT:     WAVEBR FWAIT,T
0047            TICKS  V3
0048            MOVI   V2,0
0049            JUMP   NEXT
0050 PLAYS: 'G  MOVI   V2,1            ;See PLAYA
0051            WAVEGO G
0052 GWAIT:     WAVEBR GWAIT,T
0053            TICKS  V3
0054            MOVI   V2,0
0055            JUMP   NEXT
0056 PLAYH: 'H  MOVI   V2,1            ;See PLAYA
0057            WAVEGO H
0058 HWAIT:     WAVEBR HWAIT,T
0059            TICKS  V3
0060            MOVI   V2,0
0061            JUMP   NEXT
0062 PLAYI: 'I  MOVI   V2,1            ;See PLAYA
0063            WAVEGO I
0064 IWAIT:     WAVEBR IWAIT,T
0065            TICKS  V3
0066            MOVI   V2,0
0067            JUMP   NEXT
0068 PLAYJ: 'J  MOVI   V2,1            ;See PLAYA
0069            WAVEGO J
0070 JWAIT:     WAVEBR JWAIT,T
0071            TICKS  V3
0072            MOVI   V2,0
0073            JUMP   NEXT
;note that the precise output channel for CED reward is not determined pre-implementation
0074 REWARD: 'R MOVI   V2,1            ;Do not allow sequencer access
0075            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0076            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0077            TICKS  V3              ;Record time of reward
0078            DELAY  V1              ;wait required msec (v1), delay is in clock ticks
0079            DIGOUT [.......0]      ;Set output low (close solenoid)
0080            MOVI   V2,0            ;Allow sequencer access
0081            JUMP   NEXT
0082 STIM:  'Z  MOVI   V2,1            ;Do not allow sequencer access
0083            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0084            DELAY  V9              ;Delay stimulation
0085            DIGOUT [....11..]      ;Pulse output for stimulator(s), (DIGOUT 2/3)
0086            TICKS  V3              ;Record time of stimulation reward
0087            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0088            DIGOUT [....00..]      ;Set output low for stimulator(s)
0089            MOVI   V2,0            ;Allow sequencer access
0090            JUMP   NEXT
0091 STIMNJ: 'Y MOVI   V2,1            ;Do not allow sequencer access
0092            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0093            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0094            MULI   V10,ms(1)       ;Multiply V10 (ms) by #clock ticks/ms, put in V10
0095            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0096            TICKS  V3              ;Record time of juice reward, stim reward must be inferred
0097            BGT    V1,V9,DOZAP     ;If length of juice more than zap delay, go to zap
0098            DELAY  V1              ;otherwise wait required msec (v1), delay is in clock ticks
0099            DIGOUT [.......0]      ;Set output low (close solenoid)
0100            DELAY  V10             ;wait for zap
0101            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0102            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0103            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0104            MOVI   V2,0            ;Allow sequencer access
0105            JUMP   NEXT
0106 DOZAP:     DELAY  V9              ;Delay stimulation
0107            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0108            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0109            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0110            DELAY  V10             ;wait to turn off juice
0111            DIGOUT [.......0]      ;Set output low (close solenoid)
0112            MOVI   V2,0            ;Allow sequencer access
0113            JUMP   NEXT
0114 KILLRW: 'K MOVI   V2,1            ;Do not allow sequencer access
0115            DIGOUT [.......0]      ;Set output low for solenoid, in case
0116            MOVI   V2,0            ;Allow sequencer access
0117            JUMP   NEXT            ;Extra DIGOUT bit for solenoid monitor
0118 LEDON: 'L  MOVI   V2,1            ;Do not allow sequencer access
0119            DIGOUT [......1.]      ;Turn LED on, LED connects to Digital Outputs 1
0120            BGT    V4,0,FLOFFW     ;If FLASH sequence exists, jump to FLASH OFF WAIT
0121            JUMP   EXITLED
0122 LEDOFF: 'M MOVI   V2,1            ;Do not allow sequencer access
0123            DIGOUT [......0.]      ;Turn LED off
0124            BGT    V8,0,FLONW      ;If FLASH sequence exists, jump to FLASH ON WAIT
0125            JUMP   EXITLED
0126 FLON:      BEQ    V4,1,LEDON      ;Start point, if flashing LED, jump to LED on
0127            JUMP   EXITLED         ;If 0 or intended light not found above, give up
0128 FLOFF:     BEQ    V4,1,LEDOFF     ;If flashing LED, jump to LED off
0129            JUMP   EXITLED         ;Just in case, should not happen
0130 FLONW:     MOVI   V7,0            ;Make sure #clock tick delays is zero
0131            BEQ    V8,0,EXITLED    ;If Flash-Allow variable 0, exit because light is already off
0132            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0133            SUB    V7,V4,-9        ;subtract # of BEQ ticks and add -9 constant ticks
0134            DELAY  V7              ;Wait for next FLASH ON
0135            DBNZ   V5,FLON         ;Decrement #repeats, continue flashing if any remain
0136            JUMP   EXITLED
0137 FLOFFW:    MOVI   V7,0            ;Make sure #clock tick delays is zero
0138            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0139            SUB    V7,V4,-8        ;subtract # of BEQ ticks and add -8 constant ticks
0140            DELAY  V7              ;Wait for next FLASH OFF
0141            JUMP   FLOFF           ;Do not decrement, jump to FLASH OFF
0142 FLSTOP: 'S DIGOUT [......0.]      ;Turn LED off
0143            JUMP   EXITLED
0144 EXITLED:   MOVI   V4,0            ;Set which light to flash to NONE
0145            MOVI   V8,0            ;Set Flash-Allow Variable to 0, disallow flashing
0146            MOVI   V2,0            ;Allow sequencer access, now done only once at end
0147            JUMP   NEXT
0148 LONGTONE: 'T MOVI V14,98          ;Putting ramp step in a variable makes SZINC easier
0149            MOVI   V15,0           ;Current amplitude of tone
0150            SZ     0,0             ;Set amplitude of tone to zero, to start, will ramp
0151            PHASE  0,-90           ;Change to sine phase
0152            ANGLE  0,0             ;Reset tone to phase 0
0153            RATE   0,V12           ;Start the tone
0154            MARK   1               ;Mark onset of tone on digital marker channel
0155            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
0156 RAMPUP:    ADD    V15,V14         ;Increment current tone amplitude
0157            BGE    V15,V11,UPDONE  ;If we are finished with ramp, branch
0158            SZ     0,V15,RAMPUP    ;Increment amplitude of tone and repeat
0159 UPDONE:    SZ     0,V11           ;Set amplitude to correct value
0160            MOV    V15,V11         ;Keep actual value
0161            DELAY  V13             ;Wait through the requested duration
0162 RAMPDOWN: 't SUB  V15,V14         ;Decrement current tone amplitude
0163            BLE    V15,0,DOWNDONE  ;If we are finished with ramp, branch
0164            SZ     0,V15,RAMPDOWN  ;Decrement amplitude of tone and repeat
0165 DOWNDONE:  SZ     0,0             ;Set amplitude of tone to 0
0166            RATE   0,0             ;Stop tone
0167            MARK   0               ;Mark offset of tone on digital marker channel
0168 NEXT:      NOP