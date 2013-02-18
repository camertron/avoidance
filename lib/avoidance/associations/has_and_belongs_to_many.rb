# encoding: UTF-8

module Avoidance

  module Associations

    class HasAndBelongsToManyAssociation < HasManyAssociation
      def persist!(create_new = false, new_parent = nil)
        @parent = new_parent if new_parent
        current_ids = parent.send(association.name).pluck(:id)
        new_ids = targets.map(&:id).compact

        targets.each do |target|
          if create_new
            target.model = target.model.dup
            target.persist!(create_new, target.model)
            parent.send(association.name) << target.model
          else
            if target.id.nil? || current_ids.include?(target.id) || new_ids.include?(target.id)
              # new or changed/unchanged
              target.model.save
              target.persist!(create_new)
            end

            if target.deleted
              parent.send(association.name).delete(target.model)
            else
              list = parent.send(association.name)
              list << target.model unless list.include?(target.model)
              target.model.save
            end
          end
        end

        if !create_new
          @deleted_records.each do |target|
            parent.send(association.name).delete(target.model)
          end
        end
      end
    end

  end

end