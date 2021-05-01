IO8254_MODE  	EQU   283H     ;8254控制寄存器端口地址
IO8254_COUNT0	EQU   280H     ;8254计数器0端口地址
IO8254_COUNT1	EQU   281H     ;8254计数器1端口地址
IO8254_COUNT2	EQU   282H     ;8254计数器2端口地址
                            
STACK1 SEGMENT STACK
        DW 256 DUP(?)
STACK1 ENDS
CODE SEGMENT
        ASSUME CS:CODE
START: MOV DX, IO8254_MODE       ;初始化8254工作方式
       MOV AL,00010001b         ;计数器0，方式0
	   ;MOV AL,00010111b  计数器0，方式3
       OUT DX, AL
                
       MOV DX,280H       ;装入计数初值
       MOV AL,5
       OUT DX,AL

       MOV AX,4C00H               ;返回到DOS
       INT 21H
       
CODE ENDS
     END START
