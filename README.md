## fp-sin 0.2.0

Simple Sinatra shell with all the goodies.

I added quite a few things.

1. Uses rack-fiber_pool, em_mysql2, em-resolv-replace, em-synchrony, and em-http-request for async requests.
2. ActiveRecord is included via sinatra-activerecord.
3. Basic login system included via sinatra-authentication.
4. Simple localization with i18n.
5. Added bundler and rvm support.
6. Added scss support.
7. Dalli for speedy memcache support.
8. Tux is included for console debugging.
9. Convenient hashing functions for sha1, sha2 and md5.

To start the server:

```console
bundle exec thin -R config.ru start
```

This will fire it up on port 3000.

To run the tests:

```console
bundle exec rake test
```

To launch a console:

```console
bundle exec rake console
```

If you want to see an application that used this setup as a base, you should check out em-shorty at http://github.com/zquestz/em-shorty.
