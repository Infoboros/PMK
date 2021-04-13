ORG 0
	JMP main

; обработчик прерывания int1
org 13h	; int1
	call scanKeyBoard
	mov p0, #0
	reti

org 030h
main:
	; Настройка работы UART
	CLR SM0 
	SETB SM1 ; 2 режим, 8 бит, стоп/старт, четность

	MOV A, PCON 
	SETB ACC.7 
	MOV PCON, A ; 7 бит в PCON установлен в 1, множитель скорости 2 
	; Настройка таймера
	; При переполнении записывается из TL1 в TH1 (M1 = 1, M0 = 0)
	MOV TMOD, #20H 
	MOV TH1, #243
	MOV TL1, #243 
	SETB TR1 ; запуск таймера 1
	; Настройка прерывания
	SETB IT1 ; по срезу
	SETB EX1 ; прерывание от INT1
	SETB EA	; разрешить все прерывания
	
	call init_LCD
	
	mov p0, #0
	
; Бесконечный цикл ожидания
	sjmp $
	
	
; Сканирование по рядам
scanKeyBoard:
	mov p0, #11111111b

	clr p0.3
 	CALL scanRow1

	setb p0.3
	clr  p0.2
 	CALL scanRow2
 	
	setb p0.2
	clr  p0.1
 	CALL scanRow3
 	
	setb p0.1
	clr  p0.0
 	CALL scanRow4

	ret

; Сканирование первого ряда
scanRow1:
	MOV A, #31h
 	JNB P0.6, pressKeyR1
	
	MOV A, #32h
 	JNB P0.5, pressKeyR1
	
	MOV A, #33h
	JNB P0.4, pressKeyR1
 	
	ret ; ключ не найден
	
     pressKeyR1:
	call putc
	ret

; Сканирование второго ряда
scanRow2:
	MOV A, #34h
 	JNB P0.6, pressKeyR2
	
	MOV A, #35h
 	JNB P0.5, pressKeyR2
	
	MOV A, #36h
	JNB P0.4, pressKeyR2
 	
	ret ; ключ не найден
	
     pressKeyR2:
	call putc
	ret
	
; Сканирование третьего ряда
scanRow3:
	MOV A, #37h
 	JNB P0.6, pressKeyR3
	
	MOV A, #38h
 	JNB P0.5, pressKeyR3
	
	MOV A, #39h
	JNB P0.4, pressKeyR3
 	
	ret ; ключ не найден
	
     pressKeyR3:
	call putc
	ret

; Сканирование четвертого ряда
scanRow4:
	MOV A, #02ah
 	JNB P0.6, pressKeyR4
	
	MOV A, #30h
 	JNB P0.5, pressKeyR4
	
	MOV A, #23h
	JNB P0.4, pressKeyR4
 	
	ret ; ключ не найден
	
     pressKeyR4:
	call putc
	ret
	
;печать символа из А на UART и запись символа в буфер семисегментного индикатора
putc:
	MOV C, P
	MOV ACC.7, C ; бит чётности
	MOV SBUF, A 	;отправляем символ на печать
	JNB TI, $	;ожидаем пока выведется
	CLR TI		;очищаем флаг на будущее
	
	;далее вывод на LCD
	INC r0 	;увеличиваем кол-во выведенных чисел
	cjne r0, #17, skip_br;если это не 17ый символ не перескакиваем на следующую строку
	CALL br
	
   skip_br:
   	cjne r0, #33, skip_jmp_to_start ;если не набралось 33 символа не возвращаемся в начало 
   	CALL jmp_to_start
   	CALL putc_LCD
   	
   skip_jmp_to_start:
	CALL putc_LCD
	
	ret
	

putc_LCD:
	;переносим старшие 4 бита из А в порт для передачи
	MOV C, ACC.7		
	MOV P1.7, C	
	
	MOV C, ACC.6	
	MOV P1.6, C	
	
	MOV C, ACC.5	
	MOV P1.5, C	
	
	MOV C, ACC.4	
	MOV P1.4, C	
	
	;передаем старшие 4 бита
	SETB P1.2			
	CLR P1.2			
	
	;переносим младшие 4 бита из А в порт для передачи
	MOV C, ACC.3		
	MOV P1.7, C		
	
	MOV C, ACC.2		
	MOV P1.6, C		
	
	MOV C, ACC.1		
	MOV P1.5, C		
	
	MOV C, ACC.0		
	MOV P1.4, C		

	;передаем младшие 4 бита символа
	SETB P1.2		
	CLR P1.2		

	CALL delay			;ожидаем пока выведется

;ожидание что бы цифра проявилась
delay:
	mov b,#20
	djnz b, $
	ret
	
init_LCD:
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
	SETB P1.3		; включаем режим вывода
	
	MOV R0, #0		;количество выведенных чисел на LCD
	
	ret
	
br:
	CLR P1.3		; вводим команду
	SETB P1.7		; код команды перемещения адреса записи
	SETB P1.6		; перемещаем запись на 0x40 эт вторая строчка
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
	SETB P1.3		; возвращаемся к выводу символов
	ret

jmp_to_start:
	CLR P1.3		; вводим команду
	CLR P1.7		; код команды перемещения в начало
	CLR P1.6		; 
	CLR P1.5		; 
	CLR P1.4		; первая часть команды

	SETB P1.2		; 
	CLR P1.2		; передаем команду

	CLR P1.7		; 
	CLR P1.6		; 
	SETB P1.5		; код для перемещения в начало
	CLR P1.4		; 

	SETB P1.2		; 
	CLR P1.2		; передаем

	CALL delay		; ждем выполнения и записи команды в память
	MOV R0, #0
	SETB P1.3		; возвращаемся к выводу символов
	ret
