# Helper methods for schema management
module Biggles
  def self.create_schema
    c = ActiveRecord::Base.connection
    c.create_table :one_shots
    c.create_table :scheduleds
    c.create_table :recurrings
    c.add_column :one_shots, :name, :string
    c.add_column :one_shots, :processor, :string
    c.add_column :one_shots, :options, :text, limit: 100_000
  end
end
