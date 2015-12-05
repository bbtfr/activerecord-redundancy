module Redundancy

  class UpdateBase
    attr_reader :options
    attr_reader :source, :dest, :klass
    attr_reader :change_if, :update, :target, :value

    def initialize options
      @options = options
      @source, @dest = options[:source], options[:dest]
      @klass = options[:klass]

      @change_if = options[:change_if]
      @update = options[:update] || false
    end

    def before_save record
    end

    def after_save record
    end

    def get_target_from_association record
      @target = dest[:association] ? record.send(dest[:association]) : record
    end

    def get_target_from_prev_id record
      prev_id = record.send(:attribute_was, dest[:prev_id])
      return unless prev_id
      @target = dest[:klass].where(id: prev_id)
    end

    def get_target_from_relation_first_record
      @target = @target.first if @target.kind_of? ActiveRecord::Relation
    end

    def get_value_from_association record
      @value = source[:association] ? record.send(source[:association]) : record
      @value = value && source[:attribute] && value.send(source[:attribute])
      @value = nil if source[:nil_unless] && !record.send(source[:nil_unless])
      @value
    end

    def get_value_from_source record
      @value = source
    end

    def get_value_from_target record
      @value = target && source[:attribute] && target.send(source[:attribute])
    end

    def raise_if_class_mismatch record
      raise ArgumentError, "record class mismatch, expected #{klass}, got #{record.class}" unless record.kind_of? klass
    end

    def update_target record
      case target
      when ActiveRecord::Base
        return if target.send(:read_attribute, dest[:attribute]) == value
        log "#{ update ? "update" : "write" } #{target.class}(#{target.id})##{dest[:attribute]} with #{value.inspect}"
        log "#{change_if}: #{record.send(change_if).inspect}, #{dest[:association]||"self"}.id: #{target.id}" if change_if
        if update
          target.send(:update_attribute, dest[:attribute], value)
        else
          target.send(:write_attribute, dest[:attribute], value)
        end
      when ActiveRecord::Relation
        log "update #{target.class}##{dest[:attribute]} with #{value.inspect}"
        target.send(:update_all, dest[:attribute] => value)
      end
    end

    def force_update_target record
      @update = true
      update_target record
    end

    def need_update? record
      !change_if || record.send(:attribute_changed?, change_if)
    end

    def log *message
      # puts *message
    end

  end

end
