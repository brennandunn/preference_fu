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
    assert_equal [true, false, false, false], @person.prefs.map { |k, v| v }
  end
  
  def test_new_user_for_default_preference_int
    assert_equal 1, @person.read_attribute(:preferences)
  end
  
  def test_changing_of_preference
    assert_equal false, @person.prefs[:delete_user]
    @person.prefs[:delete_user] = true
    assert_equal true, @person.prefs[:delete_user]
  end
  
  def test_mass_assignment
    @person.prefs = {:send_email => true, :change_theme => true, :delete_user => true, :create_user => true}
    assert_equal [true, true, true, true], @person.prefs.map { |k, v| v }
  end
  
  def test_setting_an_unknown_option
    @person.prefs[:unknown] = true
    assert_equal 4, @person.prefs.size
  end
  
  def test_saving_and_loading
    @person.prefs[:change_theme] = true
    @person.save
    
    @new_person = @person.reload
    assert_equal [true, true, false, false], @new_person.prefs.map { |k, v| v }
  end
  
end
