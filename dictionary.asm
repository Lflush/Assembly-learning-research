; multi-segment executable file template.
;press esc to exit         			; �������Ͼ�궨��
scroll    macro     n,ulr,ulc,lrr,lrc,att	;�궨��
    push ax
    push bx
    push cx
    push dx
    mov ah,6				;�������Ͼ�
    mov al,n		;n=�Ͼ�������n=0ʱ���������ڿհ�
    mov ch,ulr		;���Ͻ��к�
    mov cl,ulc		;���Ͻ��к�
    mov dh,lrr		;���½��к�
    mov dl,lrc		;���½��к�
    mov bh,att		;����������
    int 10h
    pop dx
    pop cx
    pop bx
    pop ax
endm

curse     macro     cury,curx
    push ax
    push bx
    push dx    
    mov       ah,2		     ;�ù��λ��
    mov       dh,cury		;�к�
    mov       dl,curx		;�к�
    mov       bh,0			;��ǰҳ
    int       10h
    pop dx
    pop bx
    pop ax
endm

;�ƶ��ļ���дָ��
rw macro file,way,devia
    push ax
    push bx
    push cx
    push dx
    
    mov ah,42h
    mov al,way
    mov bx,file
    mov cx,0
    mov dx,devia
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
endm

success macro
    ;��ʾ�޸ĳɹ�
    scroll    11,8,20,18,50,2fh;����
    curse     11,20
    mov ah,09h
    lea dx,prompt
    int 21h
    curse  12,20
    mov ah,09h
    lea dx,pkey
    int 21h
    ;������˳�
    mov ah,0
    int 16h
endm


;�޸ĵ���,posΪ��index.txt��λ�ã�pos1Ϊwords.txt��λ��
modify macro
    local get1,get2,get3,end1
    ;����ջ�����
    lea di,Explanation;������
    cld
    mov al,0
    mov cx,80
    rep stosb
    
    ;Ӣ�Ľ���
    curse 11,20
    lea di,Explanation
    mov cx,30
    get1:
    mov ah,0
    int 16h
    
    cmp al,1bh;esc�˳�
    jz exit
    cmp al,0dh;����enter�س����������
    jz sy
    mov ah,0eh
    int 10h
    
    cld
    stosb
    loop get1
    
    ;ͬ���
    sy:
    curse 13,20
    lea di,synonym
    mov cx,30
    get2:
    mov ah,0
    int 16h
    
    cmp al,1bh;esc�˳�
    jz exit
    cmp al,0dh;����enter�س����������
    jz an 
    mov ah,0eh
    int 10h
    
    cld
    stosb
    loop get2 
    ;�����
    an:
    curse 15,20
    lea di,antonym
    mov cx,30
    get3:
    mov ah,0
    int 16h
    
    cmp al,1bh;esc�˳�
    jz exit
    cmp al,0dh;����enter�س����������
    jz end1 
    mov ah,0eh
    int 10h    
    
    cld
    stosb
    loop get3
    
    ;������ɣ��ѻ����������������words.txt�ļ�pos1λ����
    end1:
    mov ah,42h
    mov al,00h
    mov bx,f2
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,100
    mul pos1
    add ax,1
    add ax,20
    mov dx,ax
    pop ax
    int 21h
    jc error
    
    mov ah,40h
    mov bx,f2
    mov cx,80
    lea dx,Explanation
    int 21h
    jc error
    success
endm

;ɾ������,posΪ��index.txt��λ�ã�pos1Ϊwords.txt��λ��
delete macro
    local next,end1
    ;pos1=pos+1
    mov al,pos
    inc al
    mov pos1,al
    
    next:
    mov al,pos1
    cmp al,count
    jnb end1
    
    ;�ƶ���дָ�� pos1
    mov ah,42h
    mov al,00
    mov bx,f1
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,21
    mul pos1
    add ax,1
    mov dx,ax
    pop ax
    int 21h
    jc error
    
    ;���stbuf������
    cld
    mov al,0
    mov cx,20
    lea di,stbuf
    rep stosb
    ;��pos1λ�õĵ��ʼ�¼����stbuf
    mov ah,3fh
    mov bx,f1
    mov cx,21
    lea dx,stbuf
    int 21h
    jc error
    
    ;�ƶ���дָ��pos1-1
    mov ah,42h
    mov al,00h
    mov bx,f1
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,21
    mul pos1
    add ax,1
    sub ax,21
    mov dx,ax
    pop ax
    int 21h
    jc error
    
    ;pos1-1д��stbuf
    mov ah,40h
    mov bx,f1
    mov cx,21
    lea dx,stbuf
    int 21h
    jc error
    
    ;pos1+1
    mov al,pos1
    inc al
    mov pos1,al
    
    jmp next
    
    end1:
    ;��count-1
    mov al,count
    dec al
    mov count,al
    ;��countд��index.txt
    mov ah,42h
    mov al,00h
    mov bx,f1
    mov cx,0
    mov dx,0
    int 21h
    jc error
    
    mov ah,40h
    mov bx,f1
    mov cx,1
    lea dx,count
    int 21h
    jc error
    
    success 
endm


;���ҵ���,buf��������Ϊ���ʣ��ҵ�����λ��,Ĭ���ļ��Ѵ�
locate macro 
    local end1,error,comp,next
    push ax
    push bx
    push cx
    push dx
    
    ;mov ah,3dh;��index.txt�ļ�
    ;mov al,02;��дģʽ
    ;lea dx,index
    ;int 21h;
    ;jc error
    ;mov f1,ax
    
    ;�ȶ��뵱ǰ���ʵ�����
    ;mov ah,3fh
    ;mov bx,f1
    ;mov cx,1
    ;lea dx,count
    ;int 21h
    ;jc error
    
    mov bl,0
    mov pos,bl;��ʼ������
    
    ;pos��¼��ǰָ���λ��
    next:
    mov bl,pos
    cmp bl,count;����
    jz end1
    
    ;�ƶ��ļ���дָ��
    mov ah,42h
    mov bx,f1
    mov al,00h
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,21
    mul pos
    add ax,1
    mov dx,ax
    
    pop ax
    
    int 21h
    
    ;���stbuf������
    cld
    mov al,0
    mov cx,20
    lea di,stbuf
    rep stosb
    ;��20���ֽڼ�����ƴд
    mov ah,3fh
    mov bx,f1
    mov cx,20
    lea dx,stbuf
    int 21h
    jc error
    
    mov cx,20;cxΪ���������
    
    cld
    lea si,stbuf
    lea di,buf
    comp:
    repz cmpsb
    ;ȫ����Ƚ���
    jz end1
    ;�����ʱͣ��
    
    dec di
    dec si 
    mov al,[di]
    cmp al,[si]
    jb end1
    
    ;pos+1
    mov al,pos
    inc al
    mov pos,al
    ja next
    
    
    error:
    lea dx,filefail2;��ʾ����
    mov ah,09h
    int 21h;
    
    end1: 
    
    ;�ر��ļ�
    ;mov ah,3eh
    ;mov bx,f1
    ;int 21h
    ;jc error
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    ;jmp start
    
endm


;���뵥�ʹ���
insert macro
    push ax
    push dx
    push di
    local get1,get2,get3,get4,get5,exit,start,find,end1,next,step3,step4
    
    mov ah,3dh;��index.txt�ļ�
    mov al,02;��дģʽ
    lea dx,index
    int 21h;
    jc error
    mov f1,ax
    
    ;�ȶ��뵱ǰ���ʵ�����
    mov ah,3fh
    mov bx,f1
    mov cx,1
    lea dx,count
    int 21h
    jc error
    
    ;���words.txt�Ķ�дָ��
    mov ah,3dh;��words.txt�ļ�
    mov al,02;��дģʽ
    lea dx,words
    int 21h
    jc error
    mov f2,ax
    
    mov ah,3fh
    mov bx,f2
    mov cx,1
    lea dx,count1 
    int 21h
    jc error
    
    start: 
    scroll    11,8,20,18,50,2fh;����
    curse     9,20
    mov ah,09h
    lea dx,menu11
    int 21h
    
    curse 11,20
    mov ah,09h
    lea dx,menu12
    int 21h
    
    curse 13,20
    mov ah,09h
    lea dx,menu13
    int 21h
           
    curse 15,20
    mov ah,09h
    lea dx,menu14
    int 21h
    
get1:
    ;��ջ���������Ȼ������bug
    lea di,buf;������
    cld
    mov al,0
    mov cx,120
    rep stosb
    curse     10,20
    lea di,buf
    mov cx,30;��һ���ַ���
get2:   
    mov ah,0			;�ȴ�����
    int 16h	
    cmp al,1bh		;�Ƿ�Ϊesc����
    jz  exit			;�ǣ��˳�
    cmp al,0dh ;���뻻��enter����ʼ��������
    jz  find
    mov ah,0eh		;��ʾ������ַ�
    int 10h
    
    
    ;��������ַ����뻺����
    cld
    stosb
    
    loop get2
    scroll 1,8,20,18,50,2fh			;�Ͼ�һ��
    curse  10,20
    jmp get1
    
    find:
    locate
    
    
    
    ;��pos֮��ĵ���ȫ��������һλ
    mov al,count
    cmp al,0
    jz end1
    dec al
    mov pos1,al
    
    next: 
    mov al,pos1
    cmp al,pos
    jl end1
    
    ;�ƶ���дָ��
    mov ah,42h
    mov al,00
    mov bx,f1
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,21
    mul pos1
    add ax,1
    mov dx,ax
    pop ax
    int 21h
    
    ;���stbuf������
    cld
    mov al,0
    mov cx,20
    lea di,stbuf
    rep stosb     
    ;����count-1�ĵ���
    mov ah,3fh
    mov bx,f1
    mov cx,21
    lea dx,stbuf
    int 21h
    jc error
    ;��pos1�ƶ���pos1+1
    ;�ƶ���дָ��
    mov ah,42h
    mov al,00
    mov bx,f1
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,21
    mul pos1
    add ax,1
    add ax,21
    mov dx,ax
    pop ax
    int 21h
    ;д��stbuf
    mov ah,40h
    mov bx,f1
    mov cx,21
    lea dx,stbuf
    int 21h
    
    ;pos1-1
    mov al,pos1
    dec al
    mov pos1,al
    
    jmp next
    
    end1:
    ;�����뵥��д��posλ��
    ;�ƶ���дָ��
    mov ah,42h
    mov al,00
    mov bx,f1
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,21
    mul pos
    add ax,1
    mov dx,ax
    pop ax
    int 21h
    
    mov ah,40h
    mov bx,f1
    mov cx,20
    lea dx,buf
    int 21h
    
    
    ;д����words.txt��λ��
    mov ah,40h
    mov bx,f1
    mov cx,1
    lea dx,count1
    int 21h
    
    mov al,count
    inc al
    mov count,al
    
    ;��countд���ļ�
    mov ah,42h
    mov al,00h
    mov bx,f1
    mov cx,0
    mov dx,0
    int 21h
    jc error
    
    mov ah,40h
    mov bx,f1
    mov cx,1
    lea dx,count
    int 21h
    jc error
    
    
    curse     12,20
    lea di,Explanation
    mov cx,30;��һ���ַ���
get3:   
    mov ah,0			;�ȴ�����
    int 16h	
    cmp al,1bh		;�Ƿ�Ϊesc����
    jz  exit			;�ǣ��˳�
    cmp al,0dh ;���뻻��enter���������
    jz  step3
    mov ah,0eh		;��ʾ������ַ�
    int 10h
    
    
    ;��������ַ����뻺����
    cld
    stosb
    
    loop get3
    
    step3:
    curse     14,20
    lea di,synonym
    mov cx,30;��һ���ַ���
get4:   
    mov ah,0			;�ȴ�����
    int 16h	
    cmp al,1bh		;�Ƿ�Ϊesc����
    jz  exit			;�ǣ��˳�
    cmp al,0dh ;���뻻��enter���������
    jz  step4
    mov ah,0eh		;��ʾ������ַ�
    int 10h
    
    
    ;��������ַ����뻺����
    cld
    stosb
    
    loop get4
    
    step4:
    curse     16,20
    lea di,antonym
    mov cx,30;��һ���ַ���
get5:   
    mov ah,0			;�ȴ�����
    int 16h	
    cmp al,1bh		;�Ƿ�Ϊesc����
    jz  exit			;�ǣ��˳�
    cmp al,0dh ;���뻻��enter���������
    jz  record
    mov ah,0eh		;��ʾ������ַ�
    int 10h
    
    
    ;��������ַ����뻺����
    cld
    stosb
    
    loop get5
    
    record:
    ;�ƶ���дָ��
    mov ah,42h
    mov al,00h
    mov bx,f2
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,100
    mul count1
    add ax,1
    mov dx,ax
    pop ax
    int 21h
    jc error
    
    ;д���ļ���¼
    mov ah,40h
    mov bx,f2
    mov cx,20
    lea dx,buf
    int 21h
    jc error
    
    mov ah,40h
    mov bx,f2
    mov cx,80
    lea dx,Explanation
    int 21h
    jc error
    
    ;��count1+1ָ����һ����¼λ��
    mov al,count1
    inc al
    mov count1,al
    
    ;��count1д���ļ�
    mov ah,42h
    mov al,00
    mov bx,f2
    mov cx,0
    mov dx,0
    int 21h
    jc error
    
    mov ah,40h
    mov bx,f2
    mov cx,1
    lea dx,count1
    int 21h
    jc error
    
    ;��ʾ�ɹ�
    scroll    11,8,20,18,50,2fh;����
    curse     11,20
    mov ah,09h
    lea dx,prompt
    int 21h
    curse  12,20
    mov ah,09h
    lea dx,pkey
    int 21h
    
    mov ah,0
    int 16h
    
    exit:
    
    ;�ر��ļ�index.txt
    mov ah,3eh
    mov bx,f1
    int 21h
    jc error
    
    ;�ر��ļ�words.txt
    mov ah,3eh
    mov bx,f2
    int 21h
    jc error
    
    pop di
    pop dx
    pop ax
    jmp startmenu
endm 

enquire macro
    local start,get1,get2,find,choose,exit
    push ax
    push bx
    push cx
    push dx
    
    mov ah,3dh;��index.txt�ļ�
    mov al,02;��дģʽ
    lea dx,index
    int 21h;
    jc error
    mov f1,ax
    
    ;�ȶ��뵱ǰ���ʵ�����
    mov ah,3fh
    mov bx,f1
    mov cx,1
    lea dx,count
    int 21h
    jc error
    
    ;���words.txt�Ķ�дָ��
    mov ah,3dh;��words.txt�ļ�
    mov al,02;��дģʽ
    lea dx,words
    int 21h
    jc error
    mov f2,ax
    
    mov ah,3fh
    mov bx,f2
    mov cx,1
    lea dx,count1 
    int 21h
    jc error
    
    start:
    scroll    11,8,20,18,50,2fh;����
    curse     9,20
    mov ah,09h
    lea dx,menu11
    int 21h
    
    get1:
    ;��ջ���������Ȼ������bug
    lea di,buf;������
    cld
    mov al,0
    mov cx,120
    rep stosb
    curse     10,20
    lea di,buf
    mov cx,30;��һ���ַ���
get2:   
    mov ah,0			;�ȴ�����
    int 16h	
    cmp al,1bh		;�Ƿ�Ϊesc����
    jz  exit			;�ǣ��˳�
    cmp al,0dh ;���뻻��enter����ʼ��������
    jz  find
    mov ah,0eh		;��ʾ������ַ�
    int 10h
    
    
    ;��������ַ����뻺����
    cld
    stosb
    
    loop get2
    
    find:
    locate 
    
    mov al,pos
    mov pos1,al
    
    lea di,Explanation
    mov al,'$'
    mov [di],al
    
    ;��ʾpos֮��ļ�������(���4)
    curse 11,20
    mov ah,02h
    mov dl,'0'
    int 21h
    
    curse 12,20
    mov ah,02h
    mov dl,'1'
    int 21h
    
    curse 13,20
    mov ah,02h
    mov dl,'2'
    int 21h
    
    curse 14,20
    mov ah,02h
    mov dl,'3'
    int 21h
    
    curse 15,20
    mov ah,09h
    lea dx,menu3
    int 21h
    
    curse 11,22
     
    mov al,pos1
    cmp al,count 
    jnb choose
    
    mov ah,42h
    mov al,00h
    mov bx,f1
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,21
    mul pos1
    add ax,1
    mov dx,ax
    pop ax
    int 21h
    jc error
    
    mov ah,3fh
    mov bx,f1
    mov cx,20
    lea dx,stbuf
    int 21h
    jc error
    
    mov ah,09h
    lea dx,stbuf
    int 21h
    
    lea di,stbuf;������
    cld
    mov al,0
    mov cx,20
    rep stosb
    
    mov al,pos1
    inc al
    mov pos1,al
    
    curse 12,22
    mov al,pos1
    cmp al,count
    jnb choose
    
    mov ah,42h
    mov al,00h
    mov bx,f1
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,21
    mul pos1
    add ax,1
    mov dx,ax
    pop ax
    int 21h
    jc error
    
    mov ah,3fh
    mov bx,f1
    mov cx,20
    lea dx,stbuf
    int 21h
    jc error
    
    mov ah,09h
    lea dx,stbuf
    int 21h
    
    lea di,stbuf;������
    cld
    mov al,0
    mov cx,20
    rep stosb
    
    mov al,pos1
    inc al
    mov pos1,al   
    
    curse 13,22
    mov al,pos1
    cmp al,count
    jnb choose
    
    mov ah,42h
    mov al,00h
    mov bx,f1
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,21
    mul pos1
    add ax,1
    mov dx,ax
    pop ax
    int 21h
    jc error
    
    mov ah,3fh
    mov bx,f1
    mov cx,20
    lea dx,stbuf
    int 21h
    jc error
    
    mov ah,09h
    lea dx,stbuf
    int 21h
    
    lea di,stbuf;������
    cld
    mov al,0
    mov cx,20
    rep stosb
    
    mov al,pos1
    inc al
    mov pos1,al
    
    curse 14,22
    mov al,pos1
    cmp al,count
    jnb choose
    
    mov ah,42h
    mov al,00h
    mov bx,f1
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,21
    mul pos1
    add ax,1
    mov dx,ax
    pop ax
    int 21h
    jc error
    
    mov ah,3fh
    mov bx,f1
    mov cx,20
    lea dx,stbuf
    int 21h
    jc error
    
    mov ah,09h
    lea dx,stbuf
    int 21h
    
    lea di,stbuf;������
    cld
    mov al,0
    mov cx,20
    rep stosb
    
    mov al,pos1
    inc al
    mov pos1,al
    
    choose:
    mov ah,0
    int 16h
    
    cmp al,1bh
    jz exit
    
    and al,0fh
    add al,pos
    mov pos,al
    
    scroll    11,8,20,18,50,2fh;����
    curse     9,20
    
    curse 10,20
    mov ah,09h
    lea dx,menu12
    int 21h
    
    curse 12,20
    mov ah,09h
    lea dx,menu13
    int 21h
           
    curse 14,20
    mov ah,09h
    lea dx,menu14
    int 21h
    
    curse 18,20
    mov ah,09h
    lea dx,menu22
    int 21h
    
    ;�ƶ���дָ��        
    mov ah,42h
    mov al,00h
    mov bx,f1
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,21
    mul pos
    add ax,1
    add ax,20
    mov dx,ax
    pop ax 
    int 21h
    jc error
    
    ;��ȡ��¼λ��
    mov ah,3fh
    mov bx,f1
    mov cx,1
    lea dx,pos1
    int 21h
    jc error
    
    ;words.txt�ж�ȡ��¼
    mov ah,42h 
    mov al,00h
    mov bx,f2
    mov cx,0
    mov dx,0
    
    push ax
    mov ax,100
    mul pos1
    add ax,1
    mov dx,ax
    pop ax
    int 21h
    jc error
    
    ;��һ����¼����stbuf
    mov ah,3fh
    mov bx,f2
    mov cx,100
    lea dx,stbuf
    int 21h
    jc error
    
    ;����¼��������ʾ
    
    
    mov al,'$'
    lea di,stbuf+19
    mov [di],al
    lea di,synonym+19
    mov [di],al
    lea di,Explanation+19
    mov [di],al
    lea di,antonym+19
    mov [di],al 
    
    curse 9,20 ;����ƴд
    mov ah,09h
    lea dx,stbuf
    int 21h
    
    curse 11,20;Ӣ�Ľ���
    mov ah,09h
    lea dx,Explanation
    int 21h
    
    curse 13,20;ͬ���
    mov ah,09h
    lea dx,synonym
    int 21h
    
    curse 15,20 ;�����
    mov ah,09h
    lea dx,antonym
    int 21h
    
    ;ѡ���޸ĺ�ɾ��
    mov ah,0
    int 16h
    
    cmp al,1bh
    jz exit
    
    cmp al,'1'
    jnz dele
    modify
    
    dele:
    cmp al,'2'
    jnz exit
    delete 
    
    
    
    
    exit:
    
    ;�ر��ļ�index.txt
    mov ah,3eh
    mov bx,f1
    int 21h
    jc error
    
    ;�ر��ļ�words.txt
    mov ah,3eh
    mov bx,f2
    int 21h
    jc error
    
    pop dx
    pop cx
    pop bx
    pop ax
    jmp startmenu
endm


data segment
    ; add your data here!
    filefail db "fail to create file$"
    filefail2 db "fail to operate file$"
    st db "Welcome to use dictionary$"
    menu1 db "1.insert word$"
    menu2 db "2.search word$"
    menu3 db "press esc Exit the dictionary$"
    menu11 db "Please enter a word$";���뵥��
    menu12 db "Explanation in English:$";Ӣ�Ľ���
    menu13 db "synonym:$";ͬ���
    menu14 db "antonym:$";�����
    menu22 db "1.modify 2.delete (exit)esc$";�޸ĵ��ʼ�¼����ɾ��
    prompt db "save successful$";��ʾ�޸ĳɹ�
    esc db "Do you want to exit(esc/n)$"
    esc1 db "Welcome to use again$"
    
    words db "D:\emu8086\MyBuild\words.txt",00h;���ʴ�ŵ��ļ�
    index db "D:\emu8086\MyBuild\index.txt",00h;�����ļ�
    f1 dw 0;index.txt�ļ�������
    f2 dw 0;words.txt�ļ�������
    count db 0;��ǰ��������
    count1 db 0;words.txt�ļ���д��ָ��
    pos db 0;�ļ�ָ���λ��
    pos1 db 0;������д��ָ��
    
    buf db 20 dup(0);������
    stbuf db 20 dup(0);���ʻ�����
    Explanation db 40 dup(0);Ӣ�Ľ��ͻ�����
    synonym db 20 dup(0);ͬ��ʻ�����
    antonym db 20 dup(0),'$';����ʻ�����
    
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
    ;�����ʼû�������ļ��������ļ�
    ;�ļ���ַ��D:\emu8086\MyBuild\Ŀ¼��
    ;mov ah,3ch;
    ;mov cx,00;
    ;lea dx,index;
    ;int 21h;
    ;jc error
    ;mov f1,ax
    
    ;mov ah,3ch;
    ;mov cx,00;
    ;lea dx,words;
    ;int 21h;
    ;jc error
    ;mov f2,ax
    
    
    ;mov ah,3dh;��index.txt�ļ�
    ;mov al,02;��дģʽ
    ;lea dx,index
    ;int 21h;
    ;jc error
    ;mov f1,ax
    
    ;mov ah,3dh;��words.txt�ļ�
    ;mov al,02;��дģʽ
    ;lea dx,words
    ;int 21h
    ;jc error
    ;mov f2,ax
    
    ;��ʼ���������һ����������index.txt��words.txt��һ���ֽ�д��0����ǰ0������
    ;mov ah,40h
    ;lea dx,count
    ;mov bx,f1
    ;mov cx,1
    ;int 21h
    ;jc error
    
    ;mov ah,40h
    ;lea dx,count1
    ;mov bx,f2
    ;mov cx,1
    ;int 21h
    ;jc error
    
    ;�ر��ļ�
    ;mov ah,3eh
    ;mov bx,f1
    ;int 21h
    ;jc error
    
    ;mov ah,3eh
    ;mov bx,f2
    ;int 21h
    ;jc error 
    
    call main
    
    error:
    lea dx,filefail2
    mov ah,09h
    int 21h;
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    main proc
        
        ;��ͷ��ҳ��˵�
        startmenu: 
        scroll    0,0,0,24,79,02		;����
        scroll    13,7,19,19,51,50h		;���ⴰ�ڣ�Ʒ���
        scroll    11,8,20,18,50,2fh    	;���ڴ��ڣ��̵װ���
        curse 10,20
        
        lea dx,st
        mov ah,09h
        int 21h
        curse 13,20
        lea dx,menu1
        mov ah,09h
        int 21h
        curse 14,20
        lea dx,menu2
        mov ah,09h
        int 21h
        curse 15,20
        lea dx,menu3
        mov ah,09h
        int 21h
        
        curse     18,20			;�ù����18��20��
        mov ah,0;���빦�ܼ�
        int 16h
        cmp al,'1';insert
        jnz search
        insert 
         
        search:
        cmp al,'2';search
        jnz exit
        enquire
        
        
        exit:
        ;cmp al,1bh;esc 
        call quit
        mov ah,01h
        int 21h;2��ѯ��esc
        cmp al,1bh
        jnz startmenu
        lea dx,esc1
        mov ah,09h
        int 21h
        mov ah,4ch
        int 21h
        
        ret
main      endp        
    quit proc
        push ax
        push dx
        
        scroll    11,8,20,18,50,2fh			;�Ͼ�һ��
        curse     18,20
        lea dx,esc
        mov ah,09h
        int 21h
        scroll    1,8,20,18,50,2fh			;�Ͼ�һ��
        curse     18,20
        
        pop dx
        pop ax
        ret
    endp
    
    
ends

end start ; set entry point and stop the assembler.
