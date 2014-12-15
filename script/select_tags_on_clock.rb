#using like
# $cd "#{Rails.root}"
# $clockworkd -c script/select_tags_on_clock.rb --log start

require "clockwork"

require File.expand_path('../../config/boot', __FILE__)
require File.expand_path('../../config/environment', __FILE__)

module Clockwork

  handler do |job|
    p "---------Setup---------"
    @_projects = Project.all().in(is_private: [false, nil])
    file_path = "#{Rails.root}/config/selected-tags.yml"

    tags_list = YAML.load_file file_path
    tag_list_length = 15
    tag_counters = {}

    p "---------Search and Evaluate tags---------"
    @_projects.each do |project|
      project.tags.each do |tag|
        if tag_counters.keys.include? tag.name
          tag_counters[tag.name] += 1
        else
          tag_counters.store tag.name, 1
        end
      end
    end

    p "---------Open file #{file_path}---------"
    File.open(file_path, "w"){|file| file = nil}
    yml_file = File.open file_path, "w"

    p "---------Write Tags to file---------"
    if tag_counters.length > tag_list_length
      used_tags = Hash[tag_counters.sort{|(k1, v1), (k2, v2)| v2 <=> v1 }]
      used_tags.keys.slice(0, tag_list_length).each do |tag_name|
        p tag_name
        yml_file.puts "- #{tag_name}"
      end
    else
      tag_counters.keys.each do |tag_name|
        p tag_name
        yml_file.puts "- #{tag_name}"
      end
    end

    p "---------Close file----------"
    yml_file.close

  end

  every 1.hour, "hourly.job"

end
