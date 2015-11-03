m = require "mithril"

module.exports = VM =
   CurrentRoute: m.prop ""
   AccountID: m.prop ""
   Email: m.prop ""
   Alert: m.prop ""
   SetAlert: (alert, seconds = 2) =>
      seconds = seconds * 1000
      VM.Alert alert

      setTimeout ( () =>
         m.startComputation()
         VM.Alert ""
         m.endComputation() ), seconds
