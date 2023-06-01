class CreateIssueCauses < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_causes do |t|


      t.string :name, null: true
      
      

      t.timestamps
    end
  end
end
