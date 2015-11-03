m = require "mithril"
VM = require './viewmodels'

NavItem =
   controller: (props) ->
      m.redraw.strategy "diff"

      @ChangeRoute = (new_route) ->
         VM.CurrentRoute new_route
         m.route new_route

      @        # Return for component

   view: (ctrl, props) ->
      className = if VM.CurrentRoute() is props.route then "selected" else ""
      m 'a', (title: props.desc ,className: className, onclick: -> ctrl.ChangeRoute props.route),
         m 'span', "#{props.route}"

module.exports = Nav =
   controller: (props) ->
      m.redraw.strategy "diff"

      @        # Return for component

   view: (ctrl, props) ->
      m '.nav',
         m.component NavItem, (route: 'Characters', desc: 'The listing for your characters')
         m.component NavItem, (route: 'Curves', desc: 'The curves sheet for your damage and cost ratios')
         m.component NavItem, (route: 'Options', desc: 'Options panel for project settings')
