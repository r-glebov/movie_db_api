# How to install

```text
git clone git@github.com:r-glebov/movie_db_api.git
```

Install Postgresql and Elasticsearch

```text
brew install postgresql elasticsearch
```

Start Postgresql and Elasticsearch

```text
brew services start postgresql
brew services start elasticsearch
```

Run `bundle install`

Run db commands: 

```text
bundle exec rails db:create
bundle exec rails db:migrate
```

Seed the database. In order to seed it correctly you need TMDB Api key, which
can be obtained by the following URL https://www.themoviedb.org

The you just need to put the key to your `.bash_profile`, `.bashrc`, etc.

```text
echo "export TMDB_KEY="key" >> ~/.bash_profile
```

```text
bundle exec rails db:seed
```

There is a `postman_collection.json` file to play with after importing it to the Postman


## Running tests

```text
rspec spec
```
