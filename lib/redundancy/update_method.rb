require 'redundancy/update_base'

module Redundancy

  class UpdateMethod < UpdateBase

    def after_save record
      raise_if_class_mismatch record
      return unless need_update? record

      get_target_from_association record
      get_value_from_target record

      force_update_target record
    end

  end

end
