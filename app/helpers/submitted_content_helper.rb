module SubmittedContentHelper

  # Installing RubyZip
  # run the command,  gem install rubyzip
  # restart the server
  def self.unzip_file(file_name, unzip_dir, should_delete)
    # Checking if file exists.
    raise "File #{file_name} does not exist" unless File.exist?(file_name)
    # begin
    Zip::File.open(file_name) do |zf|
      zf.each do |e|
        extract_entry(e, unzip_dir)
      end
    end

    if should_delete
      # The zip file is no longer needed, so delete it
      File.delete(file_name)
    end
  end

  private

  def extract_entry(e, unzip_dir)
    safename = FileHelper.sanitize_filename(e.name)
    fpath = File.join(unzip_dir, safename)
    FileUtils.mkdir_p(File.dirname(fpath))
    zf.extract(e, fpath)
  end
end
