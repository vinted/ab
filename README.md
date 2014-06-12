# ab

[![Code Climate](https://codeclimate.com/github/vinted/ab.png)](https://codeclimate.com/github/vinted/ab)
[![Gem Version](https://badge.fury.io/rb/vinted-ab.png)](http://badge.fury.io/rb/vinted-ab)
[![Dependency Status](https://gemnasium.com/vinted/ab.png)](https://gemnasium.com/vinted/ab)

Determines which ab test and variant identifier belongs to. Read more in the [wiki](https://github.com/vinted/ab/wiki).

## Usage

```ruby
ab = Ab::Tests.new(configuration, identifier)

# defining callbacks
Ab::Tests.before_picking_variant { |test| puts "picking variant for #{test}" }
Ab::Tests.after_picking_variant { |test, variant| puts "#{variant_name}" }

# ab.test never returns nil
# but if you don't belong to any of the buckets, variant will be nil
case ab.test.variant
when 'red_button'
  red_button
when 'green_button'
  green_button
else
  blue_button
end

# calls #variant underneath, results of that call are cached
puts 'red button' if ab.test.red_button?
```
