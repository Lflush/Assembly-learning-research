; multi-segment executable file template.

data segment
    ; add your data here!
    buf dw 1234h
    divisor dw 10000,1000,100,10,1
    dlen db $-divisor
    BCD db 50 dup(0)
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
    xor si,si
    xor di,di
    
    xor ax,ax
    xor dx,dx
    xor cx,cx
    mov cl,dlen
    shr cx,1
    mov ax,buf
    
division:
    xor dx,dx
    mov bx,divisor+si
    div bx
    add si,2
    mov BCD+di,al
    inc di
    mov ax,dx
    loop division
    
    
    
            
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
