; multi-segment executable file template.
;press esc to exit         			; 清屏或上卷宏定义
scroll    macro     n,ulr,ulc,lrr,lrc,att	;宏定义
    push ax
    push bx
    push cx
    push dx
    mov ah,6				;清屏或上卷
    mov al,n		;n=上卷行数；n=0时，整个窗口空白
    mov ch,ulr		;左上角行号
    mov cl,ulc		;左上角列号
    mov dh,lrr		;右下角行号
    mov dl,lrc		;右下角列号
    mov bh,att		;卷入行属性
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
    mov       ah,2		     ;置光标位置
    mov       dh,cury		;行号
    mov       dl,curx		;列号
    mov       bh,0			;当前页
    int       10h
    pop dx
    pop bx
    pop ax
endm

;移动文件读写指针
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
    ;提示修改成功
    scroll    11,8,20,18,50,2fh;清屏
    curse     11,20
    mov ah,09h
    lea dx,prompt
    int 21h
    curse  12,20
    mov ah,09h
    lea dx,pkey
    int 21h
    ;任意键退出
    mov ah,0
    int 16h
endm


;修改单词,pos为在index.txt的位置，pos1为words.txt的位置
modify macro
    local get1,get2,get3,end1
    ;先清空缓冲区
    lea di,Explanation;缓冲区
    cld
    mov al,0
    mov cx,80
    rep stosb
    
    ;英文解释
    curse 11,20
    lea di,Explanation
    mov cx,30
    get1:
    mov ah,0
    int 16h
    
    cmp al,1bh;esc退出
    jz exit
    cmp al,0dh;输入enter回车，输入结束
    jz sy
    mov ah,0eh
    int 10h
    
    cld
    stosb
    loop get1
    
    ;同义词
    sy:
    curse 13,20
    lea di,synonym
    mov cx,30
    get2:
    mov ah,0
    int 16h
    
    cmp al,1bh;esc退出
    jz exit
    cmp al,0dh;输入enter回车，输入结束
    jz an 
    mov ah,0eh
    int 10h
    
    cld
    stosb
    loop get2 
    ;反义词
    an:
    curse 15,20
    lea di,antonym
    mov cx,30
    get3:
    mov ah,0
    int 16h
    
    cmp al,1bh;esc退出
    jz exit
    cmp al,0dh;输入enter回车，输入结束
    jz end1 
    mov ah,0eh
    int 10h    
    
    cld
    stosb
    loop get3
    
    ;输入完成，把缓冲区的数据输入回words.txt文件pos1位置中
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

;删除单词,pos为在index.txt的位置，pos1为words.txt的位置
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
    
    ;移动读写指针 pos1
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
    
    ;清空stbuf缓冲区
    cld
    mov al,0
    mov cx,20
    lea di,stbuf
    rep stosb
    ;将pos1位置的单词记录读到stbuf
    mov ah,3fh
    mov bx,f1
    mov cx,21
    lea dx,stbuf
    int 21h
    jc error
    
    ;移动读写指针pos1-1
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
    
    ;pos1-1写入stbuf
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
    ;将count-1
    mov al,count
    dec al
    mov count,al
    ;将count写回index.txt
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


;查找单词,buf缓冲区中为单词，找到单词位置,默认文件已打开
locate macro 
    local end1,error,comp,next
    push ax
    push bx
    push cx
    push dx
    
    ;mov ah,3dh;打开index.txt文件
    ;mov al,02;读写模式
    ;lea dx,index
    ;int 21h;
    ;jc error
    ;mov f1,ax
    
    ;先读入当前单词的数量
    ;mov ah,3fh
    ;mov bx,f1
    ;mov cx,1
    ;lea dx,count
    ;int 21h
    ;jc error
    
    mov bl,0
    mov pos,bl;初始化计数
    
    ;pos记录当前指针的位置
    next:
    mov bl,pos
    cmp bl,count;计数
    jz end1
    
    ;移动文件读写指针
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
    
    ;清空stbuf缓冲区
    cld
    mov al,0
    mov cx,20
    lea di,stbuf
    rep stosb
    ;读20个字节即单词拼写
    mov ah,3fh
    mov bx,f1
    mov cx,20
    lea dx,stbuf
    int 21h
    jc error
    
    mov cx,20;cx为单词最长长度
    
    cld
    lea si,stbuf
    lea di,buf
    comp:
    repz cmpsb
    ;全部相等结束
    jz end1
    ;不相等时停下
    
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
    lea dx,filefail2;显示错误
    mov ah,09h
    int 21h;
    
    end1: 
    
    ;关闭文件
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


;插入单词功能
insert macro
    push ax
    push dx
    push di
    local get1,get2,get3,get4,get5,exit,start,find,end1,next,step3,step4
    
    mov ah,3dh;打开index.txt文件
    mov al,02;读写模式
    lea dx,index
    int 21h;
    jc error
    mov f1,ax
    
    ;先读入当前单词的数量
    mov ah,3fh
    mov bx,f1
    mov cx,1
    lea dx,count
    int 21h
    jc error
    
    ;获得words.txt的读写指针
    mov ah,3dh;打开words.txt文件
    mov al,02;读写模式
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
    scroll    11,8,20,18,50,2fh;清屏
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
    ;清空缓冲区，不然插入会出bug
    lea di,buf;缓冲区
    cld
    mov al,0
    mov cx,120
    rep stosb
    curse     10,20
    lea di,buf
    mov cx,30;置一行字符数
get2:   
    mov ah,0			;等待输入
    int 16h	
    cmp al,1bh		;是否为esc键？
    jz  exit			;是，退出
    cmp al,0dh ;输入换行enter，开始搜索单词
    jz  find
    mov ah,0eh		;显示输入的字符
    int 10h
    
    
    ;将输入的字符传入缓冲区
    cld
    stosb
    
    loop get2
    scroll 1,8,20,18,50,2fh			;上卷一行
    curse  10,20
    jmp get1
    
    find:
    locate
    
    
    
    ;将pos之后的单词全部往后移一位
    mov al,count
    cmp al,0
    jz end1
    dec al
    mov pos1,al
    
    next: 
    mov al,pos1
    cmp al,pos
    jl end1
    
    ;移动读写指针
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
    
    ;清空stbuf缓冲区
    cld
    mov al,0
    mov cx,20
    lea di,stbuf
    rep stosb     
    ;读入count-1的单词
    mov ah,3fh
    mov bx,f1
    mov cx,21
    lea dx,stbuf
    int 21h
    jc error
    ;将pos1移动到pos1+1
    ;移动读写指针
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
    ;写入stbuf
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
    ;将插入单词写入pos位置
    ;移动读写指针
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
    
    
    ;写入在words.txt的位置
    mov ah,40h
    mov bx,f1
    mov cx,1
    lea dx,count1
    int 21h
    
    mov al,count
    inc al
    mov count,al
    
    ;将count写回文件
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
    mov cx,30;置一行字符数
get3:   
    mov ah,0			;等待输入
    int 16h	
    cmp al,1bh		;是否为esc键？
    jz  exit			;是，退出
    cmp al,0dh ;输入换行enter，输入结束
    jz  step3
    mov ah,0eh		;显示输入的字符
    int 10h
    
    
    ;将输入的字符传入缓冲区
    cld
    stosb
    
    loop get3
    
    step3:
    curse     14,20
    lea di,synonym
    mov cx,30;置一行字符数
get4:   
    mov ah,0			;等待输入
    int 16h	
    cmp al,1bh		;是否为esc键？
    jz  exit			;是，退出
    cmp al,0dh ;输入换行enter，输入结束
    jz  step4
    mov ah,0eh		;显示输入的字符
    int 10h
    
    
    ;将输入的字符传入缓冲区
    cld
    stosb
    
    loop get4
    
    step4:
    curse     16,20
    lea di,antonym
    mov cx,30;置一行字符数
get5:   
    mov ah,0			;等待输入
    int 16h	
    cmp al,1bh		;是否为esc键？
    jz  exit			;是，退出
    cmp al,0dh ;输入换行enter，输入结束
    jz  record
    mov ah,0eh		;显示输入的字符
    int 10h
    
    
    ;将输入的字符传入缓冲区
    cld
    stosb
    
    loop get5
    
    record:
    ;移动读写指针
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
    
    ;写入文件记录
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
    
    ;将count1+1指向下一个记录位置
    mov al,count1
    inc al
    mov count1,al
    
    ;将count1写回文件
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
    
    ;提示成功
    scroll    11,8,20,18,50,2fh;清屏
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
    
    ;关闭文件index.txt
    mov ah,3eh
    mov bx,f1
    int 21h
    jc error
    
    ;关闭文件words.txt
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
    
    mov ah,3dh;打开index.txt文件
    mov al,02;读写模式
    lea dx,index
    int 21h;
    jc error
    mov f1,ax
    
    ;先读入当前单词的数量
    mov ah,3fh
    mov bx,f1
    mov cx,1
    lea dx,count
    int 21h
    jc error
    
    ;获得words.txt的读写指针
    mov ah,3dh;打开words.txt文件
    mov al,02;读写模式
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
    scroll    11,8,20,18,50,2fh;清屏
    curse     9,20
    mov ah,09h
    lea dx,menu11
    int 21h
    
    get1:
    ;清空缓冲区，不然插入会出bug
    lea di,buf;缓冲区
    cld
    mov al,0
    mov cx,120
    rep stosb
    curse     10,20
    lea di,buf
    mov cx,30;置一行字符数
get2:   
    mov ah,0			;等待输入
    int 16h	
    cmp al,1bh		;是否为esc键？
    jz  exit			;是，退出
    cmp al,0dh ;输入换行enter，开始搜索单词
    jz  find
    mov ah,0eh		;显示输入的字符
    int 10h
    
    
    ;将输入的字符传入缓冲区
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
    
    ;显示pos之后的几个单词(最多4)
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
    
    lea di,stbuf;缓冲区
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
    
    lea di,stbuf;缓冲区
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
    
    lea di,stbuf;缓冲区
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
    
    lea di,stbuf;缓冲区
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
    
    scroll    11,8,20,18,50,2fh;清屏
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
    
    ;移动读写指针        
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
    
    ;读取记录位置
    mov ah,3fh
    mov bx,f1
    mov cx,1
    lea dx,pos1
    int 21h
    jc error
    
    ;words.txt中读取记录
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
    
    ;将一个记录读入stbuf
    mov ah,3fh
    mov bx,f2
    mov cx,100
    lea dx,stbuf
    int 21h
    jc error
    
    ;将记录的内容显示
    
    
    mov al,'$'
    lea di,stbuf+19
    mov [di],al
    lea di,synonym+19
    mov [di],al
    lea di,Explanation+19
    mov [di],al
    lea di,antonym+19
    mov [di],al 
    
    curse 9,20 ;单词拼写
    mov ah,09h
    lea dx,stbuf
    int 21h
    
    curse 11,20;英文解释
    mov ah,09h
    lea dx,Explanation
    int 21h
    
    curse 13,20;同义词
    mov ah,09h
    lea dx,synonym
    int 21h
    
    curse 15,20 ;反义词
    mov ah,09h
    lea dx,antonym
    int 21h
    
    ;选择修改和删除
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
    
    ;关闭文件index.txt
    mov ah,3eh
    mov bx,f1
    int 21h
    jc error
    
    ;关闭文件words.txt
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
    menu11 db "Please enter a word$";输入单词
    menu12 db "Explanation in English:$";英文解释
    menu13 db "synonym:$";同义词
    menu14 db "antonym:$";反义词
    menu22 db "1.modify 2.delete (exit)esc$";修改单词记录或者删除
    prompt db "save successful$";提示修改成功
    esc db "Do you want to exit(esc/n)$"
    esc1 db "Welcome to use again$"
    
    words db "D:\emu8086\MyBuild\words.txt",00h;单词存放的文件
    index db "D:\emu8086\MyBuild\index.txt",00h;索引文件
    f1 dw 0;index.txt文件描述符
    f2 dw 0;words.txt文件描述符
    count db 0;当前单词数量
    count1 db 0;words.txt文件的写入指针
    pos db 0;文件指针的位置
    pos1 db 0;辅助读写的指针
    
    buf db 20 dup(0);缓冲区
    stbuf db 20 dup(0);单词缓冲区
    Explanation db 40 dup(0);英文解释缓冲区
    synonym db 20 dup(0);同义词缓冲区
    antonym db 20 dup(0),'$';反义词缓冲区
    
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
    ;如果初始没有两个文件，创建文件
    ;文件地址在D:\emu8086\MyBuild\目录下
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
    
    
    ;mov ah,3dh;打开index.txt文件
    ;mov al,02;读写模式
    ;lea dx,index
    ;int 21h;
    ;jc error
    ;mov f1,ax
    
    ;mov ah,3dh;打开words.txt文件
    ;mov al,02;读写模式
    ;lea dx,words
    ;int 21h
    ;jc error
    ;mov f2,ax
    
    ;初始化，如果第一次运行先向index.txt和words.txt第一个字节写入0代表当前0个单词
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
    
    ;关闭文件
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
        
        ;开头主页面菜单
        startmenu: 
        scroll    0,0,0,24,79,02		;清屏
        scroll    13,7,19,19,51,50h		;开外窗口，品红底
        scroll    11,8,20,18,50,2fh    	;开内窗口，绿底白字
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
        
        curse     18,20			;置光标于18行20列
        mov ah,0;输入功能键
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
        int 21h;2次询问esc
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
        
        scroll    11,8,20,18,50,2fh			;上卷一行
        curse     18,20
        lea dx,esc
        mov ah,09h
        int 21h
        scroll    1,8,20,18,50,2fh			;上卷一行
        curse     18,20
        
        pop dx
        pop ax
        ret
    endp
    
    
ends

end start ; set entry point and stop the assembler.
