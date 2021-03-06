;���������, ��������� ���� ������������ �������� �� ������ ���������� �������� N=4.

format PE console

entry Start

include 'win32a.inc'

section '.data' data readable writable
        enterStr1     db       'Enter coordinates of segment 1 (x1 y1 x2 y2) [-100, 100]', 10, 13, 0
        enterStr2     db       'Enter coordinates of segment 2 (x1 y1 x2 y2) [-100, 100]', 10, 13, 0
        enterStr3     db       'Enter coordinates of segment 3 (x1 y1 x2 y2) [-100, 100]', 10, 13, 0
        enterStr4     db       'Enter coordinates of segment 4 (x1 y1 x2 y2) [-100, 100]', 10, 13, 0
        wrongStr      db       'Wrong input', 10, 13, 0
        D             db       '%d', 0
        newLine       db       '', 10, 13, 0
        resultStr     db       'Pairs of parallel segments are:', 10, 13, 0
        finishStr     db       'Program is finished', 10, 13, 0
        heapA         dd       ?
        anc           dd       ?
        heapB         dd       ?
        A             dd       ?
        B             dd       ?
        i             dd       ?
        j             dd       ?
        M1            dd       4
        M2            dd       8
        M3            dd       12
        N             dd       16
        cur           dd       ?
        minVal        dd       -100
        maxVal        dd       100
        x1            dd       ?
        x2            dd       ?
        y1            dd       ?
        y2            dd       ?
        dx1           dd       ?
        dx2           dd       ?
        dy1           dd       ?
        dy2           dd       ?
        left          dd       ?

section '.code' code readable executable
        Start:
                call CreateA
                call ReadCoord1
                call ReadCoord2
                call ReadCoord3
                call ReadCoord4
                call CreateB
                call FormB
                call IsParallel

                cinvoke printf, finishStr

                invoke HeapFree,[heapA],HEAP_NO_SERIALIZE, [A]
                invoke HeapFree,[heapB],HEAP_NO_SERIALIZE, [B]

                invoke getch
                invoke ExitProcess

;���������� ������������ ���� ��������, ������������, �������� �� ��� �������������
IsParallel:
        cinvoke printf, resultStr
        mov [anc], esp
        mov [i], -2
        IsParallelLoop1:
                 add [i], 2
                 mov ebx, [i]
                 mov [j], ebx
                IsParallelLoop2:
                        add [j], 2
                        mov eax, [B]

                        ; ������ �������� �������� ��� ������ ���� �������� �� ������� �
                        mov ecx, [i]
                        mov ebx, [eax + ecx*4]
                        mov [dx1], ebx
                        add ecx, 1
                        mov ebx, [eax + ecx*4]
                        mov [dy1], ebx
                        mov ecx, [j]
                        mov ebx, [eax + ecx*4]
                        mov [dx2], ebx
                        add ecx, 1
                        mov ebx, [eax + ecx*4]
                        mov [dy2], ebx

                        mov ebx, [dx1]
                        imul ebx, dword [dy2]
                        mov [left], ebx
                        mov ebx, [dy2]
                        mov ebx, [dx2]
                        imul ebx, dword [dy1]
                        cmp ebx, [left]
                        je PrintIsParallel
                        cmp [i], 4
                        je Finish
                        cmp [j], 6
                        je IsParallelLoop1
                        cmp [j], 6
                        jl IsParallelLoop2
        mov esp, [anc]
        ret

;�������� ������ ���� ��������, ���� ��� ������������
PrintIsParallel:
        ; ������ �������� ������������ �� ��������� ��������� (i / 2 + 1)
         mov eax, [i]
         mov ecx, 2
         mov edx, 0
         div ecx
         add eax, 1
         cinvoke printf, D, eax
         mov eax, [j]
         mov ecx, 2
         mov edx, 0
         div ecx
         add eax, 1
         cinvoke printf, D, eax
         cinvoke printf, newLine
         cmp [i], 4
         je Finish
         cmp [j], 6
         je IsParallelLoop1
         cmp [j], 6
         jl IsParallelLoop2

; ��������� �����
Finish:
        ret

; ��������� ������ �������� �������� �������� �� ��� X � Y
FormB:
        mov [anc], esp
        mov [i], -1
        mov [j], 0
        FormLoop1:
                ; ������ ��������� �������� ����� ������� �������
                mov eax, [A]
                add [i], 1
                mov ecx, [i]
                mov ebx, [eax + ecx*4]
                mov [x1], ebx

                mov eax, [A]
                add [i], 1
                mov ecx, [i]
                mov ebx, [eax + ecx*4]
                mov [y1], ebx

                mov eax, [A]
                add [i], 1
                mov ecx, [i]
                mov ebx, [eax + ecx*4]
                mov [x2], ebx

                mov eax, [A]
                add [i], 1
                mov ecx, [i]
                mov ebx, [eax + ecx*4]
                mov [y2], ebx

                ; ����������, ����� �� ����� �������� ������ ��� ����� (�� ��������)
                mov ebx, [x1]
                ;���� x1 ������ x2, ������ ������ ����� �������� ������
                cmp ebx, [x2]
                jl ProjectionX2
                ;���� x1 ����� x2, ������ ������� ���������� ��� �
                cmp ebx, [x2]
                je ProjectionX2
                ;���� x1 ������ x2, ������ ������ ����� �������� ������
                cmp ebx, [x2]
                jg ProjectionX1

        mov esp, [anc]
        ret

; ��������� �������� �������� � ������ �, ���� ������ ����� �������� ������
ProjectionX1:
        mov ebx, [x1]
        sub ebx, dword [x2]
        mov eax, [B]
        mov ecx, [j]
        mov [eax + 4*ecx], ebx
        add [j], 1
        mov ebx, [y1]
        sub ebx, dword [y2]
        mov eax, [B]
        mov ecx, [j]
        mov [eax + 4*ecx], ebx
        add [j], 1
        cmp [i], 16
        jl FormLoop1
        ret

; ��������� �������� �������� � ������ �, ���� ������ ����� �������� ������ ��� ����� ����� ���������� �������� ��������
ProjectionX2:
        mov ebx, [x1]
        sub dword [x2], ebx
        mov eax, [B]
        mov ecx, [j]
        imul ecx, dword 4
        add eax, ecx
        mov ebx, [x2]
        mov [eax], ebx
        add [j], 1
        mov ebx, [y1]
        sub dword [y2], ebx
        mov eax, [B]
        mov ecx, [j]
        imul ecx, dword 4
        add eax, ecx
        mov ebx, [y2]
        mov [eax], ebx
        add [j], 1
        cmp [i], 16
        jl FormLoop1
        ret

; ��������� ������ ��� ������� �, � ������� �������� ���������� �������� �����
CreateA:
        mov [anc], esp
        invoke HeapCreate,HEAP_NO_SERIALIZE,0,0
        mov [heapA],eax
        invoke HeapAlloc,[heapA],HEAP_NO_SERIALIZE,N*8
        mov [A],eax
        mov esp, [anc]
        ret

; ��������� ������ ��� ������� �, � ������� �������� �������� ��������
CreateB:
        mov [anc], esp
        invoke HeapCreate,HEAP_NO_SERIALIZE,0,0
        mov [heapB], eax
        invoke HeapAlloc,[heapB],HEAP_NO_SERIALIZE,M2*8
        mov [B],eax
        mov esp, [anc]
        ret

; ������ ��������� �������� ����� 1 �������
ReadCoord1:
        mov esp, [anc]
        mov [anc], esp
        invoke printf, enterStr1
        mov [i], 0
        ReadLoop1:
                ;������ �������� � �������� �� �������
                cinvoke scanf, D, cur
                cmp [cur], -100
                jl WrongInput1
                cmp [cur], 100
                jg WrongInput1

                mov eax, [A]
                mov ecx, [i]

                mov ebx, [cur]
                mov [eax + 4*ecx], ebx

                add [i], 1
                mov ecx, [i]
                cmp ecx, [M1]
                jne ReadLoop1
        ;��������, �������� �� ��������� ���������� �����
        mov eax, [A]
        mov ebx, [eax]
        mov [x1], ebx
        mov ebx, [eax + 4]
        mov [y1], ebx
        mov eax, [A]
        mov ebx, [eax + 8]
        mov [x2], ebx
        mov eax, [A]
        mov ebx, [eax + 12]
        mov [y2], ebx
        mov ebx, [x1]
        cmp ebx, [x2]
        je IsItPoint1
        mov esp, [anc]
        ret

; ������ ��������� �������� ����� 2 �������
ReadCoord2:
        mov esp, [anc]
        mov [anc], esp
        invoke printf, enterStr2
        mov [i], 4
        ReadLoop2:
                ;������ �������� � �������� �� �������
                cinvoke scanf, D, cur
                cmp [cur], -100
                jl WrongInput2
                cmp [cur], 100
                jg WrongInput2

                mov eax, [A]
                mov ecx, [i]

                mov ebx, [cur]
                mov [eax + 4*ecx], ebx

                add [i], 1
                mov ecx, [i]
                cmp ecx, [M2]
                jne ReadLoop2
        ;��������, �������� �� ��������� ���������� �����
        mov eax, [A]
        mov ebx, [eax + 16]
        mov [x1], ebx
        mov ebx, [eax + 20]
        mov [y1], ebx
        mov eax, [A]
        mov ebx, [eax + 24]
        mov [x2], ebx
        mov eax, [A]
        mov ebx, [eax + 28]
        mov [y2], ebx
        mov ebx, [x1]
        cmp ebx, [x2]
        je IsItPoint2
        mov esp, [anc]
        ret

; ������ ��������� �������� ����� 3 �������
ReadCoord3:
        mov esp, [anc]
        mov [anc], esp
        invoke printf, enterStr3
        mov [i], 8
        ReadLoop3:
                 ;������ �������� � �������� �� �������
                cinvoke scanf, D, cur
                cmp [cur], -100
                jl WrongInput3
                cmp [cur], 100
                jg WrongInput3

                mov eax, [A]
                mov ecx, [i]

                mov ebx, [cur]
                mov [eax + 4*ecx], ebx

                add [i], 1
                mov ecx, [i]
                cmp ecx, [M3]
                jne ReadLoop3
        ;��������, �������� �� ��������� ���������� �����
        mov eax, [A]
        mov ebx, [eax + 32]
        mov [x1], ebx
        mov ebx, [eax + 36]
        mov [y1], ebx
        mov eax, [A]
        mov ebx, [eax + 40]
        mov [x2], ebx
        mov eax, [A]
        mov ebx, [eax + 44]
        mov [y2], ebx

        mov ebx, [x1]
        cmp ebx, [x2]
        je IsItPoint3
        mov esp, [anc]
        ret

; ������ ��������� �������� ����� 4 �������
ReadCoord4:
        mov esp, [anc]
        mov [anc], esp
        invoke printf, enterStr4
        mov [i], 12
        ReadLoop4:
                 ;������ �������� � �������� �� �������
                cinvoke scanf, D, cur
                cmp [cur], -100
                jl WrongInput4
                cmp [cur], 100
                jg WrongInput4

                mov eax, [A]
                mov ecx, [i]

                mov ebx, [cur]
                mov [eax + 4*ecx], ebx

                add [i], 1
                mov ecx, [i]
                cmp ecx, [N]
                jne ReadLoop4
        ;��������, �������� �� ��������� ���������� �����
        mov eax, [A]
        mov ebx, [eax + 48]
        mov [x1], ebx
        mov ebx, [eax + 52]
        mov [y1], ebx
        mov eax, [A]
        mov ebx, [eax + 56]
        mov [x2], ebx
        mov eax, [A]
        mov ebx, [eax + 60]
        mov [y2], ebx

        mov ebx, [x1]
        cmp ebx, [x2]
        je IsItPoint4
        mov esp, [anc]
        ret

; �������� ������ ��� ������ ������ ������� 1
WrongInput1:
        invoke printf, wrongStr
        jmp ReadLoop1

; �������� ������ ��� ������ ������ ������� 2
WrongInput2:
        invoke printf, wrongStr
        jmp ReadLoop2

; �������� ������ ��� ������ ������ ������� 3
WrongInput3:
        invoke printf, wrongStr
        jmp ReadLoop3

; �������� ������ ��� ������ ������ ������� 4
WrongInput4:
        invoke printf, wrongStr
        jmp ReadLoop4

; ��������, �������� �� ��������� ���������� ��� 1 ������� �����
IsItPoint1:
        mov ebx, [y1]
        cmp ebx, [y2]
        je ReadCoord1
        mov esp, [anc]
        ret

; ��������, �������� �� ��������� ���������� ��� 2 ������� �����
IsItPoint2:
        mov ebx, [y1]
        cmp ebx, [y2]
        je ReadCoord2
        mov esp, [anc]
        ret

; ��������, �������� �� ��������� ���������� ��� 3 ������� �����
IsItPoint3:
        mov ebx, [y1]
        cmp ebx, [y2]
        je ReadCoord3
        mov esp, [anc]
        ret

; ��������, �������� �� ��������� ���������� ��� 4 ������� �����
IsItPoint4:
        mov ebx, [y1]
        cmp ebx, [y2]
        je ReadCoord4
        mov esp, [anc]
        ret


section 'idata' import data readable

        library kernel, 'kernel32.dll',\
               msvcrt, 'msvcrt.dll',\
               user32,'USER32.DLL'
               include 'api\user32.inc'
               include 'api\kernel32.inc'

        import kernel,\
               ExitProcess, 'ExitProcess',\
               HeapCreate, 'HeapCreate',\
               HeapFree, 'HeapFree',\
               HeapAlloc, 'HeapAlloc'
               include 'api\kernel32.inc'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'