module SessionsHelper

  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    current_user = user
    log_user_login
  end

  def sign_out
    if not current_user.blank?
      current_user.update_attribute(:remember_token, nil)
      current_user = nil
      cookies.delete(:remember_token)
    end
  end

  # Are you signed in
  def signed_in?
    !self.current_user.nil?
  end

  def is_signed_in_and_admin?
    !self.current_user.nil? && current_user.is_admin? 
  end

  # Set current user
  def current_user=(user)
    @current_user = user
  end

  # Get current user
  def current_user
    @current_user ||= user_from_remember_token
  end

  # Are you the current user
  def current_user?(user)
    user == current_user
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_path, notice: "Please sign in."
    end
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  private

  def user_from_remember_token
    remember_token = cookies[:remember_token]
    User.find_by_remember_token(remember_token) unless remember_token.nil?
  end

  def clear_return_to
    session.delete(:return_to)
  end

end
