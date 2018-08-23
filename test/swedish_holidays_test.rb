require 'test_helper'

describe SwedishHolidays do
  let(:new_year) { Date.new(2018, 1, 1) }
  let(:non_holiday) { Date.new(2018, 1, 2) }
  let(:easter) { Date.new(2018, 4, 1) }

  describe '::[]?' do
    it "returns a holiday when date is a holiday" do
      holiday = SwedishHolidays[new_year]
      assert_instance_of(SwedishHolidays::Holiday, holiday)
      assert_equal(new_year, holiday.date)
    end

    it "returns nil when date is not a holiday" do
      assert_nil SwedishHolidays[non_holiday]
    end

    it "accepts an inclusive Range" do
      holidays = SwedishHolidays[new_year..easter]
      assert_equal(4, holidays.count)
      i = 0
      holidays.each do |holiday|
        assert_instance_of(SwedishHolidays::Holiday, holiday)
        assert_equal(HOLIDAYS_DURING_2018[i], holiday.yday)
        i += 1
      end
    end

    it "accepts an exclusive Range" do
      holidays = SwedishHolidays[new_year...easter]
      assert_equal(3, holidays.count)
      i = 0
      holidays.each do |holiday|
        assert_instance_of(SwedishHolidays::Holiday, holiday)
        assert_equal(HOLIDAYS_DURING_2018[i], holiday.yday)
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
      refute SwedishHolidays.holiday?(non_holiday)
    end

    it "accepts strings as input" do
      assert SwedishHolidays.holiday?('2018-01-01')
      refute SwedishHolidays.holiday?('2018-01-02')
    end
  end

  describe '::each' do
    let(:holidays_during_second_half_of_2018) { [307, 359, 360] }
    let(:holidays_during_2019_januari) { [1, 6] }

    it 'returns an Enumerator::Lazy' do
      assert_instance_of(Enumerator::Lazy, SwedishHolidays.each)
    end

    # it 'defaults start to today' do
    #   Holiday.stub :find, 
    #   SwedishHolidays.each(
    # end

    it "is possible to lazy iterate holidays with a start date" do
      count = 0
      assert_equal(
        holidays_during_second_half_of_2018 + holidays_during_2019_januari,
        SwedishHolidays.each(start: '2018-07-01').map { |h| count += 1; h.yday }.take(5).force
      )
      assert_equal(5, count)
    end
  end

  it "stops iterating when last year has been iterated" do
    holidays_in_2045_to_2049 = 64 # Current data ends at year 2049
    assert_equal(64, SwedishHolidays.each(start: '2045-01-01').count)
  end
end
