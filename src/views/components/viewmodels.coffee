m = require "mithril"

module.exports = VM =
   ProjectDirectory: m.prop "C:/Hello/"

   InEngineDataTypes: m.prop [
      "bool"
      "string"
      "float"
      "int"
      "List"
      "GameObject"
      "Function"
      "Action"
      "Delegate"
      "Vector3"
      "Dictionary"
      "Vector2"
      "Transform"
      "Rigidbody"
      "Camera"
      "BoxCollider",
      "Paragraph"
   ]

   UserDefinedDataTypes: m.prop ["MyGO"]

   UserDataTypesEditing: m.prop []

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

   Curves: m.prop
      Selected: null
      DamagePercent: false
      CostPercent: false

   Characters: m.prop
      EditingIDs: []
      EditingAttributes: []
      ShowingIDs: []
