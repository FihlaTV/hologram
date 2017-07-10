Utils = require "./Utils"
{EventEmitter} = require "./EventEmitter"

class exports.BaseClass extends EventEmitter

	entity :
		name: "BaseClass"
		type: "div"

	constructor: (options={}) ->
		@_id = Utils.randomID()
		@__options = options
		@_context = Hologram.CurrentContext
		@['_DefinedPropertiesValuesKey'] 	= {}

	######################################################

	toInspect: =>
		"<#{@entity.name} id:#{@id or null}>"

	######################################################

	@define = (propertyName, descriptor) ->

		for i in ["enumerable", "exportable", "importable"]
			if descriptor.hasOwnProperty(i)
				throw Error("woops #{propertyName} #{descriptor[i]}") if not Utils.isBoolean(descriptor[i])

		# See if we need to add this property to the internal properties class
		if @ isnt BaseClass
			descriptor.propertyName = propertyName

			# Have the following flags set to true when undefined:
			descriptor.enumerable ?= true
			descriptor.exportable ?= true
			descriptor.importable ?= true

			# Toggle importable to false when there's no setter defined:
			descriptor.importable = descriptor.importable and descriptor.set

			# Only retain options that are importable, exportable or both:
			if descriptor.exportable or descriptor.importable
				@['_DefinedPropertiesKey'] ?= {}
				@['_DefinedPropertiesKey'][propertyName] = descriptor

		# Set the getter/setter as setProperty on this object so we can access and override it easily
		getName = "get#{Utils.capitalizeFirst(propertyName)}"
		@::[getName] = descriptor.get
		descriptor.get = @::[getName]

		if descriptor.set
			setName = "set#{Utils.capitalizeFirst(propertyName)}"
			@::[setName] = descriptor.set
			descriptor.set = @::[setName]

		# Define the property
		Object.defineProperty(@prototype, propertyName, descriptor)

	######################################################

	@simpleProperty = (name, fallback, options={}) ->
		return Utils.extend options,
			default: fallback
			get: -> @_getPropertyValue(name)
			set: (value) -> @_setPropertyValue(name, value)

	@proxyProperty = (keyPath, options={}) ->
		# Allows to easily proxy properties from an instance object
		# Object property is in the form of "object.property"
		objectKey = keyPath.split(".")[0]
		return Utils.extend options,
			get: ->
				return unless Utils.isObject(@[objectKey])
				Utils.getValueForKeyPath(@, keyPath)
			set: (value) ->
				return unless Utils.isObject(@[objectKey])
				Utils.setValueForKeyPath(@, keyPath, value)

	_setPropertyValue: (k, v) =>
		@['_DefinedPropertiesValuesKey'][k] = v

	_getPropertyValue: (k) =>
		Utils.valueOrDefault @['_DefinedPropertiesValuesKey'][k],
			@_getPropertyDefaultValue k

	_getPropertyDefaultValue: (k) ->
		@_propertyList()[k]["default"]

	_propertyList: ->
		@constructor['_DefinedPropertiesKey']

	######################################################

	keys: ->
		Utils.keys @props

	######################################################
	# Definitions

	@define "id",
		get: -> @_id

	@define 'props',
		importable: false
		exportable: false
		get: ->
			keys = []
			propertyList = @_propertyList()
			for key, descriptor of propertyList
				if descriptor.exportable
					keys.push key

			Utils.pick(@, keys)

		set: (value) ->
			# If the value is array:
			#	first arg: default value
			#	second arg: user properties

			if Utils.isArray(value)
				if value[0]
					@props = value[0]
				if value[1]
					@props = value[1]
				return

			action = null
			propertyList = @_propertyList()
			for k,v of value
				@[k] = v if propertyList[k]?.importable
