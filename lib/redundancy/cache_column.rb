module Redundancy

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

      set_prev_nil[:klass].where(id: record.send(:attribute_was, set_prev_nil[:attribute]))
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

end
