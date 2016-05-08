require 'redundancy/utils'

module Redundancy
  extend ActiveSupport::Concern

  def self.update_redundancies
    ActiveRecord::Base.subclasses.each do |klass|
      klass.try :update_redundancies
    end
  end

  def update_redundancies
    self.class.redundancies.each do |redundancy|
      redundancy.force_update!(self)
    end
  end

  included do
    before_save :update_redundancies_before_save
    after_save :update_redundancies_after_save
  end

  private

  def update_redundancies_before_save
    self.class.redundancies.each do |redundancy|
      redundancy.before_save(self)
    end
  end

  def update_redundancies_after_save
    self.class.redundancies.each do |redundancy|
      redundancy.after_save(self)
    end
  end

  module ClassMethods
    def cache_column association, attribute, options = {}
      options.assert_valid_keys(:cache_column, :default)
      Utils.cache_column self, association, attribute, options
    end

    def cache_method association, attribute, options = {}
      options.assert_valid_keys(:cache_method)
      Utils.cache_method self, association, attribute, options
    end

    def redundancies
      @redundancies ||= []
    end

    def update_redundancies
      all.each do |record|
        redundancies.each do |redundancy|
          redundancy.force_update!(record)
        end
      end
    end

  end

end

# include in AR
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, Redundancy)
end
