require File.dirname(__FILE__) + '/../test_helper.rb'

class SieveTest < Test::Unit::TestCase
  def test_include_of_sieve
    # mock the object
    object = TestObject
    # check for filter_by, filtering_on, filter, sieve_class methods
    [:filter_by, :filtering_on, :filter, :sieve_class].each { |method|
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
    # mock some columns (require name and type methods)
    column = Object.new
    column.stubs(:name).returns(:name)
    column.stubs(:type).returns(:string)
    # mock the object
    object = TestObject
    object.stubs(:columns).returns([column])
    # add filters for the object that don't exist in columns
    object.send(:filter_by, :name)
    # check the filters added don't actual appear in the filtering_on list
    assert object.filtering_on.include?(:name), 'Filter of DB attribute not appearing in filtering_on list'
    # try to filter a non-column attribute
    e = assert_raise(Sieve::Errors::NoColumnError) { object.send(:filter_by, :random) }
    assert_match /cannot be filtered/i, e.message, 'Should have raised exception for non-db attribute'
  end
end

class TestObject < ActiveRecord::Base
  include Sieve::Filterable
end