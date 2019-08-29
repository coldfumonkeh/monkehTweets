[![Build Status](https://travis-ci.org/coldfumonkeh/monkehTweets.svg?branch=master)](https://travis-ci.org/coldfumonkeh/monkehTweets)

# monkehTweets ColdFusion Twitter API

---

monkehTweets is a ColdFusion Wrapper written to interact with the Twitter API.
Full installation details (incredibly simple) are included within
the */installation* directory.

monkehTweets has been compatible with Twitter's v1.1 API since October 2012 (well in advance of the change in May 2013)

## Authors

Developed by Matt Gifford (aka coldfumonkeh)

- [http://www.mattgifford.co.uk](web.archive.org/web/20180413021035/https://www.mattgifford.co.uk/)
- [http://www.monkehworks.com](http://web.archive.org/web/20161118203524/https://www.monkehworks.com/)


### Share the love

Got a lot out of this package? Saved you time and money?

Share the love and visit Matt's wishlist: http://www.amazon.co.uk/wishlist/B9PFNDZNH4PY

---

## Requirements

monkehTweets requires ColdFusion 8+

The package has been tested against:

* Adobe ColdFusion 9
* Adobe ColdFusion 10
* Railo 4
* Railo 4.1
* Railo 4.2
* Lucee 4.5
* Lucee 5

Project home: [http://monkehTweet.riaforge.org](http://web.archive.org/web/20180129120640/http://monkehtweet.riaforge.org/)

# CommandBox Compatible

## Installation
This CF wrapper can be installed as standalone or as a ColdBox Module. Either approach requires a simple CommandBox command:

`box install monkehtweet`

Then follow either the standalone or module instructions below.

### Standalone
This wrapper will be installed into a directory called `monkehTweet` and then can be instantiated via `new monkehTweet.com.coldfumonkeh.monkehTweet()` with the following constructor arguments:

```
     consumerKey			=	'',
     consumerSecret		=	'',
     oauthToken			=	'',
     oauthTokenSecret	=	'',
     userAccountName    =	'',
     parseResults  =	true
```

### ColdBox Module
This package also is a ColdBox module as well. The module can be configured by creating a `monkehTweeta configuration structure in your application configuration file: config/Coldbox.cfc with the following settings:

```
monkehTweet = {
     consumerKey			=	'',
     consumerSecret		=	'',
     oauthToken			=	'',
     oauthTokenSecret	=	'',
     userAccountName		=	'',
     parseResults		=	true,
};
```
Then you can leverage the CFC via the injection DSL: `monkehTweet@MonkehTweet`

## Useful Links

One of the questions received in regards to monkehTweets is how to manage authentication for multiple users.
You can find the answer right here:

- [Managing multiple Twitter users' authentication using monkehTweets](http://web.archive.org/web/20141011232750/www.monkehworks.com/managing-multiple-twitter-users-authentication-with-monkehtweet)
