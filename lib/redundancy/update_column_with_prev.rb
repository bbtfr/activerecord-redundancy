require 'redundancy/update_base'

module Redundancy

  class UpdateColumnWithPrev < UpdateBase

    def before_save record
      raise_if_class_mismatch record
      return unless need_update? record

      get_target_from_association record
      get_value_from_association record

      update_target record

      return unless foreign_key_changed? record
      get_target_from_foreign_key record, :prev
      get_value_from_default record, :prev

      update_target record, :prev
    ensure
      cleanup_context
    end

  end

end
