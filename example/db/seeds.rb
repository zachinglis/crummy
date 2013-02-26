# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

movies    = Category.create :title => "Movies",           :slug => "movies"
star_wars = Category.create :title => "Star Wars",        :slug => "star-wars", :category => movies
time      = Category.create :title => "What time Is It?", :slug => "time"

Post.create :title => "A Long Long Time Ago", :slug => "a-long-long-time-ago",  :category => star_wars
Post.create :title => "It's Hammer Time",     :slug => "its-hammer-time",       :category => time
Post.create :title => "Test",                 :slug => "test"
