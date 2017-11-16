class BackgroundImage
  include ActiveModel::Model
  attr_accessor :file
  validates :file, presence: true
  validates :content_type, format: /jpeg/

  class << self
    def find
      return unless exists?
      file = ActionDispatch::Http::UploadedFile.new(
        filename: basename,
        type: 'image/jpeg',
        tempfile: File.open(path)
      )
      new(file: file)
    end

    private
    def basename
      'background_image.jpg'
    end

    def path
      Rails.root.join('public', 'uploads', basename)
    end

    def exists?
      FileTest.file?(path)
    end
  end

  def basename
    self.class.send(:basename)
  end

  def path
    self.class.send(:path)
  end

  def content_type
    file.present? ? file.content_type : nil
  end

  def request_uri
    return unless exists?
    File.join(
      Rails.application.config.relative_url_root.presence || '/',
      'uploads',
      basename + '?t=' + timestamp
    )
  end

  def save
    return false unless valid?
    begin
      temp_path = "#{path}.#{Process.pid}.#{Time.current.to_i}.tmp"
      begin
        FileUtils.move(path, temp_path) if FileTest.file?(path)
        FileUtils.cp(file.tempfile.path, path)
        FileUtils.chmod(0644, path)
        true
      rescue
        FileUtils.cp(temp_path, path) if FileTest.file?(temp_path)
        false
      end
    ensure
      FileUtils.remove(temp_path) if FileTest.file?(temp_path)
    end
  end

  private
  def exists?
    file.present?
  end

  def stat
    @stat ||= File::Stat.new(path)
  end

  def timestamp
    (stat.mtime || stat.ctime).to_i.to_s
  rescue Errno::ENOENT
    ''
  end

end
