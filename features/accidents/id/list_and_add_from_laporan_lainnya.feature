# language: id

Fitur: tambah kecelakaan kerja
  Sebagai superadmin
  Saya dapat manambah kecelakaan kerja

 Skenario: list kecelakaan kerja
    Dengan saya telah login
    Ketika saya berkunjung ke kecelakaan kerja
    Maka saya seharusnya memiliki 1 kecelakaan kerja

Skenario: tambah kecelakaan kerja
    Dengan saya telah login
    Ketika saya berkunjung ke tambah kecelakaan kerja
    Dan saya mengisi "person_name" dengan "Devi Puspitasari, 22, CK, EDP"
    Dan saya mengisi "accident_accident_date" dengan "15/01/2012"
    Dan saya mengisi "autocomplete_accident_location_name" dengan "Depan gedung sate bandung"
    Dan saya mengisi "accident_accident_person_in_charge" dengan "Dani Ramadhani"
    Dan saya mengisi "accident_causes" dengan "Jatuh dari motor"
    Dan saya menekan "Simpan"
    Dan saya berkunjung ke kecelakaan kerja
    Maka saya seharusnya memiliki 2 kecelakaan kerja
    