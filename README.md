# Cijepljenje

Aplikacija implementirana kao praktični dio diplomskog rada na temu Razvoj web-aplikacije u aplikacijskom okviru Sinatra.
Aplikacija je dostupna na: https://cijepljenje.herokuapp.com/

## Lokalno p okretanje aplikacije

* instalacija Ruby programskog jezika
* kloniranje git repozitorija na računalo
* izvršiti kreiranje baze podataka, migracije te početno popunjavanje
  * `bundle exec rake db:create`
  * `bundle exec rake db:migrate`
  * `bundle exec rake db:seed`
* pokretanje aplikacije u terminalu naredbom `bundle exec thin -p 4567 start`


### Korisnici aplikacije:

#### Aministrator
* email: admin@example.com
* lozinka: asdfasdf

#### Liječnik
* email: doctor1@example.com
* lozinka: asdfasdf

#### Predstavnik prioritetne skupine
* email: superuser1@example.com
* lozinka: asdfasdf

#### Cjepitelj
* email: vaccination.worker1@example.com
* lozinka: asdfasdf
