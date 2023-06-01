class IssueCauseQuery < Query

  self.queried_class = IssueCause

  def initialize_available_filters
    add_available_filter 'name', name: IssueCause.human_attribute_name(:name), type: :string
    add_available_filter 'created_at', name: IssueCause.human_attribute_name(:created_at), type: :date
    add_available_filter 'updated_at', name: IssueCause.human_attribute_name(:updated_at), type: :date

  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = []
    group = l("label_filter_group_#{self.class.name.underscore}")

    @available_columns << QueryColumn.new(:name, caption: IssueCause.human_attribute_name(:name), title: IssueCause.human_attribute_name(:name), group: group)
    @available_columns << QueryColumn.new(:created_at, caption: IssueCause.human_attribute_name(:created_at), title: IssueCause.human_attribute_name(:created_at), group: group)
    @available_columns << QueryColumn.new(:updated_at, caption: IssueCause.human_attribute_name(:updated_at), title: IssueCause.human_attribute_name(:updated_at), group: group)

    @available_columns
  end

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= { "name" => {:operator => "*", :values => []} }
  end

  def default_columns_names
    super.presence || ["name", "created_at", "updated_at"].flat_map{|c| [c.to_s, c.to_sym]}
  end

  def issue_causes(options={})
    order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)

    scope = IssueCause.visible.
        where(statement).
        includes(((options[:include] || [])).uniq).
        where(options[:conditions]).
        order(order_option).
        joins(joins_for_order_statement(order_option.join(','))).
        limit(options[:limit]).
        offset(options[:offset])

    if has_custom_field_column?
      scope = scope.preload(:custom_values)
    end

    issue_causes = scope.to_a

    issue_causes
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end
end
