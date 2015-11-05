m = require "mithril"
uuid = require 'node-uuid'

module.exports = Util =
   SecretKey: "77989e26-fdc2-42fa-b09b-fd07020e38e1"
   NonEmptyStringRegex: /^\S+.+/i
   EmailRegex: /^[a-z0-9\-]+@[a-z0-9\-]+(\.[a-z0-9\-]+)+/i

   CreateNewCharacter: (data) ->
      {id, attributes, curves} = data
      new_data = {}

      if id? then new_data.id = id else new_data.id = GenerateUniqueID()
      if attributes? then new_data.attributes = attributes else new_data.attributes = []
      if curves? then new_data.curves = curves else new_data.curves = [(cost: 0, damage: 0, notifier: false)]

      return new_data

   CreateNewAttribute: (data) ->
      {key, default_value, type} = data

      if key? then key = key else key = ""
      if type? then type = type else type = ""
      if default_value? then default_value = default_value else null

      return (key: key, type: type, default_value: default_value)

   StringsAreEmpty: (data) ->
      is_empty = true

      for string in data
        if string.match Util.NonEmptyStringRegex
           is_empty = false

      return is_empty

GenerateUniqueID = -> uuid.v4()
