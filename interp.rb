require "minruby"

# An implementation of the evaluator
def evaluate(exp, env, fn)
  # exp: A current node of AST
  # env: An environment (explained later)

  case exp[0]

#
## Problem 1: Arithmetics
#

  when "lit"
    exp[1] # return the immediate value as is
  when "+"
    evaluate(exp[1], env, fn) + evaluate(exp[2], env, fn)
  when "-"
    # Subtraction.  Please fill in.
    # Use the code above for addition as a reference.
    # (Almost just copy-and-paste.  This is an exercise.)
    evaluate(exp[1], env, fn) - evaluate(exp[2], env, fn)
  when "*"
    evaluate(exp[1], env, fn) * evaluate(exp[2], env, fn)
  when "/"
    evaluate(exp[1], env, fn) / evaluate(exp[2], env, fn)
  when "%"
    evaluate(exp[1], env, fn) % evaluate(exp[2], env, fn)
  when ">"
    evaluate(exp[1], env, fn) > evaluate(exp[2], env, fn)
  when "<"
    evaluate(exp[1], env, fn) < evaluate(exp[2], env, fn)
  when "<="
    evaluate(exp[1], env, fn) <= evaluate(exp[2], env, fn)
  when ">="
    evaluate(exp[1], env, fn) >= evaluate(exp[2], env, fn)
  when "=="
    evaluate(exp[1], env, fn) == evaluate(exp[2], env, fn)


#
## Problem 2: Statements and variables
#

  when "stmts"
    # Statements: sequential evaluation of one or more expressions.
    #
    # Advice 1: Insert `pp(exp)` and observe the AST first.
    # Advice 2: Apply `evaluate` to each child of this node.
    i = 1
    while exp[i]
      r = evaluate(exp[i], env, fn)
      i = i + 1
    end
    r

  # The second argument of this method, `env`, is an "environement" that
  # keeps track of the values stored to variables.
  # It is a Hash object whose key is a variable name and whose value is a
  # value stored to the corresponded variable.

  when "var_ref"
    # Variable reference: lookup the value corresponded to the variable
    #
    # Advice: env[???]
    env[exp[1]]

  when "var_assign"
    # Variable assignment: store (or overwrite) the value to the environment
    #
    # Advice: env[???] = ???
    env[exp[1]] = evaluate(exp[2], env, fn)


#
## Problem 3: Branchs and loops
#

  when "if"
    # Branch.  It evaluates either exp[2] or exp[3] depending upon the
    # evaluation result of exp[1],
    #
    # Advice:
    #   if ???
    #     ???
    #   else
    #     ???
    #   end
    if evaluate(exp[1], env, fn)
      evaluate(exp[2], env, fn)
    else
      evaluate(exp[3], env, fn)
    end

  when "while"
    # Loop.
    while evaluate(exp[1], env, fn)
      evaluate(exp[2], env, fn)
    end


#
## Problem 4: Function calls
#

  when "func_call"
    # Lookup the function definition by the given function name.
    func = fn[exp[1]]

    if func == nil
      # We couldn't find a user-defined function definition;
      # it should be a builtin function.
      # Dispatch upon the given function name, and do paticular tasks.
      case exp[1]
      when "p"
        # MinRuby's `p` method is implemented by Ruby's `p` method.
        p(evaluate(exp[2], env, fn))
      when "pp"
        pp(evaluate(exp[2], env, fn))
      # ... Problem 4
      when "Integer"
        Integer(evaluate(exp[2], env, fn))
      when "String"
        String(evaluate(exp[2], env, fn))
      when "require"
        # do nothing
      when "minruby_parse"
        minruby_parse(evaluate(exp[2], env, fn))
      when "minruby_load"
        minruby_load()
      when "raise"
        raise(evaluate(exp[2], env, fn))
      when "fizzbuzz"
        i = 2
        r = "1"
        while i <= evaluate(exp[2], env, fn)
          if i % 15 == 0
            r = r + "FizzBuzz"
          elsif i % 3 == 0
            r = r + "Fizz"
          elsif i % 5 == 0
            r = r + "Buzz"
          else
            r = r + String(i)
          end
          i = i + 1
        end
        r
      else
        raise("unknown builtin function " + exp[1])
      end
    else


#
## Problem 5: Function definition
#

      # (You may want to implement "func_def" first.)
      #
      # Here, we could find a user-defined function definition.
      # The variable `func` should be a value that was stored at "func_def":
      # parameter list and AST of function body.
      #
      # Function calls evaluates the AST of function body within a new scope.
      # You know, you cannot access a varible out of function.
      # Therefore, you need to create a new environment, and evaluate the
      # function body under the environment.
      #
      # Note, you can access formal parameters (*1) in function body.
      # So, the new environment must be initialized with each parameter.
      #
      # (*1) formal parameter: a variable as found in the function definition.
      # For example, `a`, `b`, and `c` are the formal parameters of
      # `def foo(a, b, c)`.
      _env = {}
      i = 0
      args = fn[exp[1]][0]
      body = fn[exp[1]][1]
      while args[i]
        _env[args[i]] = evaluate(exp[i+2], env, fn)
        i = i + 1
      end

      evaluate(body, _env, fn)
    end

  when "func_def"
    # Function definition.
    #
    # Add a new function definition to function definition list.
    # The AST of "func_def" contains function name, parameter list, and the
    # child AST of function body.
    # All you need is store them into $function_definitions.
    #
    # Advice: $function_definitions[???] = ???
    fn[exp[1]] = [exp[2], exp[3]]


#
## Problem 6: Arrays and Hashes
#

  # You don't need advices anymore, do you?
  when "ary_new"
    i = 0
    arr = []
    while exp[i+1]
      arr[i] = evaluate(exp[i+1], env, fn)
      i = i + 1
    end
    arr

  when "ary_ref"
    arr = evaluate(exp[1], env, fn)
    arr[evaluate(exp[2], env, fn)]

  when "ary_assign"
    arr = evaluate(exp[1], env, fn)
    arr[evaluate(exp[2], env, fn)] = evaluate(exp[3], env, fn)

  when "hash_new"
    i = 0
    hash = {}
    while exp[i+1]
      hash[evaluate(exp[i+1], env, fn)] = evaluate(exp[i+2], env, fn)
      i = i + 2
    end
    hash

  else
    p("error")
    pp exp
    raise("unknown node: #{exp[0]}")
  end
end


fn = {}
env = {}

# `minruby_load()` == `File.read(ARGV.shift)`
# `minruby_parse(str)` parses a program text given, and returns its AST
exp = minruby_parse(minruby_load())
evaluate(exp, env, fn)
