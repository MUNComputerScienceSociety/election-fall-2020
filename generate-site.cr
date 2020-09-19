require "ecr"
require "csv"
require "option_parser"

content = File.read("./data.csv")

struct Entry
  property timestamp : String
  property email : String
  property raw_email : String
  property name : String
  property roles : Array(String)
  property paragraph_1 : String
  property paragraph_2 : String
  property photo : String?

  def initialize(row)
    timestamp, email, name, roles, paragraph_1, paragraph_2, photo = row

    @timestamp = timestamp
    @raw_email = email
    @email = email.gsub("@", " <i><code>@</code></i> ")
    @name = name
    @roles = roles.split(';')
    @paragraph_1 = paragraph_1
    @paragraph_2 = paragraph_2

    @photo = photo != "" ? photo : nil
  end
end

roles = Hash(String, Array(Entry)).new

entries = [] of Entry

CSV.each_row(content) do |row|
  entry = Entry.new(row)
  entry.roles.each do |role|
    if slot = roles[role]?
      slot << entry
    else
      roles[role] = [entry]
    end
  end
  entries << entry
end

roles.each do |k,v|
  v.shuffle!
end

entries.shuffle!

parser = OptionParser.new do |parser|
  parser.banner = "Usage: [arguments]"
  parser.on("-o", "--output-html", "Output the site, using site.ecr as a template") do
    puts ECR.render("site.ecr")
    exit(0)
  end
  parser.on("-e", "--emails", "Output all emails") do
    entries.each do |entry|
      puts entry.raw_email
    end
    exit(0)
  end
  parser.on("-r", "--roles", "Output formatted list of each role") do
    roles.each do |k,v|
      puts "#{k}:"
      v.each do |e|
        puts "  #{e.name}"
      end
      puts ""
    end
    exit(0)
  end
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

parser.parse

puts parser
