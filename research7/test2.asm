; multi-segment executable file template.

data segment
    ; add your data here!
    x db 0
    n db 0
    rt dw 1
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
    mov al,4;x
    mov x,al
    mov al,4;n
    mov n,al
    call power
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h 
    
    power proc
         push ax
         push cx
         push dx
         
         xor cx,cx
         xor dx,dx
         mov ax,rt
         mov dl,x
         
         mov cl,n
         cmp cl,0
         
         jz return
         dec cl
         mov n,cl
         call power
         mov ax,rt
         mul dl
         mov rt,ax
          
         
         return:
         pop dx
         pop cx
         pop ax
        
        
        ret
    power endp   
ends

end start ; set entry point and stop the assembler.
