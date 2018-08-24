#!/usr/bin/env ruby
# mv.rb rename after split
f=Dir['slide_*']
#puts f
r=(2..(f.length + 2)).to_a
a=f.zip(r)
x=a.map {|f,m| [f, "#{f[0..-3]}#{m}.md"] }
x.each {|f, m| puts "mv #{f} #{m}" }



