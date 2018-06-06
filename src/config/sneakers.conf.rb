workers (ENV["WORKERS"] || 1).to_i

before_fork do
  Sneakers::logger.info " ** Init db connection ** "
end


after_fork do
  Sneakers::logger.info " ** Close db connection ** "
end
