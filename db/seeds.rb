# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!([
{:first_name => "Susan",    :last_name =>  "Alvarez", :email => "susan.alvarez38@example.com", :password => "kirsty123"},
{:first_name => "Seth",     :last_name =>  "Castro",  :email => "sethcastro82@example.com",    :password => "rocktown123"},
{:first_name => "Tyler",    :last_name =>  "McEvans", :email => "tylermcevans@example.com",    :password => "bigmac123"},
{:first_name => "Smith",    :last_name =>  "Haynes",  :email => "smithdiggity@example.com",    :password => "eatforfree123"},
{:first_name => "Qwin",     :last_name =>  "Osprey",  :email => "theqwin@example.com",         :password => "medicine123"},
{:first_name => "Lucas",    :last_name =>  "Malfoy",  :email => "cowardlylion@example.com",    :password => "crucio123"},
{:first_name => "Nicholas", :last_name =>  "Flamel",  :email => "stones@example.com",          :password => "sixeyes123"},
{:first_name => "Alastar",  :last_name =>  "Moody",   :email => "vigalence@example.com",       :password => "constant123"},
{:first_name => "Tom",      :last_name =>  "Riddle",  :email => "thedarklord@example.com",     :password => "expelliarmus123"},
{:first_name => "Ludo",     :last_name =>  "Bagman",  :email => "beaterbourne@example.com",    :password => "wimbourne123"},
{:first_name => "Susan",    :last_name =>  "Bones",   :email => "daforlife@example.com",       :password => "puffpuffboom123"},
{:first_name => "Charity",  :last_name =>  "Burbage", :email => "muggles1@example.com",        :password => "nonaginino123"}])


Specialty.create!([
{:name => "General",         :is_active => true},
{:name => "Family",          :is_active => true},
{:name => "Divorce",         :is_active => true},
{:name => "Grief",           :is_active => true},
{:name => "Marriage",        :is_active => true},
{:name => "Early Childhood", :is_active => true},
{:name => "Abuse",           :is_active => true}])
