module RedmineIssueCause

  class HelpersIssuesHook < Redmine::Hook::ViewListener
    def helper_issues_show_detail_after_setting(context = {})
      if context[:detail].prop_key == "issue_cause_id"
        context[:detail].reload

        ic = IssueCause.find_by_id(context[:detail].value)
        context[:detail].value = ic.name if ic.present? && ic.name.present?

        ic = IssueCause.find_by_id(context[:detail].old_value)
        context[:detail].old_value =  ic.name if ic.present? && ic.name.present?
      end
      ''
    end
  end
end
