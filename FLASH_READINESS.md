# Hasil pengujian sebelum flashing

Tanggal: 2 Oktober 2026. Board target: iCESugar V1.5, iCE40UP5K-SG48, clock 12 MHz.

`make verify` selesai dengan exit code 0 dari sumber setelah perbaikan terakhir.

| Pemeriksaan | Hasil |
|---|---|
| Driver serial: TX/RX, LSB-first, 8 pulsa per byte | PASS |
| Array 44 elemen: mode tetap setelah release, prioritas, kiri/kanan, wrap, bolak-balik, frame | PASS |
| Model TM1638: mapping S1-S8, DIO, perintah, 16 byte/frame | PASS |
| Reset awal dan divider produksi 12.000.000 siklus | PASS |
| Netlist sintesis: startup, mode/LED tetap setelah release, prioritas dan 11 frame | PASS |
| Build make all: sintesis, place-and-route, icepack | PASS |
| Target timing 12 MHz | PASS, estimasi akhir 43.53 MHz |
| Kapasitas FPGA | 1232/5280 logic cells, 23% |
| Unpack/repack bitstream, hash identik | PASS |
| Programmer icesprog -p | iCESugar, W25Q64 8 MB terdeteksi |
| make flash | PASS, 104090 byte ditulis pada offset 0 |
| Readback flash 104090 byte dan SHA256 | PASS, identik dengan bitstream |

Bitstream: `build/top_tm1638_demo.bin`, 104090 byte.

SHA256:
`F4E17C808C3997E017AE7AA7E2A4BA993347445ADD9BD6C5A232EB8E52A8D0D9`

Log lengkap: `build/final_verify.log`.
Hash sumber RTL, pin constraints, dan bitstream: `build/verified_manifest.json`.

Perbaikan pada pengujian akhir:

- Deklarasi dio_out dibuat kompatibel dengan Icarus bawaan OSS CAD Suite.
- Clock serial dijadikan output register. Simulasi netlist sebelumnya menemukan
  edge tambahan pada clock kombinasi; pengujian yang sama kini lulus.
- Skrip Tcl memuat library SB_IO sebelum hierarchy check dan memakai yosys proc.
- Target make verify tersedia untuk mengulang seluruh pemeriksaan sebelum build.
- Perintah flashing menggunakan opsi write eksplisit: icesprog -w.

Peringatan sintesis tentang tri-state dan array menjadi register tetap tercatat.
Netlist disimulasikan dan diterima nextpnr; place-and-route selesai tanpa warning.

Bitstream sudah di-flash ke iCESugar dan diverifikasi melalui readback flash.
Kontrol memakai tombol TM1638: tekan sekali S1 untuk 00 bolak-balik, S2 untuk
01 kiri, S3 untuk 10 kanan. Melepas tombol mempertahankan mode dan LED aktif.
Mode berubah saat tombol baru ditekan. Jika beberapa tombol baru ditekan bersamaan,
prioritasnya S1, kemudian S2, lalu S3. Saat FPGA mulai, mode awal adalah 00.
Tidak diperlukan switch eksternal.
Sumber Verilog berada di direktori tcl sesuai slide.
Log flashing: build/final_flash.log; readback: build/final_readback.log.
Pengamatan langsung atas tampilan dan tombol fisik masih perlu dilakukan.

Di Command Prompt, dari direktori proyek, setelah iCESugar terhubung:

```bat
call setenv.bat
icesprog -p
make flash
```

Sesudah flashing, periksa gerakan setiap satu detik, tombol S1/S2/S3,
LED indikator mode, dan pembalikan arah pada kedua ujung untuk mode 00.
Lihat README untuk wiring TM1638 dan SUBMISSION.md untuk pengumpulan tugas.
