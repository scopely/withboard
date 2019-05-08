compile = (source) ->
  try
    output = CoffeeScript.compile source
    output.split '\n'
  catch err
    throw new Meteor.Error 400, 'Unable to compile script.\n' + err

Meteor.methods
  compileCoffee: (coffee, type='block') ->
    switch type
      when 'block'
        output = compile(coffee)
        output[output.length - 2] = '})'
        output.join '\n'

      when 'function'
        lines = coffee.split('\n')
          .map (line) -> '  ' + line
        lines.unshift 'return ->'

        output = compile lines.join('\n')
        output[output.length - 2] = '}).call();'
        output.join '\n'
