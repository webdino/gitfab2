# frozen_string_literal: true

class Backup
  include Rails.application.routes.url_helpers

  def initialize(user)
    @user = user
  end

  def create
    generate_json_files
    generate_zip_file
    FileUtils.rm_rf(json_output_dir) # cleanup json directories
  end

  def zip_filename
    "#{user.name}_backup.zip"
  end

  def path_to_zip
    zip_output_dir.join(zip_filename)
  end

  def self.delete_old_files
    zip_files = Dir.glob("#{Rails.root.join('tmp', 'backup', 'zip', '*')}")
    zip_files.each do |zip|
      s = File::Stat.new(zip)
      if s.mtime.to_date <= 3.days.ago
        File.delete(zip)
      end
    end
  end

  private

    attr_reader :user

    def json_output_dir
      Rails.root.join('tmp', 'backup', user.name)
    end

    def zip_output_dir
      Rails.root.join('tmp', 'backup', 'zip')
    end

    def generate_json_files
      # json_output_dirをルートとして階層を作る
      # ZipFileGeneratorに渡して、再帰的にzipしてもらう
      unless Dir.exist?(json_output_dir)
        FileUtils.mkdir_p("#{json_output_dir}/user")
        FileUtils.mkdir_p("#{json_output_dir}/projects")
      end

      File.open("#{json_output_dir}/user/user.json", 'w') do |file|
        JSON.dump(user_hash, file)
      end
      File.open("#{json_output_dir}/projects/projects.json", 'w') do |file|
        JSON.dump(projects_hash, file)
      end
      File.open("#{json_output_dir}/comments.json", 'w') do |file|
        JSON.dump(comments_hash, file)
      end

      # copy contents
      FileUtils.mkdir_p("#{json_output_dir}/user/avatar")
      FileUtils.copy(user.avatar.file.file, "#{json_output_dir}/user/avatar")
      user.projects.each do |project|
        copy_project_contents(project)
      end
    end

    def generate_zip_file
      File.delete(path_to_zip) if File.exist?(path_to_zip)
      Dir.mkdir(zip_output_dir) unless Dir.exist?(zip_output_dir)
      zf = ZipFileGenerator.new(json_output_dir, path_to_zip)
      zf.write
    end

    def base_url
      "https://fabble.cc"
    end

    def image_url(path)
      URI.join(base_url, path).to_s
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
        groups: user.groups.map do |group|
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
      user.projects.map do |project|
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
              material: card.attachments.select { |a| a.kind == 'material' },
              tool: card.attachments.select { |a| a.kind == 'tool' },
              blueprint: card.attachments.select { |a| a.kind == 'blueprint' },
              attachment: card.attachments.select { |a| a.kind == 'attachment' },
              annotations: card.annotations.map do |annotation|
                {
                  title: annotation.title,
                  description: annotation.description,
                  created_at: annotation.created_at.iso8601,
                  media: annotation.figures.map { |figure| image_url(figure.content.url) },
                  youtube: annotation.figures.find { |figure| figure.link.present? }&.link,
                  material: annotation.attachments.select { |a| a.kind == 'material' },
                  tool: annotation.attachments.select { |a| a.kind == 'tool' },
                  blueprint: annotation.attachments.select { |a| a.kind == 'blueprint' },
                  attachment: annotation.attachments.select { |a| a.kind == 'attachment' }
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
              youtube: card.figures.find { |figure| figure.link.present? }&.link
            }
          end,
          memos: project.note_cards.map do |card|
            {
              title: card.title,
              description: card.description,
              created_at: card.created_at.iso8601,
              media: card.figures.map { |figure| image_url(figure.content.url) },
              youtube: card.figures.find { |figure| figure.link.present? }&.link
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
            # TODO: source: https://fabble.cc/card_comments/323
            # 上記のようになっているが要確認
            source: card_comment_url(comment, host: base_url),
            body: comment.body,
            created_at: comment.created_at.iso8601
          }
        end
      }
    end

    def copy_project_contents(project)
      contents = []

      figures = project.figures.select { |figure| figure.content.present? }
      figures.each { |figure| contents << figure&.content&.file&.file }

      project.states.each do |state|
        state.figures.each { |figure| contents << figure&.content&.file&.file }
        state.annotations.each do |annotation|
          annotation.figures.each { |figure| contents << figure&.content&.file&.file }
        end
      end

      project.note_cards.each do |note_card|
        note_card.figures.each { |figure| contents << figure&.content&.file&.file }
      end
      contents.compact!

      if contents.present?
        FileUtils.mkdir_p("#{json_output_dir}/projects/media/#{project.name}")
        FileUtils.copy(contents, "#{json_output_dir}/projects/media/#{project.name}")
      end
    end
end
