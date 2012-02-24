require 'mechanize'
require 'logger'
require 'json'
require 'fileutils'

username = "mwolfe38"
save_to="/home/mwolfe/Music/downloads"

def clean_filename(filename)
  if (filename == nil)
    ""
  else
    filename = filename.gsub(/[^\w \- \(\)\.\']*/, "")
    filename.gsub(/\.\.\./, "")    
  end
end
def prompt_int(prompt, default)
  if (default != nil)
    prompt = prompt + " [#{default}]"    
  end
  prompt = prompt + ": "
  while true
    print prompt
    val = gets.strip
    if (val == "" && default != nil)
      return default
    end
    begin
      int = Integer(val)
      return int
    rescue ArgumentError
      puts "Invalid integer, try again"
    end
  end
end

def prompt_string(prompt, default) 
  if (default != nil)
    prompt = prompt + " [#{default}]"    
  end
  prompt = prompt + ": "
  while true
    print prompt
    val = gets.strip
    if (val == "" && default != nil)
      return default
    end
    if (val != "")
      return val
    end
    puts "Invalid value, try again"
  end
  
end

start_page = prompt_int("Start with page", 1)
total_pages = prompt_int("Total pages to download", 1)

username = prompt_string("Username", username)

puts "We will download from page #{start_page} with total pages #{total_pages} with username #{username}"


FileUtils.mkdir_p(save_to)
log_file = "log.txt"
agent = Mechanize.new { |a|
  if File.exists?(log_file)
     File.delete(log_file)
  end
  a.log = Logger.new(log_file)
  a.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11"
}

songs = []

total_pages.times do |page_index|
  current_page = start_page + page_index
  url = "http://hypem.com/#{username}/#{current_page}"
  page = agent.get(url)
  page.search("#content-left .section-track script").each do |script|  
   script_s = script.to_s 
   song = {}
   id = nil
   script_s.each_line() do |line|
     match  =  line.match(/\s+(artist|postid|id|key|song):\s*'(.*)'/)
     if (match != nil)
      song[match[1]] = match[2]
     end
   end 
   songs << song
  end
end


songs.each do |song|
  id = song['id']
  key = song['key']
  json_url = "http://hypem.com/serve/source/#{id}/#{key}"

  filename = "#{save_to}/#{clean_filename(song['artist'])} - #{clean_filename(song['song'])}.mp3"
  if (File.exists?(filename))
    next
  end

  begin
    data_string = agent.get_file(json_url)  
  rescue Exception => e
    puts "Exception #{e.message}\nwhile trying to fetch json for file #{song['song']}"
  end
  
  if (data_string != nil)    
    data = JSON.parse(data_string)
    song_url = data["url"]
    puts " ************** Downloading song ******************"
    puts "\tartist: #{song['artist']}\n\ttitle: #{song['song']}\n\turl: #{song_url}\n\tfile: #{filename}"
    agent.pluggable_parser.default = Mechanize::Download   
    begin  
      agent.get(song_url).save(filename)
      puts "\tSuccess!"
    rescue Exception => e
      puts "Exception #{e.message}\nwhile trying to fetch mp3 file for #{song['song']}"
    end
  end
end


