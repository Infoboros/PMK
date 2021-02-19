org 500h
	; Символы клавиатуры
	db 23h, 30h, 02ah, 39h, 38h, 37h, 36h, 35h, 34h, 33h, 32h, 31h

ORG 0

	JMP main

; обработчик прерывания int1
org 13h	; int1
	setb p0.0
	setb p0.1
	setb p0.2
	setb p0.3	
	call scanKeyBoard
	CLR p0.0
	CLR p0.1
	CLR p0.2
	CLR p0.3
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
	mov dptr, #500h
	; Устанавливаем в порте 0, чтобы ждать прерывания при нажатии
	CLR p0.0
	CLR p0.1
	CLR p0.2
	CLR p0.3
; Бесконечный пустой цикл
	sjmp $
	
; Сканирование по рядам
scanKeyBoard:
	mov p0, #11110111b
 	CALL scanRow1

	mov p0, #11111011b
 	CALL scanRow2
 	
	mov p0, #11111101b
 	CALL scanRow3
 	
	mov p0, #11111110b
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

; Сканирование третьего ряда
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
	
;печать символа из А на UART
putc:
	MOV C, P
	MOV ACC.7, C ; бит чётности
	MOV SBUF, A 	;отправляем символ на печать
	JNB TI, $	;ожидаем пока выведется
	CLR TI		;очищаем флаг на будущее
	ret
