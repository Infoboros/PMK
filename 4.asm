
	MOV 30H, #'A'
	MOV 31H, #'B'
	MOV 32H, #'C'
	MOV 33H, #'A'
	MOV 34H, #'B'
	MOV 35H, #'C'
	MOV 36H, #'1'
	MOV 37H, #'2'
	MOV 38H, #'3'
	MOV 39H, #'4'
	MOV 3AH, #'A'
	MOV 3BH, #'B'
	MOV 3CH, #'C'
	MOV 3DH, #'A'
	MOV 3EH, #'B'
	MOV 3FH, #'C'
	MOV 40H, #'1'
	MOV 41H, #'2'
	MOV 42H, #'3'
	MOV 43H, #'4'
	MOV 54H, #'5'
	MOV 55H, #'6'
	MOV 56H, #0


; настраиваем дисплей
	CLR P1.3		; очищаем бит RS что бы вводить инструкции для дисплея

; включаем настрйоку работы в 4х битном режиме в две строчки с символами 5 на	
	mov p1, #00100000b
	;передача первой части команды
	SETB P1.2		
	CLR P1.2		
	;ждем пока команда передастся
	CALL delay		
	SETB P1.2		
	CLR P1.2		
				
	;передаем вторую часть команды
	SETB P1.7		; устанавливаем работу в две строки
	;передаем команду
	SETB P1.2	
	CLR P1.2	
	;ждем пока передастся
	CALL delay	

;включаем дисплей и курсор
	CLR P1.7		; 
	CLR P1.6		; 
	CLR P1.5		; 
	CLR P1.4		; первая часть команды

	SETB P1.2		; 
	CLR P1.2		; передаем команду

	SETB P1.7		; служебный бит
	SETB P1.6		; включаем дисплей
	SETB P1.5		; включаем курсор подчеркивание
	CLR P1.4		; выключаем курсор малевича

	SETB P1.2		; 
	CLR P1.2		; передаем

	CALL delay		; ждем выполнения и записи команды в память

;переносим на следующую сторку
	SETB P1.7		; 
	SETB P1.6		; 
	CLR P1.5		; 
	CLR P1.4		; первая часть команды

	SETB P1.2		; 
	CLR P1.2		; передаем команду

	CLR P1.7		; 
	CLR P1.6		; 
	CLR P1.5		; 
	CLR P1.4		; 

	SETB P1.2		; 
	CLR P1.2		; передаем

	CALL delay		; ждем выполнения и записи команды в память

; send data
	SETB P1.3		; clear RS - indicates that data is being sent to module
	MOV R1, #30H	; data to be sent to LCD is stored in 8051 RAM, starting at location 30H
loop:
	MOV A, @R1		; move data pointed to by R1 to A
	JZ finish		; if A is 0, then end of data has been reached - jump out of loop
	CALL sendCharacter	; send data in A to LCD module
	INC R1			; point to next piece of data
	JMP loop		; repeat

finish:
	JMP $


sendCharacter:
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB P1.2			; |
	CLR P1.2			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB P1.2			; |
	CLR P1.2			; | negative edge on E

	CALL delay			; wait for BF to clear

delay:
	MOV R0, #50
	DJNZ R0, $
	RET
