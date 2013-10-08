
angular.module( 'ngIscroll', [])
  .directive('ngIscroll', ($timeout)->

    controller: ()->
      handlers = []
      this.onRefresh = (handler)->  handlers.push handler
      this.refresh = ->
        handler() for handler in handlers
        null

    link: (scope, el, attr, ctrl)->

      scroll = scope.$iscroll = new iScroll el[0]
      ctrl.onRefresh ->
        setTimeout (->scroll.refresh()),100
  )
  .directive('ngIscrollPull', ()->

    require: '^ngIscroll'
    link: (scope, el, attr, ctrl)->

      status = null
      {statusID, onLoad} = scope.$eval(attr.ngIscrollPull)
      offset = el[0].offsetHeight

      setStatus = (value, apply)->
        scope[statusID] = value
        scope.$apply() if apply

      scope.$watch statusID, (value)->
        status = value
        if value is 'loading'
          onLoad (ret)->
            setStatus 'idle'
            ctrl.refresh()

      scope.$watch '$iscroll', (scroll)->
        if scroll
          angular.extend scroll.options,

            topOffset: offset

            onScrollMove: ->
              if this.y > 5 and status is 'idle'
                setStatus('flip', yes)
                this.minScrollY = 0
              else if status is 'flip' and this.y < 5
                setStatus('idle', yes)
                this.minScrollY = -offset

            onScrollEnd: ->
              if status is 'flip'
                setStatus('loading', yes)

  )
  .directive('ngIscrollMore', ()->

    require: '^ngIscroll'
    link: (scope, el, attr, ctrl)->

      status = null
      {statusID, onLoad} = scope.$eval(attr.ngIscrollMore)

      setStatus = (value, apply)->
        scope[statusID] = value
        scope.$apply() if apply

      scope.$watch statusID, (value)->
        status = value

      ctrl.onRefresh ->
        if status is 'init'
          setStatus 'idle'

      el.on 'click', ->
        if status is 'idle'
          setStatus 'loading', yes
          onLoad (ret)->
            setStatus 'idle'
            ctrl.refresh()
  )