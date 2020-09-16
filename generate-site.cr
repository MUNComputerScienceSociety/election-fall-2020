require "ecr"
require "csv"

content = File.read("./data.csv")

struct Entry
  property timestamp : String
  property email : String
  property name : String
  property roles : Array(String)
  property paragraph_1 : String
  property paragraph_2 : String
  property photo : String?

  def initialize(row)
    timestamp, email, name, roles, paragraph_1, paragraph_2, photo = row

    @timestamp = timestamp
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

puts ECR.render("site.ecr")
