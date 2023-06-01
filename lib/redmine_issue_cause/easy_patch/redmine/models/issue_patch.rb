require_dependency 'issue'

# Patches Redmine's Issues dynamically.  Adds a relationship
# Issue +belongs_to+ to qa_contact
module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :issue_cause, :class_name => 'IssueCause', :foreign_key => 'issue_cause_id'
      # before_create :default_issue_cause
    end

  end

  module ClassMethods
  end

  module InstanceMethods

=begin
    def default_issue_cause
      if issue_cause.nil? && issue.issue_cause
        self.issue_cause = issue.issue_cause
      end
    end
=end

  end
end

# Add module to Issue
Issue.send(:include, IssuePatch)

