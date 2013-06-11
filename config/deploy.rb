set :stages, %w(production integ)
set :default_stage, "integ"
require 'capistrano/ext/multistage'


set :application, "slinggit"
set :repository,  "https://slinggit@bitbucket.org/chrisklein/slinggit-webapp-and-services.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#set :deploy_to, "/home/slinggit/webapps/slinggit_test"

set :default_environment, {
  'PATH' => "#{deploy_to}/bin:$PATH",
  'GEM_HOME' => "#{deploy_to}/gems" 
}

set :rake, 'bundle exec rake'

role :web, "web307.webfaction.com"                          # Your HTTP server, Apache/etc
role :app, "web307.webfaction.com"                          # This may be the same as your `Web` server
role :db,  "web307.webfaction.com", :primary => true # This is where Rails migrations will run


set :user, "slinggit"
set :scm_username, "slinggit"
set :use_sudo, false
default_run_options[:pty] = true

# Make sure any needed gems are installed
before "deploy:assets:precompile", "gems:install"
namespace :gems do
  desc "Install gems"
  task :install, :roles => :app do
    run "cd #{current_release} && bundle install --without development test"
    # run "cd #{current_release} && bundle install --without test production"
  end
end

# Add a symlink to the shared uploads directory (create this directory manually)
namespace :uploads do
  desc "Create the symlink to uploads shared folder for most recent version"
  task :create_symlink, :except => { :no_release => true } do
    run "rm -rf #{release_path}/public/uploads"
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
  end
end

# Restart Rails app's nginx server after deployment
namespace :deploy do
  desc "Restart nginx"
  task :restart do
    run "#{deploy_to}/bin/restart"
  end
end

# only keep the last 5 deployments on the server
after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:finalize_update", "uploads:create_symlink"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end