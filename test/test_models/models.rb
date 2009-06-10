class House < ActiveRecord::Base
  
  has_i18n_address :home, :required => true

  has_i18n_address :work, :human_attribute_name_override => (Proc.new do |part_human_name|
    "#{part_human_name} o' Work"
  end)

end