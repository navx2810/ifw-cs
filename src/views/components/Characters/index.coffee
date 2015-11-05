m = require "mithril"
Util = require '../util'
Model = require '../model'
Listing = require './listing'

module.exports =
   view: (ctrl, props, extras) ->
      characters = Model().characters

      rows = for k, v of characters
         m.component Listing, (key: k, character: v)

      m '.row',
         m '.with-buttons',
            m 'h2', "Characters"
            m '.buttons',
               m 'a.green', (onclick: -> characters.push Util.CreateNewCharacter {}), "Add"
               m 'a.red', (onclick: -> Model().characters = []), "Clear All"
         rows
