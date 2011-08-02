class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def up
    add_column    :taggings, :tagger_id, :integer
    add_column    :taggings, :tagger_type, :string
    add_column    :taggings, :context, :string

    add_index     :taggings, [:taggable_id, :taggable_type, :context]

    execute "UPDATE taggings SET context = 'tags'"
  end

  def down
  end
end
