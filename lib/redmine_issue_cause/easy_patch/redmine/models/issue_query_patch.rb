require_dependency 'issue_query'

class IssueQuery
  # Добавляем новый столбец в список доступных столбцов
  self.available_columns << QueryColumn.new(:issue_cause_name, :sortable => "#{IssueCause.table_name}.name", :groupable => "#{IssueCause.table_name}.name")

end

module RedmineIssueCause
  module IssueQueryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable

        # Сохраняем оригинальный метод initialize_available_filters
        alias_method :initialize_available_filters_without_issuecauses_filters, :initialize_available_filters
        alias_method :initialize_available_filters, :initialize_available_filters_with_issuecauses_filters
      end
    end

    module InstanceMethods
      # Переопределяем метод initialize_available_filters
      def initialize_available_filters_with_issuecauses_filters
        # Вызываем оригинальный метод
        initialize_available_filters_without_issuecauses_filters

        if project
          # Получаем значения идентификаторов и имен из таблицы IssueCause
          issue_causes = IssueCause.order("#{IssueCause.table_name}.name ASC")
          values = issue_causes.pluck(:name, :id)
          if User.current.admin? || User.current.allowed_to?(:view_test, nil, :global => true)
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

      # Переопределяем метод joins_for_order_statement, чтобы добавить соединение с таблицей IssueCause

      def joins_for_order_statement(order_options)
        joins = [super]
        if order_options
          if order_options.include?('issue_causes.name')
            joins << "LEFT JOIN #{IssueCause.table_name} ON #{Issue.table_name}.issue_cause_id = #{IssueCause.table_name}.id"
          end
        end
        joins.any? ? joins.join(' ') : nil
      end

      # Переопределяем метод sql_for_order_statement, чтобы использовать поле name для сортировки
      def sql_for_order_statement(order_options)
        if order_options.include?("issue_causes.name")
          "#{IssueCause.table_name}.name #{order_options[:sort_direction]}"
        else
          super(order_options)
        end
      end

      # Переопределяем метод sql_for_field, чтобы использовать поле name для фильтрации
=begin
      def sql_for_field(field, operator, value, db_table, db_field, is_custom_filter = false)
        if field == "issue_causes.name"
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
=end

      # Метод, вызываемый перед обновлением фильтра
=begin
      def apply_issue_cause_name_filter(query)
        if @filters["issue_cause_id"].present?
          # Применяем сохраненное значение фильтра
          query.add_filter("issue_cause_id", "=", @filters["issue_cause_id"].value)
        end
      end
=end
    end
  end
end

# Применяем патч к классу IssueQuery
# IssueQuery.include IssueQueryPatch

# IssueQuery.include RedmineIssueCause::IssueQueryPatch

unless IssueQuery.included_modules.include?(RedmineIssueCause::IssueQueryPatch)
  IssueQuery.send(:include, RedmineIssueCause::IssueQueryPatch)
end
