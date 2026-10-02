# Pengumpulan UTS

Repositori tujuan: https://github.com/Alphonsusadt/tm1638-fpga-demo

## Demo pada perangkat

Setelah make verify lulus, sambungkan TM1638 sesuai README,
probe programmer, lalu flash bitstream. Amati mode berikut:

| Tombol / mode | Yang harus terlihat |
|---|---|
| Tekan sekali S2 / 01 | NIM masuk dari kanan dan bergeser ke kiri, satu posisi setiap detik |
| Tekan sekali S3 / 10 | NIM masuk dari kiri dan bergeser ke kanan, satu posisi setiap detik |
| Tekan sekali S1 / 00 | NIM bergerak ke kiri, keluar penuh, lalu berbalik ke kanan |

Untuk masing-masing mode satu arah, amati minimal 28 detik agar satu putaran
dan pengulangan terlihat. Untuk 00, amati minimal 54 detik agar pembalikan
di kedua ujung terlihat. Tampilan tujuh segmen menggambarkan T sebagai t.
Lepaskan tombol setelah memilih mode; pastikan gerakan dan LED indikator tetap
sesuai mode pilihan sampai tombol lain ditekan.

## Isi video

Rekam sekitar 2-3 menit: tunjukkan board dan wiring, jelaskan tombol S1/S2/S3,
tunjukkan NIM berjalan pada 01, 10, dan 00, serta interval satu detik.
Unggah video yang benar-benar merekam perangkat fisik, lalu tambahkan linknya
pada bagian Video demo FPGA di README.

## Sebelum submit

- Pastikan sumber tcl/top_tm1638_demo.v dan tcl/tm1638.v tersedia di GitHub.
- Sertakan Makefile, constraints, skrip Tcl, testbench, README dan LICENSE.
- Pastikan README berisi link video yang dapat diakses penguji.
- Publikasikan perubahan lokal terbaru ke repositori tujuan.
- Buka repositori dan link video untuk memeriksa aksesnya.
- Kumpulkan link repositori melalui eLOK sesuai slide.

Status saat penyesuaian kode: video, pengujian fisik, publikasi perubahan terbaru,
dan pengumpulan eLOK masih memerlukan tindakan nyata; dokumen ini tidak
menyatakan langkah-langkah tersebut sudah dilakukan.
