# ab

[![Code Climate](https://codeclimate.com/github/vinted/ab.png)](https://codeclimate.com/github/vinted/ab)
[![Gem Version](https://badge.fury.io/rb/vinted-ab.png)](http://badge.fury.io/rb/vinted-ab)
[![Dependency Status](https://gemnasium.com/vinted/ab.png)](https://gemnasium.com/vinted/ab)

vinted-ab is used to determine whether an identifier belongs to a particular ab test and which variant of that ab test. Identifiers will usually represent users, but other scenario are possible. There are two parts to that: [Configuration](#configuration) and [Algorithm](#algorithm).

High-level description: Identifiers are divided into some number of buckets, using hashing. Before a test is started, buckets are chosen for that test. That gives the ability to pick the needed level of isolation. Each test also has a seed, which is used to randomise how users are divided among test variants.

![users](https://cloud.githubusercontent.com/assets/54526/2971326/0535267a-db69-11e3-9878-e2b6a5d5505d.png)

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

## Configuration

Configuration is expected to be in JSON, for which you can find the Schema [here](https://github.com/vinted/ab/blob/master/config.json). The provided schema is compatible with JSON Schema Draft 3. If you'd like to validate your JSON against this schema, in Ruby, you can do it using `json-schema` gem:

```
JSON::Validator.validate('/path/to/schema/config.json', json, version: :draft3)
```

An example config:

```json
{
    "salt": "534979417dc75a6f6f49146603a5e17e",
    "bucket_count": 1000,
    "ab_tests": [
        {
            "id": 42,
            "name": "experiment",
            "start_at": "2014-05-21T11:06:30+03:00",
            "end_at": "2014-05-28T11:06:30+03:00",
            "seed": "aaaa1111",
            "buckets": [1, 2, 3, 4, 5],
            "variants": [
                {
                    "name": "green_button",
                    "chance_weight": 1
                },
                {
                    "name": "red_button",
                    "chance_weight": 2
                },
                {
                    "name": "control",
                    "chance_weight": 3
                }
            ]
        },
    ]
}
```

Short explanation for a couple of config parameters:

`salt`: used to salt every identifier, before determining to which bucket that identifier belongs.

`bucket_count`: the total number of buckets.

`all_buckets`: optional boolean which tells that all buckets are used in this test. Checking `buckets` is not required in that case.

`ab_tests.start_at`: the start date time for ab test, in ISO 8601 format. Is not required, in which case, test has already started.

`ab_tests.end_at`: the end date time for ab test, in ISO 8601 format. Is not required, in which case, there's no predetermined date when test will end.

`ab_tests.buckets`: which buckets should be used for this ab test, represented as bucket ids. If the total number of buckets is 1000, values of this arrays are expected to be in 1..1000 range.

`ab_tests.variants`: tests can have multiple variants, each with a name and a weight.

More examples can be found in [spec/examples](https://github.com/vinted/ab/tree/master/spec/examples). Those examples are part of the test suite, which is run using [this code](https://github.com/vinted/ab/blob/master/spec/integration_spec.rb). We strongly recommend using those examples if you're reimplementing this library in another language.

## Algorithm

Most of the logic, is in `AssignedTest` class, which can be used as an [example implementation](https://github.com/vinted/ab/blob/master/lib/ab/assigned_test.rb).

Here's some procedural pseudo code to serve as a reference:

```pseudo
bucket_id = SHA256(salt + identifier.to_string).to_integer % bucket_count

return if not (test.all_buckets? or test.buckets.include?(bucket_id))
return if not DateTime.now.between?(test.start_at, test.end_at)

chance_weight_sum = chance_weight_sum > 0 ? test.chance_weight_sum : 1
weight_id = SHA256(test.seed + identifier.to_string).to_integer % chance_weight_sum
test.variants.find { |variant| variant.accumulated_chance_weight > weight_id }
```
