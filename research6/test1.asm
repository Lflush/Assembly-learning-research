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
    mov ax,buf;����������ax
    push ax;�����������ջ
    call dis;����dis
    call disp;����disp

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
        push ax;�����ֳ�
        push cx
        push dx
        mov cx,4;�������������cx
        
    s:  
        
        ;cmp cx,4
        ;je cope
        ;ror ax,4
        rol ax,4;��axѭ������4λ�����Ӹ�4λ��ʼ����
        
    cope:
        mov dx,ax;dx����16λ��
        and dl,0fh;����dl�ĵ�4λ����ÿ�δ����4λ
        or dl,30h;+30h��ת��ΪASCII��
        cmp dl,39h;�ж���0-9���ֻ���a-z��ĸ
        jbe disp1;���С�ھ�ֱ����� 
        add dl,7;�������39h��dlΪa-f,��Ҫ��7
    disp1:
        push ax;����ax��ֵ
        mov ah,02h;���
        int 21h
        pop ax;�ָ�ax��ֵ
        loop s;ѭ������ÿ4λ2������
        pop dx;�ָ��ֳ�
        pop cx
        pop ax
        
        ret
    dis endp 
    
    disp proc near
        push bp;ջ��
        mov bp,sp
        push ax;�����ֳ�
        push dx
        push cx
        mov ax,[bp+4];ȡ������
        mov cx,4
       s1:  
        
        rol ax,4
        
        mov dx,ax;dx����16λ��
        and dl,0fh;����dl�ĵ�4λ����ÿ�δ����4λ
        or dl,30h;+30h��ת��ΪASCII��
        cmp dl,39h;��0-9���ֻ���a-z��ĸ
        jbe disp2;���С�ھ�ֱ����� 
        add dl,7;�������39h��dlΪa-f,��Ҫ��7
    disp2:
        push ax;����ax��ֵ
        mov ah,02h;���
        int 21h
        pop ax;�ָ�ax��ֵ
        loop s1;ѭ������ÿ4λ2������
        
        
        pop cx;�ָ��ֳ�
        pop dx
        pop ax
        pop bp
        
        ret
        
    disp endp
ends

end start ; set entry point and stop the assembler.
