; multi-segment executable file template.

data segment
    ; add your data here!
    index db "D:\emu8086\MyBuild\index.txt",00h;索引文件
    words db "D:\emu8086\MyBuild\words.txt",00h;单词存放的文件 
    f1 dw 0
    f2 dw 0
    count db 0
    count1 db 0
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
    mov ah,3dh
    lea dx,index
    mov al,02h
    int 21h
    jc error
    mov f1,ax
    
    mov ah,3dh;打开words.txt文件
    mov al,02;读写模式
    lea dx,words
    int 21h
    jc error
    mov f2,ax
    
    ;读
    mov ah,3fh
    mov bx,f1
    mov cx,1
    lea dx,count 
    int 21h
    jc error
    
    mov ah,3fh
    mov bx,f2
    mov cx,1
    lea dx,count1 
    int 21h
    jc error
    
    mov al,0
    mov count,al
    mov count1,al
    
    mov ah,42h
    mov al,00h
    mov bx,f1
    mov cx,0
    mov dx,0
    int 21h
    jc error
    
    mov ah,42h
    mov al,00h
    mov bx,f2
    mov cx,0
    mov dx,0
    int 21h
    jc error 
    
    ;写
    mov ah,40h
    mov bx,f1
    mov cx,1
    lea dx,count
    int 21h
    jc error
    
    mov ah,40h
    lea dx,count1
    mov bx,f2
    mov cx,1
    int 21h
    jc error
    
    mov ah,3eh
    mov bx,f1
    int 21h
    jc error 
    
    mov ah,3eh
    mov bx,f2
    int 21h
    jc error
    
    error:
    
    
            
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
