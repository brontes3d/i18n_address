require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class I18nAddressTest < Test::Unit::TestCase
  
  def setup
    I18n.locale = "en"
  end
  
  def test_defines_more_methods    
    uk_house = House.new("home_address_1" => "Sir Giles",
                  "home_address_2" => "Appleford",
                  "home_address_3" => "",
                  "home_city" => "Abingdon",
                  "home_province" => "Lieds",
                  "home_zip" => "OX14 4PG",
                  "home_country" => "United Kingdom")
    
    assert_equal("OX14 4PG", uk_house.home_postal_code)
    assert_equal("Abingdon", uk_house.home_post_town)
    assert_equal("Lieds", uk_house.home_county)
  end
  
  def test_human_attribute_name_override
    empty_house = House.new
    
    assert_equal("Address o' Work",        House.human_attribute_name('work_address'))
    assert_equal("Address Line 1 o' Work", House.human_attribute_name('work_address_1'))
    assert_equal("City o' Work",           House.human_attribute_name('work_city'))
    assert_equal("Post Town o' Work",      House.human_attribute_name('work_post_town'))
    assert_equal("State o' Work",          House.human_attribute_name('work_state'))
    assert_equal("Province o' Work",       House.human_attribute_name('work_province'))
    assert_equal("County o' Work",         House.human_attribute_name('work_county'))
    assert_equal("Zip Code o' Work",       House.human_attribute_name('work_zip_code'))
    assert_equal("Postal Code o' Work",    House.human_attribute_name('work_postal_code'))
    assert_equal("Country o' Work",        House.human_attribute_name('work_country'))
    
    I18n.locale = "pirate"
    
    assert_equal("Hiding Place o' Work",               House.human_attribute_name('work_address'))
    assert_equal("first part of Hiding Place o' Work", House.human_attribute_name('work_address_1'))
    assert_equal("Island o' Work",                     House.human_attribute_name('work_city'))
    assert_equal("Bay o' Work",                        House.human_attribute_name('work_post_town'))
    assert_equal("Sea o' Work",                        House.human_attribute_name('work_state'))
    assert_equal("Reef o' Work",                       House.human_attribute_name('work_province'))
    assert_equal("Shore o' Work",                      House.human_attribute_name('work_county'))
    assert_equal("Lucky Number o' Work",               House.human_attribute_name('work_zip_code'))
    assert_equal("Coordinates o' Work",                House.human_attribute_name('work_postal_code'))
    assert_equal("Ocean o' Work",                      House.human_attribute_name('work_country'))
  end
  
  def test_address_parts_required
    empty_house = House.new
    
    assert_raises(ActiveRecord::RecordInvalid){
      empty_house.save!
    }
    
    assert empty_house.errors.on(:home_country)
    assert empty_house.errors.on(:home_address_1)
    assert !empty_house.errors.on(:home_address_2)
    assert !empty_house.errors.on(:home_address_3)
    assert !empty_house.errors.on(:home_city)
    assert !empty_house.errors.on(:home_state)
    assert !empty_house.errors.on(:home_province)
    assert !empty_house.errors.on(:home_zip_code)
    
    empty_house.home_address.country = "United States"
    
    assert_raises(ActiveRecord::RecordInvalid){
      empty_house.save!
    }
    
    assert !empty_house.errors.on(:home_country)
    assert empty_house.errors.on(:home_address_1)
    assert !empty_house.errors.on(:home_address_2)
    assert !empty_house.errors.on(:home_address_3)
    assert empty_house.errors.on(:home_city)
    assert empty_house.errors.on(:home_state)
    assert !empty_house.errors.on(:home_province)
    assert empty_house.errors.on(:home_zip_code)
    
    empty_house.home_address.country = "United Kingdom"
    
    assert_raises(ActiveRecord::RecordInvalid){
      empty_house.save!
    }
    
    assert !empty_house.errors.on(:home_country)
    assert empty_house.errors.on(:home_address_1)
    assert !empty_house.errors.on(:home_address_2)
    assert !empty_house.errors.on(:home_address_3)
    assert !empty_house.errors.on(:home_city)
    assert empty_house.errors.on(:home_post_town)
    assert !empty_house.errors.on(:home_state)
    assert !empty_house.errors.on(:home_province)
    assert !empty_house.errors.on(:home_zip_code)
    assert empty_house.errors.on(:home_postal_code)
    
    empty_house.home_address.country = "Canada"
    
    assert_raises(ActiveRecord::RecordInvalid){
      empty_house.save!
    }
    
    assert !empty_house.errors.on(:home_country)
    assert empty_house.errors.on(:home_address_1)
    assert !empty_house.errors.on(:home_address_2)
    assert !empty_house.errors.on(:home_address_3)
    assert empty_house.errors.on(:home_city)
    assert !empty_house.errors.on(:home_state)
    assert empty_house.errors.on(:home_province)
    assert !empty_house.errors.on(:home_zip_code)    
    assert empty_house.errors.on(:home_postal_code)
  end
  
  def test_address_to_s    
    us_house = House.new("home_address_1" => "Bob",
                  "home_address_2" => "123 Bob way",
                  "home_address_3" => "",
                  "home_city" => "Bobville",     
                  "home_state" => "BO",    
                  "home_zip" => "12345",      
                  "home_country" => "United States")
                  
    expected = "Bob\n123 Bob way\nBobville BO 12345\nUnited States"
    
    # puts us_house.home_address.to_s
    assert_equal(expected, us_house.home_address.to_s)

    italian_house = House.new("home_address_1" => "Francesco",
                  "home_address_2" => "123 villa del villa",
                  "home_address_3" => "",
                  "home_city" => "Venice",     
                  "home_province" => "NA",    
                  "home_zip" => "13421 abc",      
                  "home_country" => "Italy")

    expected = "Francesco\n123 villa del villa\n13421 abc Venice NA\nItaly"

    # puts italian_house.home_address.to_s
    assert_equal(expected, italian_house.home_address.to_s)
    
    uk_house = House.new("home_address_1" => "Sir Giles",
                  "home_address_2" => "Appleford",
                  "home_address_3" => "",
                  "home_city" => "Abingdon",
                  "home_province" => "Lieds",
                  "home_zip" => "OX14 4PG",
                  "home_country" => "United Kingdom")

    expected = "Sir Giles\nAppleford\nAbingdon\nLieds\nOX14 4PG\nUnited Kingdom"

    # puts uk_house.home_address.to_s
    assert_equal(expected, uk_house.home_address.to_s)

    uk_house_sans_county = House.new("home_address_1" => "Victoria House",
                  "home_address_2" => "15 The Street",
                  "home_address_3" => "Hurn",
                  "home_city" => "Christ Church",
                  "home_province" => "",
                  "home_zip" => "BH23 6AA",
                  "home_country" => "United Kingdom")
    
    expected = "Victoria House\n15 The Street\nHurn\nChrist Church\nBH23 6AA\nUnited Kingdom"

    # puts uk_house_sans_county.home_address.to_s
    assert_equal(expected, uk_house_sans_county.home_address.to_s)
  end
  
  #TODO: should get validation errors on missing fields if address is required
  
  def test_get_generic_address_label
    assert_equal("Address\nCity State Zip Code\nCountry",
                I18nAddress.supported_countries["United States"].address_label)
    assert_equal("Address\nPostal Code City\nCountry",
                I18nAddress.supported_countries["France"].address_label)
    assert_equal("Address\nPostal Code City Province\nCountry",
                I18nAddress.supported_countries["Italy"].address_label)
    assert_equal("Address\nPost Town\nCounty\nPostal Code\nCountry",
                I18nAddress.supported_countries["United Kingdom"].address_label)
    
    I18n.locale = "pirate"

    assert_equal("Hiding Place\nIsland Sea Lucky Number\nOcean",
                I18nAddress.supported_countries["United States"].address_label)
    assert_equal("Hiding Place\nCoordinates Island\nOcean",
                I18nAddress.supported_countries["France"].address_label)
    assert_equal("Hiding Place\nCoordinates Island Reef\nOcean",
                I18nAddress.supported_countries["Italy"].address_label)
    assert_equal("Hiding Place\nBay\nShore\nCoordinates\nOcean",
                I18nAddress.supported_countries["United Kingdom"].address_label)
  end
  
end
