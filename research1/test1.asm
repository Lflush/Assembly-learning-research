; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
ends

stacksg segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here
    mov al,99
    mov bl,99
    mov cl,99
    mov dl,99
    mov dh,0
    
    adc dl,al
    adc dh,0
    adc dl,bl
    adc dh,0
    adc dl,cl
    adc dh,0
    
            
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
