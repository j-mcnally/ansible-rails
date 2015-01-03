# Ansible-Rails

Rails ansible is a collection of playbooks to bootstrap a full rails stack, complete with Postgres, Redis, Sidekiq, Nginx and HAProxy on Centos 7 targeting Digital Ocean as a host.

The playbooks have 4 primary roles. 

- App Tier (Rails App + Nginx)
- Services Tier (Postgres / Redis / Memcached)
- Worker Tier (Sidekiq)
- Loadbalancer Tier (HAProxy)


In addtional to these 4 tiers there is a pretty extensive core / common role that all tiers/roles include.

Goals of the playbooks are:

- Create a solid foundation for hosting complex rails applications on CentOS 7. 
- Autoconfigures its own firewall rules, loadbalancer configuration, postgres access, and app environment based on inventory.
- Build current stable ruby from source, its easy to do and package maintainers seem to have a problem getting this right and keeping things current.
- Build nginx with phusion passenger.
- Host rails configuration as environment variables
- Ensure rails logs are properly rotated
- Keep a decent ammount of security through very limited firewall exposure
- Use systemd for services
- Limit sudo access for webapp user to only service management
- Automatically provision public-key authentication
- Provision required servers via DigitalOcean api.


## Getting Started

- Install ansible
- Review configurations
  - digitalocean.ini
  - provisioning/do_creds.yml
  - group_vars/staging.yml
  - group_vars/production.yml
  - roles/common/templates/app.env.j2
- Configure SSH private / public keys
  - ~/.ssh/app_private_key.pem
  - roles/common/files/public_key
  - roles/common/myapp.github.pem
  - roles/common/myapp.github.pem.pub
- Define your required architecture per environment
  - provisioning/requirements/staging.yml
  - provisioning/requirements/produciton.yml


## Spin up your instances

Once you've added you Digital Ocean api keys to the required files. 

*Note: You should be using v1 api keys.*

You can go ahead and start your staging environment servers by running the following playbook command.

`ansible-playbook -i local provisioning/stack.yml --extra-vars "myapp_env=staging"`

If you rolled with the defaults you will have 1 server for each role.

## Provision your staging environment

Now is the point where we run our main playbooks to setup the boxes.

`ansible-playbook -i dohosts myapp.yml --extra-vars="myapp_env=staging"`

With any luck at this point all the software and services for your stack should be running.

## Deploy your rails application

We wont go into a ton of detail about how to deploy a rails app. At memms.io we use Capistrano v3, so i've included a few tricks in `extra/capistrano/deploy.rb` Basically the hacks here are to load our dohosts from ansible and use our dynamic inventory to do our cap deploy. Also one of neat things we do is make sure the app.env variables are loaded for each cap command.

## Rinse, wash, repeat

Deploying your staging environment should be as easy as changing myapp_env=production in the ansible-playbook commands.

### Troubleshooting / Known-Issues

A few python packages may be missing for some of the local tasks. The dohosts script requires the request package. This can be installed with `pip install requests`. 

To run the digital ocean provisioning scripts you may need the digital ocean python library. `pip install dopy`

Mac OSX users should install ansible with brew. `brew install ansible`


# Contributing

Any issues / problems / feedback should be filed as github issues.

Pull-Requests Welcomed!

# Sponsored by

- [memms.io](http://memms.io) - Memories made easy. No signups, 
no logins, no fuss, just memms.
- [kohactive.com](http://kohactive.com) - Web / Mobile Development Studio


# Made with Love by
- [@j_mcnally](http://www.twitter.com/j_mcnally) in chicago.
