m = require "mithril"
Util = require '../util'
VM = require '../viewmodels'
Model = require '../model'

module.exports =
   controller: (props) ->
      @error_message = m.prop ["", "", ""]

      @email = ""
      @pass = ""

      @EntryDetailsAreValid = =>
         is_valid = true

         if not @email.match Util.EmailRegex
            console.log "Email: #{@email} is not a valid email address"
            @error_message()[0] = "Not a valid email address"
            @pass = ""
            is_valid = false

         if not @email.match Util.NonEmptyStringRegex
            console.log "Email: #{@email} is empty"
            @error_message()[0] = "Email cannot be blank"
            @pass = ""
            is_valid = false

         if not @pass.match Util.NonEmptyStringRegex
            console.log "Pass: #{@pass} is empty"
            @error_message()[1] = "Password cannot be blank"
            is_valid = false

         console.log "Entry Details are email:#{@email}, pass:#{@pass}, is valid: #{is_valid}"

         if is_valid then @error_message ["", "", ""]

         return is_valid

      @Create = =>
         if not @EntryDetailsAreValid()
            return

         model_string = JSON.stringify Model()

         m.request(method: "POST", url: "http://localhost:8000/create", data: (key: 'secret', email: @email, pass: @pass, json: model_string))
            .then (msg) =>
               console.log "Create request data recieved"
               console.log msg
               if msg.error?
                  @error_message()[2] = msg.error
               if msg.id? and msg.email?
                  VM.AccountID msg.id
                  VM.Email msg.email

      @Login = (e) =>
         if not @EntryDetailsAreValid()
            return

         console.log "Making the Login request now"
         m.request(method: "POST", url: "http://localhost:8000/login", data: (key: 'secret', email: @email, pass: @pass))
            .then (msg) =>
               console.log "Login request data recieved"
               if msg.error?
                  @error_message()[2] = msg.error
               else if msg.id? and msg.email?
                  VM.AccountID msg.id
                  VM.Email msg.email
                  console.log "Current ID: #{VM.AccountID()}, Email: #{VM.Email()}"
                  @error_message ["", "", ""]
                  VM.SetAlert "#{msg.email} logged in", 3
                  VM.CurrentRoute "/"
                  m.route "/"
      @

   view: (ctrl, props, extras) ->
      {error_message, email, pass} = ctrl
      email_row = []
      password_row = []
      error_row = []

      if !Util.StringsAreEmpty [error_message()[0]]
         email_row.push m '.field.red', error_message()[0]
      if !Util.StringsAreEmpty [error_message()[1]]
         password_row.push m '.field.red', error_message()[1]
      if !Util.StringsAreEmpty [error_message()[2]]
         error_row.push m '.field.red', error_message()[2]

      email_row.push m '.field', m 'input', (placeholder: "Email Address: email@email.net", value: ctrl.email, onchange: ((e) -> ctrl.email = e.target.value))
      password_row.push m '.field', m 'input[type="password"]', (placeholder: "Password: **********", onchange: ((e) -> ctrl.pass = e.target.value))

      m '.row',
         m 'h2', "Login"
         m '.row',
            email_row
            password_row
            m '.field',
               m 'a.green.left', (onclick: ctrl.Create), "Create"
               m 'a.blue.right', (onclick: ctrl.Login), "Login"
            error_row
