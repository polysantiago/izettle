# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(-> 
   $("#btn-login").click( (e) ->
    e.preventDefault();
    #$(".registration-form").addClass("hidden").hide() if $(".registration-form").not("hidden")
    $(".login-form").removeClass("hidden").hide().show("slow")
   )
)