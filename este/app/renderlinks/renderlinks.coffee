###*
  @fileoverview Render links via soy templates to have content contextually
  autoescaped to eliminate the risk of XSS.
###
goog.provide 'este.app.renderLinks'

###*
  @param {este.app.View} view
  @param {Array.<Object>} links
  @return {string}
###
este.app.renderLinks = (view, links) ->
  html = ''
  for link in links
    className = if link.selected then 'este-selected' else ''
    href = view.createUrl link.presenter
    html += "<a class='#{className}' href='#{href}'>#{link.title}</a>"
  html