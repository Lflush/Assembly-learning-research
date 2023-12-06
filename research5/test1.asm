; multi-segment executable file template.

data segment
    ; add your data here!
    buf db "assblem D DEBUG$"
    buflen db $-buf
    st db "DEBUG"
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
    cld
    lea di,buf
    xor cx,cx
    mov cl,buflen
    mov al,"D" 
find:    
    repnz scasb
    jnz no
    
    push cx
    push di
    mov cx,4
    lea si,st
    inc si
    repz cmpsb
    jz yes
    pop di
    pop cx
    jmp find
    
    
yes:
    mov ah,02h
    mov dl,'1'
    int 21h
    jmp en 
    
no:
    mov ah,02h
    mov dl,'0'
    int 21h
    
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
