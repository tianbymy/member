=begin
require 'bundler/capistrano'
set :keep_releases, 5
set :application, "member"
set :repository,  "git@github.com:tianbymy/member.git"
set :branch, 'dev'
set :scm, :git
set :scm_scm_command,"/usr/bin/git"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :use_sudo,false
role :web, "www.scscfw.com"                          # Your HTTP server, Apache/etc
role :app, "www.scscfw.com"                          # This may be the same as your `Web` server
role :db,  "www.scscfw.com", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
set :deploy_to, "/home/scpsp/zhiyisoft/program/#{application}"
set :current_path, "/home/scpsp/zhiyisoft/program/#{application}/current"
set :port,6922
set :ruby_bin ,"/home/scpsp/zhiyisoft/program/ruby/bin"
set :bundle_cmd, "/home/scpsp/zhiyisoft/program/ruby/bin/bundle"
set :rails_env, 'production'
set :runner, "scpsp"
set :user, "scpsp"
set :password, "adminxg"
set :bundle_flags, '--quiet'


after "deploy:create_symlink", "deploy:stop"
after "deploy:restart", "deploy:cleanup"#,"bundle:install"


namespace :bundle do

  desc "run bundle install and ensure all gem requirements are met"
  task :install do
    run "cd #{current_path} && #{ruby_bin}/bundle install "
  end

end


namespace :deploy do
  task :restart do
#    run "cd /home/xiegang/mass/current/ &&#{ruby_bin}/rake db:schema:load RAILS_ENV=production "
#    run "cd /home/xiegang/mass/current/ &&#{ruby_bin}/bundle exec  #{ruby_bin}/rake RAILS_ENV=production  assets:precompile"
    run "/opt/nginx/sbin/nginx -s reload"
#    run "curl -s -o /dev/null http://www.zhiyisoft.com:8000"
  end
end

end
