class CreateHonor < ActiveRecord::Migration
  def self.up
    create_table :honors do |t|
      t.references :companies
      t.references :people
      t.decimal :salary, :precision => 12, :scale => 2
      t.decimal :overtime_compensation, :precision => 12, :scale => 2
      t.decimal :leaves_redemption, :precision => 12, :scale => 2
      t.decimal :jamsostek_insurance, :precision => 12, :scale => 2
      t.decimal :jamsostek_cut, :precision => 12, :scale => 2
      t.decimal :final_take_home_pay, :precision => 12, :scale => 2
      t.date :honor_date
      t.decimal :salary_cut, :precision => 12, :scale => 2
      t.decimal :debt, :precision => 12, :scale => 2
      t.decimal :cooperation_cut, :precision => 12, :scale => 2
      t.decimal :jamsostek_house_cut, :precision => 12, :scale => 2
      t.decimal :adjustment_paid_by_company, :precision => 12, :scale => 2
      t.decimal :gross_income, :precision => 12, :scale => 2
      t.decimal :position_expenses, :precision => 12, :scale => 2
      t.decimal :month_net_income, :precision => 12, :scale => 2
      t.decimal :year_net_income, :precision => 12, :scale => 2
      t.decimal :ptkp, :precision => 12, :scale => 2
      t.decimal :pkp, :precision => 12, :scale => 2
      t.decimal :pph_indebted_per_month, :precision => 12, :scale => 2
      t.decimal :pph_indebted_per_year, :precision => 12, :scale => 2
      t.decimal :honor_status
      t.text :internal_note
      t.text :note_for_employee
      t.timestamps
    end
  end

  def self.down
    drop_table :honors
  end
end
