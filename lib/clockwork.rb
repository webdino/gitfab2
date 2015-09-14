# using like
# $cd "#{Rails.root}"
# $clockworkd -c script/extract_tags_on_clock.rb --log start

require 'clockwork'

require File.expand_path('../../config/boot', __FILE__)
require File.expand_path('../../config/environment', __FILE__)

module Clockwork
  handler do |_job|
    @_projects = Project.all.in(is_private: [false, nil])
    file_path = "#{Rails.root}/config/all-tags.yml"
    tag_counters = {}

    @_projects.each do |project|
      project.tags.each do |tag|
        if tag_counters.keys.include? tag.name
          tag_counters[tag.name] += 1
        else
          tag_counters.store tag.name, 1
        end
      end
    end

    File.open(file_path, 'w') { |_file| _file = nil }
    yml_file = File.open file_path, 'w'

    used_tags = Hash[tag_counters.sort { |(_k1, v1), (_k2, v2)| v2 <=> v1 }]
    used_tags.each do |tag|
      yml_file.puts "- #{tag[0]}"
    end

    yml_file.close
  end

  every 1.hour, 'hourly.job'
end
