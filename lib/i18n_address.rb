module I18nAddress
  
  def self.country_names
    self.supported_countries.keys.sort_by(&:to_s)
  end
  
  def self.supported_countries
    @@loaded_country_formats ||= YAML::load_file("#{File.dirname(__FILE__)}/i18n_address/countries.yml")    
    # puts @@loaded_country_formats.inspect    
    @@supported_countries ||= Hash[*@@loaded_country_formats["countries"].collect{ |k,v| [k,CountryFormatter.new(v)] }.flatten]
  end
  
  def self.load_locale(locale_named)
    file_path_to_locale = File.join(File.dirname(__FILE__),"i18n_address","locales","#{locale_named}.yml")
    unless File.exists?(file_path_to_locale)
      raise ArgumentError, "Unsupported locale #{locale_named}"
    end
    I18n.load_path << file_path_to_locale
  end
  
  def self.db_name_to_format_key_equivalencies
    @@db_name_to_format_key_equivalencies ||= {
      "city" => ["city", "post_town"],
      "state" => ["state"],
      "province" => ["province", "county"],
      "zip" => ["zip_code", "postal_code"]      
    }
  end
  
  class CountryFormatter
    attr_accessor :format
    def initialize(country_attributes)
      @format = country_attributes["format"]
      @optional_atts = country_attributes["optional"] || []
      @states = country_attributes["states"]
      @provinces = country_attributes["provinces"]
    end
    
    class AddressPart
      attr_accessor :part_name, :spacing_before, :spacing_after, :options_array
      def initialize(part_name, formatter, spacing_before)
        @part_name = part_name
        @formatter = formatter
        @spacing_before = spacing_before
        @options_array = nil
      end
      def label
        I18n.t("i18n_address.#{@part_name}")
      end
      def required?
        @formatter.part_required?(@part_name)
      end
    end
    def part_required?(part_name)
      @format.index(part_name) && 
      !@optional_atts.include?(part_name)
    end
    def parts
      prev_part = nil
      parts = [@format.split(/[^\n ]+/), @format.split(/[\n ]+/)].transpose.collect do |spacing_before, part_name|
        if prev_part
          prev_part.spacing_after = spacing_before
        end
        prev_part = AddressPart.new(part_name, self, spacing_before)
        if part_name == "state" && @states
          prev_part.options_array = @states
        end
        if part_name == "province" && @provinces
          prev_part.options_array = @provinces
        end
        prev_part
      end
    end
    def format_address(address)
      to_return = @format.dup
      
      address_lines = [address.address_1, address.address_2, address.address_3]
      address_lines = address_lines.reject(&:blank?).join("\n")
      to_return.gsub!("address", address_lines)
      
      I18nAddress.db_name_to_format_key_equivalencies.each do |db_name, format_keys|
        value = address.get(db_name)
        format_keys.each do |format_key|
          to_return.gsub!(format_key, value)
        end
      end
      
      country = address.country
      to_return.gsub!("country", country)
      
      while to_return.index("\n\n")
        to_return.gsub!("\n\n", "\n")
      end
      
      to_return
    end
    def address_label
      to_return = @format.dup
      to_return.gsub!("address", I18n.t("i18n_address.address"))
      to_return.gsub!("city", I18n.t("i18n_address.city"))
      to_return.gsub!("post_town", I18n.t("i18n_address.post_town"))
      to_return.gsub!("state", I18n.t("i18n_address.state"))
      to_return.gsub!("province", I18n.t("i18n_address.province"))      
      to_return.gsub!("county", I18n.t("i18n_address.county"))
      to_return.gsub!("zip_code", I18n.t("i18n_address.zip_code"))
      to_return.gsub!("postal_code", I18n.t("i18n_address.postal_code"))
      to_return.gsub!("country", I18n.t("i18n_address.country"))      
      to_return
    end
  end
  
  class Address
    def initialize(named, for_model)
      @named = named
      @model = for_model
    end
    def country_formatter(options = {})
      if I18nAddress.supported_countries.include?(self.country)
        I18nAddress.supported_countries[self.country]
      else
        if options[:raise] == false
          return false
        else
          raise ArgumentError, "No formatter defined for country #{self.country}"
        end
      end
    end
    def to_s
      self.country_formatter.format_address(self)
    end
    def to_html
      self.to_s.gsub("\n","<br/>")
    end
    def get(attribute_name)
      @model.send("#{@named}_#{attribute_name.to_s}").to_s
    end
    def set(attribute_name_equals, value)
      @model.send("#{@named}_#{attribute_name_equals.to_s}", value)      
    end
    def required?(addr_col)
      if addr_col == "country"
        return true
      end
      unless self.country.blank?
        if formatter = self.country_formatter(:raise => false)
          return formatter.part_required?(addr_col)
        end
      end
      false
    end
    def method_missing(symbol, *args, &block)
      if ["address_1", "address_2", "address_3", "city", "state", "province", "zip", "country"].include?(symbol.to_s)
        get(symbol)
      elsif ["address_1=", "address_2=", "address_3=", "city=", "state=", "province=", "zip=", "country="].include?(symbol.to_s)
        set(symbol, args[0])
      else
        super
      end
    end
  end
  
  module ARClassMethods
    
    def has_i18n_address(named, options = {})
      
      self.class_eval %Q{
        def #{named.to_s}_address
          @#{named.to_s}_address ||= I18nAddress::Address.new("#{named.to_s}", self)
        end
      }
      
      I18nAddress.db_name_to_format_key_equivalencies.each do |db_name, equivs|
        equivs.each do |e|
          unless e == db_name
            self.class_eval do
              define_method("#{named.to_s}_#{e}") do
                self.send("#{named.to_s}_#{db_name}")
              end
            end
          end
        end
      end
      
      column_expectations = {
        "address_1" => ["address_1", :expected],
        # "address_2" => :optional,
        # "address_3" => :optional,
        "post_town" => ["city", :conditionally_expected],
        "city" => ["city", :conditionally_expected],
        "state" => ["state", :conditionally_expected],
        "province" => ["province", :conditionally_expected],
        "county" => ["province", :conditionally_expected],
        "zip_code" => ["zip", :conditionally_expected],        
        "postal_code" => ["zip", :conditionally_expected],        
        "country" => ["country", :expected],
      }
      col_name_to_translateable_part = {"#{named.to_s}_address" => "address", 
                                       "#{named.to_s}_recipient_name" => "recipient_name",
                                       "#{named.to_s}_phone" => "phone",
                                       "#{named.to_s}_email" => "email"}
      column_expectations.keys.each{ |k| col_name_to_translateable_part["#{named.to_s}_#{k}"] = k }
      
      validates_inclusion_of "#{named.to_s}_country", :in => I18nAddress.supported_countries, :allow_nil => true
      
      if options[:required]
        self.class_eval do
          column_expectations.each do |addr_part, name_and_expectation|
            name, expectation = name_and_expectation
            col = "#{named.to_s}_#{addr_part}"
            if expectation == :expected
              validates_presence_of col
            elsif expectation == :conditionally_expected
              validates_presence_of col, :if => (Proc.new do |celf|
                celf.send("#{named.to_s}_address").required?(addr_part)
              end)
            end
          end
        end
      end
      
            
      if human_attribute_name_override = options[:human_attribute_name_override]        
        class_defintion_context = self.class_eval do
          class << self
            self
          end
        end
        implementation = Proc.new do |attr_name|
          begin
            I18n.translate("activerecord.attributes.#{self.name.underscore}.#{attr_name}", :raise => true)
          rescue I18n::ArgumentError => e
            if col_name_to_translateable_part.include?(attr_name)
              part_human_name = I18n.t("i18n_address.#{col_name_to_translateable_part[attr_name]}")
              human_attribute_name_override.call(part_human_name)
            else
              self.send("human_attribute_name_without_#{named.to_s}_address_overrides", attr_name)
            end
          end
        end
        class_defintion_context.send(:define_method, 
                                     "human_attribute_name_with_#{named.to_s}_address_overrides", 
                                     &implementation)
        class_defintion_context.send(:alias_method_chain,
                                     "human_attribute_name",
                                     "#{named.to_s}_address_overrides")        
      end
      
    end
    
  end
  
end