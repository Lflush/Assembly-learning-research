; multi-segment executable file template.

data segment
    ; add your data here!
    BCD1 dw 0906h
    BCD2 dw 0708h
    BCD3 db 10 dup(0)
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
    xor ax,ax
    xor bx,bx
    mov al,byte ptr BCD1
    add al,byte ptr BCD2
    aaa 
    mov BCD3,al
    shr ax,8
    add al,byte ptr BCD1+1
    aaa
    add al,byte ptr BCD2+1
    aaa
    mov BCD3+1,al
    mov BCD3+2,ah
    
    
    
            
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
