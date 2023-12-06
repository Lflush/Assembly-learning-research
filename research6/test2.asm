; multi-segment executable file template.

data segment
    ; add your data here!
    str db "justduzaada"
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
    mov ax,4
    push ax
    mov bx,2
    push bx
    call delstr
    
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    
    delstr proc near
        push bp
        mov bp,sp;栈顶
        push bx;保护现场
        push cx
        push ax
        mov cx,[bp+4];从堆栈中获得参数
        mov bx,[bp+6]
        sub bx,1;让bx在合适的位置
        
    del:
        mov ax,0
        mov str+bx,al;从bx寻址，删除字符
        inc bx;每次bx+1
        loop del;循环cx次，即删除cx个字符。
        pop ax;恢复现场
        pop cx
        pop bx 
        pop bp
        
        ret
    delstr endp    
ends

end start ; set entry point and stop the assembler.
