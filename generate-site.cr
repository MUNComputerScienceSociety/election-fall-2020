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

entries = [] of Entry

CSV.each_row(content) do |row|
  entries << Entry.new(row)
end

puts ECR.render("site.ecr")
