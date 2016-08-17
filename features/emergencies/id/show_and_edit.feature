# language: id

Fitur: Edit kotak darurat
  Sebagai superadmin
  Saya dapat mengedit kotak darurat

Skenario: show kontak darurat
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Kontak Darurat"
    Dan saya seharusnya melihat "Rama"
    Dan saya seharusnya melihat "02291984910"

Skenario: edit kontak darurat
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Dan saya mengisi "person_nama_kontak_darurat" dengan "Andi"
    Dan saya mengisi "person_no_telp_kontak_darurat" dengan "0213333333"
    Dan saya menekan "Simpan"
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Andi"
    Dan saya seharusnya tidak melihat "Rama"