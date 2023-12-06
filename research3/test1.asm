; multi-segment executable file template.

data segment
    ; add your data here!
    bufx db 02h
    bufy db 01h
    bufz db 01h
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
    mov al,bufx
    mov bl,bufy
    
    cmp al,bl
    jz c1
cp2:mov bl,bufz
    cmp al,bl
    jz c2
cp3:mov al,bufy
    cmp al,bl
    jz c3
    
    jmp en
    
    
     
 c1:inc cx
    jmp cp2
    
 c2:inc cx
    jmp en
    
 c3:inc cx
       
    
    
            
 en:add cl,30h
    mov ah,02h
    mov dl,cl
    int 21h
    
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
