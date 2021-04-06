require 'test_helper'

describe SwedishHolidays do
  let(:new_year) { Date.new(2018, 1, 1) }
  let(:non_holiday) { Date.new(2018, 1, 2) }
  let(:easter_eve) { Date.new(2018, 3, 31) }
  let(:easter) { Date.new(2018, 4, 1) }

  describe '::[]' do
    it "returns a holiday when date is a holiday" do
      holiday = SwedishHolidays[new_year]
      assert_instance_of(SwedishHolidays::Holiday, holiday)
      assert_equal(new_year, holiday.date)
    end

    it "returns nil when date is not a holiday" do
      assert_nil SwedishHolidays[non_holiday]
    end

    it "returns nil when date is not a real holiday" do
      assert_nil SwedishHolidays[easter_eve]
    end

    it "returns a holiday when date is not a real holiday and include_informal: true" do
      holiday = SwedishHolidays[easter_eve, include_informal: true]
      assert_instance_of(SwedishHolidays::Holiday, holiday)
      assert_equal(easter_eve, holiday.date)
    end

    it "accepts an inclusive Range" do
      holidays = SwedishHolidays[new_year..easter]
      assert_equal(4, holidays.count)
      i = 0
      holidays.each do |holiday|
        assert_instance_of(SwedishHolidays::Holiday, holiday)
        assert_equal(REAL_HOLIDAYS_DURING_2018[i], holiday.yday)
        i += 1
      end
    end

    it "accepts an exclusive Range" do
      holidays = SwedishHolidays[new_year...easter]
      assert_equal(3, holidays.count)
      i = 0
      holidays.each do |holiday|
        assert_instance_of(SwedishHolidays::Holiday, holiday)
        assert_equal(REAL_HOLIDAYS_DURING_2018[i], holiday.yday)
        i += 1
      end
    end

    it "returns all holidays (including informal) within a Range" do
      holidays = SwedishHolidays[new_year..easter, include_informal: true]
      assert_equal(5, holidays.count)
      i = 0
      holidays.each do |holiday|
        assert_instance_of(SwedishHolidays::Holiday, holiday)
        assert_equal(ALL_HOLIDAYS_DURING_2018[i], holiday.yday)
        i += 1
      end
    end
  end

  describe '::holiday?' do
    let(:new_year) { Date.new(2018, 1, 1) }
    let(:non_holiday) { Date.new(2018, 1, 2) }

    it "returns true when date is a holiday" do
      assert SwedishHolidays.holiday?(new_year)
    end

    it "returns false when date is not a holiday" do
      refute SwedishHolidays.holiday?(easter_eve)
    end

    it "returns true when date is conciders to be a holiday and include_informal: true" do
      assert SwedishHolidays.holiday?(easter_eve, include_informal: true)
    end

    it "accepts strings as input" do
      assert SwedishHolidays.holiday?('2018-01-01')
      assert SwedishHolidays.holiday?('2018-03-31', include_informal: true)
      refute SwedishHolidays.holiday?('2018-01-02')
    end
  end

  describe '::each' do
    let(:real_holidays_during_second_half_of_2018) { [307, 359, 360] }
    let(:all_holidays_during_second_half_of_2018) { [307, 358, 359, 360, 365] }
    let(:holidays_during_2019_januari) { [1, 6] }

    it 'returns an Enumerator::Lazy' do
      assert_instance_of(Enumerator::Lazy, SwedishHolidays.each)
    end

    it 'is possible to lazy iterate holidays with a start date' do
      count = 0
      expected = real_holidays_during_second_half_of_2018 + holidays_during_2019_januari
      assert_equal(
        expected,
        SwedishHolidays.each(start: '2018-07-01').map { |h| count += 1; h.yday }.take(expected.size).force
      )
      assert_equal(expected.size, count)
    end

    it 'is possible to lazy iterate holidays (including informal) with a start date' do
      count = 0
      expected = all_holidays_during_second_half_of_2018 + [holidays_during_2019_januari.first]
      assert_equal(
        expected,
        SwedishHolidays.each(start: '2018-07-01', include_informal: true).map { |h| count += 1; h.yday }.take(expected.size).force
      )
      assert_equal(expected.size, count)
    end
  end

  it "stops iterating when last year has been iterated" do
    holidays_in_2045_to_2049 = 64 # Current data ends at year 2049
    assert_equal(holidays_in_2045_to_2049, SwedishHolidays.each(start: '2045-01-01').count)
  end
end
