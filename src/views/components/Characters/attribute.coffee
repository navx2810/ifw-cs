m = require "mithril"
Util = require '../util'

module.exports =
   controller: (props) ->
      @character = props.character

      @editing = m.prop false
      @shown = m.prop false

      @

   view: (ctrl, props, extras) ->
      {character, editing, shown} = ctrl

      show_hide_link = null
      shown_row = null
      rows = []

      if shown()
         show_hide_link = m 'a.blue', (onclick: -> shown false), "Hide"
         for k, v of character.attributes
            rows.push m.component AttributeListing, (key: k, attribute: v, character: character)
         shown_row = m '.row', rows
      else
         show_hide_link = m 'a.blue', (onclick: -> shown true), "Show"
         shown_row = m 'div', null
      m '.row',
         m '.with-buttons',
            m 'span', "Attributes"
            m 'buttons',
               show_hide_link
               m 'a.green', (onclick: -> character.attributes.push Util.CreateNewAttribute {}), "Add"
               m 'a.red', (onclick: -> character.attributes = []), "Clear All"
         shown_row


AttributeListing =
   controller: (props) ->
      @character = props.character
      @key = props.key
      @attribute = props.attribute
      # @editing = m.prop( !(!!props.attribute.key and props.attribute.key? or !!props.attribute.value and props.attribute.value? or !!props.attribute.type and props.attribute.type) )

      if Util.StringsAreEmpty [@attribute.key, @attribute.value, @attribute.type]
         console.log "Attribute: #{JSON.stringify @attribute} is considered empty!"
      @editing = m.prop Util.StringsAreEmpty [@attribute.key, @attribute.value, @attribute.type]

      @key_input = ""
      @type_input = ""
      @value_input = ""

      @Save = =>
         key = @key_input.trim()
         type = @type_input.trim()
         value = @value_input.trim()

         if !Util.StringsAreEmpty [key, type, value]
            @attribute = {key: key, type: type, value: value}

            @character.attributes[@key] = @attribute

            @key_input = ""
            @type_input = ""
            @value_input = ""

            @editing false

      @Cancel = =>
         {key, type, value} = @attribute

         if not !!key.trim() or not !!type.trim() or not !!value.trim()
            @character.attributes.splice(key, 1)
         @editing false

      @
   view: (ctrl, props, extras) ->
      {key, attribute, editing, character} = ctrl

      if not editing()
         m '.attribute', (key: key),
               m 'span.listing',
                  m 'span.type', "#{attribute.type} "
                  m 'span.name', "#{attribute.key} "
                  m 'span.value', "#{attribute.value}"
               m '.buttons',
                  m 'a.green', (onclick: -> editing true), "Edit"
                  m 'a.red', (onclick: -> character.attributes.splice(key, 1)), "Delete"
      else
         m '.attribute', (key: key),
            m '.editing',
               m 'input', (placeholder: (if not !!attribute.type then "Type" else attribute.type), onchange: (e) -> ctrl.type_input = e.target.value)
               m 'input', (placeholder:  (if not !!attribute.key then "Key" else attribute.key), onchange: (e) -> ctrl.key_input = e.target.value)
               m 'input', (placeholder:  (if not !!attribute.value then "Value" else attribute.value), onchange: (e) -> ctrl.value_input = e.target.value)
            m '.buttons',
                  m 'a.green', (onclick: ctrl.Save), "Save"
                  m 'a.red', (onclick: ctrl.Cancel), "Cancel"
