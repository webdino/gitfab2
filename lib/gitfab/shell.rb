module Gitfab
  class Shell
    def add_repo! repo_path
      Rugged::Repository.init_at repo_path, :bare
    end

    def copy_repo! orig_path, dest_dir, dest_name
      _dest_name = dest_name.dup
      dest_path = build_path dest_dir, _dest_name
      while File.exists? dest_path
        dest_path = build_path dest_dir, _dest_name.sub!(/$/, "_")
      end
      FileUtils.cp_r orig_path, dest_path
      _dest_name
    end

    def move_repo! orig_path, dest_dir, dest_name
      dest_path = build_path dest_dir, dest_name
      raise if ::File.exists? dest_path
      FileUtils.mv orig_path, dest_path
      dest_path
    end


    def commit_to_repo! repo_path, contents = [], opts = {}
      return nil if contents.empty?
      repo = Rugged::Repository.new repo_path
      index = Rugged::Index.new
      contents.each do |content|
        oid = repo.write content[:data], :blob
        index.add path: content[:file_path], oid: oid, mode: 0100644
      end
      email = opts[:email] || "yourname@example.com"
      name = opts[:name] || "Your Name"
      opts[:tree] = index.write_tree repo
      opts[:parents] = repo.empty? ? [] : [repo.head.target].compact
      opts[:update_ref] = "HEAD"
      opts[:message] ||= "Commited by Gitfab"
      opts[:author] = {email: email, name: name, time: Time.now}
      opts[:committer] = {email: email, name: name, time: Time.now}
      Rugged::Commit.create repo, opts
    end

    def destroy_repo! repo_path
      FileUtils.rm_rf repo_path
    end

    private
    def build_path dir, name
      "#{dir}/#{name}.git"
    end

  end
end
