class LoadingJob < Struct.new(:user_id)
  def perform
    user = User.find(user_id)
    user.load_favorites
  end
end