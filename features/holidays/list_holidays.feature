# language: en
#Pengguna yang dapat mengakses halaman ini adalah pengguna dengan access key holiday_index.
#
#Pengguna melihat daftar hari libur perusahaannya dan pada hari libur apa saja termasuk cuti bersama sehingga pengguna dapat menginformasikan dengan mudah mengenai hari libur tersebut kepada karyawannya.
#Data yang dimunculkan:
#- Nama hari libur
#- Periode hari libur
#- Lama hari libur
#- Termasuk cuti bersama
#- Jumlah hari libur yang termasuk cuti bersama
#
#Jika data lebih dari 10, maka button pagination muncul.
Feature: Settings Holiday Page
  In order to Access Settings - Holiday page
  As a signed in user with access holiday_index
  I want to see List of Holidays page for my company

  Scenario: Signed in user with access holiday_index accessing Settings - Holiday page with national_holidays data
    Given one logged in user
    When I go to holidays page
    Then I should have 2 national_holidays
    And I should see "HUT RI ke-66"
    And I should see "Idul fitri dan cuti bersama"

  Scenario: Signed in user with access holiday_index accessing Settings
    Given one logged in user
    When I set filter on holidays page
    Then I should see "HUT RI ke-66"
    And I should not see "Idul fitri dan cuti bersama"

  Scenario: Signed in user with access holiday_index accessing blank Settings - Holiday page
    Given one logged in user
    And I have no national holidays
    When I go to holidays page
    Then I should have 0 national_holidays
    And I should see "Belum Ada Data Hari Libur."
    And I should see "Silahkan Tambah Hari Libur untuk menambah data"
