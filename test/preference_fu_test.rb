require 'test/unit'
require File.join(File.dirname(__FILE__), 'abstract_unit')
require File.join(File.dirname(__FILE__), 'person')


class PreferenceFuTest < Test::Unit::TestCase
  
  def setup
    setup_db
    @person = Person.new
  end

  def teardown
    teardown_db
  end
  
  def test_that_all_default_to_true_except_send_email
    assert_equal [true, false, false, false], @person.preferences.map { |k, v| v }
  end
  
  def test_new_user_for_default_preference_int
    assert_equal 1, @person.read_attribute(:preferences)
  end
  
  def test_changing_of_preference
    assert_equal false, @person.preferences[:delete_user]
    @person.preferences[:delete_user] = true
    assert_equal true, @person.preferences[:delete_user]
  end
  
  def test_mass_assignment
    @person.preferences = {:send_email => true, :change_theme => true, :delete_user => true, :create_user => true}
    assert_equal [true, true, true, true], @person.preferences.map { |k, v| v }
  end
  
  def test_setting_an_unknown_option
    @person.preferences[:unknown] = true
    assert_equal 4, @person.preferences.size
  end
  
end
