require 'redundancy/cache_column'

module Redundancy
  extend ActiveSupport::Concern

  included do
    before_save :redundancy_update_cache_column_after_save
  end

  private

  def redundancy_update_cache_column_after_save
    self.class.cache_columns.each do |cache_column|
      cache_column.update_record(self)
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
      
      foreign_key = reflection.foreign_key
      cache_column = options[:cache_column] || :"#{association}_#{attribute}"

      local_klass = self
      remote_klass = reflection.klass

      case reflection.macro
      when :belongs_to
        local_klass.cache_columns << CacheColumn.new({
          source: { association: association, attribute: attribute },
          dist: { association: nil, attribute: cache_column },
          change_if: foreign_key, klass: local_klass
        })

      when :has_one
        remote_klass.cache_columns << CacheColumn.new({
          source: { association: nil, attribute: attribute },
          dist: { association: inverse_association, attribute: cache_column },
          change_if: foreign_key, nil_unless: foreign_key, klass: remote_klass,
          set_prev_nil: { klass: local_klass, attribute: foreign_key }
        })
      
      end

      remote_klass.cache_columns << CacheColumn.new({
        source: { association: nil, attribute: attribute },
        dist: { association: inverse_association, attribute: cache_column },
        change_if: attribute, klass: remote_klass, update: true
      })


    end

    def cache_columns
      @cache_columns ||= []
    end

  end

end

# include in AR
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, Redundancy)
end