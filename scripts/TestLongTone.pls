;V11 is the amplitude of the tone (0-32768)
;V12 is the frequency of the tone (Degrees/step)
;V13 is the duration of the tone (Clock ticks, subtract 2)
                SET    0.010,1,0       ;10 microseconds per step (DON'T CHANGE), fastest possible
0000            JUMP   next
0001 PLAYTONE: 'T SZ   0,V11           ;Set amplitude of tone
0002            PHASE  0,-90           ;Change to sine phase
0003            ANGLE  0,0             ;Reset tone to phase 0
0004            RATE   0,V12           ;Start the tone
0005            MARK   1               ;Mark onset of tone on digital marker channel
0006            DELAY  V13             ;Wait through the requested duration
0007 GETOUT: 't RATEW  0,0             ;Will complete current sine cycle and then stop
0008            MARK   0               ;Mark offset of tone on digital marker channel
0009 NEXT:      NOP