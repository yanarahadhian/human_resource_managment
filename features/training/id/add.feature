# language: id

Fitur: tambah pelatihan
  Sebagai superadmin
  Saya dapat menambah pelatihan

 Skenario: list pelatihan
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 3 pelatihan berdasarkan person dengan employee_identification_number = "11"

 Skenario: tambah pelatihan
    Dengan saya telah login
    Dan saya berada di employment dengan employee_identification_number = "11"
    Ketika saya klik "Tambah Pelatihan"
    Dan saya mengisi "training_person_trained_in" dengan "Hartono Wiratmadja"
    Dan saya mengisi "training_training_start" dengan "11/01/2012"
    Dan saya mengisi "training_training_end" dengan "26/01/2012"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya memiliki 4 pelatihan berdasarkan person dengan employee_identification_number = "11"