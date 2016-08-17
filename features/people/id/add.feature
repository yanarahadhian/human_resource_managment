# language: id

Fitur: Tambah people
  Sebagai superadmin
  Saya dapat melihat menambah people

 Skenario: Menambah person dengan valid data
    Dengan saya telah login
    Dan saya berada di halaman people
    Ketika saya berkunjung ke tambah person
    Dan saya mengisi "person_firstname" dengan "Anggi"
    Dan saya mengisi "person_lastname" dengan "Permana"
    Dan saya mengisi "person_employee_identification_number" dengan "33"
    Dan saya mengisi "person_employment_date" dengan "19/01/2012"
    Dan saya mengisi "person_tax_status_id" dengan "T/1"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke halaman people
    Maka saya seharusnya melihat "Anggi Permana"
    Dan saya seharusnya melihat "33"