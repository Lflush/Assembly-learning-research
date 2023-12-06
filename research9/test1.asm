; multi-segment executable file template.
logical macro lop,doprd,soprd
    local a,o,x,t,end
    push ax;��������
    push bx
    mov ax,doprd;��doprd��ֵ����ax 
    mov bx,lop
    cmp bx,0h
    jz a
    cmp bx,1h
    jz o
    cmp bx,2h
    jz x
    cmp bx,3h
    jz t
    
    a:and ax,soprd;ax��soprd���� 
    jmp end
    o:or ax,soprd;ax��soprd���
    jmp end
    x:xor ax,soprd;ax��soprd�����
    jmp end
    t:test ax,soprd;ax��soprd���룬�����ͽ����ax��ֻ��Ӱ���־�Ĵ���
    
    end:
    pop bx;�ָ�
    pop ax
endm


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
    logical 0,ax,bx;���ú�
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h      
    
ends

end start ; set entry point and stop the assembler.
