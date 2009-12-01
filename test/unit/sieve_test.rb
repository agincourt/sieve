require File.dirname(__FILE__) + '/../test_helper.rb'

class SieveTest < Test::Unit::TestCase
  def test_include_of_sieve
    # mock the object
    object = TestObject
    # check for filter_by, filtering_on, filter, sieve_class methods
    [:filter_by, :filtering_on, :order_by, :ordering_on, :filter, :sieve_class].each { |method|
      assert object.respond_to?(method, true), "filterable objects should respond to: #{method}"
    }
  end
  
  def test_class_return
    # mock the object
    object = TestObject
    # check the object name doesn't include sieve
    assert !(object.sieve_class.name.to_s =~ /sieve/i), "filterable objects shouldn't return sieve-based class names on a call to sieve_class"
  end
  
  def test_only_columns_in_the_db_can_be_filtered
    object = mocked_object
    # add filters for the object that don't exist in columns
    object.send(:filter_by, :name)
    # check the filters added don't actual appear in the filtering_on list
    assert object.filtering_on.include?(:name), 'Filter of DB attribute not appearing in filtering_on list'
    # try to filter a non-column attribute
    e = assert_raise(Sieve::Errors::NoColumnError) { object.send(:filter_by, :random) }
    assert_match /cannot be filtered/i, e.message, 'Should have raised exception for non-db attribute'
  end
  
  def test_only_columns_in_the_db_can_be_ordered
    object = mocked_object
    # add filters for the object that don't exist in columns
    object.send(:order_by, :name)
    # check the filters added don't actual appear in the filtering_on list
    assert object.ordering_on.include?(:name), 'Order of DB attribute not appearing in ordering_on list'
    # try to filter a non-column attribute
    e = assert_raise(Sieve::Errors::NoColumnError) { object.send(:order_by, :random) }
    assert_match /cannot be filtered/i, e.message, 'Should have raised exception for non-db attribute'
  end
  
  def test_should_use_exact_searching_when_specifying_a_set_or_collection
    object = mocked_object
    # filter by with set
    object.send(:filter_by, :name, :set => [['Jim', 'jim'], ['Fred', 'fred']])
    # check the set is defined
    assert object.filtering_on.include?(:name), 'Filter of DB attribute not appearing in filtering_on list'
    assert object.filtering_on[:name].include?(:set), 'Set not being stored'
    # let's filter:
    result = object.filter(:name => 'jim')
    assert result.class.name.to_s =~ /scope/i, 'Should return a ActiveRecord::NamedScope::Scope object'
    assert result.find(:all).kind_of?(Array)
  end
  
  def test_should_use_between_searching_when_specifying_a_date_range
    object = mocked_object
    # filter by with set
    object.send(:filter_by, :created_at)
    # check the set is defined
    assert object.filtering_on.include?(:created_at), 'Filter of DB attribute (created_at) not appearing in filtering_on list'
    # let's filter:
    result = object.filter(:created_at => { :date => Sieve::DateRange.new(mocked_date_range_attribute) })
    assert result.class.name.to_s =~ /scope/i, 'Should return a ActiveRecord::NamedScope::Scope object'
    assert result.find(:all).kind_of?(Array)
  end
  
  def test_should_accept_singular_dates
    object = mocked_object
    # filter by with set
    object.send(:filter_by, :created_at)
    # check the set is defined
    assert object.filtering_on.include?(:created_at), 'Filter of DB attribute (created_at) not appearing in filtering_on list'
    # let's filter:
    result = object.filter(:created_at => { :date => Sieve::DateRange.new(mocked_date_range_attribute.delete_if { |k,v| k =~ /^from/ }) })
    assert result.find(:all).kind_of?(Array)
    # once more with feeling:
    result = object.filter(:created_at => { :date => Sieve::DateRange.new(mocked_date_range_attribute.delete_if { |k,v| k =~ /^to/ }) })
    assert result.find(:all).kind_of?(Array)
  end
  
  private
  def mocked_object
    # mock some columns (require name and type methods)
    column = Object.new
    column.stubs(:name).returns(:name)
    column.stubs(:type).returns(:string)

    column_two = Object.new
    column_two.stubs(:name).returns(:created_at)
    column_two.stubs(:type).returns(:datetime)
    # mock the object
    object = TestObject
    object.stubs(:columns).returns([column, column_two])
    # return
    object
  end
  
  def mocked_date_range_attribute
    # setup our dates
    from = Time.now - 3.months
    to   = Time.now - 5.days
    # seperate them into form parameters
    {
      'from(1i)' => from.year,
      'from(2i)' => from.month,
      'from(3i)' => from.day,
      'from(4i)' => from.hour,
      'from(5i)' => from.min,
      'to(1i)'   => to.year,
      'to(2i)'   => to.month,
      'to(3i)'   => to.day,
      'to(4i)'   => to.hour,
      'to(5i)'   => to.min,
    }
  end
end

class TestObject < ActiveRecord::Base
  include Sieve::Filterable
end