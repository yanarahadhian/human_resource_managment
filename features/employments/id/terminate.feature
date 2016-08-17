# language: id

Fitur: terminasi jabatan
  Sebagai superadmin
  Saya dapat melakukan terminasi untuk karyawan yang sudah keluar

 Skenario: list jabatan
    Dengan saya telah login
    Dan saya berada di employment dengan employee_identification_number = "11"
    Ketika saya klik "Terminasi"
    Dan saya mengisi "employment[created_at]" dengan "19/01/2012"
    Dan saya menekan "OK"
    Dan saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Nungky Selection resign tanggal 19/01/2012"
