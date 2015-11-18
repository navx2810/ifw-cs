_ = require 'lodash'
Hbs = require 'handlebars'
fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'

Templates = {}


Character_Compiled_Templates = {}

# fs.readFile 'a.hbs', 'utf8', (err, data) ->
# 	console.log "error" if err

# 	template = Hbs.compile data
# 	console.log template

# 	console.log template (id: 'Matt', attributes: ["hello", "world"])


ReadTemplates = =>

	dir = 'src/app/export/templates'

	files = fs.readdirSync dir

	for file in files
		dot_index = file.indexOf '.'
		file_name_without_ext = file.slice 0, dot_index

		console.log "#{file} is located at #{dir+file}, the '.' is located at #{dot_index}, file name without ext: #{file_name_without_ext}"
		Templates[file_name_without_ext] = fs.readFileSync "#{dir}/#{file}", 'utf8'

	console.log "Templates are read"

CreateCharacterString = (character, asset_folder_path) =>
	Attributes = AssignAttributes character.attributes
	DefaultValues = AssignDefaultValues character.attributes
	Curves = AssignCurves character.curves
	CurveNotifiers = AssignCurveNotifier character.curves
	Events = AssignEvents character.curves

	console.log "Creating character\nAttributes: #{JSON.stringify Attributes}\nDefaultValues: #{JSON.stringify DefaultValues}\nCurves: #{JSON.stringify Curves}\n"
	console.log "Curve Notifiers\nNotifiers: #{JSON.stringify CurveNotifiers}\n"
	template = Hbs.compile Templates.character

	return template (class_name: "#{FormatIDToClassName(character.id)}", id: character.id, attributes: Attributes, values: DefaultValues, curves: Curves, curve_notifiers: CurveNotifiers, events: Events, path: asset_folder_path)

CreateCharacterSO = (character, asset_folder_path) =>
	Attributes = AssignAttributes character.attributes
	DefaultValues = AssignDefaultValues character.attributes
	Curves = AssignCurves character.curves
	CurveNotifiers = AssignCurveNotifier character.curves
	Events = AssignEvents character.curves

	console.log "Creating ScriptableObject\nAttributes: #{JSON.stringify Attributes}\nDefaultValues: #{JSON.stringify DefaultValues}\nCurves: #{JSON.stringify Curves}\n"
	template = Hbs.compile Templates.scriptableObject

	return template (class_name: "#{FormatIDToClassName(character.id)}", id: character.id, attributes: Attributes, values: DefaultValues, curves: Curves, curve_notifiers: CurveNotifiers, events: Events, path: asset_folder_path)

FormatIDToClassName = (value) =>
	console.log "Uppercasing #{value}\nValue At index 0 is #{value[0]}\n"

	first_char = value[0]

	if typeof(first_char) is 'string'
		first_char_uppercased = first_char.toUpperCase()
	else
		first_char_uppercased = first_char

	first_char_uppercased = value[0].toUpperCase()
	new_value = "c#{first_char_uppercased}#{value.substring 1, value.length}"

	return new_value

AssignAttributes = (attributes) =>

	console.log "Creating Attributes\nAttributes: #{JSON.stringify attributes}\n"

	attributes_string = []
	for attribute in attributes
		console.log "Attribute #{attribute.key} being created\nTemplate: #{JSON.stringify Templates[attribute.type]}\n"

		template_string = if Templates[attribute.type]? then Templates[attribute.type] else Templates['Default']

		# template = Hbs.compile Templates[attribute.type]
		template = Hbs.compile template_string

		compiled_string = template attribute
		console.log "Compiled String: #{compiled_string}\n"
		attributes_string.push compiled_string

	return attributes_string

	# for each attribute
		# get the template based on the data type
		# push the HBS compiled template to the Attributes array

AssignDefaultValues = (attributes) =>
	default_value_strings = []

	for attribute in attributes
		if attribute.default_value?

			if typeof(attribute.default_value) is 'string' or attribute.type is 'Paragraph'
				template = Hbs.compile '{{key}} = "{{default_value}}";'
			else
				template = Hbs.compile '{{key}} = {{default_value}};'

			default_value_strings.push template attribute

	return default_value_strings
	# for each attribute
		# if default value isn't null
			# push compiled method to the default values array

AssignCurves = (curves) =>
	curves_string = []

	for curve, index in curves
		curve.index = index
		template = Hbs.compile 'Curves.Add(new Level { Damage = {{damage}}, Cost = {{cost}} });'
		curves_string.push template curve

	return curves_string

AssignCurveNotifier = (curves) =>
	curve_notifers_string = []

	for curve, index in curves
		if curve.notifier is true
			console.log "Curve Notifier for #{JSON.stringify curve} is #{curve.notifier}\n"
			template = Hbs.compile "case {{index}}: if (OnLevel{{index}}Attained != null) OnLevel{{index}}Attained(); break;"
			curve_notifers_string.push template (index: index)

	console.log "Curves Notifier String\n#{JSON.stringify curve_notifers_string}\n"

	return curve_notifers_string

AssignEvents = (curves) =>
	events_string = []

	for curve, index in curves
		if curve.notifier is true
			template = Hbs.compile "public event dvNotify OnLevel{{index}}Attained;"
			events_string.push template (index: index)

	return events_string

module.exports = (model, path) =>
	ReadTemplates()

	console.log "Model\n#{JSON.stringify model}\n"

	asset_folder_path_index = path.indexOf "Asset"	# if this is -1, there is no asset directory
	asset_folder_path = path.slice path.indexOf "Asset"
	asset_folder_path = asset_folder_path.replace /\\/g, "/"
	console.log "Path is #{path}\nIn Asset Folder Path is #{asset_folder_path}"

	for character in model.characters
		console.log "Character ID:#{character.id}\nValues: #{JSON.stringify character}\n"
		Character_Compiled_Templates[FormatIDToClassName character.id] = CreateCharacterString character, asset_folder_path
		Character_Compiled_Templates[FormatIDToClassName character.id] =
			character: CreateCharacterString character, asset_folder_path
			scriptableObject: CreateCharacterSO character, asset_folder_path

	mkdirp.sync "#{path}/code"

	for key, val of Character_Compiled_Templates
		fs.writeFile "#{path}/code/#{key}.cs", val.character, 'utf8', (err) -> throw err if err
		fs.writeFile "#{path}/code/so#{key}.cs", val.scriptableObject, 'utf8', (err) -> throw err if err

	# Writing the Idler GameObject
	characters_list_for_gameobject = []

	for character in model.characters
		characters_list_for_gameobject.push (id: character.id, class_name: FormatIDToClassName character.id)

	template = Hbs.compile Templates.global

	global_string = template (characters: characters_list_for_gameobject)
	fs.writeFile "#{path}/code/IdlerGO.cs", global_string, 'utf8', (err) -> throw err if err

	template = Hbs.compile Templates.characters

	characters_string = template (characters: characters_list_for_gameobject)
	fs.writeFile "#{path}/code/Characters.cs", characters_string, 'utf8', (err) -> throw err if err

	template = Hbs.compile Templates.currency

	currency_string = template()
	fs.writeFile "#{path}/code/Currency.cs", currency_string, 'utf8', (err) -> throw err if err


# Read the Templates into the array

# For each character
	# Assign Attributes
	# Assign Default Values
	# Assign Curves
	# Compile to character ScriptableObject file string

# Compile character strings to each file prefixed with c'characterName' (hungarian notation)
