numberFormat = Intl.NumberFormat()

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
