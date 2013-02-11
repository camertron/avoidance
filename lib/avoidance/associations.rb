# encoding: UTF-8

module Avoidance

  module Associations
    autoload :Association,                    "avoidance/associations/association"
    autoload :HasManyAssociation,             "avoidance/associations/has_many"
    autoload :BelongsToAssociation,           "avoidance/associations/belongs_to"
    autoload :HasOneAssociation,              "avoidance/associations/has_one"
    autoload :HasAndBelongsToManyAssociation, "avoidance/associations/has_and_belongs_to_many"
  end

end