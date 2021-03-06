{entityAttribute, Entity} = require "./Entity"

class exports.Assets extends Entity
	entity :
		name: "Assets"
		type: "a-assets"

	@define "timeout", entityAttribute("timeout", "timeout", null)

class _AssetItem extends Entity
	entity :
		name: "AssetItem"
		type: "a-asset-item"

class _AssetModel extends Entity
	entity :
		name: "AssetModel"
		type: "a-asset-item"

class _AssetAudio extends Entity
	entity :
		name: "AssetAudio"
		type: "audio"

class _AssetImage extends Entity
	entity :
		name: "AssetImage"
		type: "img"

class _AssetVideo extends Entity
	entity :
		name: "AssetVideo"
		type: "video"

exports.AssetItem = (src) ->
	asset = new _AssetItem
		src: src
		parent: Hologram.assets
	return asset

exports.AssetModel = (src) ->
	asset = new _AssetModel
		src: src
		parent: Hologram.assets
	return asset

exports.AssetAudio = (src) ->
	asset = new _AssetAudio
		src: src
		parent: Hologram.assets
	return asset

exports.AssetImage = (src) ->
	asset = new _AssetImage
		src: src
		parent: Hologram.assets
	return asset

exports.AssetVideo = (src) ->
	asset = new _AssetVideo
		src: src
		parent: Hologram.assets
	return asset
