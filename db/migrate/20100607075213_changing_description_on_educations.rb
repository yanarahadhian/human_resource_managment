class ChangingDescriptionOnEducations < ActiveRecord::Migration
  def self.up
    rename_column(:educations, :educational_description, :education_description)
    add_column :educations, :certificate_file_name, :string # Original filename
    add_column :educations, :certificate_content_type, :string # Mime type
    add_column :educations, :certificate_file_size, :integer # File size in bytes
  end

  def self.down
    rename_column(:educations, :education_description, :educational_description)
    remove_column :educations, :certificate_file_name, :certificate_content_type, :certificate_file_size # File size in bytes
  end
end
