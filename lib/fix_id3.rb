require 'taglib'
require 'pp'
if (ARGV.length < 1)
  puts "Path to mp3 files required."
  exit
end
dir = ARGV[0].chomp("/")
Dir.glob(dir + "/*.mp3") do |file|
  basename = File.basename(file);
  file_parts = basename.split(" - ")
  next if file_parts.length < 2
  f_artist = file_parts[0]
  f_album = nil
  if (file_parts.length == 3)  
	f_album = file_parts[1]
  end
  f_song = file_parts.last.chomp(".mp3")
  TagLib::FileRef.open(file) do | file1 |
    tag = file1.tag
    if tag == nil || tag.title == nil
      tag.title = f_song
      tag.artist = f_artist
      tag.album = f_album unless f_album == nil
      puts "artist and title written for #{basename}"
      file1.save
    end
  end
end

