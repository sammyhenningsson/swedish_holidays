# Swedish holidays

# Installation
```sh
gem install swedish_holidays
```
Or put `gem 'swedish_holidays'` in your Gemfile and
```sh
bundle install
```

# Usage
```
require 'date'
require 'swedish_holidays'

new_years_day = Date.new(2018, 1, 1)
easter = Date.new(2018, 4, 1)
non_holiday = Date.new(2018, 1, 3)

SwedishHolidays.holiday? '2018-01-01' # => true
SwedishHolidays.holiday? '2018-01-02' # => false
SwedishHolidays.holiday? new_years_day # => true
SwedishHolidays.holiday? non_holiday # => false

SwedishHolidays['2018-01-01'] # => <SwedishHolidays::Holiday:0x000055c52c31d688 @date=#<Date: 2018-01-01 ((2458120j,0s,0n),+0s,2299161j)>, @name="Nyårsdagen">
SwedishHolidays['2018-01-02'] # => nil

SwedishHolidays[new_years_day] # => <SwedishHolidays::Holiday:0x000055c52c31d688 @date=#<Date: 2018-01-01 ((2458120j,0s,0n),+0s,2299161j)>, @name="Nyårsdagen">
SwedishHolidays[non_holiday] # => nil

# Using a range
SwedishHolidays['2018-01-01'..'2018-04-01'] # => #<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator: #<Enumerator::Generator:0x000055c52bf37780>:each>>:take_while>
SwedishHolidays['2018-01-01'..'2018-04-01'].take(2) # => #<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator: #<Enumerator::Generator:0x000055c52c0f25e8>:each>>:take_while>:take(2)>
SwedishHolidays['2018-01-01'..'2018-04-01'].take(2).to_a # => [#<SwedishHolidays::Holiday:0x000055c52c31d688 @date=#<Date: 2018-01-01 ((2458120j,0s,0n),+0s,2299161j)>, @name="Nyårsdagen">, #<SwedishHolidays::Holiday:0x000055c52c31d1d8 @date=#<Date: 2018-01-06 ((2458125j,0s,0n),+0s,2299161j)>, @name="Trettondedag jul">]


SwedishHolidays[new_years_day..easter] # => #<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator: #<Enumerator::Generator:0x000055c52bf37780>:each>>:take_while>


SwedishHolidays.each(start: '2018-01-01') # => <Enumerator::Lazy: #<Enumerator: #<Enumerator::Generator:0x000055c52c141490>:each>>
SwedishHolidays.each(start: '2018-01-01').take(2) # => <Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator: #<Enumerator::Generator:0x000055c52c12ecc8>:each>>:take(2)>
SwedishHolidays.each(start: '2018-01-01').take(2).to_a # => [#<SwedishHolidays::Holiday:0x000055c52c31d688 @date=#<Date: 2018-01-01 ((2458120j,0s,0n),+0s,2299161j)>, @name="Nyårsdagen">, #<SwedishHolidays::Holiday:0x000055c52c31d1d8 @date=#<Date: 2018-01-06 ((2458125j,0s,0n),+0s,2299161j)>, @name="Trettondedag jul">]
SwedishHolidays.each(start: new_years_day).take(2).to_a # => [#<SwedishHolidays::Holiday:0x000055c52c31d688 @date=#<Date: 2018-01-01 ((2458120j,0s,0n),+0s,2299161j)>, @name="Nyårsdagen">, #<SwedishHolidays::Holiday:0x000055c52c31d1d8 @date=#<Date: 2018-01-06 ((2458125j,0s,0n),+0s,2299161j)>, @name="Trettondedag jul">]
```

The class `SwedishHolidays::Holiday` respond to `:date`, `:name`, `:wday`, `:yday` and `:<=>`. It includes `Comaparable`.


# Caveat
Even though påskafton, midsommarafton, julafton and nyårsafton are considered to be holidays (most people do not work those days) they are actually not really holidays per definition. If you would like to be able to know if a certain date is a swedish holiday (which is kind of asumed if your looking into this library), then you probably also want to include these 'informal' holidays. To do that pass in the keyword argument `include_informal` with a value of `true` to the methods in the examples above. Like:

```
require 'date'
require 'swedish_holidays'

easter_eve = Date.new(2018, 3, 31)

SwedishHolidays.holiday? easter_eve # => false
SwedishHolidays.holiday?(easter_eve, include_informal: true) # => true

SwedishHolidays[easter_eve] # => nil
SwedishHolidays[easter_eve, include_informal: true] # => #<SwedishHolidays::Holiday:0x00005616a2fabd88 @date=#<Date: 2018-03-31 ((2458209j,0s,0n),+0s,2299161j)>, @name="Påskafton", @informal=true>

# Using a range
SwedishHolidays['2018-01-01'..'2018-04-01'].count # => 4
SwedishHolidays['2018-01-01'..'2018-04-01', include_informal: true].count # => 5


SwedishHolidays.each(start: '2018-01-01').map(&:name).take(5).to_a # => ["Nyårsdagen", "Trettondedag jul", "Långfredagen", "Påskdagen", "Annandag påsk"]
SwedishHolidays.each(start: '2018-01-01', include_informal: true).map(&:name).take(5).to_a # => ["Nyårsdagen", "Trettondedag jul", "Långfredagen", "Påskafton", "Påskdagen"]

```
