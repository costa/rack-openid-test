
This is a working test of [rack-openid](https://github.com/josh/rack-openid)
based on the sinatra example provided there.

It is obviously a sinatra app, (hopefully) running [here](http://rack-openid-test.heroku.com/).

It was used to debug an issue with [Heroku](http://heroku.com) production deployment, and as such it uses memcache for the `OpenID::Store` via [dalli](https://github.com/mperham/dalli) client.
Feel free to [clone](https://github.com/costa/rack-openid-test) and add branches per configuration.
