gitfab2 [![Build Status](https://travis-ci.org/mozilla-japan/gitfab2.svg?branch=develop)](https://travis-ci.org/mozilla-japan/gitfab2) [![Code Climate](https://codeclimate.com/github/mozilla-japan/gitfab2/badges/gpa.svg)](https://codeclimate.com/github/mozilla-japan/gitfab2) [![Coverage Status](https://coveralls.io/repos/mozilla-japan/gitfab2/badge.svg?branch=develop&service=github)](https://coveralls.io/github/mozilla-japan/gitfab2?branch=develop)
=======

## Setup a build environment

### Requirements

- Docker 17 ce or later
- Docker Compose 1.16 or later

### Installation

```bash
$ git clone git@github.com:webdino/gitfab2.git
$ cd gitfab2
$ cp .env.sample .env
$ docker-compose build
```

### Start Docker Compose

```bash
$ docker-compose up
$ docker-compose ps
    Name                   Command                  State               Ports         
--------------------------------------------------------------------------------------
gitfab2_app_1   prehook ruby -v bundle ins ...   Up             0.0.0.0:3000->3000/tcp
gitfab2_db_1    docker-entrypoint.sh --inn ...   Up (healthy)   3306/tcp
```

Open https://localhost:3000 in your browser.

#### Create database

```bash
$ docker-compose run app bundle exec rails db:setup
```

### Run tests

```bash
$ docker-compose run app bundle exec rails db:test:prepare
$ docker-compose run app bundle exec rspec
```

## License

gitfab2 is released under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

Copyright 2017 WebDINO Japan.
