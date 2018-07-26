workers (ENV["WORKERS"] || 1).to_i

before_fork do
  ActiveRecord::Base.connection.disconnect!
end


after_fork do
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
end
