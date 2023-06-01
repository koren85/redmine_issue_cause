class AddIssueCauseIdToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :issue_cause_id, :integer
  end
end
