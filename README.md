# ab

## Configuration

For this lib to work, it requires a configuration json, which looks like this:

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
            "buckets": [
                1,
                2,
                3,
                4,
                5
            ],
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
        {
            "id": 44,
            "name": "red_shirts",
            "start_at": "2014-05-24T11:09:30+03:00",
            "end_at": "2099-05-24T11:09:30+03:00",
            "seed": "bbbb4444",
            "buckets": [
                4,
                5,
                6,
                7
            ],
            "variants": [
                {
                    "name": "red_shirt",
                    "chance_weight": 1
                },
                {
                    "name": "control",
                    "chance_weight": 1
                }
            ]
        },
        {
            "id": 47,
            "name": "feed",
            "start_at": "1999-03-31T00:00:00+03:00",
            "end_at": "2099-03-31T00:00:00+03:00",
            "seed": "cccc8888",
            "buckets": "all",
            "variants": [
                {
                    "name": "enabled",
                    "chance_weight": 1
                }
            ]
        },
    ]
}
```

## Usage

```ruby
configuration = retrieve_from_svc_abs
ab = Ab::Experiments.new(configuration, user_id)

# ab.experiment never returns nil
# but if you don't belong to any of the buckets, variant will be nil
case ab.experiment.variant
when :red_button
  red_button
when :green_button
  green_button
else
  blue_button
end

# calls #variant underneath
# #variant caches results, so meta tracking events would not be sent multiple times
puts 'magic' if ab.experiment.red_button?

render_feed if ab.feed.enabled?
```
