module PreferenceFu
  
  module ClassMethods
        
    def has_preferences(*options)
      config = { :column => 'preferences' }
      
      %w(options instance).each do |reserved|
        if options.include?(reserved.to_sym)
          raise ArgumentError.new("Cannot use reserved key '#{reserved}' as a preference")
        end
      end
      
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
    
  end
  
  module InstanceMethods
    
    def preferences
      @preferences_object ||= Preferences.new(read_attribute(preferences_column.to_sym), self)
    end
    
  end
  
  
  class Preferences
    
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
      
    end
    
    def [](key)
      instance_variable_get("@#{key}")
    end
    
    def []=(key, value)
      idx, hsh = lookup(key)
      instance_variable_set("@#{key}", value)
      update_permissions
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
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

# module PreferenceFu
#     
#   def has_preferences(*attrs)
#     
#     class_eval do
#       
#       Preferences.set_options = *attrs
#             
#       composed_of :preferences, :class_name => 'PreferenceFu::Preferences'
#       
#     end
#     
#   end
#   
#   class Preferences
#         
#     cattr_accessor :options
#     
#     class << self
#       
#       def set_options=(hsh)
#         idx = 0; @@options = {}
#         hsh.each do |pref, default|
#           @@options[2**idx] = { :key => pref.to_sym, :default => default }
#           attr_reader pref.to_sym
#           idx += 1
#         end
#         
#         @@options
#       end
#       
#     end
#     
#     def initialize(prefs)
#       if prefs.nil? or prefs.is_a?(Hash)
#         @@options.each do |idx, hsh|
#           instance_variable_set("@#{hsh[:key]}", hsh[:default])
#         end
#       end
#       
#       if prefs.is_a?(Hash)
#         prefs.each do |key, value|
#           instance_variable_set("@#{key}", true) if is_true(value)
#         end
#       elsif prefs.is_a?(Numeric)  
#         @@options.each do |idx, hsh|
#           instance_variable_set("@#{hsh[:key]}", (prefs & idx) != 0 ? true : false)
#         end
#       end
#       
#     end
#     
#     def [](key)
#       # true if key exists and is true
#       instance_variable_get("@#{key}")
#     end
#     
#     def set(key, value)
#       # composed_of is immutable, and thus can only update with a new object
#       # idx, hsh = lookup(key)
#       # if idx
#       #   @@options[idx][:value] = value
#       #   instance_variable_set("@#{key}", value)
#       # end
#       Preferences.new(:download_stuff => true)
#     end
# 
#     def to_hash
#       @@options
#     end
#     
#     def preferences
#       @@options.inject(0) do |bv, (idx, hsh)|
#         bv |= instance_variable_get("@#{hsh[:key]}") ? idx : 0
#       end
#     end
#     
#     private
#       def is_true(value)
#         case value
#         when true, 1, /1|y|yes/i then true
#         else false
#         end
#       end
#       
#       def lookup(key)
#         @@options.find { |idx, hsh| hsh[:key] == key.to_sym }
#       end
#     
#   end
#   
# end