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
0015 PLAYLL: 'l MOVI   V2,1            ;Do not allow sequencer access
0016            WAVEGO L,W             ;Play wave area L (parallel PWA 2)
0017 LLWAIT:    WAVEBR LLWAIT,T        ;Wait until area L begins playing
0018            MARK   1               ;Use digital marker as in long tone
0019            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0020 LXWAIT:    WAVEBR LXWAIT,S        ;Wait until area L STOPS playing
0021            DAC    0,0             ;Set DAC to 0
0022            MARK   0               ;Use digital marker as in long tone
0023            MOVI   V2,0            ;Allow sequencer access
0024            JUMP   NEXT
0025 PLAYMM: 'm MOVI   V2,1            ;Do not allow sequencer access
0026            WAVEGO M,W             ;Play wave area M (long tone PWA 1)
0027 MMWAIT:    WAVEBR MMWAIT,T        ;Wait until area M begins playing
0028            MARK   1               ;Use digital marker as in long tone
0029            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0030 MXWAIT:    WAVEBR MXWAIT,S        ;Wait until area M STOPS playing
0031            DAC    0,0             ;Set DAC to 0
0032            MARK   0               ;Use digital marker as in long tone
0033            MOVI   V2,0            ;Allow sequencer access
0034            JUMP   NEXT
0035 PLAYNN: 'n MOVI   V2,1            ;Do not allow sequencer access
0036            WAVEGO N,W             ;Play wave area N (long tone PWA 2)
0037 NNWAIT:    WAVEBR NNWAIT,T        ;Wait until area N begins playing
0038            MARK   1               ;Use digital marker as in long tone
0039            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0040 NXWAIT:    WAVEBR NXWAIT,S        ;Wait until area N STOPS playing
0041            DAC    0,0             ;Set DAC to 0
0042            MARK   0               ;Use digital marker as in long tone
0043            MOVI   V2,0            ;Allow sequencer access
0044            JUMP   NEXT
0045 PLAYOO: 'o MOVI   V2,1            ;Do not allow sequencer access
0046            WAVEGO O,W             ;Play wave area O (long tone PWA 3)
0047 OOWAIT:    WAVEBR OOWAIT,T        ;Wait until area O begins playing
0048            MARK   1               ;Use digital marker as in long tone
0049            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0050 OXWAIT:    WAVEBR OXWAIT,S        ;Wait until area O STOPS playing
0051            DAC    0,0             ;Set DAC to 0
0052            MARK   0               ;Use digital marker as in long tone
0053            MOVI   V2,0            ;Allow sequencer access
0054            JUMP   NEXT
0055 PLAYPP: 'p MOVI   V2,1            ;Do not allow sequencer access
0056            WAVEGO P,W             ;Play wave area P (long tone PWA 4)
0057 PPWAIT:    WAVEBR PPWAIT,T        ;Wait until area P begins playing
0058            MARK   1               ;Use digital marker as in long tone
0059            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0060 PXWAIT:    WAVEBR PXWAIT,S        ;Wait until area P STOPS playing
0061            DAC    0,0             ;Set DAC to 0
0062            MARK   0               ;Use digital marker as in long tone
0063            MOVI   V2,0            ;Allow sequencer access
0064            JUMP   NEXT
0065 PLAYQQ: 'q MOVI   V2,1            ;Do not allow sequencer access
0066            WAVEGO Q,W             ;Play wave area Q (long tone PWA 5)
0067 QQWAIT:    WAVEBR QQWAIT,T        ;Wait until area Q begins playing
0068            MARK   1               ;Use digital marker as in long tone
0069            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0070 QXWAIT:    WAVEBR QXWAIT,S        ;Wait until area Q STOPS playing
0071            DAC    0,0             ;Set DAC to 0
0072            MARK   0               ;Use digital marker as in long tone
0073            MOVI   V2,0            ;Allow sequencer access
0074            JUMP   NEXT
0075 PLAYA: 'A  MOVI   V2,1            ;Do not allow sequencer access
0076            WAVEGO A,W             ;Play wave area A
0077 AWAIT:     WAVEBR AWAIT,T         ;Wait until area A begins playing
0078            TICKS  V3              ;Place # of ticks at time of play into V3
0079            MOVI   V2,0            ;Allow sequencer access
0080            JUMP   NEXT
0081 PLAYB: 'B  MOVI   V2,1            ;See PLAYA
0082            WAVEGO B,W
0083 BWAIT:     WAVEBR BWAIT,T
0084            TICKS  V3
0085            MOVI   V2,0
0086            JUMP   NEXT
0087 PLAYC: 'C  MOVI   V2,1            ;See PLAYA
0088            WAVEGO C,W
0089 CWATT:     WAVEBR CWATT,T         ;note label "CWAIT" is reserved and disallowed
0090            TICKS  V3
0091            MOVI   V2,0
0092            JUMP   NEXT
0093 PLAYD: 'D  MOVI   V2,1            ;See PLAYA
0094            WAVEGO D,W
0095 DWATT:     WAVEBR DWATT,T         ;note label "DWAIT" is reserved and disallowed
0096            TICKS  V3
0097            MOVI   V2,0
0098            JUMP   NEXT
0099 PLAYE: 'E  MOVI   V2,1            ;See PLAYA
0100            WAVEGO E,W
0101 EWAIT:     WAVEBR EWAIT,T
0102            TICKS  V3
0103            MOVI   V2,0
0104            JUMP   NEXT
0105 PLAYF: 'F  MOVI   V2,1            ;See PLAYA
0106            WAVEGO F,W
0107 FWAIT:     WAVEBR FWAIT,T
0108            TICKS  V3
0109            MOVI   V2,0
0110            JUMP   NEXT
0111 PLAYS: 'G  MOVI   V2,1            ;See PLAYA
0112            WAVEGO G,W
0113 GWAIT:     WAVEBR GWAIT,T
0114            TICKS  V3
0115            MOVI   V2,0
0116            JUMP   NEXT
0117 PLAYH: 'H  MOVI   V2,1            ;See PLAYA
0118            WAVEGO H,W
0119 HWAIT:     WAVEBR HWAIT,T
0120            TICKS  V3
0121            MOVI   V2,0
0122            JUMP   NEXT
0123 PLAYI: 'I  MOVI   V2,1            ;See PLAYA
0124            WAVEGO I,W
0125 IWAIT:     WAVEBR IWAIT,T
0126            TICKS  V3
0127            MOVI   V2,0
0128            JUMP   NEXT
0129 PLAYJ: 'J  MOVI   V2,1            ;See PLAYA
0130            WAVEGO J,W
0131 JWAIT:     WAVEBR JWAIT,T
0132            TICKS  V3
0133            MOVI   V2,0
0134            JUMP   NEXT
;note that the precise output channel for CED reward is not determined pre-implementation
0135 REWARD: 'R MOVI   V2,1            ;Do not allow sequencer access
0136            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0137            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0138            TICKS  V3              ;Record time of reward
0139            DELAY  V1              ;wait required msec (v1), delay is in clock ticks
0140            DIGOUT [.......0]      ;Set output low (close solenoid)
0141            MOVI   V2,0            ;Allow sequencer access
0142            JUMP   NEXT
0143 STIM:  'Z  MOVI   V2,1            ;Do not allow sequencer access
0144            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0145            DELAY  V9              ;Delay stimulation
0146            DIGOUT [....11..]      ;Pulse output for stimulator(s), (DIGOUT 2/3)
0147            TICKS  V3              ;Record time of stimulation reward
0148            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0149            DIGOUT [....00..]      ;Set output low for stimulator(s)
0150            MOVI   V2,0            ;Allow sequencer access
0151            JUMP   NEXT
0152 STIMNJ: 'Y MOVI   V2,1            ;Do not allow sequencer access
0153            MULI   V1,ms(1)        ;Multiply V1 (ms) by #clock ticks/ms, put in V1
0154            MULI   V9,ms(1)        ;Multiply V9 (ms) by #clock ticks/ms, put in V9
0155            MULI   V10,ms(1)       ;Multiply V10 (ms) by #clock ticks/ms, put in V10
0156            DIGOUT [.......1]      ;Pulse output for reward solenoid, (DIGOUT 0)
0157            TICKS  V3              ;Record time of juice reward, stim reward must be inferred
0158            BGT    V1,V9,DOZAP     ;If length of juice more than zap delay, go to zap
0159            DELAY  V1              ;otherwise wait required msec (v1), delay is in clock ticks
0160            DIGOUT [.......0]      ;Set output low (close solenoid)
0161            DELAY  V10             ;wait for zap
0162            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0163            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0164            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0165            MOVI   V2,0            ;Allow sequencer access
0166            JUMP   NEXT
0167 DOZAP:     DELAY  V9              ;Delay stimulation
0168            DIGOUT [..1.1...]      ;Pulse output for stimulator(s), DIGOUT 3=26, 5=25 brkout tmp
0169            DELAY  ms(1)           ;wait one ms, delay is in clock ticks
0170            DIGOUT [..0.0...]      ;Set output low for stimulator(s)
0171            DELAY  V10             ;wait to turn off juice
0172            DIGOUT [.......0]      ;Set output low (close solenoid)
0173            MOVI   V2,0            ;Allow sequencer access
0174            JUMP   NEXT
0175 KILLRW: 'K MOVI   V2,1            ;Do not allow sequencer access
0176            DIGOUT [.......0]      ;Set output low for solenoid, in case
0177            MOVI   V2,0            ;Allow sequencer access
0178            JUMP   NEXT            ;Extra DIGOUT bit for solenoid monitor
0179 LEDON: 'L  MOVI   V2,1            ;Do not allow sequencer access
0180            DIGOUT [......1.]      ;Turn LED on, LED connects to Digital Outputs 1
0181            BGT    V4,0,FLOFFW     ;If FLASH sequence exists, jump to FLASH OFF WAIT
0182            JUMP   EXITLED
0183 LEDOFF: 'M MOVI   V2,1            ;Do not allow sequencer access
0184            DIGOUT [......0.]      ;Turn LED off
0185            BGT    V8,0,FLONW      ;If FLASH sequence exists, jump to FLASH ON WAIT
0186            JUMP   EXITLED
0187 FLON:      BEQ    V4,1,LEDON      ;Start point, if flashing LED, jump to LED on
0188            JUMP   EXITLED         ;If 0 or intended light not found above, give up
0189 FLOFF:     BEQ    V4,1,LEDOFF     ;If flashing LED, jump to LED off
0190            JUMP   EXITLED         ;Just in case, should not happen
0191 FLONW:     MOVI   V7,0            ;Make sure #clock tick delays is zero
0192            BEQ    V8,0,EXITLED    ;If Flash-Allow variable 0, exit because light is already off
0193            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0194            SUB    V7,V4,-9        ;subtract # of BEQ ticks and add -9 constant ticks
0195            DELAY  V7              ;Wait for next FLASH ON
0196            DBNZ   V5,FLON         ;Decrement #repeats, continue flashing if any remain
0197            JUMP   EXITLED
0198 FLOFFW:    MOVI   V7,0            ;Make sure #clock tick delays is zero
0199            ADD    V7,V6           ;add in #clock tick delays from pres_engine
0200            SUB    V7,V4,-8        ;subtract # of BEQ ticks and add -8 constant ticks
0201            DELAY  V7              ;Wait for next FLASH OFF
0202            JUMP   FLOFF           ;Do not decrement, jump to FLASH OFF
0203 FLSTOP: 'S DIGOUT [......0.]      ;Turn LED off
0204            JUMP   EXITLED
0205 EXITLED:   MOVI   V4,0            ;Set which light to flash to NONE
0206            MOVI   V8,0            ;Set Flash-Allow Variable to 0, disallow flashing
0207            MOVI   V2,0            ;Allow sequencer access, now done only once at end
0208            JUMP   NEXT
0209 HOUSEON: 'V MOVI  V2,1            ;Do not allow sequencer access
0210            DIGOUT [1.......]      ;Turn HOUSE LED on, HOUSE LED connects to Digital Outputs 7
0211            MOVI   V2,0            ;Allow sequencer access
0212            JUMP   NEXT
0213 HOUSEOFF: 'v MOVI V2,1            ;Do not allow sequencer access
0214            DIGOUT [0.......]      ;Turn HOUSE LED off
0215            MOVI   V2,0            ;Allow sequencer access
0216            JUMP   NEXT
0217 LONGTONE: 'T MOVI V14,98          ;Putting ramp step in a variable makes SZINC easier
0218            MOVI   V15,0           ;Current amplitude of tone
0219            SZ     0,0             ;Set amplitude of tone to zero, to start, will ramp
0220            PHASE  0,-90           ;Change to sine phase
0221            ANGLE  0,0             ;Reset tone to phase 0
0222            RATE   0,V12           ;Start the tone
0223            MARK   1               ;Mark onset of tone on digital marker channel
0224            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0225 RAMPUP:    ADD    V15,V14         ;Increment current tone amplitude
0226            BGE    V15,V11,UPDONE  ;If we are finished with ramp, branch
0227            SZ     0,V15,RAMPUP    ;Increment amplitude of tone and repeat
0228 UPDONE:    SZ     0,V11           ;Set amplitude to correct value
0229            MOV    V15,V11         ;Keep actual value
0230            DELAY  V13             ;Wait through the requested duration
0231 RAMPDOWN: 't SUB  V15,V14         ;Decrement current tone amplitude
0232            BLE    V15,0,DOWNDONE  ;If we are finished with ramp, branch
0233            SZ     0,V15,RAMPDOWN  ;Decrement amplitude of tone and repeat
0234 DOWNDONE:  SZ     0,0             ;Set amplitude of tone to 0
0235            RATE   0,0             ;Stop tone
0236            MARK   0               ;Mark offset of tone on digital marker channel
0237            JUMP   NEXT
0238 SILENCE: 'U DELAY 6               ;Delay equal to LONGTONE delay
0239            MARK   1               ;Mark "onset" of silence
0240            TICKS  V3              ;Note time for GetTimeOfLast1401Event()
0241            DELAY  V13             ;Delay duration of tone
0242            DELAY  10              ;Delay duration of additional stuff in LONGTONE
0243            MARK   0               ;Mark "offset" of silence
0244            JUMP   NEXT
0245 TICKZERO: '0 TICK0                ;Set "zero" value for TICKS so we can go long
0246            JUMP   NEXT
0247 NEXT:      NOP