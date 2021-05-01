; ICW1写入偶地址端口，ICW2-4写入奇地址端口
; OCW2和OCW3写入偶地址端口，OCW1写入奇地址端口

I8259_1   EQU   2B0H     ; 8259的ICW1端口地址
I8259_2   EQU   2B1H     ; 8259的ICW2端口地址
I8259_3   EQU   2B1H      ; 8259的ICW3端口地址
I8259_4   EQU   2B1H      ; 8259的ICW4端口地址
O8259_1   EQU   2B1H       ; 8259的OCW1端口地址
O8259_2   EQU   2B0H       ; 8259的OCW2端口地址
O8259_3   EQU   2B0H       ; 8259的OCW3端口地址

DATA SEGMENT
 MES1   DB   ‘YOU CAN PLAY A KEY ON THE KEYBOARD!',0DH, 0AH, 24H
 MES2   DD    MES1
 MESS1 DB 'HELLO! THIS IS COMPUTER LAB    *  0  *!',0DH,0AH,'$'
 MESS2 DB 'HELLO! THIS IS COMPUTER LAB     *  1  *!',0DH,0AH,'$'
 MESS3 DB 'HELLO! THIS IS COMPUTER LAB     *  2  *!',0DH,0AH,'$'
 MESS4 DB 'HELLO! THIS IS COMPUTER LAB     *  3  *!',0DH,0AH,'$'
 MESS5 DB 'HELLO! THIS IS COMPUTER LAB     *  4  *!',0DH,0AH,'$'
 MESS6 DB 'HELLO! THIS IS COMPUTER LAB     *  5  *!',0DH,0AH,'$'
 MESS7 DB 'HELLO! THIS IS COMPUTER LAB     *  6  *!',0DH,0AH,'$'
 MESS8 DB 'HELLO! THIS IS COMPUTER LAB     *  7  *!',0DH,0AH,'$'
DATA ENDS

STACKS SEGMENT
 		DB 100 DUP(?)
STACKS ENDS
STACK1 SEGMENT STACK
        DW 256 DUP(?)
STACK1 ENDS

CODE SEGMENT
        ASSUME CS:CODE, DS:DATA, SS:STACKS, ES:DATA
.386
START:  MOV AX,DATA
         MOV DS, AX
         MOV ES, AX
         MOV AX, STACKS
         MOV SS, AX
         MOV DX, I8259_1         ;初始化8259的ICW1
         MOV AL, 00010011b         ;边沿触发、单片8259、需要ICW4
         OUT DX,AL

         MOV DX,I8259_2         ;初始化8259的ICW2
         MOV AL,0B0H            ;10110000b
         OUT DX,AL
		 
         MOV AL,03H				;初始化ICW4
         OUT DX,AL
		 
         MOV DX,O8259_1     ;初始化8259的中断屏蔽操作命令字ocw1
         MOV AL,00H             ;打开所有屏蔽位
         OUT DX,AL
      
QUERY:  MOV AH,1               ;判断是否有按键按下
         INT 16H			  ;若有按键操作（即键盘缓冲区不空），则ZF＝0，AL中存放的是输入的ASCII码，AH中存放输入字符的扩展码。若无键按下，则标志位ZF＝1。
         JNZ QUIT               ;有按键则退出
         MOV DX,O8259_3        ;向8259发送查询命令
         MOV AL,00001100b		;设置为中断查询方式
         OUT DX,AL
         IN AL,DX               ;读出查询字
         TEST AL,80H            ;判断中断是否已响应，d7是否为1
         JZ QUERY               ;没有响应则继续查询
         AND AL,07H				;保留低3位，d2、d1、d0
         CMP AL,00H
         JE IR0ISR              ;若为IR0请求，跳到IR0处理程序
         CMP AL,01H
         JE IR1ISR              ;若为IR1请求，跳到IR1处理程序
         CMP AL,02H
         JE IR2ISR              ;若为IR2请求，跳到IR2处理程序
         CMP AL,03H
         JE IR3ISR              ;若为IR3请求，跳到IR3处理程序
         CMP AL,04H
         JE IR4ISR              ;若为IR4请求，跳到IR4处理程序
         CMP AL,05H
         JE IR5ISR              ;若为IR5请求，跳到IR5处理程序
         CMP AL,06H
         JE IR6ISR              ;若为IR6请求，跳到IR6处理程序
         CMP AL,07H
         JE IR7ISR              ;若为IR7请求，跳到IR7处理程序
         JMP QUERY
IR0ISR:  MOV AX,DATA
         MOV DS,AX
         MOV DX,OFFSET MESS1     ;显示提示信息
         MOV AH,09
         INT 21H
         JMP EOI
IR1ISR:  MOV AX,DATA
         MOV DS,AX
         MOV DX,OFFSET MESS2     ;显示提示信息
         MOV AH,09
         INT 21H
         JMP EOI
IR2ISR:  MOV AX,DATA
         MOV DS,AX
         MOV DX,OFFSET MESS3     ;显示提示信息
         MOV AH,09
         INT 21H
         JMP EOI
IR3ISR:  MOV AX,DATA
         MOV DS,AX
         MOV DX,OFFSET MESS4     ;显示提示信息
         MOV AH,09
         INT 21H
         JMP EOI
IR4ISR:  MOV AX,DATA
         MOV DS,AX
         MOV DX,OFFSET MESS5     ;显示提示信息
         MOV AH,09
         INT 21H
         JMP EOI
IR5ISR:  MOV AX,DATA
         MOV DS,AX
         MOV DX,OFFSET MESS6    ;显示提示信息
         MOV AH,09
         INT 21H
         JMP EOI
IR6ISR:  MOV AX,DATA
         MOV DS,AX
         MOV DX,OFFSET MESS7     ;显示提示信息
         MOV AH,09
         INT 21H
         JMP EOI
IR7ISR:  MOV AX,DATA
         MOV DS,AX
         MOV DX,OFFSET MESS8     ;显示提示信息
         MOV AH,09
         INT 21H
EOI:  
         MOV DX,O8259_2         ;向8259发送中断结束命令
         MOV AL,00100000b        ;一般的中断结束命令
         OUT DX,AL              
         JMP QUERY
QUIT:    MOV AX,4C00H            ;结束程序退出
         INT 21H

CODE ENDS
     END START
