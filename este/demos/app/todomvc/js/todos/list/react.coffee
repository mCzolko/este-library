###*
  @fileoverview este.demos.app.todomvc.todos.list.react.
  @see http://estejs.tumblr.com/post/32600427488/why-script-elements-used-for-templates-are-wrong
###
goog.provide 'este.demos.app.todomvc.todos.list.react'

goog.require 'este.react'

este.demos.app.todomvc.todos.list.react = este.react.create (`/** @lends {React.ReactComponent.prototype} */`)

  render: ->
    @div [
      @renderHeader()
      if @props['showBodyAndFooter'] then [
        @renderMain()
        @renderFooter()
      ]
    ]

  renderHeader: ->
    @header 'className': 'header', [
      @h1 'todos'
      @form 'className': 'new-todo-form', [
        @input
          'autoFocus': true
          'className': 'new-todo'
          'name': 'title'
          'placeholder': 'What needs to be done?'
      ]
    ]

  renderMain: ->
    @section 'className': 'main', [
      @input
        'checked': @props['remainingCount'] == 0
        'className': 'toggle-all'
        'type': 'checkbox'
      @label 'htmlFor': 'toggle-all', 'Mark all as complete'
      @ul 'className': 'todo-list',
        @props['todos'].map @renderTodoItem, @
    ]

  renderTodoItem: (todo) ->
    props =
      'data-e-model-cid': todo['_cid']
      'className': do ->
        classNames = []
        classNames.push 'completed' if todo['completed']
        classNames.push 'editing' if todo['editing']
        classNames.join ' '

    @li props, [
      @div 'className': 'view', [
        @input
          'checked': todo['completed']
          'className': 'toggle'
          'type': 'checkbox'
        @label todo['title']
        @button 'className': 'destroy'
      ]
      @input
        'className': 'edit'
        'defaultValue': todo['title']
    ]

  renderFooter: ->
    getClassIfSelected = (state) =>
      return 'selected' if @props['state'] == state
      ''

    @footer 'className': 'footer', [
      @span 'className': 'todo-count', [
        @strong @props['remainingCount']
        " #{@props['itemsLeftLocalized']}"
      ]
      @ul 'className': 'filters', [
        @li @a
          'className': getClassIfSelected ''
          'href': '#/'
        , 'All'
        @li @a
          'className': getClassIfSelected 'active'
          'href': '#/active'
        , 'Active'
        @li @a
          'className': getClassIfSelected 'completed'
          'href': '#/completed'
        , 'Completed'
      ]
      if @props['doneCount'] > 0
        @button
          'className': 'clear-completed'
        , "Clear completed (#{@props['doneCount']})"
    ]