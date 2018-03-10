# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('.consultar').on 'click', ->
    $('.consultar').addClass 'disabled'
    $(".resultado").html ''
    valores = {
      id: $('.id').val(),
      start: $('.start').val(),
      finish: $('.finish').val()
    }
    $(".loading").removeClass 'd-none'
    $.ajax(url: "/home/find.json", data: valores).done (rta) ->
      $(".loading").addClass 'd-none'
      $('.consultar').removeClass 'disabled'
      $(".resultado").append 'Numero de facturas: ', rta.facturas, '<br> Numero de llamadas: ', rta.llamadas
