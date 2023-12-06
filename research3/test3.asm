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
    mov dx,01h
    mov di,02h
    mov ax,0ffh
    mov si,0feh
    
    cmp dx,di
    ja above
    above:
    cmp ax,si
    jg greater
    greater:
    jcxz zero
    zero:
    cmp ax,si
    jo overflow
    overflow:
    cmp si,ax
    jle less_eq
    less_eq:
    cmp di,dx
    jbe below_eq 
    below_eq:        
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
