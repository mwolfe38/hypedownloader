require 'mechanize'
require 'logger'
require 'json'
require 'fileutils'
require 'taglib'
require 'pp'

save_to= File.expand_path("~/Music/Shared/new")


FileUtils.mkdir_p(save_to)
log_file = "log.txt"

songs = Dir.glob("#{save_to}/*.mp3") do |filename|
	song = File.basename(filename, '.mp3')
	artistIndex = song.index("-")
	if artistIndex < 0
		continue  
	end
	artist = song.slice(0, artistIndex).strip
	title = song.slice(artistIndex+1, song.length).strip
	puts("artist: #{artist} title #{title}")

	TagLib::FileRef.open(filename) do | mp3File |
		tag = mp3File.tag
		puts "tag is #{tag.title}"

		if tag == nil || tag.title == nil || tag.title.empty?
			tag.title = title
			tag.artist = artist
			#tag.album = f_album unless f_album == nil
			puts "artist #{artist} and title #{title} written for #{filename}"
			mp3File.save
		end
	end
end

