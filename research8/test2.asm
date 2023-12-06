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
    push ds;�ȱ����ֳ���ax,bx,ds��ջ
    push ax
    push bx
    xor ax,ax;���ax
    mov ds,ax;��ax����ds
    mov bx,36;bx��ֵΪ36��9*4��9���жϴ���������
    
    cli;���ж� 
    mov word ptr [bx],offset judge;��judge�����ƫ�Ƶ�ַ����bxѰַ���ֵ�Ԫ
    mov word ptr [bx+2],seg judge;��judge����Ķε�ַ����bx+2Ѱַ���ֵ�Ԫ
    sti;���ж�
    pop bx;�ָ��ֳ� 
    pop ax
    pop ds
    int 9h;����9���жϳ���
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    delay proc
        push ax;�����ֳ�
        push cx
        push dx
        mov ah,86h;����bios�ж���ʱ1s
        mov cx,0000fh;cx:dx=��ʱʱ��us
        mov dx,4240h
        int 15h
        pop dx;�ָ��ֳ�
        pop cx
        pop ax
        ret 
    delay endp
    judge proc far
        call delay;����ʱ1s
        push ax;�����ֳ�
        in al,20h;�ֽ�����i/o�˿�20h->al
        shl al,1;�߼�����1λ�����λ����cf
        jnc rt;���cfΪ0����������ֱ�ӷ���
        mov al,0ffh;cfΪ1����fault����Ϊȫ1
        mov fault,al
        rt:;����
        pop ax;�ָ��ֳ�
        iret
    judge endp
ends

end start ; set entry point and stop the assembler.
