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
      set_context :update, true
      before_save record
      after_save record
    end

    # ActiveRecord Hooks
    def before_save record
    end

    def after_save record
    end

    protected

    # Context
    def set_context key, value
      log "set #{key} to #{value.inspect}"
      @context[key] = value
    end

    def cleanup_context
      log "===== cleanup context ====="
      @context = {}
    end

    def update
      @context[:update] || @update
    end

    [:force, :target, :value, :skip_callbacks].each do |key|
      define_method key do
        @context[key]
      end
    end

    def get_target_from_association record
      set_context :target, dest[:association] ? record.send(dest[:association]) : record
    end

    def get_target_from_prev_association record
      set_context :skip_callbacks, true
      set_context :target, record.send(:attribute_was, dest[:association])
    end

    def get_target_from_prev_id record
      prev_id = record.send(:attribute_was, dest[:prev_id])
      return unless prev_id
      set_context :target, dest[:klass].where(id: prev_id)
    end

    def get_target_from_relation_first_record
      set_context :target, target.first if target.kind_of? ActiveRecord::Relation
    end

    def get_value_from_association record
      value = source[:association] ? record.send(source[:association]) : record
      value = value && source[:attribute] && value.send(source[:attribute])
      value = nil if source[:nil_unless] && !record.send(source[:nil_unless])
      set_context :value, value
    end

    def get_value_from_source record
      set_context :value, source
    end

    def get_value_from_target record
      set_context :value, target && source[:attribute] && target.send(source[:attribute])
    end

    def raise_if_class_mismatch record
      raise ArgumentError, "record class mismatch, expected #{klass}, got #{record.class}" unless record.kind_of? klass
    end

    def update_target record
      case target
      when ActiveRecord::Base
        return if target.send(:read_attribute, dest[:attribute]) == value
        log "#{ update ? "update" : "write" } #{target.class}(#{target.id})##{dest[:attribute]} with #{value.inspect}"
        if update
          update_method = skip_callbacks ? :update_column : :update_attribute
          target.send(update_method, dest[:attribute], value)
        else
          target.send(:write_attribute, dest[:attribute], value)
        end
      when ActiveRecord::Relation
        log "update #{target.class}##{dest[:attribute]} with #{value.inspect}"
        target.send(:update_all, dest[:attribute] => value)
      end
    end

    def force_update_target record
      set_context :update, true
      update_target record
    end

    def need_update? record
      force || !change_if || record.send(:attribute_changed?, change_if)
    end

    # require 'colorize'
    def log message
      # puts "  Redundancy  ".colorize(:green) + message
    end

  end

end
