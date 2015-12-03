class Dashing.Number extends Dashing.Widget
  @accessor 'current', Dashing.AnimatedValue

  @accessor 'difference', ->
    if @get('last')
      last = @get('last')
      current = @get('current')
      current = current.toString().replace /,/g, ''
      if last != 0
        diff = Math.abs(Math.round((current - last) / last * 100))
        "#{diff}%"
    else
      ""

  @accessor 'arrow', ->
    if @get('last')
      current = @get('current')
      current = current.toString().replace /,/g, ''
      if current >= @get('last') then 'icon-arrow-up' else 'icon-arrow-down'

  ready: ->
    @refreshWidgetStatus()

  onData: (data) ->
    @refreshWidgetStatus()

  refreshWidgetStatus: =>
    node = $(@node)
    node.removeClass "down"
    node.addClass(@get('status').toLowerCase())
