json.(post, :id, :hashtag_prefix, :content, :price, :id_hash, :open?, :post_medium_image_src, :has_photo?)

json.postedAgo time_ago_in_words(post.updated_at)