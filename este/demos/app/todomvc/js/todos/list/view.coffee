###*
  @fileoverview View for list of todos.
###
goog.provide 'este.demos.app.todomvc.todos.list.View'

goog.require 'este.app.View'
goog.require 'este.demos.app.todomvc.todos.list.react'
goog.require 'goog.i18n.pluralRules'

class este.demos.app.todomvc.todos.list.View extends este.app.View

  ###*
    @constructor
    @extends {este.app.View}
  ###
  constructor: ->
    super()

  ###*
    @type {string}
  ###
  filter: ''

  ###*
    @type {este.demos.app.todomvc.todos.Collection}
  ###
  todos: null

  ###*
    @type {React.ReactComponent}
    @protected
  ###
  react: null

  ###*
    @override
  ###
  enterDocument: ->
    super()
    @on '.new-todo-form', 'submit', @onNewTodoSubmit
    @on '.toggle-all', 'click', @onToggleAllClick
    @on '.clear-completed', 'click', @onClearCompletedClick
    @on '.toggle', 'click', @bindModel @onToggleClick
    @on '.destroy', 'click', @bindModel @onDestroyClick
    @on 'label', 'dblclick', @bindModel @onLabelDblclick
    @on '.edit', ['focusout', goog.events.KeyCodes.ENTER], @bindModel @onEditEnd
    return

  ###*
    @param {este.events.SubmitEvent} e
    @protected
  ###
  onNewTodoSubmit: (e) ->
    todo = new este.demos.app.todomvc.todos.Model e.json
    errors = todo.validate()
    return if errors
    e.target.elements['title'].value = ''
    @todos.add todo

  ###*
    @protected
  ###
  onToggleAllClick: ->
    @todos.toggleAll()

  ###*
    @protected
  ###
  onClearCompletedClick: ->
    @todos.clearCompleted()

  ###*
    @param {este.demos.app.todomvc.todos.Model} model
    @protected
  ###
  onToggleClick: (model) ->
    model.toggleCompleted()

  ###*
    @param {este.demos.app.todomvc.todos.Model} model
    @protected
  ###
  onDestroyClick: (model) ->
    @todos.remove model

  ###*
    @param {este.demos.app.todomvc.todos.Model} model
    @param {Element} el
    @protected
  ###
  onLabelDblclick: (model, el) ->
    model.set 'editing', true
    edit = el.querySelector '.edit'
    este.dom.focusAsync edit

  ###*
    @param {este.demos.app.todomvc.todos.Model} model
    @param {Element} el
    @protected
  ###
  onEditEnd: (model, el) ->
    edit = el.querySelector '.edit'
    title = goog.string.trim edit.value
    if !title
      @todos.remove model
      return

    model.set
      'title': title
      'editing': false

  ###*
    This method is called when view is shown and when todos collection is
    changed.
    @override
  ###
  update: ->
    length = @todos.getLength()
    remainingCount = @todos.getRemainingCount()

    props =
      'doneCount': length - remainingCount
      'filter': @filter
      'itemsLeftLocalized': @getItemsLeftLocalized remainingCount
      'showBodyAndFooter': length > 0
      'remainingCount': remainingCount
      'todos': @todos.filterByState @filter

    if !@react
      @react = este.demos.app.todomvc.todos.list.react props
      este.react.render @react, @getElement()
      return
    @react.setProps props

  ###*
    This method allows us to define plural translations for every language.
    @param {number} remainingCount
    @return {string} Localized string.
    @protected
    @see estejs.tumblr.com/post/35639619128/este-js-localization-cheat-sheet
  ###
  getItemsLeftLocalized: (remainingCount) ->
    switch goog.i18n.pluralRules.select remainingCount
      when goog.i18n.pluralRules.Keyword.ZERO
        ###*
          @desc Zero items left.
          @protected
        ###
        View.MSG_ZERO_ITEMLEFT = goog.getMsg 'items left'

      when goog.i18n.pluralRules.Keyword.ONE
        ###*
          @desc One item left.
          @protected
        ###
        View.MSG_ONE_ITEMLEFT = goog.getMsg 'item left'

      when goog.i18n.pluralRules.Keyword.TWO
        ###*
          @desc Two items left.
          @protected
        ###
        View.MSG_TWO_ITEMLEFT = goog.getMsg 'items left'

      when goog.i18n.pluralRules.Keyword.FEW
        ###*
          @desc Few items left.
          @protected
        ###
        View.MSG_FEW_ITEMLEFT = goog.getMsg 'items left'

      when goog.i18n.pluralRules.Keyword.MANY
        ###*
          @desc Many items left.
          @protected
        ###
        View.MSG_MANY_ITEMLEFT = goog.getMsg 'items left'

      else
        ###*
          @desc Other items left.
          @protected
        ###
        View.MSG_OTHER_ITEMLEFT = goog.getMsg 'items left'