; multi-segment executable file template.

data segment
    ; add your data here!
    buf dw 1234h
    pkey db "press any key...$"
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    mov ax,buf;将参数传入ax
    push ax;将参数传入堆栈
    call dis;调用dis
    call disp;调用disp

    ; add your code here
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h  
    
    dis proc near
        push ax;保存现场
        push cx
        push dx
        mov cx,4;将处理次数传入cx
        
    s:  
        
        ;cmp cx,4
        ;je cope
        ;ror ax,4
        rol ax,4;将ax循环左移4位，即从高4位开始处理
        
    cope:
        mov dx,ax;dx处理16位数
        and dl,0fh;保留dl的低4位，即每次处理的4位
        or dl,30h;+30h，转换为ASCII码
        cmp dl,39h;判断是0-9数字还是a-z字母
        jbe disp1;如果小于就直接输出 
        add dl,7;如果大于39h即dl为a-f,还要加7
    disp1:
        push ax;保存ax的值
        mov ah,02h;输出
        int 21h
        pop ax;恢复ax的值
        loop s;循环处理每4位2进制数
        pop dx;恢复现场
        pop cx
        pop ax
        
        ret
    dis endp 
    
    disp proc near
        push bp;栈顶
        mov bp,sp
        push ax;保护现场
        push dx
        push cx
        mov ax,[bp+4];取出参数
        mov cx,4
       s1:  
        
        rol ax,4
        
        mov dx,ax;dx处理16位数
        and dl,0fh;保留dl的低4位，即每次处理的4位
        or dl,30h;+30h，转换为ASCII码
        cmp dl,39h;是0-9数字还是a-z字母
        jbe disp2;如果小于就直接输出 
        add dl,7;如果大于39h即dl为a-f,还要加7
    disp2:
        push ax;保存ax的值
        mov ah,02h;输出
        int 21h
        pop ax;恢复ax的值
        loop s1;循环处理每4位2进制数
        
        
        pop cx;恢复现场
        pop dx
        pop ax
        pop bp
        
        ret
        
    disp endp
ends

end start ; set entry point and stop the assembler.
