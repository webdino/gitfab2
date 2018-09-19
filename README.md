gitfab2 [![Build Status](https://travis-ci.org/mozilla-japan/gitfab2.svg?branch=develop)](https://travis-ci.org/mozilla-japan/gitfab2) [![Code Climate](https://codeclimate.com/github/mozilla-japan/gitfab2/badges/gpa.svg)](https://codeclimate.com/github/mozilla-japan/gitfab2) [![Coverage Status](https://coveralls.io/repos/mozilla-japan/gitfab2/badge.svg?branch=develop&service=github)](https://coveralls.io/github/mozilla-japan/gitfab2?branch=develop)
=======

## Setup a build environment

### Requirements

- Docker 17 ce or later
- Docker Compose 1.16 or later
- direnv
- rbenv
- node.js

### Installation

```bash
$ git clone git@github.com:webdino/gitfab2.git
$ cd gitfab2
$ rbenv install `cat .ruby-version`
$ gem install bundler --no-document
$ bundle install
$ npm install
$ npm run build
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
gitfab2_db_1                 docker-entrypoint.sh --inn ...   Up      0.0.0.0:13306->3306/tcp
```

#### Create database

Dockerコンテナを起動してから

```bash
$ bundle exec rake db:create
$ bundle exec rake db:migrate
```

### Run Server

```bash
$ bundle exec rails s
```

Open http://localhost:3000 in your browser.

### Frontend

`app/frontend/` 以下の開発を行う場合は、 `npm start` でwebpackを起動する。
`app/frontend/` 以下に変更を加えない場合は、一度 `npm run build` をすればOK。


### Run tests

```bash
$ bundle exec rspec
```

### Install node.js on CentOS 7
- CentOS 7.5
- node.js 10.7.0

```bash
$ curl -sL https://rpm.nodesource.com/setup_10.x | bash -
$ yum install -y gcc-c++ make nodejs
$ npm install
```

## License

gitfab2 is released under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

Copyright 2017 WebDINO Japan.
