m = require 'mithril'
request = require 'superagent'

{Model, VM, Nav, Characters, Curves, Options, Login} = require './components'

alert_style =
   flex: '1 1 auto'
   background: 'none'
   textAlign: 'center'
   display: 'flex'
   justifyContent: 'center'
   alignItems: 'center'

span_style =
   flex: '0 0 auto'
   textAlign: 'center'
   color: '#777'

header_row = m 'h2', (style: (flex: '0 0 auto')), "Idler :: Framework"


App =
   controller: (props) ->
      m.redraw.strategy "diff"
      @Model = Model
      @Alert = VM.Alert

      @

   view: (ctrl, props) ->
      alert_row = m 'div', (style: alert_style), m 'span', (style: span_style), VM.Alert()

      m 'div.Application',
         m '.header', header_row, alert_row, LoginButtons
         m '.app-content',
            m '.nav-content', Nav
            m '.content',
               m '#route'

LoginButtons =
   controller: (props) ->
      m.redraw.strategy "diff"
      @id = VM.AccountID

      @Save = =>
         m.request method: "PUT", url: "http://localhost:8000/accounts?id=#{VM.AccountID()}", data: (model: JSON.stringify Model())
            .then (msg) =>
               VM.SetAlert "Saved your data", 3

      @Logout = =>
         VM.AccountID ""
         VM.Email ""

      @Resync = =>
         # m.request method: "GET", url: "http://localhost:8000/accounts?id=#{VM.AccountID()}"
         #    .then (msg) =>
         #       if msg.error?
         #          console.log "Error happened during GET request to Resync"
         #          VM.SetAlert "There was an error with your request to sync", 3
         #       else
         #          Model JSON.parse msg.data
         #          m.route '/'

         req = request.get "http://localhost:8000/accounts"
         req.query id: VM.AccountID()
         req.end((e) => console.log e.text)

      @

   view: (ctrl, props) ->
      if !ctrl.id()
         m '.button-row',
            m 'a', (title: "Login to your account", onclick: -> m.route "Login"), "Login"
      else
         m '.button-row',
            m 'a', (title: "Logout of your account", onclick: ctrl.Logout), "Logout"
            m 'a', (title: "Save your data to the server", onclick: ctrl.Save), "Save"
            m 'a', (title: "Resync your data from the server", onclick: ctrl.Resync), "Resync"

WelcomeScreen =
   controller: (props) ->
      @RedirectToLogin = ->
         m.route "Login"
         VM.CurrentRoute "Login"

      @
   view: (ctrl, props) ->
      welcome_message = [null]

      if not !!VM.AccountID()
         welcome_message.push m 'span', "Welcome. Please choose a path in the navigation panel to the left of the screen to begin using this application, if you are a returning user, please"
         welcome_message.push m 'a.blue', (onclick: ctrl.RedirectToLogin) , "login"
         welcome_message.push m 'span', "to fetch your latest saved data"

      else
         welcome_message.push m 'span', "Welcome. You are currently logged into "
         welcome_message.push m 'em', "#{VM.Email()}"
         welcome_message.push m 'span', ". Please choose a path in the navigation panel to the left of the screen to begin using this application"

      m '.row',
         m 'h2',
            welcome_message

m.mount document.body, App

m.route.mode = "hash"

m.route document.querySelector("#route"), '/',
   "/": WelcomeScreen
   "Characters": Characters
   "Curves": Curves
   "Options": Options
   "Login": Login
