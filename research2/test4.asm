; multi-segment executable file template.

data segment
    ; add your data here!
    BCD1 db 06h,09h 
    BCD2 db 08h,07h
    BCDlen dw $-BCD2
    BCD3 db 50 dup(10)
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
    xor cx,cx
    mov cx,BCDlen
    xor si,si
    
  s:add al,byte ptr BCD1+si
    aaa
    
    add al,byte ptr BCD2+si
    aaa 
    mov BCD3+si,al
    shr ax,8
    add si,1
    loop s
    mov BCD3+si,al
    
            
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
