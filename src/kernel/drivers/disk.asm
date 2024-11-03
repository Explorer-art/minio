bits 16

section _TEXT class=CODE

global _disk_reset
global _disk_read
global _disk_get_params

;bool _cdecl disk_reset(uint8_t drive);

_disk_reset:
    push bp
    mov bp, sp

    mov ah, 0
    mov dl, [bp + 4]    ; dl - drive
    stc
    int 13h

    mov ax, 1
    sbb ax, 0

    pop bp
    mov sp, bp
    ret

;bool _cdecl disk_read(uint8_t drive, uint16_t cylinder, uint16_t sector, uint8_t head, uint8_t count, void far* disk_out);

_disk_read:
    push bp
    mov bp, sp

    push bx
    push es

    ; установка парамтеров
    mov ah, 02h
    mov dl, [bp + 4]    ; диск

    mov ch, [bp + 6]    ; старшие 8 бит цилиндра
    mov cl, [bp + 7]    ; младшие 2 бита цилиндра
    shl cl, 6

    mov al, [bp + 8]    ; сектор
    and al, 3Fh         ; маска для того, что бы сохранить только биты с 0-5
    or cl, al           ; объединяем регистры

    mov dh, [bp + 10]   ; головка

    mov al, [bp + 12]   ; количество секторов на чтение

    mov bx, [bp + 16]   ; es:bx - адрес по которому будут записаны данные
    mov es, bx
    mov bx, [bp + 14]

    ; вызов прерывания
    stc
    int 13h

    mov ax, 1
    sbb ax, 0

    pop es
    pop bx

    mov sp, bp
    pop bp
    ret

;bool _cdecl disk_get_params(uint8_t drive, uint8_t* disk_type_out, uint16_t* cylinders_out, uint16_t* sectors_out, uint16_t* heads_out);

_disk_get_params:
    push bp
    mov bp, sp

    push es
    push bx
    push si
    push di

    ; установка параметров
    mov ah, 08h
    mov dl, [bp + 4]    ; диск
    mov di, 0
    mov es, di

    ; вызов прерывания
    stc
    int 13h

    mov ax, 1
    sbb ax, 0

    ; возвращаем результат
    mov si, [bp + 6] ; тип диска
    mov [si], bl

    mov bl, ch
    mov bh, cl
    shr bh, 6
    mov si, [bp + 8]    ; цилиндр
    mov [si], bx

    xor ch, ch
    and cl, 3Fh
    mov si, [bp + 10]   ; сектор
    mov [si], cx

    mov cl, dh
    mov si, [bp + 12]   ; головка
    mov [si], cx

    pop di
    pop si
    pop bx
    pop es

    mov sp, bp
    pop bp
    ret