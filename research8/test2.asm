; multi-segment executable file template.

data segment
    ; add your data here!
    fault db 0
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

    ; add your code here
    push ds;先保护现场，ax,bx,ds入栈
    push ax
    push bx
    xor ax,ax;清空ax
    mov ds,ax;将ax移入ds
    mov bx,36;bx赋值为36即9*4，9号中断处理程序入口
    
    cli;关中断 
    mov word ptr [bx],offset judge;将judge程序的偏移地址传入bx寻址的字单元
    mov word ptr [bx+2],seg judge;将judge程序的段地址传入bx+2寻址的字单元
    sti;开中断
    pop bx;恢复现场 
    pop ax
    pop ds
    int 9h;调用9号中断程序
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    delay proc
        push ax;保护现场
        push cx
        push dx
        mov ah,86h;调用bios中断延时1s
        mov cx,0000fh;cx:dx=延时时间us
        mov dx,4240h
        int 15h
        pop dx;恢复现场
        pop cx
        pop ax
        ret 
    delay endp
    judge proc far
        call delay;先延时1s
        push ax;保护现场
        in al,20h;字节输入i/o端口20h->al
        shl al,1;逻辑左移1位即最高位移入cf
        jnc rt;如果cf为0，则不做操作直接返回
        mov al,0ffh;cf为1，则将fault设置为全1
        mov fault,al
        rt:;返回
        pop ax;恢复现场
        iret
    judge endp
ends

end start ; set entry point and stop the assembler.
