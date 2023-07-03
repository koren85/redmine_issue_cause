Redmine::Plugin.register :redmine_issue_cause do
  name 'Redmine Issue Cause'
  author 'Chernyaev Alexandr'
  author_url ''
  description 'Issue Cause directory'
  version '2023.2'

  #into easy_settings goes available setting as a symbol key, default value as a value
  settings easy_settings: {  }


end



unless Redmine::Plugin.registered_plugins[:easy_extensions]
  require_relative 'after_init'
end


