require 'ftools'
require 'ostruct'
require 'open-uri'

site = OpenStruct.new({
  :ssh_user => "deploy@mobydick",
  :remote_root => "/var/www/default/project/",
  :public_url => "http://mobydick/project/"
})

# site = OpenStruct.new({
#   :ssh_user => "fusion@dev.fusion.fi",
#   :remote_root => "/var/www/project/",
#   :public_url => "http://dev.fusion.fi/project/"
# })

desc "Deploy 'deploy' dir to #{site.ssh_user}:#{site.remote_root}"
task :deploy do
  Dir.chdir("deploy") do
    puts
    puts "Deploying: #{Dir.pwd} -> #{site.ssh_user}:#{site.remote_root}"
    puts
    exclude_files = %w(.DS_Store).map{|file| "--exclude #{file}"}.join(" ")
    system("rsync -cvr --delete --cvs-exclude #{exclude_files} . #{site.ssh_user}:#{site.remote_root}")
    puts
    puts "See the page here: #{site.public_url}"
  end
end

site_root = 'http://localhost:4000/'
output_dir = 'deploy/'

desc "Spider the site #{site_root} and save the files under #{output_dir}"
task :spider do
  FileUtils.rm_rf(Dir.glob("#{output_dir}*"))
  files_to_copy = Dir.glob("public/**/[^_]*.{gif,png,jpg,css,js,ico,html}")
  files_to_copy.each do |path|
    save_path = output_dir + path.gsub(/^public\//, "")
    FileUtils.mkdir_p(File.dirname(save_path))
    File.copy(path, save_path, true)
  end
  files_to_spider = []
  files_to_spider += Dir.glob("views/**/[^_]*.html.haml").map{|f|f.gsub(/^views\//, "").gsub(".haml", "")}
  files_to_spider += Dir.glob("stylesheets/**/[^_]*.sass").map{|f|f.gsub(".sass", ".css")}
  files_to_spider.each do |path|
    save_path = output_dir + path
    puts "#{path} -> #{output_dir + path}"
    FileUtils.mkdir_p(File.dirname(save_path))
    open(site_root + path, 'rb') do |input|
      File.open(save_path, 'wb') do |output|
        output.write(input.read)
      end
    end
  end
end
