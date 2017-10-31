gitfab2 [![Build Status](https://travis-ci.org/mozilla-japan/gitfab2.svg?branch=develop)](https://travis-ci.org/mozilla-japan/gitfab2) [![Code Climate](https://codeclimate.com/github/mozilla-japan/gitfab2/badges/gpa.svg)](https://codeclimate.com/github/mozilla-japan/gitfab2) [![Coverage Status](https://coveralls.io/repos/mozilla-japan/gitfab2/badge.svg?branch=develop&service=github)](https://coveralls.io/github/mozilla-japan/gitfab2?branch=develop)
=======

## Setup a build environment

### Requirements

- Docker 17 ce or later
- Docker Compose 1.16 or later
- direnv
- rbenv

### Installation

```bash
$ cd gitfab2
$ rbenv install `cat .ruby-version`
$ gem install bundler --no-ri --no-rdoc
$ bundle install
$ cp config/database.ymls/development.yml config/database.yml
$ cp .envrc.sample .envrc
$ vi .envrc
$ direnv allow
```

### Start Docker Compose

```bash
$ docker-compose up -d
$ docker-compose ps
              Name                             Command               State            Ports
----------------------------------------------------------------------------------------------------
gitfab2private_db_1                 docker-entrypoint.sh --inn ...   Up      0.0.0.0:13306->3306/tcp
gitfab2private_solr_development_1   docker-entrypoint.sh solr- ...   Up      0.0.0.0:18983->8983/tcp
gitfab2private_solr_test_1          docker-entrypoint.sh solr- ...   Up      0.0.0.0:28983->8983/tcp
```

#### Create solr cores

コンテナを起動したまま

```bash
docker exec -it --user=solr gitfab2private_solr_test_1 solr create -c gitfab2
docker exec -it --user=solr gitfab2private_solr_development_1 solr create -c gitfab2
```

※`gitfab2private_solr_test_1`および`gitfab2private_solr_development_1`の部分は起動中のコンテナ名。（`docker-compose ps`で確認できるもの）

Web UIで確認できる。

http://127.0.0.1:18983/solr/

http://127.0.0.1:28983/solr/

#### Create database

Dockerコンテナを起動してから

```bash
$ bundle exec rake db:create
$ bundle exec ridgepole -c config/database.yml -E development --apply -f db/schemas/Schemafile --enable-foreigner
$ bundle exec ridgepole -c config/database.yml -E test --apply -f db/schemas/Schemafile --enable-foreigner
```

### Run Server

```bash
$ bundle exec rails s
[DEPRECATION] requiring "RMagick" is deprecated. Use "rmagick" instead
warning: parser/current is loading parser/ruby21, which recognizes
warning: 2.1.6-compliant syntax, but you are running 2.1.2.
warning: please see https://github.com/whitequark/parser#compatibility-with-ruby-mri.
=> Booting WEBrick
=> Rails 4.1.16 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
=> Notice: server is listening on all interfaces (0.0.0.0). Consider using 127.0.0.1 (--binding option)
=> Ctrl-C to shutdown server
[2017-11-01 14:47:18] INFO  WEBrick 1.3.1
[2017-11-01 14:47:19] INFO  ruby 2.1.2 (2014-05-08) [x86_64-linux]
[2017-11-01 14:47:19] INFO  WEBrick::HTTPServer#start: pid=6533 port=3000
```

Open http://localhost:3000 in your browser.


### Run tests

```bash
$ bundle exec rspec
```

## License

gitfab2 is released under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

Copyright 2017 WebDINO Japan.
