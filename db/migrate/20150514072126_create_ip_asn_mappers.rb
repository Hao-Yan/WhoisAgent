class CreateIpAsnMappers < ActiveRecord::Migration
  def change
    create_table :ip_asn_mappers do |t|
      t.string :ip
      t.string :as_number
      t.string :prefix
      t.string :country
      t.string :registry
      t.string :allocated_date
      t.string :as_name

      t.timestamps null: false
    end
  end
end
