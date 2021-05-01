CODE SEGMENT
	ASSUME CS:CODE
START:  
		.386
CLI
		 MOV AX,CS
		 MOV DS,AX
		 
		 MOV DX,OFFSET INT10     
		 MOV AX,2572H		; AH=25设置中断向量，DS:DX=中断向量 AL=中断向量号=72H，设置中断向量IRQ10
         INT 21H
		 
		 MOV DX,OFFSET INT3  ; AH=25，DS:DX=中断向量 AL=中断向量号=0BH，设置中断向量IRQ3
		 MOV AX,250BH
		 INT 21H

		 IN AL,21H
		 AND AL,0F3H              
		 OUT 21H,AL

IN AL,0A1H
AND AL,0FBH              
OUT 0A1H,AL
MOV CX,10
STI

        WAIT:    JMP WAIT
        INT10:   CLI
					 PUSHAD    
					 PUSHFD    
				 MOV CX,10
		NEXT10_1:
                 MOV DX,59H    
				 MOV AH,02H            
				 INT 21H
				 MOV DX,20H    
				 MOV AH,02H            
				 INT 21H
				 
				 CALL DELAY1
				 LOOP NEXT10_1
				 
				 MOV DX,0DH    
				 MOV AH,02H            
				 INT 21H
				 MOV DX,0AH    
				 MOV AH,02H            
				 INT 21H

				 MOV AL,20H		;不懂
				 OUT 0A0H,AL
				 OUT 20H,AL
				 POPFD
				 POPAD
				 STI
				 IRET

        INT3:    CLI
				 PUSHAD
				 PUSHFD
				 MOV CX,10
		NEXT3_1:                
				 MOV DX,4EH    
				 MOV AH,02H            
				 INT 21H
				 MOV DX,20H    
				 MOV AH,02H            
				 INT 21H

				 CALL DELAY1
				 LOOP NEXT3_1
				
MOV DX,0DH    
				 MOV AH,02H            
				 INT 21H
				 MOV DX,0AH    
				 MOV AH,02H            
				 INT 21H

				 MOV AL,20H
				 OUT 20H,AL
				 OUT 0A0H,AL
				 POPFD
				 POPAD
				 STI
				 IRET
		DELAY1  PROC
				 PUSHAD
				 PUSHFD
				 MOV CX,0FH
		  DELAY_LOOP1:
				 MOV BX,0FFFFH
		  DELAY_LOOP2:
				 DEC BX
				 NOP
				 JNZ DELAY_LOOP2
				 LOOP DELAY_LOOP1
				 POPFD
				 POPAD
				 RET
		DELAY1  ENDP

		CODE ENDS
			END START
