# frozen_string_literal: true

class Backup
  def initialize(user)
    @user = user
  end

  def run
    generate_json_files
    generate_zip_file
    FileUtils.rm_rf(input_dir) # cleanup json directories
  end

  def zip_filename
    "#{@user.name}_backup.zip"
  end

  def path_to_zip
    output_dir.join(zip_filename)
  end

  private

    def input_dir
      Rails.root.join('tmp', 'backup', @user.name)
    end

    def output_dir
      Rails.root.join('tmp', 'backup', 'zip')
    end

    def generate_json_files
      # input_dirをルートとして階層を作る
      # ZipFileGeneratorに渡して、再帰的にzipしてもらう
      unless Dir.exist?(input_dir)
        FileUtils.mkdir_p("#{input_dir}/user")
        FileUtils.mkdir_p("#{input_dir}/projects")
      end

      File.open("#{input_dir}/user/user.json", 'w') do |file|
        JSON.dump(generate_user_hash, file)
      end
      File.open("#{input_dir}/projects/projects.json", 'w') do |file|
        JSON.dump(generate_projects_hash, file)
      end
      File.open("#{input_dir}/comments.json", 'w') do |file|
        JSON.dump(generate_comments_hash, file)
      end

      # copy contents
      FileUtils.mkdir_p("#{input_dir}/user/avatar")
      FileUtils.copy(@user.avatar.file.file, "#{input_dir}/user/avatar")
      @user.projects.each do |project|
        copy_project_contents(project)
      end
    end

    def generate_zip_file
      File.delete(path_to_zip) if File.exist?(path_to_zip)
      Dir.mkdir(output_dir) unless Dir.exist?(output_dir)
      zf = ZipFileGenerator.new(input_dir, path_to_zip)
      zf.write
    end

    def generate_user_hash
      {
        source: Rails.application.routes.url_helpers.owner_url(@user, host: "https://fabble.cc"),
        name: @user.name,
        url: @user.url,
        location: @user.location,
        email: @user.email,
        avatar: "https://fabble.cc#{@user.avatar.url}",
        created_at: @user.created_at.iso8601,
        identities: @user.identities.map do |identity|
          {
            provider: identity.provider,
            email: identity.email,
            image: identity.image,
            name: identity.name,
            nickname: identity.nickname,
            created_at: identity.created_at.iso8601
          }
        end,
        groups: @user.groups.map do |group|
          {
            name: group.name,
            url: group.url,
            location: group.location,
            avatar: "https://fabble.cc#{group.avatar.url}",
            role: @user.membership_in(group).role
          }
        end
      }
    end

    def generate_projects_hash
      @user.projects.map do |project|
        {
          source: Rails.application.routes.url_helpers.project_url(project.owner, project, host: "https://fabble.cc"),
          title: project.title,
          description: project.description,
          created_at: project.created_at.iso8601,
          media: project.figures.map { |figure| "https://fabble.cc#{figure.content.url}" },
          youtube: project.figures.find { |figure| figure.link.present? }&.link,
          states: project.states.order(:position).map do |card|
            {
              contributors: card.contributors.map do |contributor|
                {
                  source: Rails.application.routes.url_helpers.owner_url(contributor, host: "https://fabble.cc"),
                  name: contributor.name
                }
              end,
              title: card.title,
              description: card.description,
              created_at: card.created_at.iso8601,
              media: card.figures.map { |figure| "https://fabble.cc#{figure.content.url}" },
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
                  media: annotation.figures.map { |figure| "https://fabble.cc#{figure.content.url}" },
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
              media: card.figures.map { |figure| "https://fabble.cc#{figure.content.url}" },
              youtube: card.figures.find { |figure| figure.link.present? }&.link
            }
          end,
          memos: project.note_cards.map do |card|
            {
              title: card.title,
              description: card.description,
              created_at: card.created_at.iso8601,
              media: card.figures.map { |figure| "https://fabble.cc#{figure.content.url}" },
              youtube: card.figures.find { |figure| figure.link.present? }&.link
            }
          end
        }
      end
    end

    def generate_comments_hash
      {
        projects: @user.project_comments.map do |comment|
          {
            # TODO: project_commentへのアンカーを入れたのだが、要確認
            source: Rails.application.routes.url_helpers.project_url(comment.project.owner, comment.project, anchor: "project-comment-#{comment.id}", host: "https://fabble.cc"),
            body: comment.body,
            created_at: comment.created_at.iso8601
          }
        end,
        recipes: @user.card_comments.map do |comment|
          {
            # TODO: source: https://fabble.cc/card_comments/323
            # 上記のようになっているが要確認
            source: Rails.application.routes.url_helpers.card_comment_url(comment, host: "https://fabble.cc"),
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
        FileUtils.mkdir_p("#{input_dir}/projects/media/#{project.name}")
        FileUtils.copy(contents, "#{input_dir}/projects/media/#{project.name}")
      end
    end
end
