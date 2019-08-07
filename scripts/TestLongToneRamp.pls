;V11 is the amplitude of the tone (0-32768)
;V12 is the frequency of the tone (Degrees/step)
;V13 is the duration of the tone (Clock ticks, subtract 2)
;V14 is the step size of the ramp
;V15 is current amplitude of the tone, while ramping
                SET    0.010,1,0       ;10 microseconds per step (DON'T CHANGE), fastest possible
0000            JUMP   next
0001 PLAYTONE: 'T MOVI V14,5           ;Putting ramp step in a variable makes SZINC easier
0002            MOVI   V15,0           ;Current amplitude of tone
0003            SZ     0,0             ;Set amplitude of tone to zero, to start, will ramp
0004            PHASE  0,-90           ;Change to sine phase
0005            ANGLE  0,0             ;Reset tone to phase 0
0006            RATE   0,V12           ;Start the tone
0007            MARK   1               ;Mark onset of tone on digital marker channel
0008 RAMPUP:    ADD    V15,V14         ;Increment current tone amplitude
0009            BGE    V15,V11,UPDONE  ;If we are finished with ramp, branch
0010            SZ     0,V15,RAMPUP    ;Increment amplitude of tone and repeat
0011 UPDONE:    SZ     0,V11           ;Set amplitude to correct value
0012            MOV    V15,V11         ;Keep actual value
0013            DELAY  V13             ;Wait through the requested duration
0014 RAMPDOWN: 't SUB  V15,V14         ;Decrement current tone amplitude
0015            BLE    V15,0,DOWNDONE  ;If we are finished with ramp, branch
0016            SZ     0,V15,RAMPDOWN  ;Decrement amplitude of tone and repeat
0017 DOWNDONE:  SZ     0,0             ;Set amplitude of tone to 0
0018            RATE   0,0             ;Stop tone
0019            MARK   0               ;Mark offset of tone on digital marker channel
0020 NEXT:      NOP