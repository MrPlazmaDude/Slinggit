class IdHashForComments < ActiveRecord::Migration
  def up
    add_column :comments, :id_hash, :string

    Comment.all.each do |comment|
      comment.id_hash = Digest::SHA1.hexdigest(comment.id.to_s + Time.now.to_s)
      comment.save
    end

  end

  def down
    remove_column :comments, :id_hash
  end
end
