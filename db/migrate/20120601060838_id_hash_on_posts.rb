class IdHashOnPosts < ActiveRecord::Migration
  class Post < ActiveRecord::Base
    attr_accessible :id_hash
  end

  def up
    add_column :posts, :id_hash, :string
    Post.all().each do |post|
      post.id_hash = Digest::SHA1.hexdigest(post.id.to_s + Time.now.to_s)
      post.save
    end
  end

  def down
    remove_column :posts, :id_hash
  end
end
