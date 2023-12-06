; multi-segment executable file template.
logical macro lop,doprd,soprd
    local a,o,x,t,end
    push ax;保护环境
    push bx
    mov ax,doprd;将doprd的值传给ax 
    mov bx,lop
    cmp bx,0h
    jz a
    cmp bx,1h
    jz o
    cmp bx,2h
    jz x
    cmp bx,3h
    jz t
    
    a:and ax,soprd;ax和soprd相与 
    jmp end
    o:or ax,soprd;ax和soprd相或
    jmp end
    x:xor ax,soprd;ax和soprd相异或
    jmp end
    t:test ax,soprd;ax和soprd相与，但不送结果回ax，只会影响标志寄存器
    
    end:
    pop bx;恢复
    pop ax
endm


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
    logical 0,ax,bx;调用宏
            
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
