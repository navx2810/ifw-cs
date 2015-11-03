m = require "mithril"
uuid = require 'node-uuid'

module.exports = Util =
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
      {key, value, type} = data
      new_data = {}

      if key? then new_data.key = key else new_data.key = ""
      if value? then new_data.value = value else new_data.value = ""
      if type? then new_data.type = type else new_data.type = ""

      return new_data

   StringsAreEmpty: (data) ->
      is_empty = true

      for string in data
        if string.match Util.NonEmptyStringRegex
           is_empty = false

      return is_empty

GenerateUniqueID = -> uuid.v4()
