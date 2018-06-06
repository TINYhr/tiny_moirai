Interface to trigger TINYpulse export

On server, use amqp-tools to trigger worker
```bash
amqp-publish -e "amq.topic" -r "worker1" --url=amqp://guest@127.0.0.1:5672 -p -b "this is a test message 3"

amqp-consume -e "amq.topic" -r "worker1" --url=amqp://guest@127.0.0.1:5672 ~/onmessage.sh

# Or using queue
amqp-consume -q "tpops.export.engage" --url=amqp://guest@127.0.0.1:5672 ~/onmessage.sh
```

Queue on server to clean up Heroku flag in db

```bash
bundle exec sneakers work HerokuDeregisterListener  --require src/listeners/all.rb
```
