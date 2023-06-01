module RedmineIssueCause

  class HelpersIssuesHook < Redmine::Hook::ViewListener
    def helper_issues_show_detail_after_setting(context = {})
      if context[:detail].prop_key == "issue_cause_id"
        context[:detail].value = IssueCause.find_by_id(context[:detail].value).try(:name)
        context[:detail].old_value = IssueCause.find_by_id(context[:detail].old_value).try(:name)
      end
    end
  end
end
