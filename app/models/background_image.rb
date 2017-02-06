class BackgroundImage
  extend Forwardable
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
      Rails.root.join('public', basename)
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
      basename + '?t=' + timestamp
    )
  end

  def save
    return false unless valid?
    FileUtils.cp(file.tempfile.path, path)
    true
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
