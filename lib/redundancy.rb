module Redundancy
  extend ActiveSupport::Concern

  class CacheColumn
    class << self
      alias_method :create, :new
    end

    attr_reader :reflection, :options
    attr_reader :attribute, :association, :inverse_association, :cache_column

    def initialize reflection, attribute, options
      @reflection, @attribute, @options = reflection, attribute, options
      @association = reflection.name
      @inverse_association = options[:inverse_of]
      @cache_column = options[:cache_column] || :"#{association}_#{attribute}"

      add_cache_column_local_callbacks
      add_cache_column_remote_callbacks
    end

    private

    def add_cache_column_local_callbacks
      callback_name = :redundancy_cache_column_after_save
      klass = reflection.active_record
      return if klass.method_defined? callback_name

      klass.class_eval do
        define_method callback_name do
          self.class.cache_columns_on_foreign_key.each do |foreign_key, cache_columns|
            next unless self.send :attribute_changed?, foreign_key

            cache_columns.each do |cache_column|
              association = self.send(cache_column.association)
              attribute = association && association.send(cache_column.attribute)
              write_attribute(cache_column.cache_column, attribute)
            end
          end
        end
        
        before_save callback_name
      end

    end

    def add_cache_column_remote_callbacks
      callback_name = :redundancy_update_remote_cache_column_after_update
      klass = reflection.klass
      return if klass.method_defined? callback_name

      klass.class_eval do
        define_method callback_name do
          self.class.cache_columns_on_attribute.each do |attribute, cache_columns|
            next unless self.send :attribute_changed?, attribute

            cache_columns.each do |cache_column|
              association = self.send(cache_column.inverse_association)
              association.update_all(cache_column.cache_column => self.send(attribute))
            end
          end
        end
        
        before_save callback_name
      end

    end


  end

  module ClassMethods
    def redundancy association, attribute, options = {}
      options.assert_valid_keys(:cache_column, :inverse_of)

      reflection = self.reflect_on_association(association)
      raise ArgumentError, "Unknown association :#{association}" unless reflection
      raise ArgumentError, "BelongsTo or HasOne reflection needed" unless 
        [:has_one, :belongs_to].include? reflection.macro

      inverse_associations = options[:inverse_of] 
      inverse_associations ||= [model_name.plural, model_name.singular].map(&:to_sym)

      inverse_association = Array.wrap(inverse_associations).find do |inverse_association|
        reflection.klass.reflect_on_association(inverse_association)
      end

      raise ArgumentError, "Could not find the inverse association for #{association} (#{inverse_associations.inspect} in #{reflection.klass})" unless inverse_association
      options[:inverse_of] = inverse_association

      cache_column = CacheColumn.create(reflection, attribute, options)
      cache_columns << cache_column

      cache_columns_on_foreign_key[reflection.foreign_key] ||= []
      cache_columns_on_foreign_key[reflection.foreign_key] << cache_column

      cache_columns_on_attribute = reflection.klass.cache_columns_on_attribute
      cache_columns_on_attribute[attribute] ||= []
      cache_columns_on_attribute[attribute] << cache_column

    end

    def cache_columns
      @cache_columns ||= []
    end

    def cache_columns_on_foreign_key
      @cache_columns_on_foreign_key ||= {}
    end
    
    def cache_columns_on_attribute
      @cache_columns_on_attribute ||= {}
    end

  end


end

# include in AR
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, Redundancy)
end