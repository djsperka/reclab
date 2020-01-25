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

0016 PLAYA8: 'a MOVI   V2,1            ;Do not allow sequencer access
0017            WAVEGO A               ;Play wave area A
0018 A8WAIT:    WAVEBR A8WAIT,T        ;Wait until area A begins playing
0019            MARK   1               ;Use digital marker as in long tone
0020            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
0021 A9WAIT:    WAVEBR A9WAIT,S        ;Wait until area A STOPS playing
0022            DAC    0,0             ;Set DAC to 0
0023            MARK   0               ;Use digital marker as in long tone
0024            MOVI   V2,0            ;Allow sequencer access
0025            JUMP   NEXT

0026 PLAYB8: 'b MOVI   V2,1            ;Do not allow sequencer access
0027            WAVEGO B               ;Play wave area B
0028 B8WAIT:    WAVEBR B8WAIT,T        ;Wait until area B begins playing
0029            MARK   1               ;Use digital marker as in long tone
0030            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
0031 B9WAIT:    WAVEBR B9WAIT,S        ;Wait until area B STOPS playing
0032            DAC    0,0             ;Set DAC to 0
0033            MARK   0               ;Use digital marker as in long tone
0034            MOVI   V2,0            ;Allow sequencer access
0035            JUMP   NEXT

0036 PLAYC8: 'c MOVI   V2,1            ;Do not allow sequencer access
0037            WAVEGO C               ;Play wave area C
0038 C8WAIT:    WAVEBR C8WAIT,T        ;Wait until area C begins playing
0039            MARK   1               ;Use digital marker as in long tone
0040            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
0041 C9WAIT:    WAVEBR C9WAIT,S        ;Wait until area C STOPS playing
0042            DAC    0,0             ;Set DAC to 0
0043            MARK   0               ;Use digital marker as in long tone
0044            MOVI   V2,0            ;Allow sequencer access
0045            JUMP   NEXT

0046 PLAYD8: 'd MOVI   V2,1            ;Do not allow sequencer access
0047            WAVEGO D               ;Play wave area D
0048 D8WAIT:    WAVEBR D8WAIT,T        ;Wait until area D begins playing
0049            MARK   1               ;Use digital marker as in long tone
0050            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
0051 D9WAIT:    WAVEBR D9WAIT,S        ;Wait until area D STOPS playing
0052            DAC    0,0             ;Set DAC to 0
0053            MARK   0               ;Use digital marker as in long tone
0054            MOVI   V2,0            ;Allow sequencer access
0055            JUMP   NEXT


0056 PLAYA:  'A MOVI   V2,1            ;Do not allow sequencer access
0057            WAVEGO A               ;Play wave area A
0058 AWAIT:     WAVEBR AWAIT,T         ;Wait until area A begins playing
0059            TICKS  V3              ;Place # of ticks at time of play into V3
0060            MOVI   V2,0            ;Allow sequencer access
0061            JUMP   NEXT
0062 PLAYB:  'B MOVI   V2,1            ;See PLAYA
0063            WAVEGO B
0064 BWAIT:     WAVEBR BWAIT,T
0065            TICKS  V3
0066            MOVI   V2,0
0067            JUMP   NEXT
0068 PLAYC:  'C MOVI   V2,1            ;See PLAYA
0069            WAVEGO C
0070 CWATT:     WAVEBR CWATT,T         ;note label "CWAIT" is reserved and disallowed
0071            TICKS  V3
0072            MOVI   V2,0
0073            JUMP   NEXT
0074 PLAYD:  'D MOVI   V2,1            ;See PLAYA
0075            WAVEGO D
0076 DWATT:     WAVEBR DWATT,T         ;note label "DWAIT" is reserved and disallowed
0077            TICKS  V3
0078            MOVI   V2,0
0079            JUMP   NEXT
0080 PLAYE:  'E MOVI   V2,1            ;See PLAYA
0081            WAVEGO E
0082 EWAIT:     WAVEBR EWAIT,T
0083            TICKS  V3
0084            MOVI   V2,0
0085            JUMP   NEXT
0086 PLAYF:  'F MOVI   V2,1            ;See PLAYA
0087            WAVEGO F
0088 FWAIT:     WAVEBR FWAIT,T
0089            TICKS  V3
0090            MOVI   V2,0
0091            JUMP   NEXT
0092 PLAYS:  'G MOVI   V2,1            ;See PLAYA
0093            WAVEGO G
0094 GWAIT:     WAVEBR GWAIT,T
0095            TICKS  V3
0096            MOVI   V2,0
0097            JUMP   NEXT
0098 PLAYH:  'H MOVI   V2,1            ;See PLAYA
0099            WAVEGO H
0100 HWAIT:     WAVEBR HWAIT,T
0101            TICKS  V3
0102            MOVI   V2,0
0103            JUMP   NEXT
0104 PLAYI:  'I MOVI   V2,1            ;See PLAYA
0105            WAVEGO I
0106 IWAIT:     WAVEBR IWAIT,T
0107            TICKS  V3
0108            MOVI   V2,0
0109            JUMP   NEXT
0110 PLAYJ:  'J MOVI   V2,1            ;See PLAYA
0111            WAVEGO J
0112 JWAIT:     WAVEBR JWAIT,T
0113            TICKS  V3
0114            MOVI   V2,0
0115            JUMP   NEXT
;note that the precise output channel for CED reward is not determined pre-implementation
0116 REWARD: 'R MOVI   V2,1            ;Do not allow sequencer access
0117            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0118            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0119            TICKS  V3              ;Record time of reward
0120            DELAY  V1              ;wait required msec (v1), delay is in clock ticks
0121            DIGOUT [.......0]      ;Set output low (close solenoid)
0122            MOVI   V2,0            ;Allow sequencer access
0123            JUMP   NEXT
0124 STIM:   'Z MOVI   V2,1            ;Do not allow sequencer access
0125            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0126            DELAY  V9              ;Delay stimulation
0127            DIGOUT [....11..]      ;Pulse output for stimulator(s), (DIGOUT 2/3)
0128            TICKS  V3              ;Record time of stimulation reward
0129            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0130            DIGOUT [....00..]      ;Set output low for stimulator(s)
0131            MOVI   V2,0            ;Allow sequencer access
0132            JUMP   NEXT
0133 STIMNJ: 'Y MOVI   V2,1            ;Do not allow sequencer access
0134            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0135            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0136            MULI   V10,ms(1)       ;Multiply V10 (ms) by #clock ticks/ms, put in V10
0137            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0138            TICKS  V3              ;Record time of juice reward, stim reward must be inferred
0139            BGT    V1,V9,DOZAP     ;If length of juice more than zap delay, go to zap
0140            DELAY  V1              ;otherwise wait required msec (v1), delay is in clock ticks
0141            DIGOUT [.......0]      ;Set output low (close solenoid)
0142            DELAY  V10             ;wait for zap
0143            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0144            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0145            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0146            MOVI   V2,0            ;Allow sequencer access
0147            JUMP   NEXT
0148 DOZAP:     DELAY  V9              ;Delay stimulation
0149            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0150            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0151            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0152            DELAY  V10             ;wait to turn off juice
0153            DIGOUT [.......0]      ;Set output low (close solenoid)
0154            MOVI   V2,0            ;Allow sequencer access
0155            JUMP   NEXT
0156 KILLRW: 'K MOVI   V2,1            ;Do not allow sequencer access
0157            DIGOUT [.......0]      ;Set output low for solenoid, in case
0158            MOVI   V2,0            ;Allow sequencer access
0159            JUMP   NEXT            ;Extra DIGOUT bit for solenoid monitor
0160 LEDON:  'L MOVI   V2,1            ;Do not allow sequencer access
0161            DIGOUT [......1.]      ;Turn LED on, LED connects to Digital Outputs 1
0162            BGT    V4,0,FLOFFW     ;If FLASH sequence exists, jump to FLASH OFF WAIT
0163            JUMP   EXITLED
0164 LEDOFF: 'M MOVI   V2,1            ;Do not allow sequencer access
0165            DIGOUT [......0.]      ;Turn LED off
0166            BGT    V8,0,FLONW      ;If FLASH sequence exists, jump to FLASH ON WAIT
0167            JUMP   EXITLED
0168 FLON:      BEQ    V4,1,LEDON      ;Start point, if flashing LED, jump to LED on
0169            JUMP   EXITLED         ;If 0 or intended light not found above, give up
0170 FLOFF:     BEQ    V4,1,LEDOFF     ;If flashing LED, jump to LED off
0171            JUMP   EXITLED         ;Just in case, should not happen
0172 FLONW:     MOVI   V7,0            ;Make sure #clock tick delays is zero
0173            BEQ    V8,0,EXITLED    ;If Flash-Allow variable 0, exit because light is already off
0174            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0175            SUB    V7,V4,-9        ;subtract # of BEQ ticks and add -9 constant ticks
0176            DELAY  V7              ;Wait for next FLASH ON
0177            DBNZ   V5,FLON         ;Decrement #repeats, continue flashing if any remain
0178            JUMP   EXITLED
0179 FLOFFW:    MOVI   V7,0            ;Make sure #clock tick delays is zero
0180            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0181            SUB    V7,V4,-8        ;subtract # of BEQ ticks and add -8 constant ticks
0182            DELAY  V7              ;Wait for next FLASH OFF
0183            JUMP   FLOFF           ;Do not decrement, jump to FLASH OFF
0184 FLSTOP: 'S DIGOUT [......0.]      ;Turn LED off
0185            JUMP   EXITLED
0186 EXITLED:   MOVI   V4,0            ;Set which light to flash to NONE
0187            MOVI   V8,0            ;Set Flash-Allow Variable to 0, disallow flashing
0188            MOVI   V2,0            ;Allow sequencer access, now done only once at end
0189            JUMP   NEXT
0190 LONGTONE: 'T MOVI V14,98          ;Putting ramp step in a variable makes SZINC easier
0191            MOVI   V15,0           ;Current amplitude of tone
0192            SZ     0,0             ;Set amplitude of tone to zero, to start, will ramp
0193            PHASE  0,-90           ;Change to sine phase
0194            ANGLE  0,0             ;Reset tone to phase 0
0195            RATE   0,V12           ;Start the tone
0196            MARK   1               ;Mark onset of tone on digital marker channel
0197            TICKS  V3              ;Redundant, but get time of onset (plus one tick) again
0198 RAMPUP:    ADD    V15,V14         ;Increment current tone amplitude
0199            BGE    V15,V11,UPDONE  ;If we are finished with ramp, branch
0200            SZ     0,V15,RAMPUP    ;Increment amplitude of tone and repeat
0201 UPDONE:    SZ     0,V11           ;Set amplitude to correct value
0202            MOV    V15,V11         ;Keep actual value
0203            DELAY  V13             ;Wait through the requested duration
0204 RAMPDOWN: 't SUB  V15,V14         ;Decrement current tone amplitude
0205            BLE    V15,0,DOWNDONE  ;If we are finished with ramp, branch
0206            SZ     0,V15,RAMPDOWN  ;Decrement amplitude of tone and repeat
0207 DOWNDONE:  SZ     0,0             ;Set amplitude of tone to 0
0208            RATE   0,0             ;Stop tone
0209            MARK   0               ;Mark offset of tone on digital marker channel
0210 NEXT:      NOP    