m = require "mithril"
_ = require 'lodash'

Attribute = require './attribute'

VM = require '../viewmodels'
Model = require '../model'
Util = require '../util'
{Characters} = VM

module.exports =
   view: (ctrl, props, extras) ->
      {character, key} = props

      rows = []

      if _.contains Characters().EditingIDs, character.id
         rows.push m.component Editing, (character: character)
      else
         rows.push m.component Default, (character: character, index: key)

      if _.contains Characters().ShowingIDs, character.id
         rows.push m.component Showing, (character: character)

      m '.row', rows

Editing =
   saveName: (character, name) ->
      name = _.trimLeft name

      if not _.isEmpty(name) and not _.isNull(name)
         _.pull Characters().ShowingIDs, character.id
         character.id = name
         Characters().ShowingIDs.push character.id

      _.pull Characters().EditingIDs, character.id

   view: (ctrl, props, extras) ->
      {character} = props

      m '.with-buttons',
         m 'input', (placeholder: "ID = #{character.id} | Press ENTER or lose focus to save", style: (flex: '1 1 auto'), onchange: m.withAttr "value", (val) -> Editing.saveName character, val)
         m 'button-row',
            m 'a.red', (onclick: -> _.pull Characters().EditingIDs, character.id), "cancel"

Default =
   toggleShown: (character, is_shown) ->
      if is_shown
         _.pull Characters().ShowingIDs, character.id
      else Characters().ShowingIDs.push character.id

   gotoCurves: (character, index) ->
      VM.Curves().Selected = character
      m.route "Curves?id=#{index}"

   remove: (character, index) ->
      Model().characters.splice(index, 1)

   view: (ctrl, props, extras) ->
      {character, index} = props

      showing_row = []

      is_shown = _.contains Characters().ShowingIDs, character.id

      m '.with-buttons',
         m 'span', "#{character.id}"
         m 'button-row',
            m 'a.blue', (onclick: -> Default.toggleShown character, is_shown), if is_shown then "hide" else "show"
            m 'a.blue', (onclick: -> Default.gotoCurves character, index), 'curves..'
            m 'a.green', (onclick: -> Characters().EditingIDs.push character.id), "edit"
            m 'a.red', (onclick: -> Default.remove character, index), "remove"

Showing =
   add: (character) ->
      character.attributes.push Util.CreateNewAttribute {}
   clear: (character) ->
      character.attributes = []
      Characters().EditingAttributes = []
   view: (ctrl, props, extras) ->
      {character} = props

      attribute_rows = []

      for attribute, index in character.attributes
         attribute_rows.push m.component Attribute, (character: character, attribute: attribute, index: index)

      m '.row',
         m '.with-buttons',
            m 'span', "Attributes"
            m '.buttons',
               m 'a.green', (onclick: -> Showing.add character), 'add'
               m 'a.red', (onclick: -> Showing.clear character),'clear all'
         m '.row', attribute_rows
