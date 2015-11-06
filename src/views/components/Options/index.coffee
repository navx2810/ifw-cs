m = require "mithril"

VM = require '../viewmodels'
Model = require '../model'

_ = require 'lodash'

module.exports =
   controller: (props) ->
      m.redraw.strategy "diff"

      @
   view: (ctrl, props, extras) ->
      m '.row',
         m 'h2', "Project Options"
         m.component Export
         m.component DataTypes

Export =
   ShowDialogue: ->
      ipc.send 'show:dialog'

      ipc.on 'dialog:reply', (directory) ->
         VM.ProjectDirectory directory
         m.redraw true

   ExportData: ->
      ipc.send 'export', (directory: VM.ProjectDirectory(), model: Model())

      ipc.on 'export:err', (message) ->
         VM.SetAlert message, 5
         m.redraw true

   view: (ctrl, props, extras) ->
      m '.row',
         m 'h2', "Export"
         m '.row',
            m '.with-buttons',
               m 'span', "Project Directory",
                  m 'em', (style: padding: '0px 0px 0px 1em'), "#{VM.ProjectDirectory()}"
               m '.buttons',
                  m 'a.blue', (onclick: Export.ShowDialogue), "change"
                  m 'a', (onclick: Export.ExportData), "export"
DataTypes =
   AddUserType: ->
      VM.UserDefinedDataTypes().push ""

   RemoveAll: ->
      VM.UserDefinedDataTypes []
      VM.UserDataTypesEditing []

   view: (ctrl, props, extras) ->

      in_engine_types_rows = for type in VM.InEngineDataTypes()
         m '.attribute',
            m 'span.listing', m 'span.type', type

      user_types_rows = for type, index in VM.UserDefinedDataTypes()
         m.component UserDataType, (type: type, index: index, editing: if type in VM.UserDataTypesEditing() then true else false)

      m '.row',
         m 'h2', "Data Types"
         m '.row',
            m '.row',
               m '.with-buttons',
                  m 'span', "Built-In Types"
               m '.row',
                  in_engine_types_rows
            m '.row',
               m '.with-buttons',
                  m 'span', "User-Defined Types"
                  m '.buttons',
                     m 'a.green', (onclick: DataTypes.AddUserType), "Add"
                     m 'a.red', (onclick: DataTypes.RemoveAll), "Clear All"
               m '.row',
                  user_types_rows

UserDataType =
   CancelEditing: (old_type, new_type, index) ->

      # If original value was empty (as in just added) and is still empty
         # remove it from the defined old_types

      if old_type is new_type and _.isEmpty(old_type)
         console.log "Pulling '#{old_type}' from DataTypes"
         _.pullAt VM.UserDefinedDataTypes(), index
      else
         _.pull VM.UserDataTypesEditing(), old_type


   Save: (old_type, new_type, index) ->

      console.log "Old Type: #{old_type}, New Type: #{new_type}, Index: #{index}"

      new_type = _.trimLeft(new_type)

      if new_type not in VM.UserDefinedDataTypes()
         VM.UserDefinedDataTypes()[index] = if _.isEmpty(new_type) then old_type else new_type
      else if new_type isnt old_type
         _.pullAt VM.UserDefinedDataTypes(), index


      @CancelEditing old_type, new_type, index

   Edit: (type) ->
      VM.UserDataTypesEditing().push type

   Remove: (type, index) ->
      _.pullAt VM.UserDefinedDataTypes(), index
      @CancelEditing type

   controller: (props) ->
      @input = ""

      @

   view: (ctrl, props, extras) ->
      {type, index, editing} = props

      if editing or _.isEmpty(type)
         m '.attribute', (key: type),
            m '.editing',
               m 'input', (value: ctrl.input or type or null, placeholder: "namespace.DataType", onchange: m.withAttr "value", (v) -> ctrl.input = v)
            m '.buttons',
               m 'a.green', (onclick: -> UserDataType.Save type, ctrl.input, index), "save"
               m 'a.red', (onclick: -> UserDataType.CancelEditing type, ctrl.input, index), "cancel"
      else
         m '.attribute', (key: type),
            m 'span.listing', m 'span.value', type
            m '.buttons',
               m 'a.green', (onclick: -> UserDataType.Edit type), "edit"
               m 'a.red', (onclick: -> UserDataType.Remove type, index), "remove"
