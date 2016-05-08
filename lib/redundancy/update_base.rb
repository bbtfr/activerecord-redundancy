module Redundancy

  class UpdateBase
    attr_reader :options
    attr_reader :klass, :source, :dest, :change_if
    attr_reader :context

    def initialize options
      @options = options
      @klass = options[:klass]
      @source, @dest = options[:source], options[:dest]
      @change_if = options[:change_if]
      @update = options[:update] || false

      cleanup_context
    end

    def force_update! record
      set_context :force, true
    end

    # ActiveRecord Hooks
    def before_save record
    end

    def after_save record
    end

    protected

    # Context
    def set_context key, value
      @context[key] = value
    end

    def cleanup_context
      @context = {}
    end

    def update
      @context[:update] || @update
    end

    def force
      @context[:force]
    end

    def update_method
      @context[:update_method] || (update ? :update_attribute : :write_attribute)
    end

    def context key
      @context[key]
    end

    def get_target_from_association record, key = :default
      set_context :"target_#{key}", dest[:association] ? record.send(dest[:association]) : record
    end

    def get_target_from_prev_association record, key = :default
      set_context :"target_#{key}", record.send(:attribute_was, dest[:association])
    end

    def get_target_from_foreign_key record, key = :default
      id = record.send(:attribute_was, dest[:foreign_key])
      return unless id
      set_context :"target_#{key}", dest[:klass].where(id: id)
    end

    def get_target_from_relation_first_record key = :default
      target = context(:"target_#{key}")
      set_context :"target_#{key}", target.first if target.kind_of? ActiveRecord::Relation
    end

    def get_value_from_association record, key = :default
      value = source[:association] ? record.send(source[:association]) : record
      value = value && source[:attribute] && value.send(source[:attribute])
      value = nil if source[:nil_unless] && !record.send(source[:nil_unless])
      set_context :"value_#{key}", value
    end

    def get_value_from_default record, key = :default
      set_context :"value_#{key}", source[:default]
    end

    def get_value_from_target record, key = :default
      target = context(:"target_#{key}")
      set_context :"value_#{key}", target && source[:attribute] && target.send(source[:attribute])
    end

    def raise_if_class_mismatch record
      raise ArgumentError, "record class mismatch, expected #{klass}, got #{record.class}" unless record.kind_of? klass
    end

    def update_target record, key = :default
      target = context(:"target_#{key}")
      value = context(:"value_#{key}")

      case target
      when ActiveRecord::Base
        return if target.send(:read_attribute, dest[:attribute]) == value
        log "#{update_method} #{target.class}(#{target.id})##{dest[:attribute]} with #{value.inspect}"
        target.send(update_method, dest[:attribute], value)
      when ActiveRecord::Relation
        log "update_all #{target.class}##{dest[:attribute]} with #{value.inspect}"
        target.send(:update_all, dest[:attribute] => value)
      end
    end

    def need_update? record
      force || !change_if || record.send(:attribute_changed?, change_if)
    end

    def foreign_key_changed? record
      record.send(:attribute_changed?, dest[:foreign_key])
    end

    # require 'colorize'
    def log message
      # puts "  Redundancy  ".colorize(:green) + message
    end

  end

end
