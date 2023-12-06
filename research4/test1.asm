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
    mov ah,0ah;输入字符串
    lea dx,str
    int 21h
    
    xor cx,cx
    xor si,si;si存放最小值下标
    mov cl,str+1;cx存放字符串数量
    add cx,2
    
    mov ax,2;i
    xor bx,bx;j
begin:
    cmp ax,cx
    
    jnb en
    

    mov si,ax
    mov bx,ax
    inc bx
find:    
    cmp bx,cx
    ;jb find1
    jnb swap
    
find1:
    ;mov al,str+bx
    
    mov dl,str+si
    cmp str+bx,dl
    jnb next
record:
    mov si,bx
    
next:
    inc bx
    jmp find
    
    
swap:
    
    
    mov dl,str+si
    mov di,ax
    xchg str+di,dl
    mov str+si,dl
    inc ax
    jmp begin
     
            
 en:
    
    mov di,cx
    mov str+di,'$'
    lea dx,str+2
    mov ah,9
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
