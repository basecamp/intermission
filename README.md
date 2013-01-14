#intermission


intermission is a bit of [OpenResty](http://openresty.org) magic written in Lua to help you perform zero down time maintenance. At [37signals](http://37signals.com) we use this to perform application maintenance with limited/no impact to the user. In our use cases, we "hold" the users requests for less than 10 seconds while we do our database maintenance via [mysql\_role\_swap](https://github.com/37signals/mysql_role_swap/). The user sees a single long request, and things carry right along.

## Design Concepts
Put an incoming web request on hold long enough to do bad things behind the scenes. Release the incoming requests in the same order they were received. Has zero dependencies.

## Gotchas
Requests can only be paused as long the device sitting in front of it will allow. If you have [haproxy](haproxy.1wt.eu) deployed in front of your Nginx instance, make sure to check your "srvtimeout" values.

# Getting started

### Trying it Out (Local)

+ Copy all of the files (except this one!) to /usr/local/openresty/nginx/conf (assuming a default installation).
+ Run /usr/local/openresty/nginx/sbin/nginx -c conf/sample-nginx.conf.
+ Tail /usr/local/openresty/nginx/log/intermission-error.log.
+ Hit [http://localhost:8080](http://localhost:8080) (you should see google)
+ Hit [http://localhost:8080/control](http://localhost:8080/control).
+ Hit [http://localhost:8080](http://localhost:8080) (you should see nothing)
+ Hit [http://localhost:8080/control](http://localhost:8080/control).
+ (Your request should have gone through now...)

# Getting help and contributing

### Getting help with intermission
The fastest way to get help is to send an email to intermission@librelist.com. 
Github issues and pull requests are checked regularly.

### Contributing
Pull requests with passing tests (there are no tests!) are welcomed and appreciated.

# License

     Copyright (c) 2012 37signals (37signals.com)

     Permission is hereby granted, free of charge, to any person obtaining
     a copy of this software and associated documentation files (the
     "Software"), to deal in the Software without restriction, including
     without limitation the rights to use, copy, modify, merge, publish,
     distribute, sublicense, and/or sell copies of the Software, and to
     permit persons to whom the Software is furnished to do so, subject to
     the following conditions:

     The above copyright notice and this permission notice shall be
     included in all copies or substantial portions of the Software.

     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
     LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
     OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
     WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
