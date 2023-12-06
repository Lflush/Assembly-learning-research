; multi-segment executable file template.

data segment
    ; add your data here!
    str db 100
    db 0
    db 100 dup(0)
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
    lea di,str+1
    mov al,10
    stosb
    call inputs
    
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    
    inputs proc
        push cx
        push ax
        xor cx,cx
        mov cl,str+1
        s:
        call inp
        stosb 
        loop s
        pop ax 
        pop cx
        
        ret
    inputs endp
    
    inp proc
        
        mov ah,01h
        int 21h
        
        
        ret
    inp endp
ends

end start ; set entry point and stop the assembler.
