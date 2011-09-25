require File.expand_path('../macanudo', __FILE__)

desc "Macanudo"
task :cron do
  m = Macanudo.new
  if m.get_last_entry
    m.update_last_entry
  end
end