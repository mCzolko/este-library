###*
  @fileoverview View for list of todos.
###
goog.provide 'este.demos.app.todomvc.todos.list.View'

goog.require 'este.app.View'
goog.require 'este.demos.app.todomvc.todos.list.templates'
goog.require 'goog.i18n.pluralRules'

class este.demos.app.todomvc.todos.list.View extends este.app.View

  ###*
    @constructor
    @extends {este.app.View}
  ###
  constructor: ->
    super()

  # Localization messages for goog.i18n.pluralRules.
  # estejs.tumblr.com/post/35639619128/este-js-localization-cheat-sheet

  ###*
    @desc Zero items left.
    @protected
  ###
  @MSG_ZERO_ITEMLEFT: goog.getMsg 'items left'

  ###*
    @desc One item left.
    @protected
  ###
  @MSG_ONE_ITEMLEFT: goog.getMsg 'item left'

  ###*
    @desc Two items left.
    @protected
  ###
  @MSG_TWO_ITEMLEFT: goog.getMsg 'items left'

  ###*
    @desc Few items left.
    @protected
  ###
  @MSG_FEW_ITEMLEFT: goog.getMsg 'items left'

  ###*
    @desc Many items left.
    @protected
  ###
  @MSG_MANY_ITEMLEFT: goog.getMsg 'items left'

  ###*
    @desc Other items left.
    @protected
  ###
  @MSG_OTHER_ITEMLEFT: goog.getMsg 'items left'

  ###*
    @type {este.demos.app.todomvc.todos.Collection}
  ###
  todos: null

  ###*
    @type {string}
    @protected
  ###
  filter: ''

  ###*
    @override
  ###
  registerEvents: ->
    @on '#new-todo-form', 'submit', @onNewTodoSubmit
    @on '#toggle-all', 'click', @onToggleAllClick
    @on '#clear-completed', 'click', @onClearCompletedClick
    @on '.toggle', 'click', @bindModel @onToggleClick
    @on '.destroy', 'click', @bindModel @onDestroyClick
    @on 'label', 'dblclick', @bindModel @onLabelDblclick
    @on '.edit', ['focusout', goog.events.KeyCodes.ENTER ], @bindModel @onEditEnd

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
    @override
  ###
  enterDocument: ->
    super()
    @update()
    return

  ###*
    @protected
  ###
  update: ->
    json = @getJsonForTemplate()
    html = este.demos.app.todomvc.todos.list.templates.element json
    este.dom.merge @getElement(), html

  ###*
    @return {Object}
    @protected
  ###
  getJsonForTemplate: ->
    length = @todos.getLength()
    remainingCount = @todos.getRemainingCount()

    doneCount: length - remainingCount
    filter: @filter
    itemsLocalized: @getLocalizedItems remainingCount
    remainingCount: remainingCount
    todos: @todos.filterByState @filter
    showMainAndFooter: !!length

  ###*
    @param {number} remainingCount
    @return {string}
    @protected
  ###
  getLocalizedItems: (remainingCount) ->
    switch goog.i18n.pluralRules.select remainingCount
      when goog.i18n.pluralRules.Keyword.ONE
        View.MSG_ONE_ITEMLEFT
      when goog.i18n.pluralRules.Keyword.ZERO
        View.MSG_ZERO_ITEMLEFT
      when goog.i18n.pluralRules.Keyword.TWO
        View.MSG_TWO_ITEMLEFT
      when goog.i18n.pluralRules.Keyword.FEW
        View.MSG_FEW_ITEMLEFT
      when goog.i18n.pluralRules.Keyword.MANY
        View.MSG_MANY_ITEMLEFT
      else
        View.MSG_OTHER_ITEMLEFT