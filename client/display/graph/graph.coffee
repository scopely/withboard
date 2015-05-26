Template.Graph.rendered = ->
  @node = @find '.graph'

  width  = 280
  height = 120
  margin = 5

  x = d3.time.scale(  ).range [0, width]
  y = d3.scale.linear().range [height, 0]

  valueline = d3.svg.line()
    .x (d) -> x(d.x)
    .y (d) -> y(d.y)

  area = d3.svg.area()
    .x (d) -> x(d.x)
    .y0 height
    .y1 (d) -> y(d.y)

  svg = d3.select @node
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
    data = Template.currentData().data
    metric = Template.currentData().name
    min = if metric is 'Apdex' then 0.8 else 0

    x.domain  d3.extent(data,   (d) -> d.x )
    y.domain [min, d3.max(data, (d) -> d.y )]

    svg = d3.select(@node).transition()
    svg.select '.line'
      .duration 1500
      .attr 'd', valueline data
    svg.select '.area'
      .duration 1500
      .attr 'd', area data
