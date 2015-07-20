class AddIpUniquenessIndex < ActiveRecord::Migration
  def change
      add_index :ip_asn_mappers, :ip, :unique => true
  end
end
