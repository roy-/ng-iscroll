
angular.module( 'ngIscroll', [])
  .directive('ngIscroll', ()->

    controller: ()->
      handlers = []
      this.onRefresh = (handler)->  handlers.push handler
      this.refresh = ->
        handler() for handler in handlers
        null

    link: (scope, el, attr, ctrl)->

      IScroll = iScroll
      scroll = null
      status = null
      offset = 0
      setStatus = (value)-> status = value

      scroll = new IScroll el[0],
        onScrollMove: ->
          if this.y > 5 and status isnt 'flip'
            setStatus('flip')
            this.minScrollY = 0
          else if status is 'flip' and this.y < 5
            setStatus('idle')
            this.minScrollY = -offset

        onScrollEnd: ->
          if status is 'flip'
            setStatus('loading')

      ctrl.onRefresh -> scroll.refresh()

      if ctrl.pullOptions
        {statusID, onLoad, offset} = ctrl.pullOptions
        angular.isFunction(onLoad) or onLoad = angular.noop

        setStatus = (value)->
          scope[statusID] = value
          scope.$apply()

        scope.$watch statusID, (value)->
          status = value
          if value is 'loading'
            onLoad (ret)->
              setStatus 'idle'
              if ret > 0 then ctrl.refresh()
          else if value is 'idle'
            if scroll.options.topOffset?
              scroll.options.topOffset = offset


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