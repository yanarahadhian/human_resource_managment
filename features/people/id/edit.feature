# language: id

Fitur: Tambah people
  Sebagai superadmin
  Saya dapat melihat menambah people

Skenario: list people
    Dengan saya telah login
    Ketika saya berkunjung ke halaman people
    Maka saya harus memiliki 2 person
    Dan saya seharusnya melihat "Nungky Selection"

 Skenario: Edit person dengan valid data
    Dengan saya telah login
    Dan saya berada di halaman people
    Ketika saya berkunjung ke edit person dengan id = 1
    Dan saya mengisi "person_firstname" dengan "Vita"
    Dan saya mengisi "person_lastname" dengan "Asmara"
    Dan saya mengisi "person_tax_status_id" dengan "T/1"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke halaman people
    Maka saya seharusnya melihat "Vita Asmara"
    Dan saya seharusnya tidak melihat "Nungky Selection"