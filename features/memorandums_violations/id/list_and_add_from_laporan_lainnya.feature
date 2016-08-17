# language: id

Fitur: Add SP
  Sebagai superadmin
  Saya dapat mengedit pelanggaran

 Skenario: list SP
    Dengan saya telah login 
    Ketika saya berkunjung ke SP
    Maka saya seharusnya memiliki 3 SP

 Skenario: tambah SP
    Dengan saya telah login
    Ketika saya berkunjung ke tambah SP
    Dan saya mengisi "person_name" dengan "Devi Puspitasari, 22, CK, EDP"
    Dan saya mengisi "violation_violation_category" dengan "Ringan"
    Dan saya mengisi "violation_occurence_date" dengan "01/01/2012"
    Dan saya mengisi "violation_action_taken" dengan "Warning"
    Dan saya mengisi "violation_active_until" dengan "01/02/2012"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke SP
    Maka saya seharusnya memiliki 4 SP