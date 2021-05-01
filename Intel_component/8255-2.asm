datas segment
	letter			db		3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh ;0-9
	IO8255_A		equ		288H
	IO8255_B		equ		289H
	IO8255_C		equ		28AH
	IO8255_MODE		equ		28BH
datas ends

stack segment
	dw 128 dup (0)
stack ends

code segment
	assume ds:datas,cs:code,ss:stack
start:
	mov	ax,datas		; 初始化
	mov	ds,ax
	mov	ax,stack
	mov	ss,ax
	mov	si,0
	mov	cx,0

	mov	dx,IO8255_MODE
	mov	al,80H		; 端口ABC方式0，输出
	out	dx,al

	mov	dx,IO8255_B
	mov	al,0FFH		;A-DP位码为1，S0-S7为1
	out	dx,al

letter_loop:
	mov	dx,IO8255_A
	mov	al,letter[si]	;读入一个字符段码
	out	dx,al			;A口输出
	inc	si			    ; si++

	push  ax
	mov	ax,si			; si = si%10
	mov	bx,10
	div	bl				;商放在AL，余数放在AH
	mov	al,ah
	mov ah,0
	mov	si,ax
	pop	ax
	
delay:
	call waitf
	jmp	letter_loop		;循环展示数字

waitf:			; 延时子程序 1,000,000微秒= 1秒，cx,dx分别为高位字、低位字
      push cx
      mov  cx,100
      mov  ah,86h
      int  15h
      pop  cx      
      ret
code ends
	end start