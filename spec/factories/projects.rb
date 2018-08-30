# frozen_string_literal: true
# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  description :text(65535)
#  draft       :text(65535)
#  is_deleted  :boolean          default(FALSE), not null
#  is_private  :boolean          default(FALSE), not null
#  license     :integer          not null
#  likes_count :integer          default(0), not null
#  name        :string(255)      not null
#  owner_type  :string(255)      not null
#  scope       :string(255)
#  slug        :string(255)
#  title       :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  original_id :integer
#  owner_id    :integer          not null
#
# Indexes
#
#  index_projects_on_is_private_and_is_deleted  (is_private,is_deleted)
#  index_projects_original_id                   (original_id)
#  index_projects_owner                         (owner_type,owner_id)
#  index_projects_slug_owner                    (slug,owner_type,owner_id) UNIQUE
#  index_projects_updated_at                    (updated_at)
#

FactoryBot.define do
  factory :project do
    association :owner, factory: :user
    name { "project-#{SecureRandom.hex 10}" }
    title { SecureRandom.uuid }
    description { SecureRandom.uuid }
    license { 3 }
    is_deleted { false }

    trait :public do
      is_private { false }
    end

    trait :private do
      is_private { true }
    end

    trait :soft_destroyed do
      is_deleted { true }
    end
  end

  factory :user_project, parent: :project do
    association :owner, factory: :user
  end

  factory :group_project, parent: :project do
    association :owner, factory: :group
  end
end
