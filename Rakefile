require File.expand_path('../macanudo', __FILE__)

desc "Macanudo"
task :cron do
  m = Macanudo.new
  if m.get_post(:today)
    m.update_with_post
  end
end