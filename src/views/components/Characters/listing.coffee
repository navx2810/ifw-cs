m = require "mithril"
Model = require '../model'
Attribute = require './attribute'

module.exports =
   controller: (props) ->
      @character = props.character
      @hidden = m.prop true
      @editing = m.prop false

      @inputValue = null

      @Save = (e) =>
         @inputValue = e.target.value
         valueIsEmpty = !!@inputValue.trim()

         if valueIsEmpty
            @character.id = @inputValue
            @inputValue = null

         @editing false

      @

   view: (ctrl, props, extras) ->
      {character} = props

      show_button = null
      id_row = null
      buttons_row = []
      attributes_row = null

      if ctrl.hidden()
         show_button = m 'a.blue', (onclick: -> ctrl.hidden false), "Show"
         attributes_row = m 'div', null
      else
         show_button = m 'a.blue', (onclick: -> ctrl.hidden true), "Hide"
         attributes_row = m.component Attribute, (character: character)

      if ctrl.editing()
         id_row = m 'input', (placeholder: character.id, style: (flex: '1 1 auto'), onchange: ctrl.Save)
      else
         id_row = "#{character.id}"

      if !ctrl.editing()
         buttons_row.push show_button
         buttons_row.push m 'a.green', (onclick: -> ctrl.editing true) , "Edit"
         buttons_row.push m 'a.blue', (onclick: -> m.route "Curves?id=#{props.key}") , "To Curves"
         buttons_row.push m 'a.red', (onclick: -> Model().characters.splice props.key, 1), "Delete"
      else
         buttons_row.push m 'a.green', (onclick: ctrl.Save), "Save"
         buttons_row.push m 'a.red', (onclick: -> ctrl.editing false) , "Cancel"

      m '.row', (key: props.key),
         m '.with-buttons',
            m 'span', (style: (display: "flex")), id_row
            m '.buttons',
               buttons_row
         attributes_row
