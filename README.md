# Kafka Worker Pool

__tense warning: all of this is aspirational at the moment,
so shift all present tense to future tense__

Create two topics in Kafka,
one called e.g. "work_orders",
and another "work_claims".

Arrange to have
several instances of `pool_worker` run so that
it receives

```
ORDERS_TOPIC=work_orders
COORDINATION_TOPIC=work_claims
INSTANCE_NUMBER=1 #e.g. unique per instance
```

in its environment
and so that it will be restarted when it exits.

Send jobs to "work_orders" and
a `pool_worker` will pick it up and execute the jobs.

## How It Works

On boot, `pool_worker` consumes the coordination topic
and looks for entries for its instance number.
These entries will look like
`(<instance-number>, "claimed", <job-offset>)`, or
`(<instance-number>, "completed", <job-offset>)`.
The coordination topic is compacted on instance number and event type.

There's two basic possibilities: either the worker has an outstanding job
(because its most advanced completed job-offset
is smaller than
its most advanced claimed job-offset)
or else it's up to date
(because the two job offsets are the same).
If the worker has an outstanding job,
it consumes that offset off the orders topic
and starts working.

If the worker is up to date,
it starts consuming the orders queue.
When it consumes a work order
it checks the coordination topic.
There's two more events that might appear there,
besides "claimed" and "completed":
"committed" and "yielded".

If no events are on the coordination topic
for the newly read work order,
the worker publishes a "claimed" event.
Then it consumes the coordination topic again.
If there's no other "claimed" events,
it publishes a "committed" event
and starts work.
When the work is completed,
it publishes "completed" and exits.
(It's restarted and goes through its boot process.)

Note that workers use
the low level Kafka consumer interface
so that they can control when
their topic offets are updated.
Effectively, offset updates
are held until a work order commit cycle completes,
so that a dying worker can
pick back up at a checkpoint.

### Conflicts

If there is one other "claimed" event,
the worker compares its instance number
to the number of the other claimant.

If the other number is lower,
and there's no "committed" or "yielded" event,
immediately issue a "yielded" event.

If the other number is higher,
it consumes the coordination topic
waiting for a "committed" or "yielded" event.
For "committed", it issues a "yielded",
for "yielded", it issues a "committed".

More than one other claimant is handled analogously.
If any other claimant has a lower number than you, yield.
Otherwise, if any other claimant has a higher number than you,
wait for what they do

## Work Orders

Complete underpants gnome moment here:

0. Claim work order
0. :shrug:
0. Complete work order

Could be a docker image and environment pairs list.
Could be and executable line.
Could be a URL to get the actual work order from.

For the moment, we're concerned with ensuring that the work is done and done once.
