# language: id

Fitur: Hapus pekerjaan
  Sebagai superadmin
  Saya dapat melihat menghapus pekerjaan

 Skenario: list pekerjaan
    Dengan saya telah login
    Ketika saya berkunjung ke riwayat dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 riwayat pekerjaan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Sekretaris ,Humas"

 Skenario: hapus pekerjaan
    Dengan saya telah login
    Dan saya berada di riwayat dengan employee_identification_number = "11"
    Ketika saya mencentang "myrow[ids][]" pada pekerjaan dengan id = "1"
    Dan saya menghapus pekerjaan
    Maka saya seharusnya memiliki 0 riwayat pekerjaan berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya tidak melihat "Sekretaris ,Humas"