datas segment
	led			db		01h,02h,04h,08h,10h,20h,40h,80h
	IO8255_MODE		equ		8006H ;11mode
	IO8255_A		equ		8000H ;00A
	IO8255_B		equ		8002H ;01B
	IO8255_C		equ		8004H ;10C
datas ends

stacks	segment	stack
        dw	128 dup(?)
stacks	ends
	 
CODE    SEGMENT 
        ASSUME CS:CODE,ds:datas
START:
	mov ax,datas
	mov ds,ax		;初始化
	mov dx,IO8255_MODE
	mov al,80h		; 1000 0000 工作方式0，端口ABC输出
	out dx,al
	mov si,0
	change:
	mov si,0;
	change_loop:
	mov	dx,IO8255_A	; A端口输出亮灯对应的位为1
	mov	al,led[si]
	out	dx,al	
	inc	si			; si++
	mov	cx,0FFFFH
DELAY:
	LOOP DELAY
	cmp 	si,8
	jz	change		;计数值等于8，归0，重新计数
	jmp  change_loop
CODE    ENDS
        END START
