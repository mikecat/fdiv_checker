FDIV Checker
============

割り算およびCPUID命令を実行し、[Pentium FDIV バグ](https://ja.wikipedia.org/wiki/Pentium_FDIV_%E3%83%90%E3%82%B0)があるかをチェックする PC-98 用ツールです。

以下を行います。

* 割り算 [4195835 / 3145727](https://web.archive.org/web/20240306141239/https://ipsr.ku.edu/stafffil/hoyle/pentium_fdiv/)
* 割り算 [5506153 / 294911](https://daviddeley.com/pentbug/pentbug8.htm)
* [CPUID命令](https://c9x.me/x86/html/file_module_x86_id_45.html)の実行結果の出力 (Basic CPUID Information のみ)

CPUID命令の実行結果のうち、ID=1 のときの EAX レジスタへの出力を十六進数で現した時、下位3桁が左(上位)から Family ID、Model、Stepping ID を表します。  
Wikipediaに、FDIVバグがあるCPUモデルの一覧があります。  
[Error de división del Intel Pentium - Wikipedia, la enciclopedia libre](https://es.wikipedia.org/w/index.php?title=Error_de_divisi%C3%B3n_del_Intel_Pentium&oldid=157472206#Modelos_afectados)

以下に出力例を示します。この例で表示されている割り算の結果は正しいものです。

```
4195835 / 3145727 = 1.333820449
5506153 / 294911 = 18.670558236

  EAX      EBX      ECX      EDX
0 00000001 756e6547 6c65746e 49656e69
1 00000525 00000000 00000000 000001bf
```

ビルドには [NASM](https://www.nasm.us/) を用います。

```
nasm cpuid_and_fdiv.asm -o cpuid_and_fdiv.img
```

イメージファイル `cpuid_and_fdiv.img` を1.23MBのフロッピーディスク (77トラック、1トラックあたり8セクタ、セクタサイズ1024バイト) に書き込んで実行します。

-------

This is a tool for PC-98 that performs some divisions and executes CPUID instruction to check if the [Pentium FDIV bug](https://en.wikipedia.org/wiki/Pentium_FDIV_bug) exists.

This tool performs following things:

* A division [4195835 / 3145727](https://web.archive.org/web/20240306141239/https://ipsr.ku.edu/stafffil/hoyle/pentium_fdiv/)
* A division [5506153 / 294911](https://daviddeley.com/pentbug/pentbug8.htm)
* Print results of [CPUID instruction](https://c9x.me/x86/html/file_module_x86_id_45.html) (only Basic CPUID Information)

The lower 3 digits of hexadecimal representation of the output for EAX register of CPUID with ID=1 represents for Family ID, Model, and Stepping ID respectively from left (higher) digits.  
A list of CPU models with the FDIV bug is on Wikipedia:  
[Error de división del Intel Pentium - Wikipedia, la enciclopedia libre](https://es.wikipedia.org/w/index.php?title=Error_de_divisi%C3%B3n_del_Intel_Pentium&oldid=157472206#Modelos_afectados)

This is an example of this tool's output. The results of divisions in this example are correct.

```
4195835 / 3145727 = 1.333820449
5506153 / 294911 = 18.670558236

  EAX      EBX      ECX      EDX
0 00000001 756e6547 6c65746e 49656e69
1 00000525 00000000 00000000 000001bf
```

You should use [NASM](https://www.nasm.us/) to build this tool.

```
nasm cpuid_and_fdiv.asm -o cpuid_and_fdiv.img
```

To execute, you should write the image file `cpuid_and_fdiv.img` to a 1.23MB-floppy disk (with 77 8-sector tracks and 1024-byte sectors).
