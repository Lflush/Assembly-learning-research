; multi-segment executable file template.
move macro dbuf,sop
    push ax;保护环境
    mov ax,sop;将sop的值通过寻址赋值给ax
    mov dbuf,ax;将ax值传入dbuf中
    pop ax;恢复环境
endm
data segment
    ; add your data here!
    dbuf dw 50 dup(0)
    array dw "hello world"
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
    move dbuf,10;立即数寻址
    
    mov bx,11h
    move dbuf,bx;寄存器寻址
    
    move dbuf,array;直接寻址
     
    lea si,array
    move dbuf[2],[si];寄存器间接寻址
    
    move dbuf,array+2;相对寻址
    
    mov bx,1
    mov si,4
    move dbuf[si],array[bx+si];基址变址寻址
    
            
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
