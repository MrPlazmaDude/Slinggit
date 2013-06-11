@posts = get_posts_for_user(params[:filter], params[:page], 20, params[:id].to_i, STATUS_ACTIVE, true)

json.array!(@posts) do |json, post|
  json.partial! 'posts/post.json.jbuilder', post: post
end
