class CreateLocationWeathers < ActiveRecord::Migration[7.0]
  def change
    create_table :location_weathers do |t|
      t.string :lat
      t.string :lon
      t.json :data
      t.datetime :fetched_at

      t.timestamps
    end
  end
end
