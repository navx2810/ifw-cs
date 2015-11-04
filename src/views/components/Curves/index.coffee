m = require "mithril"
Model = require '../model'
_ = require 'lodash'

VM = require '../viewmodels'

{NonEmptyStringRegex} = require '../util'

module.exports =
   # controller: (props) ->
   #    @index = m.route.param "id"
   #    @character = Model().characters[@index]
   #
   #    @
   view: (ctrl, props, extras) ->

      index = m.route.param "id"

      if not index?
         VM.Curves().Selected = null

      character = VM.Curves().Selected

      data_row = if character? then m.component TableView, (index: index, character: character) else CharacterDropDownView

      header_text = if character? then "Editing curves for #{character.id}" else "Curves"

      m '.row',
         m 'h2', header_text
         data_row

Cell =
   FormatCell: (value, attr, curve) =>

      if _.isNaN value
         return
      # if not NonEmptyStringRegex.test value
      #    console.log "'#{value}' is an empty string"
      #    return

      curve[attr] = value

   view: (ctrl, props, extras) ->
      {curve, attr} = props
      m 'td', m 'input', (value: curve[attr], onchange: m.withAttr "value", (val) => Cell.FormatCell val, attr, curve)

NotifierCheckBox =
   view: (ctrl, props, extras) ->
      {curve} = props

      m 'td', m 'input[type=checkbox]', (checked: curve.notifier, onclick: (e) => curve.notifier = !curve.notifier; m.redraw)

TableView =
   controller: (props) ->
      @index = props.index
      @character = props.character
      @curves = @character.curves

      @DeleteAll = =>
         @curves.splice(1, @character.curves.length)
         @ClearFirstColumn()

      @ClearFirstColumn = =>
         curve = @character.curves[0]
         curve.cost = 0
         curve.damage = 0
         curve.notifier = false

      @Delete = (e) =>
         {value} = e.target.attributes.index
         @curves.splice(value, 1)

      @AddLevel = =>
         @curves.push (cost: 0, damage: 0, notifier: false)

      @
   AddLevel: (character) ->
      character.curves.push (cost: 0, damage: 0, notifier: false)
   DeleteAll: (character) ->
      character.curves = [(cost: 0, damage: 0, notifier: false)]
   ClearFirstColumn: (character) ->
      character.curves[0] = (cost: 0, damage: 0, notifier: false)
   Delete: (character, index) ->
      _.pullAt character.curves, index
   view: (ctrl, props, extras) ->
      {character, index} = props

      level_row = [
         m 'th', m 'a.green', (onclick: -> TableView.AddLevel character),
            "Add Level"
            m 'a.blue', (title: "Add a level to your character"), "?"
      ]

      damage_row = [
         m 'th', "Damage"
      ]

      cost_row = [
         m 'th', "Cost"
      ]

      deletion_row = [
         m 'td', m 'a.red', (onclick: -> TableView.DeleteAll character),
            "Delete All"
            m 'a.blue', (title: "Delete every and clear the first level"), "?"
      ]

      delta_damage_row = [
         m 'th', "Delta Damage"
      ]

      delta_cost_row = [
         m 'th', "Delta Cost"
      ]

      notifier_row = [
         m 'th',
            "On LevelUp Notifier"
            m 'a.blue', (title: "An option to define a 'hook' in the code-behind for when a player attains this level.\nYou will be able to drop a function in the inspector which will pass the data as arguments"), "?"
      ]

      for curve, index in character.curves
         level_row.push m 'th', "#{index + 1}"
         damage_row.push m.component Cell, (curve: curve, attr: "damage")
         cost_row.push m.component Cell, (curve: curve, attr: "cost")
         notifier_row.push m.component NotifierCheckBox, (curve: curve)

         if index is 0
            deletion_row.push m 'td', m 'a.red', (onclick: -> TableView.ClearFirstColumn character), "Clear"
            delta_damage_row.push m 'td', (style: (color: "#777")), "N/A"
            delta_cost_row.push m 'td', (style: (color: "#777")), "N/A"
         else
            deletion_row.push m 'td', m 'a.red', (index: index, onclick: (e) => TableView.Delete(character, e.target.attributes.index.value)), "X"
            delta_damage_row.push m 'td', (style: (color: "#777")), "#{curve.damage - character.curves[index-1].damage}"
            delta_cost_row.push m 'td', (style: (color: "#777")), "#{curve.cost - character.curves[index-1].cost}"

      m '.row.table-row',
         m 'table',
            m 'tr', level_row
            m 'tr', damage_row
            m 'tr', cost_row
            m 'tr', notifier_row
            m 'tr', deletion_row
            m 'tr', delta_damage_row
            m 'tr', delta_cost_row

CharacterDropDownView =
   controller: (props) ->
      @selected_character_index = m.prop null

      @RouteToCharacter = (e) =>
         VM.Curves().Selected = Model().characters[e.target.value]
         m.route "Curves?id=#{e.target.value}"

      @

   view: (ctrl, props, extras) ->
      options_row = [m 'option', (disabled: true, selected: true), "select a character"]

      for index, character of Model().characters
         options_row.push m 'option', (value: index), "#{character.id}"

      m '.row',
         m 'select', (onchange: ctrl.RouteToCharacter),
            options_row
