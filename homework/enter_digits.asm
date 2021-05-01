
;每行输入一个100以内的数，回车结束
data segment
    str_input   db  0dh,0ah,'Please input 15 numbers within 100 ',0dh,0ah,'$';输入提示
    numbers     db  15 dup(?);存放15个100以内的数
    count       equ 15
data ends

code segment 
    start:
        assume  cs:code, ds:data
        mov     ax, data
        mov     ds, ax      ;初始化ds寄存器
        mov     dx,0        ;初始化dx
        mov     bx,0        ;初始化bx
        push    dx
        lea     dx,str_input
        mov     ah,9        ;输出提示信息
        int     21h
        pop     dx
        mov     cx,count       ;循环输入15个100以内的数
	loop_input:
        call    get_int
        mov     numbers[bx],al
        inc     bx
        loop    loop_input
        mov     bx,0
    sort_process:
        call    sort
        mov     ah,4ch
        int     21h

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

    ;在屏幕上显示排序过程子程序,入口参数为numbers
    display_process:
        push    bx
        push    cx
        push    dx
        mov     bx,offset numbers  ;bx存放首元素地址
        mov     cx,count
    display_number: 
        mov     ax,0            ;清0  
        mov     al,[bx]             

        push    bx
        push    cx
        push    dx
        mov     bx,0            ;记录压栈次数
    loop_transform:
        mov     cx,10
        mov     dx,0
        div     cx          ;dx存放余数,ax存放商
        mov     cx,ax       
        push    dx          ;压栈存放字符
        inc     bx
        jcxz    ending      ;商为0，求值结束
        jmp     loop_transform
    ending:
        mov     cx,bx       ;输出次数   
    print:
        pop     dx
        push    ax          ;输出一个字符
        add     dx,30h 
        mov     ah,02h
        int     21h
        pop     ax
        loop    print

        pop     dx
        pop     cx
        pop     bx

        mov     dl,' '      ;输出空格
        mov     ah,02h
        int     21h
        inc     bx          ;更新bx，指向下一个元素
        loop    display_number ;输出所有元素

        mov     dl,0dh      ;输出换行
        mov     ah,02h
        int     21h
        mov     dl,0ah      
        mov     ah,02h
        int     21h
        pop     dx
        pop     cx
        pop     bx
        ret   

    ;冒泡排序子程序,入口参数为numbers
    sort:
        push    cx
        push    dx
        push    bx
        push    ax
        mov     cx,count    ;cx<-元素个数
        dec     cx          ;元素个数-1为外循环次数
    out_loop:    
        mov     dx,cx       ;dx<-内循环次数
        mov     bx,offset numbers  ;从首元素开始
    in_loop:    
        mov     al,[bx]     ;取前一个元素
        cmp     al,[bx+1]   ;与后一个元素比较
        jna     next        ;前一个元素不大于后一个元素，则不交换
        XCHG    al,[bx+1]   ;否则进行交换 
        mov     [bx],al     ;更新数据段中的值
    next:
        inc     bx          ;更新bx，指向下一个元素
        dec     dx          ;内循环次数减1
        jnz     in_loop          ;内循环次数不为0,继续内循环
        call    display_process;显示一次外循环结束后的数字
        loop    out_loop         ;cx不为0，继续外循环
        pop     ax
        pop     bx
        pop     dx
        pop     cx
        ret
code ends
end start