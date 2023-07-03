module RedmineIssueCause
  include ActionView::Context
  class IssueCauseHooks < Redmine::Hook::ViewListener

    # отображение на форме задачи
    def view_issues_show_details_bottom(context = {})

      current_user = User.current
      issue = context[:issue]

      issue_cause = issue.issue_cause
      if current_user.allowed_to?(:view_issue_cause_id, issue.project) || User.current.admin?
        if issue_cause then
          return "<tr><td><b>#{l(:field_issue_cause)}:</b></td><td> #{link_to issue_cause.name, issue_cause_path(issue_cause)}</td>"
        else
          return "<tr><td><b>#{l(:field_issue_cause)}:</b></td></tr>"
        end

      end

    end

    # отображение на форме редактирования
    def view_issues_form_details_bottom(context = {})

      issue = context[:issue]
      form = context[:form]
      current_user = User.current

      # Отобразить выпадающий список модели IssueCause
      issue_cause = issue.issue_cause
      if current_user.admin? || current_user.allowed_to?(:edit_issue_cause_id, issue.project)
        select = form.select :issue_cause_id, IssueCause.order(:name).all.map { |ic| [ic.name, ic.id] }, include_blank: true
        return "<p>#{select}</p>"
      elsif current_user.allowed_to?(:view_issue_cause_id, issue.project) && !current_user.allowed_to?(:edit_issue_cause_id, issue.project)
        # Пользователь имеет право на просмотр, но не на управление
        if issue_cause then
          return "<tr><td><b>#{l(:field_issue_cause)}:</b></td><td> #{link_to issue_cause.name, issue_cause_path(issue_cause)}</td></tr>"
        else
          return "<tr><td><b>#{l(:field_issue_cause)}:</b></td></tr>"
        end
      end

    end

    # Сохранение значчения при редактировании
    def controller_issues_edit_before_save(context = {})

      issue = context[:issue]
      params = context[:params]
      current_user = User.current

      puts "issue.issue_cause_id #{issue.issue_cause_id}"
      puts "params[:issue][:issue_cause_id] #{params[:issue][:issue_cause_id]}"
      if issue.issue_cause_id
        issue_cause_old = IssueCause.find_by_id(issue.issue_cause_id)
      end
      if current_user.admin? || current_user.allowed_to?(:edit_issue_cause_id, issue.project)
        if params[:issue] && params[:issue][:issue_cause_id] != issue.issue_cause_id.to_s
          issue_cause = IssueCause.find_by_id(params[:issue][:issue_cause_id])
          issue.issue_cause = issue_cause
=begin
        # Создаем журнальную запись, фиксирующую изменение поля issue_cause_id
        if issue_cause
          journal = issue.current_journal || issue.init_journal(User.current)
          journal.details << JournalDetail.new(property: 'attr', prop_key: 'issue_cause_id', old_value: issue_cause_old.name, value: issue_cause.name)
        end
=end
        end
      end
    end

    # Сохранение при создании задачи
    def controller_issues_new_before_save(context = {})
      issue = context[:issue]
      params = context[:params]
      if User.current.admin? || User.current.allowed_to?(:edit_issue_cause_id, issue.project)
        # Проверяем, было ли выбрано значение для issue_cause_id
        if params[:issue] #&& params[:issue][:issue_cause_id].present?
          # issue_cause = SprIssueCause.find_by_id(params[:issue][:issue_cause_id])

          # Сохраняем выбранное значение issue_cause_id в задаче
          issue.issue_cause_id = params[:issue][:issue_cause_id]
        end
      end
    end


  end
end
