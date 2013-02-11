# encoding: UTF-8

module ActiveRecord
  class Base

    def detach
      Avoidance::Model.class_for(self.class).new(self)
    end

  end
end