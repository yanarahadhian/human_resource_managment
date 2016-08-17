class AddAttachmentToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :headshot_file_name, :string # Original filename
    add_column :people, :headshot_content_type, :string # Mime type
    add_column :people, :headshot_file_size, :integer # File size in bytes

    add_column :people, :resume_file_name, :string # Original filename
    add_column :people, :resume_content_type, :string # Mime type
    add_column :people, :resume_file_size, :integer # File size in bytes

    add_column :people, :ktp_file_name, :string # Original filename
    add_column :people, :ktp_content_type, :string # Mime type
    add_column :people, :ktp_file_size, :integer # File size in bytes

    add_column :people, :npwp_file_name, :string # Original filename
    add_column :people, :npwp_content_type, :string # Mime type
    add_column :people, :npwp_file_size, :integer # File size in bytes
  end

  def self.down
    remove_column :people, :headshot_file_name
    remove_column :people, :headshot_content_type
    remove_column :people, :headshot_file_size

    remove_column :people, :resume_file_name
    remove_column :people, :resume_content_type
    remove_column :people, :resume_file_size

    remove_column :people, :ktp_file_name
    remove_column :people, :ktp_content_type
    remove_column :people, :ktp_file_size

    remove_column :people, :npwp_file_name
    remove_column :people, :npwp_content_type
    remove_column :people, :npwp_file_size
  end
end
