; multi-segment executable file template.
movestr macro strN,dstr,sstr
    push cx;保护环境
    push si
    push di
    lea si,sstr;将sstr即源串的地址赋值给si
    lea di,dstr;将dstr即目的串的地址赋值给di
    mov cx,strN;将传输字符串的长度赋值给cx
    s:
    movsb
    loop s
    pop di;恢复环境
    pop si
    pop cx
endm
data segment
    ; add your data here!
    sstr db "hello world!"
    dstr db 50 dup(0)
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
    movestr 10,dstr,sstr
            
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
