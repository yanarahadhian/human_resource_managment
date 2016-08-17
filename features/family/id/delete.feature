# language: id

Fitur: Hapus keluarga
  Sebagai superadmin
  Saya dapat melihat menghapus keluarga

 Skenario: list keluarga
    Dengan saya telah login
    Ketika saya berkunjung ke person dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 keluarga berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "Data Keluarga"
    Dan saya seharusnya melihat "Asmiranda"

 Skenario: hapus keluarga
    Dengan saya telah login
    Dan saya berada di person dengan employee_identification_number = "11"
    Ketika saya mencentang "myrow[ids][]" pada keluarga dengan id = "1"
    Dan saya menghapus keluarga
    Maka saya seharusnya memiliki 0 keluarga berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya tidak melihat "Asmiranda"