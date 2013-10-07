
angular.module( 'ngIscroll', [])
  .directive('ngIscroll', ()->

    controller: ()->
      handlers = []
      this.onRefresh = (handler)->  handlers.push handler
      this.refresh = ->
        handler() for handler in handlers
        null

    link: (scope, el, attr, ctrl)->

      offset = 0
      setStatus = angular.noop

      scroll = new iScroll el[0],
        onScrollMove: ->
          if this.y > 5 and status isnt 'flip'
            setStatus('flip', yes)
            this.minScrollY = 0
          else if status is 'flip' and this.y < 5
            setStatus('idle', yes)
            this.minScrollY = -offset

        onScrollEnd: ->
          if status is 'flip'
            setStatus('loading', yes)

      #window
      window.scroll = scroll

      ctrl.onRefresh ->
        if scroll.options.topOffset?
          scroll.options.topOffset = offset
        setTimeout (->scroll.refresh()),10

      if ctrl.pullOptions

        status = null
        {statusID, onLoad, offset} = ctrl.pullOptions
        angular.isFunction(onLoad) or onLoad = angular.noop

        setStatus = (value, apply)->
          scope[statusID] = value
          scope.$apply() if apply

        scope.$watch statusID, (value)->
          status = value
          if value is 'loading'
            onLoad (ret)->
              setStatus 'idle'
              if ret > 0 then ctrl.refresh()

  )
  .directive('ngIscrollPull', ()->
    require: '^ngIscroll'
    link: (scope, el, attr, ctrl)->
      ctrl.pullOptions = scope.$eval(attr.ngIscrollPull, scope)
      ctrl.pullOptions.offset = el[0].offsetHeight
  )
  .directive('ngIscrollMore', ()->

    require: '^ngIscroll'
    link: (scope, el, attr, ctrl)->

      status = null
      {statusID, onLoad} = scope.$eval(attr.ngIscrollMore, scope)

      setStatus = (value)->
        scope[statusID] = value
        scope.$apply()

      scope.$watch statusID, (value)->
        status = value

      ctrl.onRefresh ->
        if status is 'init'
          setStatus 'idle'

      el.on 'click', ->
        if status is 'idle'
          setStatus 'loading'
          onLoad (ret)->
            setStatus 'idle'
            if ret > 0 then ctrl.refresh()
  )