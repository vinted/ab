# ab

[![Code Climate](https://codeclimate.com/github/vinted/ab.png)](https://codeclimate.com/github/vinted/ab)
[![Build Status](https://secure.travis-ci.org/vinted/ab.png)](http://travis-ci.org/vinted/ab)
[![Gem Version](https://badge.fury.io/rb/vinted-ab.png)](http://badge.fury.io/rb/vinted-ab)
[![Dependency Status](https://gemnasium.com/vinted/ab.png)](https://gemnasium.com/vinted/ab)

If you didn't guess it from the name, this library is meant for ab testing. But it doesn't cover everything associated with it, it lacks configuration and management parts. [vinted/ab](https://github.com/vinted/ab) is only used to determine which variant should be applied for a user. Two inputs are expected - [configuration](#configuration) and identifier. Identifier, at least in Vinted's case, represents users, but other scenarios are certainly possible.

Each identifier is assigned to a bucket, using a hashing function. Buckets can then be assigned to tests. That allows isolation control, when we don't want clashing and creation of biases. Each test also has a seed, which is used to randomise how identifiers are divided among test variants. You can find algorithm description [here](#algorithm) if you want more detail.

![users](https://cloud.githubusercontent.com/assets/54526/2971326/0535267a-db69-11e3-9878-e2b6a5d5505d.png)

## Usage

```ruby
ab = Ab::Tests.new(configuration, identifier)

# defining callbacks, will use caller's context
Ab::Tests.before_picking_variant { |test| puts "picking variant for #{test}" }
Ab::Tests.after_picking_variant { |test, variant| puts "#{variant_name}" }

# ab.test never returns nil, but #variant can
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

# non existant variants return false
puts 'this will not get printed' if ab.test.there_is_no_button?

# both start_at and end_at dates are accessible
puts 'newbie button' if user.created_at > ab.test.start_at && ab.test.for_newbies?
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
            "start_at": "2014-05-21T11:06:30+0300",
            "end_at": "2014-05-28T11:06:30+0300",
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

More examples can be found in [spec/examples](https://github.com/vinted/ab/tree/master/spec/examples). Those examples are part of the test suite, which is run using [this code](https://github.com/vinted/ab/blob/master/spec/integration_spec.rb). `input.json` is configuration json and `output.json` gives expectations - which identifiers should fall to which variant. We strongly recommend using those examples if you're reimplementing this library in another language.

## Algorithm

Most of the logic, is in `AssignedTest` class, which can be used as an [example implementation](https://github.com/vinted/ab/blob/master/lib/ab/assigned_test.rb).

Here's some procedural pseudo code to serve as a reference:

```pseudo
salted_identifier = salt + identifier.to_string
bucket_id = SHA256.hexdigest(salted_identifier).to_int % bucket_count

return if not (test.all_buckets? or test.buckets.include?(bucket_id))
return if not DateTime.now.between?(test.start_at, test.end_at)

chance_weight_sum = chance_weight_sum > 0 ? test.chance_weight_sum : 1
seeded_identifier = test.seed + identifier.to_string
weight_id = SHA256.hexdigest(seeded_identifier).to_int % chance_weight_sum
test.variants.find { |variant| variant.accumulated_chance_weight > weight_id }
```

## Other Implementations

* [Java](https://github.com/vinted/ab-java) - intended to be used on Android, but not limited to that
* [Objective-C](https://github.com/vinted/ab-ios) - intended to be used on iOS devices
