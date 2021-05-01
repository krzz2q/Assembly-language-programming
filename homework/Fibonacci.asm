DATAS SEGMENT
   TH DW 1; 
   str DB 0DH,0AH, 'Please input the num of fibonacci sequence required:$'
   NUM DW 0;
   str1 DB 0DH,0AH,'The $'
   str2 DB 'th Of Fibonacci Sequence is:    $'
DATAS ENDS

STACKS SEGMENT
   STACK DW 4096 DUP(?);
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS

START:
MAIN PROC FAR   
  MOV AX,DATAS  ;初始化
  MOV DS,AX
  MOV AH,09H    ;输出提示信息
  LEA DX,str
  INT 21H
  CALL get_int  ;得到输入的项数n
  MOV   NUM,AX

  XOR AX,AX  
  PUSH DS  
  PUSH AX       
  MOV SP,STACK  ;栈首指针
  MOV AX,1      ;令ax=1
FIB:
  PUSH AX;      ;压入AX，向栈压入1
  CALL Fibonacci ;

  ;输出显示
  push ax
  push bx
  push dx

  mov ah,09h
  lea dx,str1
  int 21h

  mov bx,th
  call smallbinidec

  mov ah,09h
  lea dx,str2
  int 21h 
  pop dx
  pop bx
  pop ax

  mov bx,ax   ;disp
  call binidec
  call crlf  
  inc th
  mov ax,th
  cmp ax,num
  jbe fib

  call crlf
  jmp exit

main endp  

Fibonacci proc near  ;fibonacci函数
  PUSH BP   
  MOV BP,SP  
  ADD SP,-4   
  ;ax存放fibonacci数列的值，cx存放该值是第几项 
  MOV CX,[BP+4]  ;cx=1
  CMP CX,2  
  JA CALCULATE  ;if CX > 2 :caculate
  MOV AX,1  
  ADD SP,4 
  POP BP  
  RET 2  

calculate:;sp = bp - 4 
  mov word ptr[bp-4],cx  
  dec cx  
  push cx  
  call Fibonacci   
  mov word ptr[bp-2],ax  ;save f（x-1）
  dec cx  
  push cx  ;
  call Fibonacci  
  add AX,word ptr[bp-2]   ;f（x）= f（x-1）+ f（x-2）
                          ;ax = f（x-2），word ptr[bp-2] = f（x-1）
  mov cx,word ptr[bp-4]  
  add sp,4 
  pop bp  
  ret 2  
Fibonacci endp  

binidec  proc  near 
         mov   cx, 10000d
         call  dec_div
         mov   cx, 1000d
         call  dec_div
         mov   cx, 100d
         call  dec_div
         mov   cx, 10d
         call  dec_div
         mov   cx, 1d
         call  dec_div
         ret

binidec  endp

smallbinidec  proc  near 
         mov   cx, 10d
         call  dec_div
         mov   cx, 1d
         call  dec_div
         ret

smallbinidec  endp

dec_div  proc  near
         mov   ax, bx
         mov   dx, 0
         div   cx
         mov   bx, dx
         mov   dl, al
         add   dl, 30h
         mov   ah, 2
         int   21h
         ret
dec_div  endp

CRLF PROC NEAR
         MOV AH,02H
         MOV DL,0DH
         INT 21H
         MOV AH,02H
         MOV DL,0AH
         INT 21H
         RET
CRLF ENDP

exit:
    MOV AH,4CH
    INT 21H

 ;读取100以内的整数子程序,存放到ax中
	get_int:
		push	bx
		push	cx
		push	dx
		mov		ax,0
		mov		bx,0
		mov		cx,0
		mov		dx,0
	get_char:
	;读入一个字符
        mov     ah,1        ;输入数据
        int     21h
		cmp     al,0dh	; 判断回车符
		jz		getInt_ret	;是回车跳转

        cmp     al,30h      
		jb 		get_char	;<'0'重新读
		cmp 	al,39h      
    	jbe 	read; >'0'<='9'
    	jmp 	get_char	; >'9'
    read:
	;读一个100以内的数
		mov		ah,0		;清除ax高位
        push    ax

        mov     ax,bx       ;ax<-bx
        mov     cx,10       ;10->cx
    	mul     cx          ;ax=ax*10
		mov		dx,0		
        mov		bx,ax		;bx=ax*10
        pop     ax
        
		sub		al,30h
		add		bx,ax		;bx=ax*10+al
        jmp    	get_char
	getInt_ret:
		mov		ax,bx
		pop		dx
		pop		cx
		pop		bx
		ret

CODES ENDS
    END START