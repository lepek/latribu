Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  user.update_credits!
end