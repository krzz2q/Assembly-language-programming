DATA	SEGMENT
	letter			db		3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh
	IO8255_MODE		equ		28BH
	IO8255_A		equ		288H
	IO8255_B		equ		289H
	IO8255_C		equ		28AH
	bit				dw	 	9,9,9
	CHESSBOARD DB 218,13 DUP(194),191,13 DUP(195,13 DUP(197),180),192,13 DUP(193),217 	;设置棋盘的缓冲区，1是黑子，2是白子
	X DB 0										;落子坐标 x
	Y DB 0                                      ;落子坐标 y
	FLAG DB 0									;判断是否可以落子的标记，1为可以，0为不可以
	OVER DB 0									;判断是否比赛结束，CALL ISWIN 0为没有结束，1为结束。结束时，最后落子方获胜
	TEMP DB 0                          	 								;判断该下黑子还是白子，TEMP=0白子，TEMP=1黑子
	TI DB ' 1 2 3 4 5 6 7 8 9 a b c d e f',0AH,0DH,'$'					;棋盘的x,y坐标
	ERROR1 DB 'YOU CANNOT PUT HERE!',0AH,0DH,'$' 						;报错,"你不能放在这里"
	CLEAN DB 72 DUP(32),0AH,0DH,72 DUP(32),0AH,0DH,72 DUP(32),0AH,0DH,72 DUP(32),0AH,0DH,72 DUP(32),0AH,0DH,72 DUP(32),0AH,0DH,72 DUP(32),0AH,0DH,72 DUP(32),0AH,0DH,'$';更新棋盘
	PUT DB 'PLEASE INPUT THE POSITION(X Y): ',0AH,0DH,'$'				;请输入棋子的位置(x,y)
	ORDER DB 'PLEASE INPUT THE FIRST PLAYER.(0:white,1:black)',0AH,0DH,'$'	;下棋先手
	WHITEWIN DB 'WHITE PLAYER HAS WIN!',0AH,0DH,'$'						;白子赢
	BLACKWIN DB 'BLACK PLAYER HAS WIN!',0AH,0DH,'$'						;黑子赢
	PING DB 'NO PLAYER HAS WIN!',0AH,0DH,'$'

	BLACKEXIT DB 'BLACK PLAYER HAS QUIT!',0AH,0DH,'$'
	WHITEEXIT DB 'WHITE PLAYER HAS QUIT!',0AH,0DH,'$'				
	ENTER DB 0AH,0Dh,'$'						;回车换行		
DATA	ENDS

IO8254_MODE    EQU       283H        ;8254控制寄存器端口地址
IO8254_COUNT1  EQU       281H        ;8254计数器1端口地址
IO8254_COUNT2  EQU       282H        ;8254计数器2端口地址

I8259_1   EQU   2B0H     ; 8259的ICW1端口地址
I8259_2   EQU   2B1H     ; 8259的ICW2端口地址
I8259_3   EQU   2B1H      ; 8259的ICW3端口地址
I8259_4   EQU   2B1H      ; 8259的ICW4端口地址
O8259_1   EQU   2B1H       ; 8259的OCW1端口地址
O8259_2   EQU   2B0H       ; 8259的OCW2端口地址
O8259_3   EQU   2B0H       ; 8259的OCW3端口地址


CODE	SEGMENT
		ASSUME CS:CODE, DS:DATA
START:	
	MOV AX, DATA
	MOV DS, AX
	MOV ES, AX
	mov	si,0
	mov	cx,0
	CALL INITIAL								;初始化8259、8254

	MOV AL,11H									;在屏幕上显示
	MOV AH,00H
	INT 10H										;设置显示器模式640×480 2 色,清空屏幕
	CALL PRINT									;打印棋盘

	MOV DX,OFFSET ORDER							;选择先手，0：while，1：black
    MOV AH,09H										
    INT 21H
	
	mov AL,0
	MOV AH,1									
	INT 21H
	sub AL,30h
	MOV TEMP,AL

	MOV DX,OFFSET ENTER							;回车换行
    MOV AH,09H										
    INT 21H
QUERY:  
	JMP CLOCK
CHAXUN:
	MOV DX,O8259_3        ;向8259发送查询命令
    MOV AL,00001100b		;设置为中断查询方式
    OUT DX,AL	
	IN AL,DX               ;读出查询字
    TEST AL,80H            ;判断中断是否已响应，d7是否为1
    JZ QUERY               ;没有响应则继续查询
	AND AL,07H				;保留低3位，d2、d1、d0
	CMP AL,00H
	JE IR0ISR				;若为IR0请求，跳到IR0处理程序
	CMP AL,01H
    JE IR1ISR              ;若为IR1请求，跳到IR1处理程序
IR0ISR:											;GAME
	MOV DX,OFFSET PUT							;放置棋子
	MOV AH,09H									;在屏幕上显示输入的内容
	INT 21H

	MOV AH,1									;若输入的是ESC则退出
	INT 21H
	CMP AL,27									;若输入的是ESC
	JE QUIT										;退出游戏
	JMP RXY1									;否则输入坐标X Y

QUIT:											;退出游戏的信息							
	JMP QUIT_1

RXY1:											;记录坐标X Y(ASCII码)
	MOV X,AL									;记录x的坐标
	
	INT 21H										;读入间隔符
	CMP AL,27									;若是ESC则退出
	JE QUIT										;退出
	
	INT 21H										;读入y
	CMP AL,27									;若是ESC则退出
	JE QUIT										;退出
	MOV Y,AL									;记录y的坐标
	
N1:	MOV AH,07									;无回显输入
	INT 21H
	CMP AL,27									;若是ESC则退出
	JE QUIT										;退出游戏
	CMP AL,13									;若是回车则继续，否则等待回车
	JNE N1										;继续执行N1程序
	
	MOV AH,2
	MOV DL,0AH								
	INT 21H										;输出回车换行
	MOV DL,0DH									
	INT 21H										
	
	MOV FLAG,1									;flag的值为1
	CALL CHECK									;检查可否落子，将X，Y改变为真实的数值
	
	CMP FLAG,1									;可以落子
	JE THERE1									;可以落子则判断落子
	JMP EOI										;如果不可以落子则重新输入
	
THERE1:
	CALL PUTDOWN1								;落子v
	CALL ISWIN									;判断输赢，有结果则OVER=1
	CALL PRINT									;打印棋盘
	CMP OVER,1									;游戏结束																		
	JNZ EOI
END1:
	CMP TEMP,1
	JNZ	BLACK
	MOV DX,OFFSET WHITEWIN						;白子赢
	JMP END_DISPLAY
BLACK:
	MOV DX,OFFSET BLACKWIN						;黑子赢
	JMP END_DISPLAY

END2:
	MOV DX,OFFSET PING							;游戏结束的信息提示
    JMP END_DISPLAY

IR1ISR:  
    PUSH ax
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
	CMP	ax,0
	JZ 	END2				;百位为0，平局
	DEC	ax						
	MOV	bit[0],ax			;百位不为0减1
	MOV	bit[2],9			;十位变成9
	MOV	bit[4],9			;个位变成9
	JMP	EOI					;结束中断
EOI:  
    MOV DX,O8259_2         ;向8259发送中断结束命令
    MOV AL,00100000b        ;一般的中断结束命令
    OUT DX,AL              
    JMP QUERY


CLOCK:
	;计时
	MOV	dx,IO8255_A
	MOV	al,0
	OUT	dx,al
		
	MOV	dx,IO8255_B
	MOV	al,00000001b	;S0=1,最低位数码管亮
	OUT	dx,al
		
	MOV	dx,IO8255_A
	MOV	si,bit[4]		;个位
	MOV	al,letter[si]	;读入一个字符段码
	OUT	dx,al			;A口输出
		
	MOV	dx,IO8255_A
	MOV	al,0
	OUT	dx,al
		
	MOV	dx,IO8255_B
	MOV	al,00000010b	;S1=1,次低位数码管亮
	OUT	dx,al
		
	MOV	dx,IO8255_A
	MOV	si,bit[2]		;十位
	MOV	al,letter[si]	;读入一个字符端码
	OUT	dx,al			;A口输出
	

	MOV	dx,IO8255_A
	MOV	al,0
	OUT dx,al
		
	MOV	dx,IO8255_B
	MOV	al,00000100b	;S2=1,次低位数码管亮
	OUT	dx,al
		
	MOV	dx,IO8255_A
	MOV	si,bit[0]		;百位
	MOV	al,letter[si]	;读入一个字符段码
	OUT	dx,al			;A口输出
	JMP CHAXUN
	
QUIT_1 PROC 										;退出游戏的信息
	CMP TEMP,0
	JNZ	BLACK_EXIT
	MOV DX,OFFSET WHITEEXIT						;白子退出
	JMP END_DISPLAY
BLACK_EXIT:
	MOV DX,OFFSET BLACKEXIT						;黑子退出
	JMP END_DISPLAY
QUIT_1 ENDP 

;检验落子位置是否合法
CHECK PROC NEAR										;落子位置是否合法的检查信息 
	PUSH AX										;保存CPU现场
	PUSH BX
	PUSH CX
	PUSH DX
 	CMP X,'a'									;输入小于a，合法
	JL CMPDX									;则进行数字判断
	CMP X,'f'                           		;若输出大于f，不合法
	JG ERR										;报错信息
	SUB X,39 
	JMP CMPDY
CMPDX:											;X的数字判断
	CMP X,'1'                           								;输入小于1，不合法
	JL ERR										;报错信息
	CMP X,'9'										;输入小于9，不合法
	JG ERR										;报错信息
CMPDY:                                  									;输入X合法，比较Y
    CMP Y,'a'										;输入小于A，合法
	JL CMPDY1									;则进行数字判断 
	CMP Y,'f'										;输入大于F，不合法
	JG ERR 										;报错信息
	SUB Y,39 
	JMP SUBXY
CMPDY1:											;Y的数字判断
    CMP Y,'1'										;输入小于1，不合法
	JL ERR										;不合法
	CMP Y,'9'										;输入小于9，不合法
	JG ERR										;不合法							
SUBXY:
    SUB X,'1'                            		;将X改变为真实的值
	SUB Y,'1'									;将Y改变为真实的值
	MOV CX,0									;传送指令
	MOV CL,Y
	MOV BX,0									;清空寄存器
MULX1: 
    ADD BL,15										;棋子右移15单位
    LOOP MULX1										;循环MULX1
	ADD BL,X										;棋子右移输入Y的值
	CMP CHESSBOARD[BX],1                 			;若此处已有棋子，输入不合法
	JE ERR							
	CMP CHESSBOARD[BX],2							;若此处没有棋子，输入合法
	JNE RETURNC 
ERR:
    MOV FLAG,0                           								;对于不合法的输入，显示错误信息
	MOV DX,OFFSET ERROR1
	MOV AH,09H									;在屏幕上显示输入错误的信息
    INT 21H
RETURNC:
    POP DX										;恢复CPU现场
    POP CX
    POP BX
    POP AX
	RET										;子程序结束返回
CHECK ENDP

END_DISPLAY  PROC NEAR												
    MOV AH,09H									
    INT 21H
	MOV AH,4CH									;退出游戏
	INT 21H
	ret
END_DISPLAY ENDP
;落子子程序
PUTDOWN1 PROC NEAR									;单机落子的信息提示					
	PUSH AX										;保存CPU现场
	PUSH BX
	PUSH CX
	PUSH DX
	MOV CX,0									;字符指针初始化
	MOV CL,Y
	MOV BX,0									;清空寄存器
MULX2: 
	ADD BL,15									;字符指针右移15个字节，行
	LOOP MULX2									;循环MULX2
	ADD BL,X										;字符指针右移Y个字节，列
	CMP TEMP,1                         	 			;根据TEMP值，轮流放置黑子和白子
	JE MM1
	MOV CHESSBOARD[BX],2						;放白子
	MOV TEMP,1									;根据TEMP值，轮流放置黑子和白子
	JMP YY1
MM1:											;TEMP=1
    MOV CHESSBOARD[BX],1						;放黑子
    MOV TEMP,0										
YY1:	
    POP DX										;恢复CPU现场	
	POP CX
	POP BX
	POP AX
	RET										;子程序结束返回
PUTDOWN1 ENDP
 	
;判断是否获胜
ISWIN PROC NEAR										;获胜的信息提示
    MOV X,0										;初始化X和Y
    MOV Y,0
LOOPY:
    MOV CX,0										;字符指针初始化
	MOV CL,Y
	MOV BX,0									;清空寄存器
MULX3: 
    ADD BL,15									;字符指针右移15个字节
	LOOP MULX3									;循环MULX3
	ADD BL,X                           			;BX=15*X+Y

	MOV DL,CHESSBOARD[BX]  
	CMP DL,1 
	JE  PANDUAN   
	CMP DL,2      																	
	JE PANDUAN									;判断是否可以连成5个
	JMP NEXT									;进入下一轮判断

PANDUAN: 										;游戏胜利的判断
    CALL TEST1                          		;横着
	CMP OVER,1									;横着连成5个游戏结束
	JE RETURNISWIN									;返回胜利的判断
	CALL TEST2                         				;竖着
    CMP OVER,1										;竖着连成5个游戏结束
	JE RETURNISWIN									;返回胜利的判断
	CALL TEST3                          								;斜上
	CMP OVER,1									;斜上连成5个游戏结束
	JE RETURNISWIN									;返回胜利的判断
	CALL TEST4                          								;斜下
    CMP OVER,1										;斜下连成5个游戏结束
	JE RETURNISWIN									;返回胜利的判断
NEXT: 
    INC Y											;Y的字符指针右移
	CMP Y,15										;比较Y的值
	JNE LOOPY
	MOV Y,0											;初始化Y的值
	INC X											;X的字符指针右移
	CMP X,15										;比较X的值
	JNE LOOPY
RETURNISWIN:
    RET											
ISWIN ENDP

;判断横向是否连成5个
TEST1 PROC NEAR										
    PUSH BX										
    CMP Y,10	 									;Y>10横向不能连成5个
    JG RETURN1										
    CMP DL,CHESSBOARD[BX+1]							;判断棋盘横向是否有2个棋子连在一起
    JNE RETURN1
    CMP DL,CHESSBOARD[BX+2]							;判断棋盘横向是否有3个棋子连在一起
    JNE RETURN1 
    CMP DL,CHESSBOARD[BX+3]							;判断棋盘横向是否有4个棋子连在一起
    JNE RETURN1
    CMP DL,CHESSBOARD[BX+4]							;判断棋盘横向是否有5个棋子连在一起
    JNE RETURN1
    MOV OVER,1										;游戏结束
RETURN1: 
    POP BX										
    RET											
TEST1 ENDP

;判断纵向是否连成5个
TEST2 PROC NEAR										
   PUSH BX										
   CMP X,10										;X>10纵向不能连成5个
   JG RETURN2										
   CMP DL,CHESSBOARD[BX+15]						;判断棋盘纵向是否有2个棋子连在一起
   JNE RETURN2
   CMP DL,CHESSBOARD[BX+30]						;判断棋盘纵向是否有3个棋子连在一起
   JNE RETURN2
   CMP DL,CHESSBOARD[BX+45]						;判断棋盘纵向是否有4个棋子连在一起
   JNE RETURN2
   CMP DL,CHESSBOARD[BX+60]						;判断棋盘纵向是否有5个棋子连在一起
   JNE RETURN2
   MOV OVER,1   								;游戏结束
RETURN2: 
   POP BX
   RET											
TEST2 ENDP

;判断斜上是否连成5个
TEST3 PROC NEAR										
   PUSH BX										
   CMP X,4		      								;X<4斜上不能连成5个                																	
   JL RETURN3										
   CMP Y,4											;Y<4纵向不能连成5个
   JL RETURN3
   CMP DL,CHESSBOARD[BX-14]							;判断棋盘斜上是否有2个棋子连在一起
   JNE RETURN3
   CMP DL,CHESSBOARD[BX-28]							;判断棋盘斜上是否有3个棋子连在一起
   JNE RETURN3
   CMP DL,CHESSBOARD[BX-42]							;判断棋盘斜上是否有4个棋子连在一起
   JNE RETURN3
   CMP DL,CHESSBOARD[BX-56]							;判断棋盘斜上是否有5个棋子连在一起
   JNE RETURN3
   MOV OVER,1   									;游戏结束
RETURN3: 
   POP BX
   RET											
TEST3 ENDP

;判断斜下是否连成5个
TEST4 PROC NEAR										
   PUSH BX										
   CMP X,10											;X>10斜下不能连成5个
   JG RETURN4										
   CMP Y,10											;Y>10斜下不能连成5个
   JG RETURN4         								
   CMP DL,CHESSBOARD[BX+16]							;判断棋盘斜下是否有2个棋子连在一起 
   JNE RETURN4
   CMP DL,CHESSBOARD[BX+32]							;判断棋盘斜下是否有3个棋子连在一起
   JNE RETURN4
   CMP DL,CHESSBOARD[BX+48]							;判断棋盘斜下是否有4个棋子连在一起
   JNE RETURN4
   CMP DL,CHESSBOARD[BX+64]							;判断棋盘斜下是否有5个棋子连在一起
   JNE RETURN4
   MOV OVER,1   									;游戏结束																		
RETURN4: 
   POP BX
   RET											
TEST4 ENDP 	 


;打印棋盘
PRINT PROC NEAR										;打印棋盘
	PUSH SI
	PUSH AX										
	PUSH DX
	MOV AH,02H										;使用10H中断的设置光标位置功能
	MOV DL,00H										;光标从0,0开始
    MOV DH,00H										;光标的列坐标
    INT 10H	
    MOV DX,OFFSET TI								;指定字符串  
    MOV AH,09H										;屏幕显示字符串
    INT 21H
	MOV X,0											;初始化X Y SI
	MOV Y,0
	MOV SI,0
LOOP2: 
    CMP Y,0											;判断Y是否为0
    JNE NOTHEAD
    MOV DL,X
    ADD DL,31H										;X的字符指针右移
	CMP DL,'9'										;判断X是否大于等于9
	JLE PP
	ADD DL,39										;X的字符指针右移39个字节 
PP:
    MOV AH,02H
    INT 21H											;使用21H中断的输出字符功能
NOTHEAD:
    MOV DL,CHESSBOARD[SI]
    MOV AH,02H
	INT 21H
	INC SI											;SI、Y指针同时右移1个字节，指向下一个字符
	INC Y											;SI、Y指针同时右移1个字节，指向下一个字符
	CMP Y,15										;判断Y的大小
	JE NEXTLINE
	MOV DL,'-'										;输出一个'-'
	MOV AH,02H										;使用21H中断的输出字符功能
	INT 21H
	JMP LOOP2										;回到循环2
NEXTLINE:
    MOV DL,32
    MOV AH,02H
	INT 21H
	MOV DL,0AH										;输出一个回车符（0AH）
	MOV AH,02H										;使用21H中断的输出字符功能
	INT 21H	
	MOV DL,0DH										;输出一个换行符（0AD）
	MOV AH,02H										;使用21H中断的输出字符功能
	INT 21H
    INC X											;X的字符指针右移1个字节
	MOV Y,0											;初始化Y
    CMP X,15
	JNE LOOP2
    MOV DX,OFFSET CLEAN								;更新屏幕的信息提示
    MOV AH,09H										;使用21H中断的显示字符串功能
    INT 21H
    MOV AH,02H										;使用10H中断的设置光标位置功能
	MOV DL,00H										;光标从0,17开始
    MOV DH,10H										;设置光标的列坐标
	INT 10H	
	POP DX											
	POP AX
	POP SI
	RET												
PRINT ENDP 	

INITIAL PROC NEAR
    MOV DX, I8259_1         ;初始化8259的ICW1
    MOV AL, 00010011b         ;边沿触发、单片8259、需要ICW4
    OUT DX,AL

    MOV DX,I8259_2         ;初始化8259的ICW2
    MOV AL,0B0H            ;10110000b
    OUT DX,AL
		 
    MOV AL,03H				;初始化ICW4
    OUT DX,AL
		 
    MOV DX,O8259_1     ;初始化8259的中断屏蔽操作命令字ocw1
    MOV AL,11111100b             ;打开IR0、IR1
    OUT DX,AL

	MOV       DX, IO8254_MODE         ;初始化8254工作方式
    MOV       AL, 00110110B           ;计数器0，方式3
    OUT       DX, AL
    ;计数器1的初值为1000(3E8H)       
    MOV       DX, IO8254_COUNT1     ;装入计数初值al
    MOV       AL, 0E8H                 ;先读低八位
    OUT       DX,AL
    ;装入计数初值ah
    MOV       AL, 03H                  ;后读高八位
    OUT       DX,AL

    MOV       DX, IO8254_MODE         ;初始化8254工作方式
    MOV       AL, 01110110B           ;计数器1，方式3
    OUT       DX, AL
		
	;计数器2的初值为1000
    MOV       DX, IO8254_COUNT2     ;装入计数初值al
    MOV       AL, 0E8H                  ; 先读低第八位
    OUT       DX,AL
               ;装入计数初值ah
    MOV       AL, 03H    			 ; 后读高八位
    OUT       DX,AL
		
	MOV	dx,IO8255_MODE
	MOV	al,80H		; 端口A、B、C均为方式0，输出
	OUT	dx,al
	RET												

CODE   ENDS
       END    START