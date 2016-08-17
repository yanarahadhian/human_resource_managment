# language: id

Fitur: Edit kesehatan
  Sebagai superadmin
  Saya dapat mengedit kesehatan

Skenario: show kesehatan
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Informasi Kesehatan"
    Dan saya seharusnya melihat "Riwayat penyakit"
    Dan saya seharusnya melihat "Penyakit paru-paru basah"
    
Skenario: edit kesehatan
    Dengan saya telah login
    Ketika saya berkunjung ke edit kesehatan dengan person employee_identification_number = "11"
    Dan saya mengisi "person_known_illnesses" dengan "Penyakit lemah jantung"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Penyakit lemah jantung"
    Dan saya seharusnya tidak melihat "Penyakit paru-paru basah"