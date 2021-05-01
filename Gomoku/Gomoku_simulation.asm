;====================================================================
;中断向量设置，X为中断向量，Y为中断子程序名
SET_INT MACRO X, Y
    PUSH DS
    MOV AX, 0
    MOV DS, AX
    MOV DI, X*4
    MOV AX, OFFSET Y
    MOV [DI], AX
    MOV AX, SEG Y
    MOV [DI+2], AX
    POP DS 
ENDM
;====================================================================

DATA	SEGMENT
letter			db		3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh
IO8255_MODE		equ		36H ;11mode
IO8255_A		equ		30H ;00A
IO8255_B		equ		32H ;01B
IO8255_C		equ		34H ;10C
bit			dw	 	9,9,9
IO8254_MODE    EQU       46H        ;8254控制寄存器端口地址
   ;8254计数器0端口地址 0b000h
IO8254_COUNT1  EQU       42H        ;8254计数器1端口地址
IO8254_COUNT2  EQU       44H        ;8254计数器2端口地址
I8259_1   EQU   20H     ; 8259的ICW1端口地址
I8259_2   EQU   22H     ; 8259的ICW2端口地址
I8259_3   EQU   22H      ; 8259的ICW3端口地址
I8259_4   EQU   22H      ; 8259的ICW4端口地址
O8259_1   EQU   22H       ; 8259的OCW1端口地址
O8259_2   EQU   20H       ; 8259的OCW2端口地址
O8259_3   EQU   20H       ; 8259的OCW3端口地址
DATA	ENDS

STACK SEGMENT
      DW 1024H DUP(?)
STACK ENDS


CODE	SEGMENT
		ASSUME CS:CODE, DS:DATA
START:	
   
	MOV AX, DATA
	MOV DS, AX
	MOV ES, AX
	mov	si,0
	mov	cx,0
	CLI 
	  ; 8259A初始化段代码

    SET_INT 81H, INT_1

    MOV DX, I8259_1         ;初始化8259的ICW1
    MOV AL, 13H             ;边沿触发、单片8259、需要ICW4
    OUT DX, AL
    
    MOV DX, I8259_2         ;初始化8259的ICW2
    MOV AL, 80H            
    OUT DX, AL	       
    MOV AL, 03H		    ;初始化8259的ICW4, 主片，自动EOI，8086系统
    OUT DX, AL
		 
    ;MOV DX,O8259_1     ;初始化8259的中断屏蔽操作命令字ocw1
    ;MOV AL,11111101b             ;打开IR0、IR1屏蔽位
   ; OUT DX,AL

    MOV       DX, IO8254_MODE         ;初始化8254工作方式
    MOV       AL, 00110110B           ;计数器0，方式3
    OUT       DX, AL
    ;计数器1的初值为1000(3E8H)    
     MOV       DX, IO8254_COUNT1       ;装入计数初值al 
    MOV      AX,1000  
    OUT       DX,AL
    MOV       AL, AH
    OUT       DX,AL
        
  MOV       DX, IO8254_MODE         ;初始化8254工作方式
    MOV       AL, 01110110B           ;计数器1，方式3
    OUT       DX, AL
    ;计数器1的初值为1000(3E8H)       
    MOV       DX, IO8254_COUNT1       ;装入计数初值al
    MOV       AL, 0E8H                 ;先读低八位
    OUT       DX,AL
    ;装入计数初值ah
    MOV       AL, 03H                  ;后读高八位
    OUT       DX,AL

    MOV       DX, IO8254_MODE         ;初始化8254工作方式
    MOV       AL, 10110110B           ;计数器2，方式3
    OUT       DX, AL
		
	;计数器2的初值为1000
    MOV       DX, IO8254_COUNT2       ;装入计数初值al
    MOV       AL, 0E8H                  ; 先读低第八位
    OUT       DX,AL
               ;装入计数初值ah
    MOV       AL, 03H    			 ; 后读高八位
    OUT       DX,AL
		
		
    MOV	dx,IO8255_MODE
    MOV	al,80H		; 端口A、B、C均为方式0，输出
    OUT	dx,al
    								;初始化8259、8254
        STI                         ;开中断
QUERY:  
   call CLOCK
  ; call query_8259
   JMP QUERY
	

CLOCK PROC
	;计时
	MOV	dx,IO8255_A
	MOV	al,0
	OUT	dx,al
		
	MOV	dx,IO8255_B
	MOV	al,11111110b	;S0=0,最低位数码管亮，低电平选中
	OUT	dx,al
		
	MOV	dx,IO8255_A
	MOV	si,bit[4]		;个位
	MOV	al,letter[si]	;读入一个字符段码
	OUT	dx,al			;A口输出
		
	MOV	dx,IO8255_A
	MOV	al,0
	OUT	dx,al
		
	MOV	dx,IO8255_B
	MOV	al,11111101b	;S1=0,次低位数码管亮，低电平选中
	OUT	dx,al
		
	MOV	dx,IO8255_A
	MOV	si,bit[2]		;十位
	MOV	al,letter[si]	;读入一个字符位码
	OUT	dx,al			;A口输出
	

	MOV	dx,IO8255_A
	MOV	al,0
	OUT     dx,al
		
	MOV	dx,IO8255_B
	MOV	al,11111011b	;S2=0,次低位数码管亮
	OUT	dx,al
		
	MOV	dx,IO8255_A
	MOV	si,bit[0]		;百位
	MOV	al,letter[si]	;读入一个字符段码
	OUT	dx,al			;A口输出
	RET
CLOCK ENDP
	
INT_1 PROC
	;MOV DX,O8259_3        ;向8259发送查询命令
	;MOV AL,6CH		;设置为中断查询方式
	;OUT DX,AL	
	;IN AL,DX               ;读出查询字
	;TEST AL,80H            ;判断中断是否已响应，d7是否为1
	;AND AL,07H				;保留低3位，d2、d1、d0
	;CMP AL,01H
	
	;JE IR1ISR              ;若为IR1请求，跳到IR1处理程序
	;JMP NO_SIGNAL
;IR1ISR:  
CLI
	PUSH AX
	   PUSH BX
	   PUSH CX
	   PUSH DX
	
	MOV ax,bit[4]
	CMP	ax,0
	JZ 	shiwei				;个位为0，跳转到十位
	DEC	ax						
	MOV	bit[4],ax			;个位不为0减1
	JMP	EOI					;结束中断
shiwei:
	MOV ax,bit[2]
	CMP	ax,0
	JZ 	baiwei				;十位为0，跳转到百位
	DEC	ax						
	MOV	bit[2],ax			;十位不为0减1
	MOV	bit[4],9			;个位变成9
	JMP	EOI					;结束中断
baiwei:
	MOV ax,bit[0]
	DEC	ax						
	MOV	bit[0],ax			;百位不为0减1
	MOV	bit[2],9			;十位变成9
	MOV	bit[4],9			;个位变成9
	JMP	EOI					;结束中断
EOI:  
	 POP DX
    POP CX
    POP BX
    POP AX
 STI			;开中断
    IRET 		;中断返回
INT_1 ENDP

    

CODE   ENDS
       END    START