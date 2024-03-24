module FileHelper
  def self.sanitize_filename(file_name)
    just_filename = File.basename(file_name)
    FileHelper.clean_path(just_filename)
  end

  def self.move_file(oldloc, newloc)
    items = newloc.split(%r{/})
    filename = items[items.length - 1]
    items.delete_at(items.length - 1)

    newdir = ''
    items.each do |item|
      newdir += FileHelper.clean_path(item) + '/'
    end

    FileHelper.create_directory_from_path(newdir)
    FileUtils.mv oldloc, newdir + filename
  end

  def self.sanitize_folder(folder)
    folder.gsub('..', '')
  end

  def self.create_directory_from_path(path)
    FileUtils.mkdir_p(path) unless File.exist? path
  rescue StandardError => e
    raise 'An error occurred while creating this directory: ' + e.message
  end
end