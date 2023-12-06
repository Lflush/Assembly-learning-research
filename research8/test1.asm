; multi-segment executable file template.

data segment
    ; add your data here!
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
    mov word ptr [bx],offset INTROUT9;将INTROUPT9程序的偏移地址传入bx寻址的字单元
    mov word ptr [bx+2],seg INTROUT9;将INTROUPT9程序的段地址传入bx+2寻址的字单元
    sti;开中断
    pop bx;恢复现场 
    pop ax
    pop ds
    int 9h;调用中断处理程序9
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    
    ;输出9和换行
    INTROUT9 proc far
        push ax
        push dx
        
        mov ah,02h
        mov dl,'9'
        int 21h
        mov ah,02h
        mov dl,0dh
        int 21h
        mov ah,02h
        mov dl,0ah
        int 21h
        pop dx
        pop ax
        iret
        
    INTROUT9 endp    
ends

end start ; set entry point and stop the assembler.
