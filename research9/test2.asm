; multi-segment executable file template.
move macro dbuf,sop
    push ax;��������
    mov ax,sop;��sop��ֵͨ��Ѱַ��ֵ��ax
    mov dbuf,ax;��axֵ����dbuf��
    pop ax;�ָ�����
endm
data segment
    ; add your data here!
    dbuf dw 50 dup(0)
    array dw "hello world"
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
    move dbuf,10;������Ѱַ
    
    mov bx,11h
    move dbuf,bx;�Ĵ���Ѱַ
    
    move dbuf,array;ֱ��Ѱַ
     
    lea si,array
    move dbuf[2],[si];�Ĵ������Ѱַ
    
    move dbuf,array+2;���Ѱַ
    
    mov bx,1
    mov si,4
    move dbuf[si],array[bx+si];��ַ��ַѰַ
    
            
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
