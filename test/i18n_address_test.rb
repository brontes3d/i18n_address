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

    empty_house.home_address.country = "Ireland"
    
    assert_raises(ActiveRecord::RecordInvalid){
      empty_house.save!
    }
    
    assert !empty_house.errors.on(:home_country)
    assert empty_house.errors.on(:home_address_1)
    assert !empty_house.errors.on(:home_address_2)
    assert !empty_house.errors.on(:home_address_3)
    assert empty_house.errors.on(:home_post_town)
    assert !empty_house.errors.on(:home_district)
    assert !empty_house.errors.on(:home_county)
  end
  
  def test_address_to_s_and_to_html
    span_wrapper = Proc.new do |field_name, value|
      "<span id='#{field_name}'>#{value}</span>"
    end
    
    irish_house = House.new("home_address_1" => "Reed",
                            "home_address_2" => "123 Rock Road",
                            "home_address_3" => "Blackrock",
                            "home_post_town" => "Cork",
                            "home_county"    => "Munster",
                            "home_country"   => "Ireland")

    expected = "Reed\n123 Rock Road\nBlackrock\nCork\nMunster\nIreland"
    assert_equal(expected, irish_house.home_address.to_s)
    assert_equal(expected.gsub("\n","<br/>"), irish_house.home_address.to_html)
    
    assert_equal(%Q{
<span id='address_1'>Reed</span>
<span id='address_2'>123 Rock Road</span>
<span id='address_3'>Blackrock</span>
<span id='city'>Cork</span> <span id='zip'></span>
<span id='province'>Munster</span>
<span id='country'>Ireland</span>
    }.strip, irish_house.home_address.to_html(span_wrapper).gsub("<br/>","\n"))
    
    irish_house_in_dublin = House.new("home_address_1" => "Reed",
                            "home_address_2" => "123 Rock Road",
                            "home_post_town" => "Dublin",
                            "home_district"  => "12",
                            "home_country"   => "Ireland")

    expected = "Reed\n123 Rock Road\nDublin 12\nIreland"
    assert_equal(expected, irish_house_in_dublin.home_address.to_s)
    assert_equal(expected.gsub("\n","<br/>"), irish_house_in_dublin.home_address.to_html)

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
    assert_equal(expected.gsub("\n","<br/>"), us_house.home_address.to_html)

    canadian_house = House.new("home_address_1" => "Robert Chevalier",
                  "home_address_2" => "321 Queen Elizabeth Driveway",
                  "home_address_3" => "",
                  "home_city" => "Ottawa",
                  "home_province" => "ON",
                  "home_postal_code" => "K1A 0A9",
                  "home_country" => "Canada")

    expected = "Robert Chevalier\n321 Queen Elizabeth Driveway\nOttawa ON K1A 0A9\nCanada"

    # puts canadian_house.home_address.to_s
    assert_equal(expected, canadian_house.home_address.to_s)
    assert_equal(expected.gsub("\n","<br/>"), canadian_house.home_address.to_html)

    italian_house = House.new("home_address_1" => "Francesco",
                  "home_address_2" => "123 villa del villa",
                  "home_address_3" => "",
                  "home_postal_code" => "13421 abc",
                  "home_city" => "Venice",     
                  "home_province" => "NA",    
                  "home_country" => "Italy")

    expected = "Francesco\n123 villa del villa\n13421 abc Venice NA\nItaly"

    # puts italian_house.home_address.to_s
    assert_equal(expected, italian_house.home_address.to_s)
    assert_equal(expected.gsub("\n","<br/>"), italian_house.home_address.to_html)
    
    uk_house = House.new("home_address_1" => "Sir Giles",
                  "home_address_2" => "Appleford",
                  "home_address_3" => "",
                  "home_post_town" => "Abingdon",
                  "home_county" => "Lieds",
                  "home_postal_code" => "OX14 4PG",
                  "home_country" => "United Kingdom")

    expected = "Sir Giles\nAppleford\nAbingdon\nLieds\nOX14 4PG\nUnited Kingdom"

    # puts uk_house.home_address.to_s
    assert_equal(expected, uk_house.home_address.to_s)
    assert_equal(expected.gsub("\n","<br/>"), uk_house.home_address.to_html)

    uk_house_sans_county = House.new("home_address_1" => "Victoria House",
                  "home_address_2" => "15 The Street",
                  "home_address_3" => "Hurn",
                  "home_post_town" => "Christ Church",
                  "home_province" => "",
                  "home_postal_code" => "BH23 6AA",
                  "home_country" => "United Kingdom")
    
    expected = "Victoria House\n15 The Street\nHurn\nChrist Church\nBH23 6AA\nUnited Kingdom"

    # puts uk_house_sans_county.home_address.to_s
    assert_equal(expected, uk_house_sans_county.home_address.to_s)
    assert_equal(expected.gsub("\n","<br/>"), uk_house_sans_county.home_address.to_html)
    
    empty_address = House.new("home_address_1" => "",
                  "home_address_2" => "",
                  "home_address_3" => "",
                  "home_city" => "",     
                  "home_state" => "",    
                  "home_zip" => "",      
                  "home_country" => "")
    assert_equal("\n", empty_address.home_address.to_s)
    assert_equal("<br/>", empty_address.home_address.to_html)
    assert_equal("<span id='address_1'></span><br/><span id='address_2'></span><br/>"+
                 "<span id='address_3'></span><br/>"+
                 "<span id='city'></span> <span id='state'></span> <span id='zip'></span><br/>"+
                 "<span id='country'></span>", 
                 empty_address.home_address.to_html(span_wrapper))
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
    assert_equal("Address\nPost Town District\nCounty\nCountry",
                I18nAddress.supported_countries["Ireland"].address_label)
    
    I18n.locale = "pirate"

    assert_equal("Hiding Place\nIsland Sea Lucky Number\nOcean",
                I18nAddress.supported_countries["United States"].address_label)
    assert_equal("Hiding Place\nCoordinates Island\nOcean",
                I18nAddress.supported_countries["France"].address_label)
    assert_equal("Hiding Place\nCoordinates Island Reef\nOcean",
                I18nAddress.supported_countries["Italy"].address_label)
    assert_equal("Hiding Place\nBay\nShore\nCoordinates\nOcean",
                I18nAddress.supported_countries["United Kingdom"].address_label)
    assert_equal("Hiding Place\nBay Inlet\nShore\nOcean",
                I18nAddress.supported_countries["Ireland"].address_label)
  end
  
end
