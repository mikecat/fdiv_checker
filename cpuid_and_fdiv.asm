cpu pentium

%include "disk_header.asm"

_start:
	; initialize DS
	mov ax, cs
	mov ds, ax
	; clear text and attributes
	mov ax, 0xa000
	mov es, ax
	xor ax, ax
	mov cx, 80 * 25
	xor di, di
	rep stosw
	mov al, 0xe1 ; show, white
	mov cx, 80 * 25
	mov di, 0x2000
	rep stosw
	; initialize text pointer
	xor di, di

	; initialize FPU
	fwait
	fninit
	fwait

	; division test #1
	mov bx, values
	xor cx, cx
	call print_int
	mov si, operator1
	call print_string
	mov bx, values + 4
	xor cx, cx
	call print_int
	mov si, operator2
	call print_string
	fild dword [values]
	fwait
	fidiv dword [values + 4]
	fwait
	call print_float
	call newline

	; division test #2
	mov bx, values2
	xor cx, cx
	call print_int
	mov si, operator1
	call print_string
	mov bx, values2 + 4
	xor cx, cx
	call print_int
	mov si, operator2
	call print_string
	fild dword [values2]
	fwait
	fidiv dword [values2 + 4]
	fwait
	call print_float
	call newline
	call newline

	; 80386+ check
	pushf
	mov bp, sp
	mov ax, [bp]
	xor ax, 0x1000
	push ax
	popf
	pushf
	pop ax
	cmp ax, [bp]
	jne check1_pass
	mov si, no_32bit
	call print_string
	jmp stopper
check1_pass:
	popf
	; CPUID check
	pushfd
	mov bp, sp
	mov eax, [bp]
	xor eax, 1 << 21
	push eax
	popfd
	pushfd
	pop eax
	cmp eax, [bp]
	jne check2_pass
	mov si, no_support
	call print_string
	jmp stopper
check2_pass:
	popfd
	; print header for CPUID
	mov si, cpuid_header
	call print_string
	call newline
	; query maximum type ID
	xor eax, eax
	cpuid
	push eax
	; put loop counter
	push dword 0
	mov bp, sp
	; print CPUID info
cpuid_loop:
	mov eax, [bp]
	inc dword [bp]
	cmp eax, [bp + 4]
	jbe cpuid_proceed
	; stop
stopper:
	hlt
	jmp stopper
	; proceed
cpuid_proceed:
	; print ID
	add ax, '0'
	stosw
	sub ax, '0'
	; fetch information
	cpuid
	push edx
	push ecx
	push ebx
	push eax
	; print information
	mov cx, 4
cpuid_print:
	mov ax, ' '
	stosw
	pop eax
	push cx
	mov cx, 8
cpuid_print_reg:
	rol eax, 4
	push eax
	and ax, 0xf
	cmp al, 9
	jbe not_10_or_more
	add al, 'a' - '0' - 10
not_10_or_more:
	add al, '0'
	stosw
	pop eax
	loop cpuid_print_reg
	pop cx
	loop cpuid_print
	call newline
	jmp cpuid_loop

; print string (terminated by 0x00) from ds:si
; crobbers si, ax
print_string:
	xor ax, ax
print_string_loop:
	lodsb
	test al, al
	jnz print_string_proceed
	ret
print_string_proceed:
	stosw
	jmp print_string_loop

; print 32-bit unsigned integer at ds:bx
; print at least cx digits
; crobbers ax, bx, cx, dx, si
print_int:
	; allocate memory
	push bp
	mov bp, sp
	sub sp, 20
	; fetch value to print
	mov ax, [bx]
	mov [bp - 4], ax
	mov ax, [bx + 2]
	mov [bp - 2], ax
	; convert the value to string
	mov bx, 10
	lea si, [bp - 5]
print_int_loop:
	xor dx, dx
	mov ax, [bp - 2]
	div bx
	mov [bp - 2], ax
	mov ax, [bp - 4]
	div bx
	mov [bp - 4], ax
	add dl, '0'
	mov ss:[si], dl
	dec si
	test cx, cx
	jz print_int_no_cx_dec
	dec cx
print_int_no_cx_dec:
	or ax, [bp - 2]
	jnz print_int_loop
	test cx, cx
	jnz print_int_loop
	; print converted string
	lea cx, [bp - 5]
	sub cx, si
	inc si
	xor ax, ax
print_int_print_loop:
	db 0x36 ; segment override prefix: SS
	lodsb
	stosw
	loop print_int_print_loop
	mov sp, bp
	pop bp
	ret

; print non-negative float value in st(0), assuming it is not too large
; then pop (discard) st(0)
; crobbers ax, bx, cx, dx, si (including crobbering by print_int)
print_float:
	push bp
	mov bp, sp
	sub sp, 8
	; get FPU control word
	fwait
	fnstcw [bp - 4]
	fwait
	; set rounding to Chop, set Precision to 64 bits
	mov ax, [bp - 4]
	or ah, 0x0f
	mov [bp - 2], ax
	; set FPU control word
	fldcw [bp - 2]
	; print integer part of st(0)
	fwait
	fist dword [bp - 8]
	lea bx, [bp - 8]
	xor cx, cx
	push ds
	mov ax, ss
	mov ds, ax
	fwait
	call print_int
	pop ds
	; print dot
	mov ax, '.'
	stosw
	; set rounding to Round to Nearest or Even
	and byte [bp - 1], ~0x0c
	fldcw [bp - 2]
	fwait
	; prepare for extracting fractional part
	fld1
	fwait
	fxch
	fwait
	; extract fractional part
print_float_extract_fractional_part:
	fprem
	fwait
	fnstsw [bp - 6]
	fwait
	test byte [bp - 5], 4 ; test C2
	jnz print_float_extract_fractional_part
	; multiply value
	fimul dword [print_float_mult]
	; print fractional part
	fwait
	fist dword [bp - 8]
	lea bx, [bp - 8]
	mov cx, 9
	push ds
	mov ax, ss
	mov ds, ax
	fwait
	call print_int
	pop ds
	; remove the value and "1" from the FPU stack
	fcompp
	fwait
	; restore FPU control word
	fldcw [bp - 4]
	fwait
	mov sp, bp
	pop bp
	ret
print_float_mult:
	dd 1000000000

; move to new line
; crobbers ax, dx
newline:
	mov ax, di
	xor dx, dx
	add ax, 160
	div word [newline_mult]
	mul word [newline_mult]
	mov di, ax
	ret
newline_mult:
	dw 160

values:
	dd 4195835, 3145727
values2:
	dd 5506153, 294911

operator1:
	db ' / ', 0
operator2:
	db ' = ', 0

no_32bit:
	db '16-bit CPU', 0

no_support:
	db 'CPUID is not supported', 0

cpuid_header:
	db '  EAX      EBX      ECX      EDX', 0

%include "disk_trailer.asm"
