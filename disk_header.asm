org 0
bits 16

%ifndef volume_serial
	volume_serial equ 0x00000000
%endif

	jmp _start
	times 3 - ($ - $$) nop
	db 'MSWIN4.1'    ; OEM name
	dw 1024          ; # bytes / sector
	db 1             ; # sectors / cluster
	dw 1             ; # reserved sectors
	db 2             ; # FATs
	dw 0xc0          ; # entries in root directory
	dw 0x4d0         ; # total sectors
	db 0xfe          ; media type
	dw 2             ; # sectors / FAT
	dw 8             ; # sectors / track
	dw 2             ; # heads
	dd 0             ; # hidden sectors
	dd 0             ; # total sectors (for large disk)
	db 0             ; drive number
	db 0             ; reserved
	db 0x29          ; boot signature
	dd volume_serial ; volume serial number
	db 'NO NAME    ' ; volume label
	db 'FAT12   '    ; file system type
