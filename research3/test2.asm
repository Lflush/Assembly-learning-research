; multi-segment executable file template.

data segment
    ; add your data here!
    LEDtable   DB 0c0h, 0f9h, 0a4h, 0b0h, 99h, 92h, 82h, 0f8h
               DB 80h, 90h, 88h, 83h, 0c6h, 0c1h, 86h, 8eh
    pt  db "c0$f9$a4$b0$99$92$82$f8$80$90$88$83$c6$c1$86$8e$"
    
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
    mov ah,1
    int 21h
    sub al,30h
    cmp al,10h
    ja t
    jna x
  
  
    
    
    
  t:sub al,7h
    cmp al,29h
    ja t1
    jna x
    
 t1:sub al,20h
    jmp x
    
  x:xor ah,ah
    
    mov bl,3
    mul bl
    
    lea dx,pt
    add dx,ax
    mov ah,9
    int 21h 
    
            
 en:lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
