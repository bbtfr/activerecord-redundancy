module Redundancy
  extend ActiveSupport::Concern

  class CacheColumn
    attr_reader :options
    attr_reader :source, :dist, :klass
    attr_reader :change_if, :nil_unless, :update, :set_prev_nil

    def initialize options
      @options = options
      @source, @dist = options[:source], options[:dist]
      @klass = options[:klass]

      @change_if = options[:change_if]
      @nil_unless = options[:nil_unless]
      @update = options[:update] || false
      @set_prev_nil = options[:set_prev_nil]
    end

    def update_record record
      raise ArgumentError, "record class mismatch, expected #{klass}, got #{record.class}" unless record.kind_of? klass
      return unless need_update?(record)
      
      src = source[:association] ? record.send(source[:association]) : record
      src = src && source[:attribute] && src.send(source[:attribute])
      src = nil if nil_unless && !record.send(nil_unless) 

      dst = dist[:association] ? record.send(dist[:association]) : record

      set_prev_nil.where(id: record.send(:attribute_was, change_if))
        .update_all(dist[:attribute] => nil) if set_prev_nil

      case dst
      when ActiveRecord::Base
        return if dst.send(:read_attribute, dist[:attribute]) == src
        log "#{ update ? "update" : "write" } #{dst.class}(#{dst.id})##{dist[:attribute]} with #{src.inspect}"
        log "#{change_if}: #{record.send(change_if).inspect}, #{dist[:association]||"self"}.id: #{dst.id}"
        if update
          dst.send(:update_attribute, dist[:attribute], src)
        else
          dst.send(:write_attribute, dist[:attribute], src)
        end
      when ActiveRecord::Relation
        log "update #{dst.class}##{dist[:attribute]} with #{src.inspect}"
        dst.send(:update_all, dist[:attribute] => src)
      end

    end

    def need_update? record
      record.send(:attribute_changed?, change_if)
    end

    def log *message
      # puts *message
    end

  end

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
        remote_klass.cache_columns << CacheColumn.new({
          source: { association: nil, attribute: attribute },
          dist: { association: inverse_association, attribute: cache_column },
          change_if: attribute, klass: remote_klass, update: true
        })

      when :has_one
        remote_klass.cache_columns << CacheColumn.new({
          source: { association: nil, attribute: attribute },
          dist: { association: inverse_association, attribute: cache_column },
          change_if: foreign_key, nil_unless: foreign_key, klass: remote_klass,
          set_prev_nil: local_klass
        })
        remote_klass.cache_columns << CacheColumn.new({
          source: { association: nil, attribute: attribute },
          dist: { association: inverse_association, attribute: cache_column },
          change_if: attribute, klass: remote_klass, update: true
        })
      end


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