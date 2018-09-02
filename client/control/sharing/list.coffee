Template.SharingList.helpers
  orgName: ->
    Meteor.settings.public.organization_name

Template.SharingListEntry.helpers
  icon: ->
    switch @sharing
      when 'myself' then 'person'
      when 'unlisted' then 'group'
      when 'domain' then 'domain'
      when 'public' then 'public'

  shareInfo: ->
    switch @sharing
      when 'myself' then 'Visible only to me'
      when 'unlisted' then 'Accessible by anyone with the link'
      when 'domain' then 'Visible to anyone at ' + Meteor.settings.public.organization_name
      when 'public' then 'Accessible by anyone with the secret link'
