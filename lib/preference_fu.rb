module PreferenceFu
  
  def self.included(receiver)
    #return if receiver.included_modules.include?(PreferenceFu::InstanceMethods)
    
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
  
  module ClassMethods
        
    def has_preferences(*options)
      alias_method_chain :initialize, :preferences
      
      class_eval do
        class << self
          alias_method_chain :instantiate, :preferences
        end
      end
      
      config = { :column => 'preferences' }
      
      idx = 0; @@preference_options = {}
      options.each do |pref|
        @@preference_options[2**idx] = { :key => pref.to_sym, :default => false }
        idx += 1
      end
      
      class_eval <<-EOV

      def preferences_column
        '#{config[:column]}'
      end

      EOV
            
    end
    
    def set_default_preference(key, default)
      raise ArgumentError.new("Default value must be boolean") unless [true, false].include?(default)
      idx = preference_options.find { |idx, hsh| hsh[:key] == key.to_sym }.first rescue nil
      if idx
        preference_options[idx][:default] = default
      end
    end
    
    def preference_options
      @@preference_options
    end
    
    def instantiate_with_preferences(*args)
      record = instantiate_without_preferences(*args)
      record.prefs
      record
    end
    
  end
  
  module InstanceMethods
    
    def initialize_with_preferences(attributes = nil)
      initialize_without_preferences(attributes)
      prefs # use this to trigger update_permissions in Preferences
      yield self if block_given?
    end
    
    def prefs
      @preferences_object ||= Preferences.new(read_attribute(preferences_column.to_sym), self)
    end
    
    def prefs=(hsh)
      prefs.store(hsh)
    end
    
  end
  
  
  class Preferences
    
    include Enumerable
    
    attr_accessor :instance, :options
    
    def initialize(prefs, instance)
      @instance = instance
      @options = instance.class.preference_options
      
      # setup defaults if prefs is nil
      if prefs.nil?
        @options.each do |idx, hsh|
          instance_variable_set("@#{hsh[:key]}", hsh[:default])
        end
      elsif prefs.is_a?(Numeric)
        @options.each do |idx, hsh|
          instance_variable_set("@#{hsh[:key]}", (prefs & idx) != 0 ? true : false)
        end
      else
        raise(ArgumentError, "Input must be numeric")
      end
      
      update_permissions
      
    end
    
    def each
      @options.each_value do |hsh|
        yield hsh[:key], self[hsh[:key]]
      end
    end
    
    def size
      @options.size
    end
    
    def [](key)
      instance_variable_get("@#{key}")
    end
    
    def []=(key, value)
      idx, hsh = lookup(key)
      instance_variable_set("@#{key}", value)
      update_permissions
    end
    
    # used for mass assignment of preferences, such as a hash from params
    def store(prefs)
      prefs.each do |key, value|
        self[key] = value
      end if prefs.respond_to?(:each)
    end
    
    def to_i
      @options.inject(0) do |bv, (idx, hsh)|
        bv |= instance_variable_get("@#{hsh[:key]}") ? idx : 0
      end
    end
    
    private
    
      def update_permissions
        instance.write_attribute(instance.preferences_column, self.to_i)
      end
    
      def is_true(value)
        case value
        when true, 1, /1|y|yes/i then true
        else false
        end
      end
      
      def lookup(key)
        @options.find { |idx, hsh| hsh[:key] == key.to_sym }
      end
    
  end
  
end