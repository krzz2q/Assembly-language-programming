IO8255_MODE	   EQU   28BH
IO8255_A	   EQU   288H
IO8255_B	   EQU   289H
IO8255_C           EQU   28AH

CODE SEGMENT
	     ASSUME CS: CODE
;学号41824071，B口输入，A口输出
START:  MOV DX, IO8255_MODE      	  ;8255初始化
	  	 MOV AL, 10000010B 		  ;/端口A方式0，端口A输出，端口B方式0，端口B输入，端口C不管
	  	 OUT DX, AL
INOUT:  MOV DX, IO8255_B         ;读入数据
	  	IN AL,DX				;B口输入
	  	 MOV DX,IO8255_A        ;输出数据
		 OUT DX,AL      		 ;A口输出         
	  	 MOV DL,0FFH            ;判断是否有按键
	  	 MOV AH, 06H
	  	 INT 21H
	  	 JZ INOUT            	  ;若无,则继续
	  	 MOV AH,4CH             ;否则返回
	  	 INT 21H

CODE ENDS
	END START
