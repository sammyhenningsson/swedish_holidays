require 'test_helper'

module SwedishHolidays
  describe Holiday do
    let(:new_year) { Date.new(2018, 1, 1) }
    let(:easter_eve) { Date.new(2018, 3, 31) }
    let(:non_holiday) { Date.new(2018, 1, 2) }
    let(:unknown_date) { Date.new(1800, 1, 1) }

    it '#holiday? returns true when date is a holiday' do
      assert_equal(true, Holiday.holiday?(new_year))
    end

    it '#holiday? returns false when date is not a holiday' do
      assert_equal(false, Holiday.holiday?(easter_eve))
    end

    it '#holiday? returns true when date is considered a holiday and real: false' do
      assert_equal(true, Holiday.holiday?(easter_eve, real: false))
    end

    it '#holiday? returns false when date is not a holiday and real: false' do
      assert_equal(false, Holiday.holiday?(non_holiday, real: false))
    end

    it('loads all holidays for the given year') do
      Holiday.find(new_year)
      assert_equal(
        ALL_HOLIDAYS_DURING_2018,
        Holiday.send(:loaded)[2018].keys
      )
    end

    it 'raises Error when year does not exist' do
      assert_raises Error do
        Holiday.find(unknown_date)
      end
    end

    it 'is possible to sort holidays' do
      h1 = Holiday.find(Date.strptime('2018 89', '%Y %j'))
      h2 = Holiday.find(Date.strptime('2018 121', '%Y %j'))
      h3 = Holiday.find(Date.strptime('2018 307', '%Y %j'))
      h4 = Holiday.find(Date.strptime('2018 360', '%Y %j'))
      assert_equal(
        [89, 121, 307, 360],
        [h3, h2, h4, h1].sort.map(&:yday)
      )
    end

    it '#each returns an Enumerator' do
      Holiday.send(:load, 2018)
      assert_instance_of(Enumerator, Holiday.each)
    end

    it '#each yields all holidays for a given year' do
      i = 0
      Holiday.each do |holiday|
        assert_instance_of(Holiday, holiday)
        assert_equal(REAL_HOLIDAYS_DURING_2018[i], holiday.yday)
        i += 1
      end
    end

    it '#each yields all holidays (including non-real) for a given year' do
      i = 0
      Holiday.each(2018, real: false) do |holiday|
        assert_instance_of(Holiday, holiday)
        assert_equal(ALL_HOLIDAYS_DURING_2018[i], holiday.yday)
        i += 1
      end
    end
  end
end
