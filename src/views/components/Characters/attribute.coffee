m = require "mithril"
_ = require 'lodash'

{Characters, UserDefinedDataTypes, InEngineDataTypes} = require '../viewmodels'

module.exports =
   view: (ctrl, props, extras) ->
      {attribute, index, character} = props

      if _.contains(Characters().EditingAttributes, attribute) or _.isEmpty(attribute.key) or _.isEmpty(attribute.type)
         m.component Editing, (attribute: attribute, index: index, character: character)
      else
         m.component Default, (attribute: attribute, index: index, character: character)


Default =
   remove: (character, attribute) ->
      _.pull character.attributes, attribute

   edit: (character, attribute) ->
      if not _.contains(Characters().EditingAttributes, attribute)
         Characters().EditingAttributes.push attribute
   view: (ctrl, props, extras) ->
      {attribute, index, character} = props

      type_row = m 'span.type', "#{attribute.type} "
      name_row = m 'span.name', "#{attribute.key}"
      value_row = m 'span', null

      if attribute.default_value?
         value_row = m 'span.value', " = #{attribute.default_value}"

      span = [type_row, name_row, value_row]

      m '.attribute', (key: character.id),
         m 'span.listing', span
         m '.buttons',
            m 'a.green', (onclick: -> Default.edit character, attribute), "edit"
            m 'a.red', (onclick: -> Default.remove character, attribute), "remove"

Editing =
   controller: (props) ->

      @key = null
      @type = null
      @default_value = null

      @save = (character, attribute, index) =>
         @key = _.trimLeft @key
         @type = _.trimLeft @type
         @default_value = if @default_value? then _.trimLeft(@default_value) else attribute.default_value

         # If all input values are empty or null, go to cancel this editing
         attribute.key = if _.isEmpty(@key) then attribute.key else @key
         attribute.type = if _.isEmpty(@type) then attribute.type else @type
         attribute.default_value = if _.isEmpty(@default_value) or _.isNull(@default_value) then null else @default_value

         # If input key is not blank and different than its old value
         # If type key is not blank and different than its old value
         # If default_value key is not blank and different than its old value

         # if not _.isEmpty(@key) and not _.isNull(@key) or not _.isEmpty(@type) and not _.isNull(@type)
         #    attribute.key = @key
         #    attribute.type = @type
         #    attribute.default_value = if @default_value? then @default_value else null

         @cancel character, attribute, index

      @cancel = (character, attribute, index) =>

         if _.isEmpty(attribute.key) and _.isEmpty(attribute.type)
            _.pullAt character.attributes, index
         _.pull Characters().EditingAttributes, attribute

         # console.log Characters().EditingAttributes

      @
   view: (ctrl, props, extras) ->
      {attribute, index, character} = props

      options_row = [m 'option', (disabled: true, selected: true), "Type"]

      for type in InEngineDataTypes()
         options_row.push m 'option.blue', (value: type), type

      for type in UserDefinedDataTypes()
         options_row.push m 'option.value-green', (value: type), type

      m '.attribute', (key: character.id),
         m '.editing',
            # m 'input', (value: ctrl.type or attribute.type, placeholder: "Type", onchange: m.withAttr "value", (v) -> ctrl.type = v)
            m 'select', (style: (flex: '1 1 auto'), value: ctrl.type or attribute.type, onchange: m.withAttr "value", (v) -> ctrl.type = v),
               options_row
            m 'input', (value: ctrl.key or attribute.key, placeholder: "Name", onchange: m.withAttr "value", (v) -> ctrl.key = v)
            m 'input', (value: ctrl.default_value or attribute.default_value or "", placeholder: "Default Value | optional", onchange: m.withAttr "value", (v) -> ctrl.default_value = v)
         m '.buttons'
            m 'a.green', (onclick: -> ctrl.save character, attribute, index), "save"
            m 'a.red', (onclick: -> ctrl.cancel character, attribute, index), "cancel"
