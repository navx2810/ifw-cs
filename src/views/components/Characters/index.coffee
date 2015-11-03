m = require "mithril"
Util = require '../util'
Model = require '../model'
Listing = require './listing'

module.exports =
   controller: (props) ->
      m.redraw.strategy "diff"

      @
   view: (ctrl, props, extras) ->
      rows = for k, v of Model().characters
         m.component Listing, (key: k, character: v)

      m '.row',
         m '.with-buttons',
            m 'h2', "Characters"
            m '.buttons',
               m 'a.green', (onclick: -> Model().characters.push Util.CreateNewCharacter {}), "Add"
               m 'a.red', (onclick: -> Model().characters = []), "Clear All"
         rows
