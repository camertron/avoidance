# encoding: UTF-8

module Avoidance
  module BaseConcern
    extend ActiveSupport::Concern

    module ClassMethods
      def singleton
        @singleton
      end

      def singleton=(val)
        @singleton = val
      end

      alias :singleton? :singleton
    end

    included do
      def detach
        Avoidance::Model.class_for(self.class).new(self)
      end
    end

  end
end