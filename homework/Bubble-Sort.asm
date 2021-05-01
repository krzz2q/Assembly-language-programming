;每行输入一个16位的二进制数

data segment
    str_input   db  0dh,0ah,'Please input  a 16 bit binary number $ ';输入提示
    str_error   db  0dh,0ah,'Input error, please re-enter the 16 bit binary number $';输入错误提示
    output      db  0dh,0ah,'The 1-16 bits of the binary number are divided into 4 groups from low to high, which are respectively stored in DL, Cl, BL and Al registers ',0dh,0ah,'$';输出缓冲区
    output1     db  '1 to 4 bit:','$'
    output2     db  '5 to 8 bit:','$'
    output3     db  '9 to 12 bit:','$'
    output4     db  '13 to 16 bit:','$'
    bit1        db  4 dup(?),0dh,0ah,'$'
    bit2        db  4 dup(?),0dh,0ah,'$'
    bit3        db  4 dup(?),0dh,0ah,'$'
    bit4        db  4 dup(?),0dh,0ah,'$'
data ends

code segment 
    start:
        assume  cs:code, ds:data
        mov     ax, data
        mov     ds, ax      ;初始化ds寄存器
        mov     dx,0        ;初始化dx
        push    dx
        lea     dx,str_input
        mov     ah,9        ;输出提示信息
        int     21h
        pop     dx
        mov     cx,16       ;循环输入16位的二进制数
    loop_input:
        mov     ah,1        ;输入数据
        int     21h
        sub     al,30h      ;ascii码转为数字
        cmp     al,01h      
        jz      read1       ;输入的是1，进入read1
        cmp     al,0     
        jz      read0       ;输入的是0或1,进入read0
        push    dx          ;输入的不是0或1,进入异常处理程序
        lea     dx,str_error;输入的数不是0或1重新输入该16位二进制数
        mov     ah,9        ;输出提示信息
        int     21h
        pop     dx
        mov     cx,16       ;初始化，重新循环输入16位的二进制数
        jmp     loop_input
    read1:
        push    ax
        push    cx
        xor     bx,bx       ;清0
        mov     bl,al       ;al->bx
        dec     cx
        shl     bx,cl       ;bx中的值左移cl位
        add     dx,bx       ;结果加到dx中，暂存16位二进制数
        pop     cx
        pop     ax
    read0:
        loop    loop_input
    process:
        mov     ax,dx       ;16位二进制数存放在AX中
        push    ax
        and     al,0fh      ;保留低4位
        xor     dl,dl       ;清0
        mov     dl,al       ;dl存放低1-4位
        pop     ax

        push    ax
        shr     al,4        ;保留高4位
        xor     cl,cl       ;清0
        mov     cl,al       ;cl存放5-8位
        pop     ax

        push    ax
        and     ah,0fh      ;保留低4位
        xor     bl,bl       ;清0
        mov     bl,ah       ;bl存放9-12位
        pop     ax

        
        shr     ah,4        ;保留高4位
        xor     al,al       ;清0
        mov     al,ah       ;al存放13-16位 
        

        push    dx
        shr     dl,3        ;保留第4位
        add     dl,30h      ;数字转ascii码
        mov     bit1,dl
        pop     dx

        push    dx
        shr     dl,2        ;保留第3位
        and     dl,1        ;保留第3位
        add     dl,30h      ;数字转ascii码
        mov     [bit1+1],dl
        pop     dx

        push    dx
        shr     dl,1        ;保留第2位
        and     dl,1        ;保留第2位
        add     dl,30h      ;数字转ascii码
        mov     [bit1+2],dl
        pop     dx

        push    dx
        and     dl,1        ;保留第1位
        add     dl,30h      ;数字转ascii码
        mov     [bit1+3],dl
        pop     dx

        push    cx
        shr     cl,3        ;保留第4位
        add     cl,30h      ;数字转ascii码
        mov     bit2,cl
        pop     cx

        push    cx
        shr     cl,2        ;保留第3位
        and     cl,1        ;保留第3位
        add     cl,30h      ;数字转ascii码
        mov     [bit2+1],cl
        pop     cx

        push    cx
        shr     cl,1        ;保留第2位
        and     cl,1        ;保留第2位
        add     cl,30h      ;数字转ascii码
        mov     [bit2+2],cl
        pop     cx
        
        push    cx
        and     cl,1        ;保留第1位
        add     cl,30h      ;数字转ascii码
        mov     [bit2+3],cl
        pop     cx

        push    bx
        shr     bl,3        ;保留第4位
        add     bl,30h      ;数字转ascii码
        mov     bit3,bl
        pop     bx

        push    bx
        shr     bl,2        ;保留第3位
        and     bl,1        ;保留第3位
        add     bl,30h      ;数字转ascii码
        mov     [bit3+1],bl
        pop     bx

        push    bx
        shr     bl,1        ;保留第2位
        and     bl,1        ;保留第2位
        add     bl,30h      ;数字转ascii码
        mov     [bit3+2],bl
        pop     bx

        push    bx
        and     bl,1        ;保留第1位
        add     bl,30h      ;数字转ascii码
        mov     [bit3+3],bl
        pop     bx

        push    ax
        shr     al,3        ;保留第4位
        add     al,30h      ;数字转ascii码
        mov     bit4,al
        pop     ax

        push    ax
        shr     al,2        ;保留第3位
        and     al,1        ;保留第3位
        add     al,30h      ;数字转ascii码
        mov     [bit4+1],al
        pop     ax

        push    ax
        shr     al,1        ;保留第2位
        and     al,1        ;保留第2位
        add     al,30h      ;数字转ascii码
        mov     [bit4+2],al
        pop     ax

        push    ax
        and     al,1        ;保留第1位
        add     al,30h      ;数字转ascii码
        mov     [bit4+3],al
        pop     ax
    print_result:
        push    dx
        lea     dx,output 
        mov     ah,9        ;输出提示信息
        int     21h
        pop     dx

        push    dx
        lea     dx,output1 
        mov     ah,9        ;输出1-4位提示信息
        int     21h
        pop     dx

        push    dx
        lea     dx,bit1 
        mov     ah,9        ;输出1-4位
        int     21h
        pop     dx

        
        push    dx
        lea     dx,output2 
        mov     ah,9        ;输出5-8位提示信息
        int     21h
        pop     dx

        push    dx
        lea     dx,bit2
        mov     ah,9        ;输出5-8位
        int     21h
        pop     dx

        push    dx
        lea     dx,output3 
        mov     ah,9        ;输出9-12位提示信息
        int     21h
        pop     dx

        push    dx
        lea     dx,bit3
        mov     ah,9        ;输出9-12位
        int     21h
        pop     dx

        push    dx
        lea     dx,output4 
        mov     ah,9        ;输出13-16位提示信息
        int     21h
        pop     dx

        push    dx
        lea     dx,bit4
        mov     ah,9        ;输出13-16位
        int     21h
        pop     dx
code ends
end start
