desc 'Current version'
task version: [:environment] do
  puts Settings.version
end
