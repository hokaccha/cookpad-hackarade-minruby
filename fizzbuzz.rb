def fizzbuzz(n)
  (1..n).map do |i|
    if i % 15 == 0
      "FizzBuzz"
    elsif i % 3 == 0
      "Fizz"
    elsif i % 5 == 0
      "Buzz"
    else
      i
    end
  end.join
end
