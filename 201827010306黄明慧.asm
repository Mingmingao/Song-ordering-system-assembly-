DATAS SEGMENT
   intro db '1 Just met you',0dh,0ah
   		 db '2 Happy birthday to you',0dh,0ah
   		 db '3 Happy New Year',0dh,0ah
   		 db '0 exit',0dh,0ah
  		 db 'please input the number to select the song to play or to end program:',0dh,0ah,'$'
   error db 0dh,0ah,'You input is error,please input again:','$'
   mus1_freq dw 20,220,294,330
		dw 294,19,19,294,294,330,294
		dw 294,20,20,294,294,330
		dw 370,494,541,587,20,494,494,440
		dw 440,370,294,330,20,220,294,330,294
		dw 294,20,20,294,294,330
		dw 370,20,20,220,294,330
		dw 370,494,541,587,20,494,494,440
		
		dw 440,494,370,330,20,587,587,587
		dw 587,494,1175,988,988,988,880
		dw 880,740,740,587,659,587,587
		dw 587,494,1175,1318,1175,1175,988
		dw 20,880,740,880,659,587,554
		dw 587,484,1175,988,988,988,880
		dw 880,880,988,740,880,659,587,659
		dw 587,554,587,587,20,587,659
		
		dw 740,659,587,587,554,587,587
		dw -1
   mus1_time dw 50,50,50,50
		dw 100,100,50,50,50,25,25
		dw 100,100,50,50,50,50
		dw 50,50,50,50,50,50,50,50
		dw 50,50,50,50,50,50,50,25,25
		dw 100,100,50,50,75,25
		dw 100,100,50,50,50,50
		dw 50,50,50,50,50,50,50,50
		
		dw 50,50,50,50,50,50,50,50
		dw 50,50,50,50,100,50,50
		dw 50,50,50,50,100,50,50
		dw 50,50,50,50,100,50,50
		dw 50,50,50,50,100,50,50
		dw 50,50,50,50,100,50,50
		dw 50,25,25,50,50,100,50,50
		dw 50,25,25,100,100,50,50
		
		dw 50,25,25,50,25,25,100
   mus2_freq dw 220,220,247,220
   		dw 294,262,20
   		dw 220,220,247,220
   		dw 330,294,20
   		dw 220,220,440,349
   		dw 294,262,247
   		dw 392,392,349,294
   		dw 330,262
   		dw -1
   mus2_time dw 50,50,100,100
   		dw 100,100,100
   		dw 50,50,100,100
   		dw 100,100,100
   		dw 50,50,100,100
   		dw 100,100,100
   		dw 75,25,100,100
   		dw 100,100
   mus3_freq dw 330,330,330,247
   		dw 415,415,415,330
   		dw 330,415,494,494
   		dw 440,415,370,20
   		dw 370,415,440,440
   		dw 415,370,415,330
   		dw 330,415,370,247
   		dw 311,370,330
		dw -1
   mus3_time dw 25,25,50,50
   		dw 25,25,50,50
   		dw 25,25,50,50
   		dw 25,25,50,50
   		dw 25,25,50,50
   		dw 25,25,50,50
   		dw 25,25,50,50
   		dw 25,25,50
DATAS ENDS

STACKS SEGMENT
    db 100h dup(0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    MOV AX,STACKS
    MOV SS,AX
    MOV SP,100H
    
    ;选择介绍
    LEA DX,intro
    MOV AH,09H
    INT 21H
    
INPUT:   
    ;输入数字
    MOV AH,1
    INT 21H
    CMP AL,'0'
    JE EXIT
    CMP AL,'1'
    JE M1
    CMP AL,'2'
    JE M2
    CMP AL,'3'
    JE M3
    ;输入错误,重新输入
    MOV AH,09H
    LEA DX,ERROR
    INT 21H
    JMP INPUT
	
M1:
	LEA SI,mus1_freq
	LEA DI,mus1_time
	JMP PLAY
M2:
	LEA SI,mus2_freq
	LEA DI,mus2_time
	JMP PLAY
M3:
    LEA SI,mus3_freq
	LEA DI,mus3_time
	JMP PLAY
    
    ;播放每一个音符
PLAY:
	MOV DX,[SI]
	CMP DX,-1;最后一个是-1就结束
	JE EXIT
	CALL SOUND
	ADD SI,2
	ADD DI,2
	JMP PLAY

SOUND:
	PUSH AX;保护现场
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI
	
	MOV AL,0B6H;往43h端口送控制字0B6h，对定时器2进行初始化
				;使定时器2准备接受计数初值
	OUT 43H,AL
	
	MOV DX,12H;往42h端口送16位的计数值（12348ch/给定频率）
	MOV AX,348CH
	DIV word ptr [SI]
	OUT 42H,AL
	MOV AL,AH
	OUT 42H,AL
	
	IN AL,61H;使61h端口的低两位置1，发出端口
	MOV AH,AL
	OR AL,3
	OUT 61H,AL
	
	MOV DX,[DI];每一个音符延长时间
WAIT1:
	MOV CX,28000
DELAY:
	LOOP DELAY
	DEC DX
	JNZ WAIT1
	
	MOV AL,AH;恢复61h端口的值
	OUT 61H,AL
	
	POP DI;恢复现场
	POP DX
	POP CX
	POP BX
	POP AX
	RET
	
EXIT:   
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START





