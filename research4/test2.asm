; multi-segment executable file template.

data segment
    ; add your data here!
    bufa db 1,2,3,4,5,6,7,8,9,14,15,16,17,8,9
    bufalen db $-bufa
    bufb db 1,2,3,4,5,6,7,8,9,10,11,14,12,13,15,16,45,65,49,32
    bufblen db $-bufb
    bufc db 100 dup(0)
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
    
    
    
    
    xor di,di
    xor ax,ax
    xor bx,bx
    xor cx,cx
    mov cl,bufalen
s1:
    mov si,cx
    sub si,1 
    mov al,bufa+si

    push cx
    mov cl,bufblen
    
s2:
    mov si,cx
    sub si,1
    mov bl,bufb+si
    cmp al,bl
    jne next

    mov bufc+di,al
    inc di
    jmp n2    
    
next:    
    loop s2
n2:
    pop cx
    loop s1
    
    

    
en:        
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
