require 'redundancy/update_base'

module Redundancy

  class UpdateMethodWithPrev < UpdateBase

    def before_save record
      raise_if_class_mismatch record
      return unless foreign_key_changed? record

      get_target_from_foreign_key record, :prev
      get_target_from_relation_first_record :prev
    end

    def after_save record
      return unless need_update? record
      get_target_from_association record
      get_value_from_target record

      force_update_target record

      return unless context(:"target_prev")

      get_value_from_target record, :prev
      force_update_target record, :prev
    ensure
      cleanup_context
    end

  end

end
