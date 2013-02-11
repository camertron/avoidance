# encoding: UTF-8

module Avoidance

  class Model
    attr_reader :attributes, :deleted
    attr_accessor :model

    def initialize(model)
      @model = model
      @attributes = model.attributes.dup
      @deleted = false
    end

    def delete
      @deleted = true
    end

    def persist
      persist!
      @model
    end

    def persist_duplicate(models = {})
      fetch_all(models)
      @model = @model.dup
      @model.save
      id = @model.id
      persist!(true, @model)
      @model.id = id
      @model
    end

    def errors
      errors_without_associations(@model).merge(
        association_cache.inject({}) do |ret, (name, association)|
          assoc_errors = association.targets.map(&:errors).select { |err| !err.empty? }
          ret[association.association.name] = assoc_errors
          ret
        end
      )
    end

    def flat_errors
      flatten_errors(errors)
    end

    def valid?
      @model.valid?
      association_cache.each_pair do |name, association|
        association.targets.each do |target|
          target.valid?
        end
      end
      flat_errors.size == 0
    end

    private

    def flatten_errors(errors)
      return errors if errors.is_a?(String)
      errors.inject([]) do |ret, (field, errors)|
        ret += errors.flat_map { |hash| flatten_errors(hash) }
      end
    end

    def errors_without_associations(model)
      association_names = model.class.reflect_on_all_associations.map { |assoc| assoc.foreign_key.to_sym }
      model.errors.messages.select do |field, errors|
        !association_names.include?(field)
      end
    end

    def persist!(create_new = false, new_parent = nil)
      skip = false

      if @deleted
        @model.delete
      else
        unless skip
          @model.class.columns.each do |column|
            if @attributes.include?(column.name) && !column.primary
              @model.send(:"#{column.name}=", @attributes[column.name])
            end
          end
        end

        association_cache.each_pair do |name, association|
          association.persist!(create_new, new_parent)
        end
      end
    end

    def fetch_all(models = {}, visited = {})
      # recursively call #targets on each association, which will load them in
      # preparation for duplication (or whatever)
      key = "#{@model.class.to_s}-#{@model.id}"
      @model.class.reflect_on_all_associations.each do |association|
        if models.include?(association.name)
          "#{key}-#{association.name}".tap do |key_assoc|
            unless visited.include?(key_assoc)
              visited[key_assoc] = true
              self.send(association.name).targets.each do |t|
                t.fetch_all(models[association.name] || {}, visited) if t.respond_to?(:fetch_all)
              end
            end
          end
        end
      end
    end

    class << self
      def class_cache
        @class_cache ||= {}
      end

      def class_for(const)
        class_cache[const] ||= Class.new(Avoidance::Model) do
          const.columns.each do |column|
            define_method(:"#{column.name}") do
              @attributes[column.name]
            end

            define_method(:"#{column.name}=") do |value|
              @attributes[column.name] = value
            end
          end

          def association_cache
            @association_cache ||= {}
          end

          const.reflect_on_all_associations.each do |association|
            define_method(association.name) do
              const_name = "#{association.macro.to_s.camelize}Association".to_sym
              if Avoidance::Associations.const_defined?(const_name)
                association_cache[association.name] ||= Avoidance::Associations.const_get(const_name).new(association, @model)
              else
                nil
              end
            end
          end

        end
      end
    end
  end

end