# language: id

Fitur: tambah jabatan
  Sebagai superadmin
  Saya dapat melihat daftar jabatan

 Skenario: list jabatan
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 1 employment berdasarkan person dengan employee_identification_number = "11"

 Skenario: tambah jabatan
    Dengan saya telah login
    Dan saya berada di employment dengan employee_identification_number = "11"
    Ketika saya klik "Tambah Jabatan"
    Dan saya mengisi "employment_employment_start" dengan "11/01/2012"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 2 employment berdasarkan person dengan employee_identification_number = "11"
    Dan saya seharusnya melihat "11/01/2012"