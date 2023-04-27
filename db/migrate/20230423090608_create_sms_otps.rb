class CreateSmsOtps < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_otps do |t|
      t.string :full_phone_number
      t.integer :pin
      t.boolean :activated, default: false, null: false
      t.datetime :valid_until
      t.timestamps
    end
  end
end
