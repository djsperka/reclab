                SET      0.01 1 0      ;10 microseconds per step
0000            JUMP   next
0001 PLAYS:  'S WAVEGO S               ;Play wave area S
0058 SWAIT:     WAVEBR SWAIT,T         ;Wait until area S begins playing
0059            TICKS  V1              ;Place # of ticks at time of play into V1
0006            JUMP   next
0035 NEXT:      NOP    
