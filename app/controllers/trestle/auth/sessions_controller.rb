class Trestle::Auth::SessionsController < Trestle::ApplicationController
  layout 'trestle/auth'

  skip_before_action :require_authenticated_user

  def new
  end

  def create
    if user = Trestle.config.auth.authenticate(params)
      if user.use_otp && user.otp_verified
        session[:pendinguser] = user #hold user info in session for 2factor auth
        redirect_to "/admin/twofactorauth"
      else
        login!(user)
        remember_me! if params[:remember_me] == "1"
        redirect_to previous_location || instance_exec(&Trestle.config.auth.redirect_on_login)
      end
    else
      flash[:error] = t("admin.auth.error", default: "Incorrect login details.")
      redirect_to action: :new
    end
  end
  
  def destroy
    logout!
    redirect_to instance_exec(&Trestle.config.auth.redirect_on_logout)
  end
  
  def twofactorauth
  end
  
  def twofactorauth_login
    begin
      if user = session[:pendinguser]
        user = Trestle.config.auth.user_class.find(user["id"])
        if user.authenticate_otp(params[:twofactorauth], drift: Trestle.config.auth.drift_time)
          session.delete(:pendinguser)
          login!(user)
          remember_me! if params[:remember_me] == "1"
          redirect_to previous_location || instance_exec(&Trestle.config.auth.redirect_on_login)
        else
          raise Trestle::Auth::AuthException, "Incorrect two factor authentication code."
        end
      else
        raise Trestle::Auth::AuthException, "Problem with session login."
      end
    rescue Trestle::Auth::AuthException => e
      session.delete(:pendinguser)
      flash[:error] = t("admin.auth.error", default: e.message)
      redirect_to action: :new
    end
  end
  
  def verify_twofactorauth
    require_authenticated_user
    if @current_user.authenticate_otp(params[:twofactorauth], drift: Trestle.config.auth.drift_time)
      @current_user.use_otp = true
      @current_user.otp_verified = true
      @current_user.save
    else
      flash[:error] = t("admin.auth.error", default: "Incorrect two factor authentication code. Two factor authentication disabled.")
      redirect_to previous_location || "/admin"
    end
  end
  
  def remove_twofactorauth
    require_authenticated_user
    begin
      @current_user.use_otp = false
      @current_user.otp_verified = false
      @current_user.update_attribute(:otp_secret_key, ROTP::Base32.random_base32)
      @current_user.save
      redirect_to "/admin/auth/administrators/#{@current_user.id})"
    rescue
      flash[:error] = t("admin.auth.error", default: "Issue with 2 factor authentication.")
      redirect_to previous_location || "/admin"
    end
  end

end
