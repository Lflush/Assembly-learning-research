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
    push ds;�ȱ����ֳ���ax,bx,ds��ջ
    push ax
    push bx
    xor ax,ax;���ax
    mov ds,ax;��ax����ds
    mov bx,36;bx��ֵΪ36��9*4��9���жϴ���������
    
    cli;���ж� 
    mov word ptr [bx],offset INTROUT9;��INTROUPT9�����ƫ�Ƶ�ַ����bxѰַ���ֵ�Ԫ
    mov word ptr [bx+2],seg INTROUT9;��INTROUPT9����Ķε�ַ����bx+2Ѱַ���ֵ�Ԫ
    sti;���ж�
    pop bx;�ָ��ֳ� 
    pop ax
    pop ds
    int 9h;�����жϴ������9
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    
    ;���9�ͻ���
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
