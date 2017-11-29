# Let's Encrypt HTTP Service

This container uses [dehydrated](https://github.com/lukas2511/dehydrated)
to automatically obtain SSL certs from [Let's Encrypt](https://letsencrypt.org/).

You will need a webserver that will serve the challenge responses when
queried by Let's Encrypt, such as my
[service-nginx](https://github.com/csmith/docker-service-nginx) container.

Multiple domains, as well as SANs, are supported. Certificates will be
renewed automatically, and obtained automatically as soon as new domains
are added.

## Usage

### Accepting Let's Encrypt's terms

In order to issue certificates with Let's Encrypt, you must agree to the
Let's Encrypt terms of service. You can do this by running the command
`/dehydrated --register --accept-terms` from within the container.

For ease of automation, you can define the `ACCEPT_CA_TERMS` env var
(with any non-empty value) to automatically accept the terms. Be warned
that doing so will automatically accept any future changes to the terms
of service.

### Defining domains

The container defines one volume at `/letsencrypt`, and expects there to be
a list of domains in `/letsencrypt/domains.txt`. Certificates are output to
`/letsencrypt/certs/{domain}`.

domains.txt should contain one line per certificate. If you want alternate
names on the cert, these should be listed after the primary domain. e.g.

```
example.com www.example.com
admin.example.com
```

This will request two certificates: one for example.com with a SAN of
www.example.com, and a separate one for admin.example.com.

The container uses inotify to monitor the domains.txt file for changes,
so you can update it while the container is running and changes will be
automatically applied.

### Well-known files 

To verify that you own the domain, a webserver must be listening for
requests and serve a unique file under the `/.well-known/acme-challenge`
directory. The responses for these files are written by this container
to `/letsencrypt/well-known`. 

### Other configuration

For testing purposes, you can set the `STAGING` environment variable to
a non-empty value. This will use the Let's Encrypt staging server, which
has much more relaxed limits.

You should pass in a contact e-mail address by setting the `EMAIL` env var.
This is passed on to Let's Encrypt, and may be used for important service
announcements.

By default this container uses Eliptic Curve keys. You can override this
behaviour by setting the `ALGORITHM` environment variable. Dehydrated
supports the following algorithms: `rsa`, `prime256v1` and `secp384r1`.

