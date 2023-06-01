Dir[File.dirname(__FILE__) + '/lib/redmine_issue_cause/easy_patch/**/*.rb'].each {|file| require_dependency file }
Dir[File.dirname(__FILE__) + '/extra/easy_patch/**/*.rb'].each { |file| require_dependency file }

# this block is executed once just after Redmine is started
# means after all plugins are initialized
# it is place for plain requires, not require_dependency
# it should contain hooks, permissions - base class in Redmine is required thus is not reloaded
ActiveSupport.on_load(:easyproject, yield: true) do

  require 'redmine_issue_cause/internals'
  require 'redmine_issue_cause/hooks'

end

# this block is called every time rails are reloading code
# in development it means after each change in observed file
# in production it means once just after server has started
# in this block should be used require_dependency, but only if necessary.
# better is to place a class in file named by rails naming convency and let it be loaded automatically
# Here goes query registering, custom fields registering and so on
RedmineExtensions::Reloader.to_prepare do

end

ActiveSupport.on_load(:easyproject, yield: true) do
  require 'redmine_issue_cause/issue_cause_hooks'

  Redmine::AccessControl.map do |map|
    map.project_module :issue_causes do |pmap|
      pmap.permission :view_issue_causes, { issue_causes: [:index, :show, :autocomplete, :context_menu] }, read: true
      pmap.permission :manage_issue_causes, { issue_causes: [:new, :create, :edit, :update, :destroy, :bulk_edit, :bulk_update] }

    end
    # Право доступа на чтение параметра issue_cause_id
    map.project_module :issue_tracking do |pmap|
      pmap.permission :view_issue_cause_id, { :issues => [:show] }
      pmap.permission :edit_issue_cause_id, { :issues => [:show] }
    end
  end

  Redmine::MenuManager.map :top_menu do |menu|
    menu.push :issue_causes, { controller: 'issue_causes', action: 'index', project_id: nil }, caption: :label_issue_causes
  end

end