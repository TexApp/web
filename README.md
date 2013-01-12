# TexApp.org

## Configuration

The application requires credentials for `mysql` and `CloudFiles` in `config/credentials.yml`. You will need to set one up for local testsing. An example is provided.

## Deployment

Ensure your SSH public key is copied to the `thin@texapp.org`'s `authorized_keys` file:

    $ ssh-copy-id thin@texapp.org
    password: [enter password]
    $ ssh thin@texapp.org
    [no password required]
    thin@texapp:~$ 

Then be certain that SSH knows about your key. Capistrano will need to forward it so `thin@texapp.org` can access GitHub to pull your commit:

    $ ssh-add
    Identity added: /home/[USER]/.ssh/id_rsa ...

Then deploy:

    $ cap deploy

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
