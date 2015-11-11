m = require 'mithril'

module.exports = m.prop
	characters: [(id: 'apple', attributes: [(key: "Nickname", type: "string", default_value: "carrrl"), (key: "Description", type: "string", default_value: null)], curves: [(damage: 40, cost:200, notifier: true), (damage: 90, cost:500, notifier: true), (damage: 150, cost:1000, notifier: false)])]
	types: []
	currency: (prefix: null, suffix: null)
