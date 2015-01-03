# config valid only for Capistrano 3.1
require 'json'

lock '3.3.5'

set :application, 'myapp'
set :repo_url, 'git@github.com:myorg/myapp.git'
set :branch, :master
set :deploy_to, '/var/app'
set :scm, :git
set :format, :pretty
set :log_level, :debug
set :pty, true
set :keep_releases, 3

set :ssh_options, {
  keys: ["#{ENV['HOME']}/.ssh/private_key.pem"]
}

set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Lookup servers and roles

do_hosts_script = File.expand_path("../../ansible/dohosts", __FILE__)
do_servers = JSON.parse(`#{do_hosts_script}`)

puts fetch(:stage)

app_servers = do_servers["#{fetch(:stage)}-myapp-apps"]
worker_servers = do_servers["#{fetch(:stage)}-myapp-workers"]

app_servers.each_with_index do |s, i|
  roles = ['web', 'app']
  roles << 'db' if i == 0
  server s, user: 'webapp', roles: roles
end

worker_servers.each do |s|
  server s, user: 'webapp', roles: %w{app sidekiq}
end




namespace :deploy do

  desc 'Setup environment'
  task :setup_env do
    SSHKit.config.command_map = Hash.new do |hash, command|
      hash[command] = "#{command}"
    end
    SSHKit.config.command_map.prefix[:rake].push("export $(cat /var/app/support/app.env | xargs); /usr/bin/env bundle exec")
    SSHKit.config.command_map.prefix[:bundle].push("export $(cat /var/app/support/app.env | xargs); /usr/bin/env")
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "mkdir -p #{release_path.join('tmp/')}"
    end
    on roles(:web), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
      execute "sudo systemctl restart nginx"
    end
    on roles(:sidekiq), in: :sequence, wait: 5 do
      execute "sudo systemctl restart sidekiq"
    end
  end

  after :updating, :setup_env
  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end

end
