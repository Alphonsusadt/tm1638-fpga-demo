# UTS IC Digital - iCESugar dan TM1638

Proyek menampilkan NIM `22-505908-TE-55399` pada delapan seven-segment TM1638.
Alur build diadaptasi dari template tugas:
https://github.com/arumdapta98/oss-cad-suite-tcl-template

## Kontrol sesuai tugas

Tombol S1/S2/S3 pada TM1638 dipetakan menjadi input mode dua bit.

| Tombol | Mode | Animasi | Interval |
|---|---|---|---|
| S1 | 00 | Bolak-balik | 1 detik |
| S2 | 01 | Ke kiri | 1 detik |
| S3 | 10 | Ke kanan | 1 detik |
| Tidak ditekan | Mode terakhir | Tetap berjalan | 1 detik |

Tekan sekali untuk memilih mode. Melepas tombol mempertahankan mode terakhir;
mode baru berubah saat tombol lain ditekan. Saat FPGA mulai, mode awal adalah 00.
Jika beberapa tombol baru ditekan bersamaan, prioritasnya S1, kemudian S2, lalu S3.
Tombol baru yang ditekan dapat mengganti mode meskipun tombol sebelumnya masih ditahan.
LED1 menunjukkan mode 00, LED2 mode 01, LED3 mode 10, dan tetap menyala setelah tombol dilepas.
S4-S8 tidak memilih mode. Hasil pembacaan empat byte tombol diterapkan sekaligus.
Tidak diperlukan dua switch eksternal untuk implementasi ini.

## Wiring TM1638 sesuai gambar

| TM1638 | PMOD 1 iCESugar | Pin FPGA / port |
|---|---|---|
| VCC | Pin 6, 3.3 V | - |
| GND | Pin 5 | - |
| STB | Pin 12 | 9 / tm_cs |
| CLK | Pin 11 | 4 / tm_clk |
| DIO | Pin 10 | 2 / tm_dio |

Gunakan `constraints/TM1638.pcf` untuk build ini.

## Array scrolling

`scroll_buffer[0:43]` adalah array 44 elemen, masing-masing pola seven-segment 7 bit.
Indeks 18-25 menjadi layar delapan digit; NIM awal berada di indeks 26-43.
Isi array bergeser setiap 12.000.000 siklus clock 12 MHz, setara satu detik.
Posisi berjalan dari 0 sampai 26 sehingga NIM dapat masuk dan keluar sepenuhnya.
Mode bolak-balik membalik arah pada batas; mode satu arah mengulang dari sisi masuk.
Satu frame disalin sebelum pengiriman agar delapan digit tetap konsisten.
Clock serial TM1638 dihasilkan register agar tidak memiliki pulsa decoding tambahan.

## Struktur proyek

- `tcl/top_tm1638_demo.v`: top level, tombol TM1638, array NIM, animasi dan protokol display.
- `tcl/tm1638.v`: driver serial TM1638.
- `tcl/top_tm1638_demo.tcl`: skrip sintesis top level.
- `tcl/tm1638.tcl`: skrip pemeriksaan driver.
- `constraints/TM1638.pcf`: clock dan antarmuka TM1638.
- `tb/`: pengujian otomatis.

Sumber Verilog ditempatkan pada direktori tcl sesuai instruksi literal slide.
Target build dan perangkat mengikuti template Windows/iCESugar.
Driver TM1638 berasal dari https://github.com/alangarf/tm1638-verilog; lihat LICENSE.

## Pengujian dan build pada Windows

Dari Command Prompt pada direktori proyek:

```bat
call setenv.bat
make verify
```

`make verify` menjalankan tiga testbench RTL, pengujian divider produksi
12.000.000 siklus, simulasi startup netlist sintesis, dan build FPGA.
Bitstream hasilnya adalah `build/top_tm1638_demo.bin`.

Untuk menjalankan pengujian singkat atau build saja:

```bat
make test
make all
```

Lokasi library iCE40 default sesuai instalasi lokal. Jika berbeda:

```bat
make test ICE40_CELLS=C:/lokasi/oss-cad-suite/share/yosys/ice40/cells_sim.v
```

`setenv.bat` juga perlu mengikuti lokasi instalasi OSS CAD Suite.
Setelah board terhubung dan programmer dapat dibuka:

```bat
icesprog -p
make flash
```

Pengujian mencakup driver serial, animasi, pemilihan mode dengan satu penekanan,
LED indikator, divider produksi, dan startup netlist hasil sintesis.
Bitstream kontrol tombol sudah di-flash ke iCESugar dan hash hasil readback
flash identik dengan file bitstream. Pengamatan tampilan dan penekanan tombol
fisik tetap perlu dilakukan langsung pada board.

## GitHub dan video demo

Repositori tujuan dari remote origin:
https://github.com/Alphonsusadt/tm1638-fpga-demo

### Link video demo

**Link video:** [Tonton video demo FPGA](https://youtu.be/bd-I7llxBzw)

Video perlu menunjukkan mode S1/00 bolak-balik, S2/01 kiri, dan S3/10 kanan,
termasuk LED1/LED2/LED3 serta mode yang tetap aktif setelah tombol dilepas.
Perubahan lokal terbaru belum otomatis dipublikasikan ke GitHub.
Setelah kode dan video tersedia di GitHub, kumpulkan link repositori melalui eLOK.
