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
        mov bp,sp;ջ��
        push bx;�����ֳ�
        push cx
        push ax
        mov cx,[bp+4];�Ӷ�ջ�л�ò���
        mov bx,[bp+6]
        sub bx,1;��bx�ں��ʵ�λ��
        
    del:
        mov ax,0
        mov str+bx,al;��bxѰַ��ɾ���ַ�
        inc bx;ÿ��bx+1
        loop del;ѭ��cx�Σ���ɾ��cx���ַ���
        pop ax;�ָ��ֳ�
        pop cx
        pop bx 
        pop bp
        
        ret
    delstr endp    
ends

end start ; set entry point and stop the assembler.
