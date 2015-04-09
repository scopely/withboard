numberFormat = Intl.NumberFormat()

Template.DisplayNewrelic.helpers
  latest: (data) ->
    data[data.length - 1].pretty

Template.DisplayMetrics.helpers
  getMetric: (name) ->
    state = State.findOne key: 'metrics'
    if state
      state.value.filter((s) -> s.id == name )[0]

  latest: (metricId, divisor, suffix) ->
    suffix = '' if not suffix

    state = State.findOne key: 'metrics'
    return '???' if not state

    metric = state.value.filter((s) -> s.id == metricId )[0]
    return 'n/a' if not metric

    value = metric.points[metric.points.length - 1].y / (divisor or 1)
    value = Math.round(value * 10) / 10

    numberFormat.format(value) + suffix

Template.Graph.rendered = ->
  @node = @find '.graph'
  self = @

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

  svg = d3.select self.node
    .append 'svg'
      .attr 'width', width + (2 * margin)
      .attr 'height', height + (2 * margin)
    .append 'g'
      .attr 'transform', "translate(#{margin}, #{margin})"

  svg.append 'path'
    .attr 'class', 'area'
  svg.append 'path'
    .attr 'class', 'line'

  @autorun (computation) ->
    data = Template.currentData().data
    metric = Template.currentData().name
    min = if metric is 'Apdex' then 0.8 else 0

    x.domain  d3.extent(data,   (d) -> d.x )
    y.domain [min, d3.max(data, (d) -> d.y )]

    svg = d3.select(self.node).transition()
    svg.select '.line'
      .duration 1500
      .attr 'd', valueline data
    svg.select '.area'
      .duration 1500
      .attr 'd', area data
