# frozen_string_literal: true

class Backup
  include Rails.application.routes.url_helpers

  BACKUP_DIR = Rails.root.join('tmp', 'backup')
  ZIP_OUTPUT_DIR = BACKUP_DIR.join('zip')
  private_constant :BACKUP_DIR, :ZIP_OUTPUT_DIR

  def initialize(user)
    @user = user
  end

  def create
    generate_json_files
    copy_contents
    generate_zip_file
    remove_json_files
  end

  def zip_filename
    "#{user.name}_backup.zip"
  end

  def zip_path
    ZIP_OUTPUT_DIR.join(zip_filename)
  end

  def zip_exist?
    zip_path.exist?
  end

  def mtime
    return unless zip_exist?
    zip_path.mtime
  end

  def self.delete_old_files(before = 3.days.ago)
    ZIP_OUTPUT_DIR.each_child do |zip|
      s = File::Stat.new(zip)
      if s.mtime.to_date <= before
        File.delete(zip)
      end
    end
  end

  private

    attr_reader :user

    def json_output_dir
      BACKUP_DIR.join(user.name)
    end

    def generate_json_files
      # json_output_dirをルートとして階層を作る
      # ZipFileGeneratorに渡して、再帰的にzipしてもらう
      user_dir = json_output_dir.join('user')
      projects_dir = json_output_dir.join('projects')
      user_dir.mkpath
      projects_dir.mkpath

      File.open(user_dir.join('user.json'), 'w') do |file|
        JSON.dump(user_hash, file)
      end
      File.open(projects_dir.join('projects.json'), 'w') do |file|
        JSON.dump(projects_hash, file)
      end
      File.open(json_output_dir.join('comments.json'), 'w') do |file|
        JSON.dump(comments_hash, file)
      end
    end

    def remove_json_files
      FileUtils.rm_rf(json_output_dir)
    end

    def generate_zip_file
      File.delete(zip_path) if File.exist?(zip_path)
      ZIP_OUTPUT_DIR.mkpath
      zf = ZipFileGenerator.new(json_output_dir, zip_path)
      zf.write
    end

    def base_url
      "https://fabble.cc"
    end

    def image_url(path)
      return unless path

      URI.join(base_url, path).to_s
    end

    def groups
      @groups ||= user.groups.active
    end

    def projects
      @projects ||= user.projects.active
    end

    def user_hash
      {
        source: owner_url(user, host: base_url),
        name: user.name,
        url: user.url,
        location: user.location,
        email: user.email,
        avatar: image_url(user.avatar.url),
        created_at: user.created_at.iso8601,
        identities: user.identities.map do |identity|
          {
            provider: identity.provider,
            email: identity.email,
            image: identity.image,
            name: identity.name,
            nickname: identity.nickname,
            created_at: identity.created_at.iso8601
          }
        end,
        groups: groups.map do |group|
          {
            name: group.name,
            url: group.url,
            location: group.location,
            avatar: image_url(group.avatar.url),
            role: user.membership_in(group).role
          }
        end
      }
    end

    def projects_hash
      projects.map do |project|
        {
          source: project_url(project.owner, project, host: base_url),
          title: project.title,
          description: project.description,
          created_at: project.created_at.iso8601,
          media: project.figures.map { |figure| image_url(figure.content.url) },
          youtube: project.figures.find { |figure| figure.link.present? }&.link,
          states: project.states.order(:position).map do |card|
            {
              contributors: card.contributors.map do |contributor|
                {
                  source: owner_url(contributor, host: base_url),
                  name: contributor.name
                }
              end,
              title: card.title,
              description: card.description,
              created_at: card.created_at.iso8601,
              media: card.figures.map { |figure| image_url(figure.content.url) },
              youtube: card.figures.find { |figure| figure.link.present? }&.link,
              material: card.attachments.where(kind: 'material').map { |a| image_url(a.content.url) }.compact,
              tool: card.attachments.where(kind: 'tool').map { |a| image_url(a.content.url) }.compact,
              blueprint: card.attachments.where(kind: 'blueprint').map { |a| image_url(a.content.url) }.compact,
              attachment: card.attachments.where(kind: 'attachment').map { |a| image_url(a.content.url) }.compact,
              annotations: card.annotations.map do |annotation|
                {
                  title: annotation.title,
                  description: annotation.description,
                  created_at: annotation.created_at.iso8601,
                  media: annotation.figures.map { |figure| image_url(figure.content.url) },
                  youtube: annotation.figures.find { |figure| figure.link.present? }&.link,
                  material: annotation.attachments.where(kind: 'material').map { |a| image_url(a.content.url) }.compact,
                  tool: annotation.attachments.where(kind: 'tool').map { |a| image_url(a.content.url) }.compact,
                  blueprint: annotation.attachments.where(kind: 'blueprint').map { |a| image_url(a.content.url) }.compact,
                  attachment: annotation.attachments.where(kind: 'attachment').map { |a| image_url(a.content.url) }.compact
                }
              end
            }
          end,
          usages: project.usages.map do |card|
            {
              title: card.title,
              description: card.description,
              created_at: card.created_at.iso8601,
              media: card.figures.map { |figure| image_url(figure.content.url) },
              youtube: card.figures.find { |figure| figure.link.present? }&.link,
              material: card.attachments.where(kind: 'material').map { |a| image_url(a.content.url) }.compact,
              tool: card.attachments.where(kind: 'tool').map { |a| image_url(a.content.url) }.compact,
              blueprint: card.attachments.where(kind: 'blueprint').map { |a| image_url(a.content.url) }.compact,
              attachment: card.attachments.where(kind: 'attachment').map { |a| image_url(a.content.url) }.compact
            }
          end,
          memos: project.note_cards.map do |card|
            {
              title: card.title,
              description: card.description,
              created_at: card.created_at.iso8601,
              media: card.figures.map { |figure| image_url(figure.content.url) },
              youtube: card.figures.find { |figure| figure.link.present? }&.link,
              material: card.attachments.where(kind: 'material').map { |a| image_url(a.content.url) }.compact,
              tool: card.attachments.where(kind: 'tool').map { |a| image_url(a.content.url) }.compact,
              blueprint: card.attachments.where(kind: 'blueprint').map { |a| image_url(a.content.url) }.compact,
              attachment: card.attachments.where(kind: 'attachment').map { |a| image_url(a.content.url) }.compact
            }
          end
        }
      end
    end

    def comments_hash
      {
        projects: user.project_comments.map do |comment|
          {
            source: project_url(comment.project.owner, comment.project, anchor: "project-comment-#{comment.id}", host: base_url),
            body: comment.body,
            created_at: comment.created_at.iso8601
          }
        end,
        recipes: user.card_comments.map do |comment|
          {
            source: project_url(comment.card.project.owner, comment.card.project, anchor: "card-comment-#{comment.id}", host: base_url),
            body: comment.body,
            created_at: comment.created_at.iso8601
          }
        end
      }
    end

    def copy_contents
      avatar_dir = json_output_dir.join('user', 'avatar')
      avatar_dir.mkpath
      FileUtils.copy(user.avatar.file.file, avatar_dir)
      projects.each do |project|
        copy_project_contents(project)
      end
    end

    def copy_project_contents(project)
      contents = []

      figures = project.figures.select { |figure| figure.content.present? }
      figures.each { |figure| contents << figure&.content&.file&.file }

      project.states.each do |state|
        state.figures.each { |figure| contents << figure&.content&.file&.file }
        state.attachments.each { |attachment| contents << attachment&.content&.file&.file }
        state.annotations.each do |annotation|
          annotation.figures.each { |figure| contents << figure&.content&.file&.file }
          annotation.attachments.each { |attachment| contents << attachment&.content&.file&.file }
        end
      end

      project.usages.each do |usage|
        usage.figures.each { |figure| contents << figure&.content&.file&.file }
        usage.attachments.each { |attachment| contents << attachment&.content&.file&.file }
      end

      project.note_cards.each do |note_card|
        note_card.figures.each { |figure| contents << figure&.content&.file&.file }
        note_card.attachments.each { |attachment| contents << attachment&.content&.file&.file }
      end
      contents.compact!

      if contents.present?
        contents_dir = json_output_dir.join('projects', 'media', project.name)
        contents_dir.mkpath
        FileUtils.copy(contents, contents_dir)
      end
    end
end
