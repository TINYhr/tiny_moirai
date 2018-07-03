# TINYmoirai

Interface to trigger TINYpulse exports, proxies and other goodies.

NOTE: we'll make it work well enough, then rewrite it to improve design and security.

## Set up

Install RabbitMQ and PostgreSQL

```bash
docker-compose up
```

Set up the app. We don't put the app inside docker because file system sync between Docker and Mac is still slow.

```bash
gem install bundler
bundle install
bundle exec rake db:create db:migrate
```

## Run

```bash
rackup
```


## Notes

On server, use amqp-tools to trigger worker
```bash
amqp-publish -e "amq.topic" -r "worker1" --url=amqp://guest@127.0.0.1:5672 -p -b "this is a test message 3"

amqp-consume -e "amq.topic" -r "worker1" --url=amqp://guest@127.0.0.1:5672 ~/onmessage.sh

# Or using queue
amqp-consume -q "tpops.export.engage" --url=amqp://guest@127.0.0.1:5672 ~/onmessage.sh
```

Queue on server to clean up Heroku flag in db

```bash
bundle exec sneakers work HerokuDeregisteredListener  --require src/listeners/all.rb
```


### ActiveRecord

Generate a new migration

```bash
rake db:create_migration NAME=
```
