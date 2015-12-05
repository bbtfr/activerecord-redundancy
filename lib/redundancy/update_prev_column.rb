require 'redundancy/update_base'

module Redundancy

  class UpdatePrevColumn < UpdateBase

    def before_save record
      raise_if_class_mismatch record
      return unless need_update? record

      get_target_from_prev_id record
      get_value_from_source record

      update_target record
    end

  end

end
