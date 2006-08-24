            SET    1,1,0           ; Get rate & scaling OK

E0:     '0  DIGOUT [00000001]
            DELAY  s(0.996)-1
            HALT                   ; End of this sequence section


ES:		'S	DIGOUT V1
			DELAY  s(0.996)-1
			HALT
			
EH:     'H  DIGOUT [....0011]
            DELAY  s(0.996)-1
            HALT                   ; End of this sequence section

EL:     'L  DIGOUT [....0001]
            DELAY  s(0.996)-1
            HALT                   ; End of this sequence section

EQ:     'Q  DIGOUT [01000001]
            DELAY  s(0.996)-1
            HALT                   ; End of this sequence section

EJ:     'J  DIGOUT [.......1]
            DIGOUT [.......0]
            DELAY  s(0.005)-1
            DIGOUT [.......1]
            DELAY  s(0.989)-1
            HALT                   ; End of this sequence section

