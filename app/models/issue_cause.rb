class IssueCause < ActiveRecord::Base
  include Redmine::SafeAttributes

  
  

  scope :visible, ->(*args) { where(IssueCause.visible_condition(args.shift || User.current, *args)) }
  
  scope :sorted, -> { order("#{table_name}.name ASC") }


  validates :name, presence: true

  safe_attributes *%w[name]



  def self.visible_condition(user, options = {})
    '1=1'
  end

  def self.css_icon
    'icon icon-user'
  end

  def editable_by?(user)
    editable?(user)
  end

  def project
    nil
  end

  def visible?(user = nil)
    user ||= User.current
    user.allowed_to?(:view_issue_causes, project, global: true)
  end

  def editable?(user = nil)
    user ||= User.current
    user.allowed_to?(:manage_issue_causes, project, global: true)
  end

  def deletable?(user = nil)
    user ||= User.current
    user.allowed_to?(:manage_issue_causes, project, global: true)
  end

  def attachments_visible?(user = nil)
    visible?(user)
  end

  def attachments_editable?(user = nil)
    editable?(user)
  end

  def attachments_deletable?(user = nil)
    deletable?(user)
  end

  def to_s
    name.to_s
  end
=begin

  def name_changed?
    attribute_changed?("name")
  end

  def attribute_change_to_log_text(attribute, value)
    if attribute == "name"
      "#{name_was} -> #{name}"
    else
      super
    end
  end

  def name
    # Вернуть значение поля, содержащего имя причины
  end
=end

  alias_attribute :created_on, :created_at
  alias_attribute :updated_on, :updated_at


end
