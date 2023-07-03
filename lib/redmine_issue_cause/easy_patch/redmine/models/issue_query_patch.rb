module IssueQueryPatch
  def self.included(base)
    base.class_eval do
      unloadable
      # Добавляем новый фильтр "Причина задачи"
      #   add_available_column(QueryColumn.new(:issue_cause_id, caption: :field_issue_cause , :sortable  => "#{Issue.table_name}.issue_cause_id", :default_order => 'desc',:groupable => true))

      # Добавляем новый фильтр и возможность сортировки/группировки
      # self.available_columns << QueryColumn.new(:issue_cause_id, caption: :field_issue_cause , :sortable => "#{Issue.table_name}.issue_cause_id", :groupable => true)

=begin
      self.available_columns += [
        QueryColumn.new(:issue_cause_id,caption: :field_issue_cause,
      :sortable  => "#{Issue.table_name}.root_id", :default_order => 'desc',
                        :groupable => true
        )
      ]
=end
      # Сохраняем оригинальный метод initialize_available_filters
      alias_method :original_initialize_available_filters, :initialize_available_filters

      # Переопределяем метод initialize_available_filters
      def initialize_available_filters
        # Вызываем оригинальный метод
        original_initialize_available_filters

        if project
          # Получаем значения идентификаторов и имен из таблицы IssueCause
          issue_causes = IssueCause.order("#{IssueCause.table_name}.name ASC")
          values = issue_causes.pluck(:name, :id)
          if User.current.admin? || User.current.allowed_to?(:view_test, nil, :global => true)

            # Добавляем новый столбец в список доступных столбцов
            self.available_columns << QueryColumn.new(:issue_cause_id, :sortable => "#{Issue.table_name}.issue_cause_id", :groupable => true)

            # Добавляем новый столбец в список доступных столбцов
            self.available_columns << QueryColumn.new(:issue_cause_name, :sortable => "#{IssueCause.table_name}.name", :groupable => true)


            # Добавляем новый фильтр по имени
            add_available_filter "issue_cause_id",
                                 :type => :list_optional,
                                 :values => values,
                                 :label => :label_issue_cause,

                                 :join => "#{IssueCause.table_name} ON #{IssueCause.table_name}.id = #{Issue.table_name}.issue_cause_id",
                                 :field => "#{IssueCause.table_name}.name",
                                 :before_filter => :apply_issue_cause_name_filter

          end
        end
      end

      # Переопределяем метод sql_for_field, чтобы использовать поле name для фильтрации
      def sql_for_field(field, operator, value, db_table, db_field, is_custom_filter = false)
        if field == "issuecauses_name"
          case operator
          when "="
            "#{Issue.table_name}.id IN (SELECT issue_id FROM #{IssueCause.table_name} WHERE name = '#{value.first}')"
          when "!"
            "#{Issue.table_name}.id NOT IN (SELECT issue_id FROM #{IssueCause.table_name} WHERE name = '#{value.first}')"
          end
        else
          super
        end
      end

      # Метод, вызываемый перед обновлением фильтра
      def apply_issue_cause_name_filter(query)
        if @filters["issue_cause_id"].present?
          # Применяем сохраненное значение фильтра
          query.add_filter("issue_cause_id", "=", @filters["issue_cause_id"].value)
        end
      end
    end
  end
end

# Применяем патч к классу IssueQuery
IssueQuery.include IssueQueryPatch