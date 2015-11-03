m = require "mithril"

module.exports =
   controller: (props) ->
      m.redraw.strategy "diff"

      @
   view: (ctrl, props, extras) ->
      m '.row',
         m 'h2', "Project Options"
