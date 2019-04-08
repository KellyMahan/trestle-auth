Trestle::Engine.routes.draw do
  controller "trestle/auth/sessions" do
    get  'login'  => :new, as: :login
    get  'twofactorauth'  => :twofactorauth
    post 'twofactorauth_login'  => :twofactorauth_login
    post 'verify_twofactorauth' => :verify_twofactorauth
    post 'remove_twofactorauth' => :remove_twofactorauth
    post 'login'  => :create
    get  'logout' => :destroy, as: :logout
  end
end
