avoidance
=========

Avoidance is a Ruby gem that allows you to manipulate ActiveRecord models and their associations in a natural way without persisting them to the database.  With Avoidance, you can create, delete, and modify ActiveRecord models just like you would normally.  When you're ready, Avoidance lets you save (persist) the original records or save a persisted copy, including associated models.

## Usage
Got an ActiveRecord model you'd like to mess with?  Just call the `detach` method.

```ruby
meal = Meal.first.detach
```

The detached object is an instance of `Avoidance::Model`, but it behaves just like a normal ActiveRecord object.  For example, you're still able to set and retrieve its attributes.

```ruby
meal.price = 9.95
meal.price  # returns 9.95
```

You can also fetch associated models via the usual ActiveRecord-provided methods.  Avoidance will return the association wrapped an instance of the appropriate association class, such as `Avoidance::Associations::HasManyAssociation`.

```ruby
meal.recipes        # returns instance of Avoidance::Associations::HasManyAssociation
meal.recipes.count  # returns 2
```

### Creating Associated Objects

Now things get interesting.  Avoidance associations allow you to create objects on the fly just like ActiveRecord using the familiar methods `<<`, `add`, `build`, `new`, and `create`.  

```ruby
meal.recipes.create(:name => "Cheese Soufflé", :serving_size => "6oz")
meal.recipes.add(Recipe.new(:name => "Cheese Soufflé", :serving_size => "6oz"))
meal.recipes << Recipe.new(:name => "Cheese Soufflé", :serving_size => "6oz")
```

You can create nested associations as well.  Remember that these objects will not be persisted to the database - they exist only in memory.

```ruby
meal.recipes.first.ingredients.create(:name => "Cheddar Cheese", :amount => "1 cup shredded")
```

Use the `delete` and `clear` methods to remove associations.  You can delete associations that you created earlier on the detached record, or preexisting associations.

```ruby
# delete an association by passing in the object to remove
ingredient = meal.recipes.first.ingredients.first
meal.recipes.first.ingredients.delete(ingredient)

# or just call delete on it
meal.recipes.first.ingredients.first.delete

# delete all associations
meal.recipes.clear
```

### Persisting Records
