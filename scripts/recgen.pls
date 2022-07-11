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
;0005 PLAYN: 'N  MOVI   V2,1            ;Do not allow sequencer access
;0006            WAVEGO N               ;Play wave area N
;0007 NWAIT:     WAVEBR NWAIT,T         ;Wait until area N begins playing
;0008            MARK   1               ;Use digital marker as in long tone
;0009            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
;;0010 N1WAIT:    WAVEBR N1WAIT,S        ;Wait until area N STOPS playing
;0010 N1WAIT:    WAVEBR N1WAIT,C        ;Wait until current cycle count changes
;0011            DBNZ   V16,N1WAIT      ;Decrement V16 (total cycle count) and await next cycle
;0012            DAC    0,0             ;Set DAC to 0
;0013            MARK   0               ;Use digital marker as in long tone
;0014            MOVI   V2,0            ;Allow sequencer access
;0015            JUMP   NEXT
0005 PLAYKK: 'k MOVI   V2,1            ;Do not allow sequencer access
0006            WAVEGO K,W             ;Play wave area K (parallel PWA 1)
0007 KKWAIT:    WAVEBR KKWAIT,T        ;Wait until area K begins playing
0008            MARK   1               ;Use digital marker as in long tone
0009            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0010 KXWAIT:    WAVEBR KXWAIT,S        ;Wait until area K STOPS playing
0011            DAC    0,0             ;Set DAC to 0
0012            MARK   0               ;Use digital marker as in long tone
0013            MOVI   V2,0            ;Allow sequencer access
0014            JUMP   NEXT
0005 PLAYLL: 'l MOVI   V2,1            ;Do not allow sequencer access
0006            WAVEGO L,W             ;Play wave area L (parallel PWA 2)
0007 LLWAIT:    WAVEBR LLWAIT,T        ;Wait until area L begins playing
0008            MARK   1               ;Use digital marker as in long tone
0009            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0010 LXWAIT:    WAVEBR LXWAIT,S        ;Wait until area L STOPS playing
0011            DAC    0,0             ;Set DAC to 0
0012            MARK   0               ;Use digital marker as in long tone
0013            MOVI   V2,0            ;Allow sequencer access
0014            JUMP   NEXT
0015 PLAYMM: 'm MOVI   V2,1            ;Do not allow sequencer access
0016            WAVEGO M,W             ;Play wave area M (long tone PWA 1)
0017 MMWAIT:    WAVEBR MMWAIT,T        ;Wait until area M begins playing
0018            MARK   1               ;Use digital marker as in long tone
0019            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0020 MXWAIT:    WAVEBR MXWAIT,S        ;Wait until area M STOPS playing
0021            DAC    0,0             ;Set DAC to 0
0022            MARK   0               ;Use digital marker as in long tone
0023            MOVI   V2,0            ;Allow sequencer access
0024            JUMP   NEXT
0025 PLAYNN: 'n MOVI   V2,1            ;Do not allow sequencer access
0026            WAVEGO N,W             ;Play wave area N (long tone PWA 2)
0027 NNWAIT:    WAVEBR NNWAIT,T        ;Wait until area N begins playing
0028            MARK   1               ;Use digital marker as in long tone
0029            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0030 NXWAIT:    WAVEBR NXWAIT,S        ;Wait until area N STOPS playing
0031            DAC    0,0             ;Set DAC to 0
0032            MARK   0               ;Use digital marker as in long tone
0033            MOVI   V2,0            ;Allow sequencer access
0034            JUMP   NEXT
0035 PLAYOO: 'o MOVI   V2,1            ;Do not allow sequencer access
0036            WAVEGO O,W             ;Play wave area O (long tone PWA 3)
0037 OOWAIT:    WAVEBR OOWAIT,T        ;Wait until area O begins playing
0038            MARK   1               ;Use digital marker as in long tone
0039            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0040 OXWAIT:    WAVEBR OXWAIT,S        ;Wait until area O STOPS playing
0041            DAC    0,0             ;Set DAC to 0
0042            MARK   0               ;Use digital marker as in long tone
0043            MOVI   V2,0            ;Allow sequencer access
0044            JUMP   NEXT
0045 PLAYPP: 'p MOVI   V2,1            ;Do not allow sequencer access
0046            WAVEGO P,W             ;Play wave area P (long tone PWA 4)
0047 PPWAIT:    WAVEBR PPWAIT,T        ;Wait until area P begins playing
0048            MARK   1               ;Use digital marker as in long tone
0049            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0050 PXWAIT:    WAVEBR PXWAIT,S        ;Wait until area P STOPS playing
0051            DAC    0,0             ;Set DAC to 0
0052            MARK   0               ;Use digital marker as in long tone
0053            MOVI   V2,0            ;Allow sequencer access
0054            JUMP   NEXT
0045 PLAYQQ: 'q MOVI   V2,1            ;Do not allow sequencer access
0046            WAVEGO Q,W             ;Play wave area Q (long tone PWA 5)
0047 QQWAIT:    WAVEBR QQWAIT,T        ;Wait until area Q begins playing
0048            MARK   1               ;Use digital marker as in long tone
0049            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0050 QXWAIT:    WAVEBR QXWAIT,S        ;Wait until area Q STOPS playing
0051            DAC    0,0             ;Set DAC to 0
0052            MARK   0               ;Use digital marker as in long tone
0053            MOVI   V2,0            ;Allow sequencer access
0054            JUMP   NEXT
0055 PLAYA: 'A  MOVI   V2,1            ;Do not allow sequencer access
0056            WAVEGO A,W             ;Play wave area A
0057 AWAIT:     WAVEBR AWAIT,T         ;Wait until area A begins playing
0058            TICKS  V3              ;Place # of ticks at time of play into V3
0059            MOVI   V2,0            ;Allow sequencer access
0060            JUMP   NEXT
0061 PLAYB: 'B  MOVI   V2,1            ;See PLAYA
0062            WAVEGO B,W
0063 BWAIT:     WAVEBR BWAIT,T
0064            TICKS  V3
0065            MOVI   V2,0
0066            JUMP   NEXT
0067 PLAYC: 'C  MOVI   V2,1            ;See PLAYA
0068            WAVEGO C,W
0069 CWATT:     WAVEBR CWATT,T         ;note label "CWAIT" is reserved and disallowed
0070            TICKS  V3
0071            MOVI   V2,0
0072            JUMP   NEXT
0073 PLAYD: 'D  MOVI   V2,1            ;See PLAYA
0074            WAVEGO D,W
0075 DWATT:     WAVEBR DWATT,T         ;note label "DWAIT" is reserved and disallowed
0076            TICKS  V3
0077            MOVI   V2,0
0078            JUMP   NEXT
0079 PLAYE: 'E  MOVI   V2,1            ;See PLAYA
0080            WAVEGO E,W
0081 EWAIT:     WAVEBR EWAIT,T
0082            TICKS  V3
0083            MOVI   V2,0
0084            JUMP   NEXT
0085 PLAYF: 'F  MOVI   V2,1            ;See PLAYA
0086            WAVEGO F,W
0087 FWAIT:     WAVEBR FWAIT,T
0088            TICKS  V3
0089            MOVI   V2,0
0090            JUMP   NEXT
0091 PLAYS: 'G  MOVI   V2,1            ;See PLAYA
0092            WAVEGO G,W
0093 GWAIT:     WAVEBR GWAIT,T
0094            TICKS  V3
0095            MOVI   V2,0
0096            JUMP   NEXT
0097 PLAYH: 'H  MOVI   V2,1            ;See PLAYA
0098            WAVEGO H,W
0099 HWAIT:     WAVEBR HWAIT,T
0100            TICKS  V3
0101            MOVI   V2,0
0102            JUMP   NEXT
0103 PLAYI: 'I  MOVI   V2,1            ;See PLAYA
0104            WAVEGO I,W
0105 IWAIT:     WAVEBR IWAIT,T
0106            TICKS  V3
0107            MOVI   V2,0
0108            JUMP   NEXT
0109 PLAYJ: 'J  MOVI   V2,1            ;See PLAYA
0110            WAVEGO J,W
0111 JWAIT:     WAVEBR JWAIT,T
0112            TICKS  V3
0113            MOVI   V2,0
0114            JUMP   NEXT
;note that the precise output channel for CED reward is not determined pre-implementation
0115 REWARD: 'R MOVI   V2,1            ;Do not allow sequencer access
0116            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0117            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0118            TICKS  V3              ;Record time of reward
0119            DELAY  V1              ;wait required msec (v1), delay is in clock ticks
0120            DIGOUT [.......0]      ;Set output low (close solenoid)
0121            MOVI   V2,0            ;Allow sequencer access
0122            JUMP   NEXT
0123 STIM:  'Z  MOVI   V2,1            ;Do not allow sequencer access
0124            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0125            DELAY  V9              ;Delay stimulation
0126            DIGOUT [....11..]      ;Pulse output for stimulator(s), (DIGOUT 2/3)
0127            TICKS  V3              ;Record time of stimulation reward
0128            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0129            DIGOUT [....00..]      ;Set output low for stimulator(s)
0130            MOVI   V2,0            ;Allow sequencer access
0131            JUMP   NEXT
0132 STIMNJ: 'Y MOVI   V2,1            ;Do not allow sequencer access
0133            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0134            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0135            MULI   V10,ms(1)       ;Multiply V10 (ms) by #clock ticks/ms, put in V10
0136            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0137            TICKS  V3              ;Record time of juice reward, stim reward must be inferred
0138            BGT    V1,V9,DOZAP     ;If length of juice more than zap delay, go to zap
0139            DELAY  V1              ;otherwise wait required msec (v1), delay is in clock ticks
0140            DIGOUT [.......0]      ;Set output low (close solenoid)
0141            DELAY  V10             ;wait for zap
0142            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0143            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0144            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0145            MOVI   V2,0            ;Allow sequencer access
0146            JUMP   NEXT
0147 DOZAP:     DELAY  V9              ;Delay stimulation
0148            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0149            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0150            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0151            DELAY  V10             ;wait to turn off juice
0152            DIGOUT [.......0]      ;Set output low (close solenoid)
0153            MOVI   V2,0            ;Allow sequencer access
0154            JUMP   NEXT
0155 KILLRW: 'K MOVI   V2,1            ;Do not allow sequencer access
0156            DIGOUT [.......0]      ;Set output low for solenoid, in case
0157            MOVI   V2,0            ;Allow sequencer access
0158            JUMP   NEXT            ;Extra DIGOUT bit for solenoid monitor
0159 LEDON: 'L  MOVI   V2,1            ;Do not allow sequencer access
0160            DIGOUT [......1.]      ;Turn LED on, LED connects to Digital Outputs 1
0161            BGT    V4,0,FLOFFW     ;If FLASH sequence exists, jump to FLASH OFF WAIT
0162            JUMP   EXITLED
0163 LEDOFF: 'M MOVI   V2,1            ;Do not allow sequencer access
0164            DIGOUT [......0.]      ;Turn LED off
0165            BGT    V8,0,FLONW      ;If FLASH sequence exists, jump to FLASH ON WAIT
0166            JUMP   EXITLED
0167 FLON:      BEQ    V4,1,LEDON      ;Start point, if flashing LED, jump to LED on
0168            JUMP   EXITLED         ;If 0 or intended light not found above, give up
0169 FLOFF:     BEQ    V4,1,LEDOFF     ;If flashing LED, jump to LED off
0170            JUMP   EXITLED         ;Just in case, should not happen
0171 FLONW:     MOVI   V7,0            ;Make sure #clock tick delays is zero
0172            BEQ    V8,0,EXITLED    ;If Flash-Allow variable 0, exit because light is already off
0173            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0174            SUB    V7,V4,-9        ;subtract # of BEQ ticks and add -9 constant ticks
0175            DELAY  V7              ;Wait for next FLASH ON
0176            DBNZ   V5,FLON         ;Decrement #repeats, continue flashing if any remain
0177            JUMP   EXITLED
0178 FLOFFW:    MOVI   V7,0            ;Make sure #clock tick delays is zero
0179            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0180            SUB    V7,V4,-8        ;subtract # of BEQ ticks and add -8 constant ticks
0181            DELAY  V7              ;Wait for next FLASH OFF
0182            JUMP   FLOFF           ;Do not decrement, jump to FLASH OFF
0183 FLSTOP: 'S DIGOUT [......0.]      ;Turn LED off
0184            JUMP   EXITLED
0185 EXITLED:   MOVI   V4,0            ;Set which light to flash to NONE
0186            MOVI   V8,0            ;Set Flash-Allow Variable to 0, disallow flashing
0187            MOVI   V2,0            ;Allow sequencer access, now done only once at end
0188            JUMP   NEXT
0189 LONGTONE: 'T MOVI V14,98          ;Putting ramp step in a variable makes SZINC easier
0190            MOVI   V15,0           ;Current amplitude of tone
0191            SZ     0,0             ;Set amplitude of tone to zero, to start, will ramp
0192            PHASE  0,-90           ;Change to sine phase
0193            ANGLE  0,0             ;Reset tone to phase 0
0194            RATE   0,V12           ;Start the tone
0195            MARK   1               ;Mark onset of tone on digital marker channel
0196            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0197 RAMPUP:    ADD    V15,V14         ;Increment current tone amplitude
0198            BGE    V15,V11,UPDONE  ;If we are finished with ramp, branch
0199            SZ     0,V15,RAMPUP    ;Increment amplitude of tone and repeat
0200 UPDONE:    SZ     0,V11           ;Set amplitude to correct value
0201            MOV    V15,V11         ;Keep actual value
0202            DELAY  V13             ;Wait through the requested duration
0203 RAMPDOWN: 't SUB  V15,V14         ;Decrement current tone amplitude
0204            BLE    V15,0,DOWNDONE  ;If we are finished with ramp, branch
0205            SZ     0,V15,RAMPDOWN  ;Decrement amplitude of tone and repeat
0206 DOWNDONE:  SZ     0,0             ;Set amplitude of tone to 0
0207            RATE   0,0             ;Stop tone
0208            MARK   0               ;Mark offset of tone on digital marker channel
0209            JUMP   NEXT
0210 SILENCE: 'U DELAY 6               ;Delay equal to LONGTONE delay
0211            MARK   1               ;Mark "onset" of silence
0212            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0213            DELAY  V13             ;Delay duration of tone
0214            DELAY  10              ;Delay duration of additional stuff in LONGTONE
0215            MARK   0               ;Mark "offset" of silence
0216            JUMP   NEXT
0217 TICKZERO: '0 TICK0                ;Set "zero" value for TICKS so we can go long
0218            JUMP   NEXT
0219 NEXT:      NOP