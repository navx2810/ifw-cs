m = require "mithril"

Model = require '../model'

RowStyle =
   display: 'flex'
   justifyContent: 'space-around'
   alignItems: 'center'
InputStyle =
   flex: '1 1 auto'
   textAlign: 'center'

module.exports = Currency =
   controller: (props) ->
      @prefix_editing = m.prop true
      @suffix_editing = m.prop false

      @
   view: (ctrl, props, extras) ->
      console.log Model().currency
      {prefix_editing, suffix_editing} = ctrl
      prefix_row = []
      suffix_row = []

      if prefix_editing()
         prefix_row = m.component Editing, (value: Model().currency, attr: 'prefix', editing: prefix_editing)
      else
         prefix_row = m.component Showing, (value: Model().currency, attr: 'prefix', editing: prefix_editing)


      m '.row',
         m 'h2', "Currency"
         m '.row',
            m '.row', (style: RowStyle),
               prefix_row
            m '.row', (style: RowStyle),
               m 'input', (value: "", placeholder: "Suffix | ex: dollars", style: InputStyle)


Editing =
   view: (ctrl, props, extras) ->
      {value, attr, editing} = props

      m 'div', (style: RowStyle),
         m 'div', (style: InputStyle), "Prefix:"
         m 'input', (value: value[attr], style: InputStyle, placeholder: "Prefix | ex: $", onchange: m.withAttr "value", (v) -> value[attr] = v; editing false)

Showing =
   view: (ctrl, props, extras) ->
      {value, attr, editing} = props

      m '.with-buttons',
         m 'span', "Prefix: #{value[attr]}"
