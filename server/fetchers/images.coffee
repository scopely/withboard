update = ->
  folders = Config.findOne(key: 'image-folders')?.value
  userId = Config.findOne(key: 'google-user-id')?.value
  return unless folders and userId
  return unless user = Meteor.users.findOne userId

  getItem = (id) ->
    fields = 'createdDate,description,imageMediaMetadata(height,width),mimeType,ownerNames,webContentLink,title,labels'
    image = GoogleApi.get "drive/v2/files/#{id}?fields=#{fields}", {user}

    return if image.labels.trashed
    return if image.mimeType.indexOf('image/') isnt 0

    createdDate: image.createdDate
    description: image.description
    size: image.imageMediaMetadata
    mimeType: image.mimeType
    owner: image.ownerNames[0]
    url: image.webContentLink
    title: image.title

  getList = (folderId) ->
    throw new Error 'No image folder ID present' unless folderId

    images = []
    {items} = GoogleApi.get "drive/v2/files/#{folderId}/children?fields=items/id", {user}
    for {id} in items
      Meteor._sleepForMs 1000 # rate limiting
      if image = getItem id
        images.push image
    return images

  imageMap = {}
  for key, folderId of folders
    imageMap[key] = getList folderId

  State.upsert {key: 'images'},
    $set: value: imageMap

  console.log 'Fetched', Object.keys(imageMap).length, 'image folders'

Meteor.startup -> Meteor.defer update
Meteor.setInterval update, 60 * 60 * 1000 # 60 minutes
