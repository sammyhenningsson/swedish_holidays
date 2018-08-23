require 'test_helper'

module SwedishHolidays
  describe Utils do
    it "::to_date handles dates" do
      date = Date.new(2018, 1, 1)
      assert_equal(date, Utils.to_date(date))
    end

    it "::to_date handles nil" do
      date = Date.today
      assert_equal(date, Utils.to_date)
    end

    it "::to_date handles strings" do
      date = Date.new(2018, 1, 1)
      assert_equal(date, Utils.to_date('2018-01-01'))
    end
  end
end
