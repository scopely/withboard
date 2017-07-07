Template.__checkName 'Graph'
Template.Graph = new Template 'Template.Graph', ->
  HTML.Raw '<div class="graph"></div>'

Template.Graph.onRendered ->
  @dom = @$ '.graph'
  @d3 = d3.select @dom[0]

  # margins are NOT included in width/height
  margin = 5 # must match CSS TODO
  width  = @dom.width() - 2*margin
  height = @dom.height() - 2*margin

  x = d3.time.scale(  ).range [0, width]
  y = d3.scale.linear().range [height, 0]

  valueline = d3.svg.line()
    .x (d) -> x(d.x)
    .y (d) -> y(d.y)

  area = d3.svg.area()
    .x (d) -> x(d.x)
    .y0 height
    .y1 (d) -> y(d.y)

  # margin is built into the svg so there's no further logic
  svg = @d3
    .append 'svg'
      .attr 'width', width + (2 * margin)
      .attr 'height', height + (2 * margin)
    .append 'g'
      .attr 'transform', "translate(#{margin}, #{margin})"

  svg.append 'path'
    .attr 'class', 'area'
  svg.append 'path'
    .attr 'class', 'line'

  @autorun =>
    {data, name} = Template.currentData()
    min = if name is 'Apdex' then 0.8 else 0
    min = Math.min(min, d3.min(data, (d) -> d.y))

    x.domain  d3.extent(data,   (d) -> d.x )
    y.domain [min, d3.max(data, (d) -> d.y )]

    svg = @d3.transition()
    svg.select '.line'
      .duration 1500
      .attr 'd', valueline data
    svg.select '.area'
      .duration 1500
      .attr 'd', area data
