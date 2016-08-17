# language: id

Fitur: edit pelatihan
  Sebagai superadmin
  Saya dapat mengedit pelatihan

 Skenario: list pelatihan
    Dengan saya telah login
    Ketika saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Jack fernandes"

 Skenario: edit pelatihan
    Dengan saya telah login
    Dan saya berada di employment dengan employee_identification_number = "11"
    Ketika saya klik "Jack fernandes"
    Ketika saya klik "Edit"
    Dan saya mengisi "training_person_trained_in" dengan "Fitrah Ramadhani"
    Dan saya mengisi "training_training_start" dengan "15/01/2012"
    Dan saya mengisi "training_training_end" dengan "27/01/2012"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke employment dengan employee_identification_number = "11"
    Maka saya seharusnya melihat "Fitrah Ramadhani"
    Dan saya seharusnya tidak melihat "Jack fernandes"