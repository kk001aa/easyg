# https://github.com/seeu-inspace/easyg/blob/main/easyg.rb

# ToDo: - add a webscreenshot, use: https://github.com/michenriksen/aquatone

# ===================================================================


require 'socket'
require 'json'

puts "\e[35m\n E a s y G\n\e[0m"

$c = 0

def firefox(target)

	system 'start firefox "' + target.to_s + '"'
	puts target.to_s
	
	$c += 1
			
	if $c >= 15
		sleep 30
		$c = 0
	end

end

def go_on(file_i)

	system "type " + file_i + " | httprobe > " + file_i +  "_httprobed"

	File.open(file_i + "_httprobed",'r').each_line do |f|
	
	begin
		target = f.gsub("\n","")
	end

		firefox(target.to_s)
		
	end
	
end

def wayback_go_on(file_i)

	File.open(file_i,'r').each_line do |f|
	
	begin
		target = f.gsub("\n","")
	end
		
		system "python waybackurls.py " + target.to_s
		
		if File.exists?(target.to_s + "-waybackurls.json") == true
		
			file_parsed = JSON.parse(File.read(target.to_s + "-waybackurls.json"));
			
			for i in 0..file_parsed.length()-1 do
			
				firefox("https://" + file_parsed[i].to_s[9...-2])
			
			end
		
		end
		
		system "python waybackrobots.py " + target.to_s
			
		if File.exists?(target.to_s + "-robots.txt") == true
			
			File.open(target.to_s + "-robots.txt",'r').each_line do |f|
			begin
				target_robot = f.gsub("\n","")
			end

				firefox(target.to_s + target_robot.to_s)

			end

		end
			
	end
	
end

# --- OPTIONS ---

if ARGV[1] == "nmap"
	system "nmap -T4 -A -v -iL " + ARGV[0]
end

if ARGV[1] == "firefox"
	File.open(ARGV[0],'r').each_line do |f|
	begin
		target = f.gsub("\n","")
	end
		firefox(target.to_s)
	end
end

if ARGV[1] == "wayback"
	wayback_go_on(ARGV[0])
end

if ARGV[1] == "amass"

	File.open(ARGV[0],'r').each_line do |f|
	begin
		target = f.gsub("\n","")
	end
		
		system "amass enum -brute -active -d " + target.to_s + " -o " + target.to_s + ".txt"
		
		if ARGV[2] == "firefox"
			go_on(target.to_s + ".txt")
		end
		
		if ARGV[2] == "wayback"
			wayback_go_on(target.to_s + ".txt")
		end
		
		if ARGV[2] == "firefox-wayback"
			go_on(target.to_s + ".txt")
			wayback_go_on(target.to_s + ".txt")
		end

	end
	
end

if ARGV[0] == "help"

	puts 'Usage: ruby easyg.rb <file_input> <nmap/firefox/wayback/amass>'
	puts 'If amass is selected, you can add <firefox/wayback/firefox-wayback>' + "\n\n"
	
	puts 'Tested on Windows, if you need to use it on Unix:'
	puts ' - use `xdg-open` insead of `start firefox`'
	puts ' - for httprobe, use `cat <file_name> | httprobe`' + "\n\n"
	
	puts 'You need waybackurls.py and waybackrobots.py in the same folder as easyg.rb. Links:'
	puts 'https://gist.github.com/mhmdiaa/adf6bff70142e5091792841d4b372050'
	puts 'https://gist.github.com/mhmdiaa/2742c5e147d49a804b408bfed3d32d07' + "\n\n"
	
end
