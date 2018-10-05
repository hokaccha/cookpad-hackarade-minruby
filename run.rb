Dir.glob('test*.rb').sort.each do |f|
  correct = `ruby #{f}`
  answer = `ruby interp.rb #{f}`

  if correct == answer
    puts "#{f} OK"
  else
    warn answer
    exit
  end
end
