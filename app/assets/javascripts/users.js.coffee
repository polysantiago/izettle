$( ->    
  $("#new_user").validate(
    focusCleanup: true
    rules:
      'user[email]':
        required: true
        email: true
        remote: '/check_availability'
      'user[password]': 
        required: true
        minlength: 6
        maxlength: 8
      'user[password_confirmation]':
        required: true
        minlength: 6
        maxlength: 8
        equalTo: "#user_password"
    messages:
      'user[email]':
        remote: $.format "{0} is already registered"
      'user[password_confirmation]':
        equalTo: "Passwords don't match"
    highlight: (element, errorClass, validClass) ->
      $(element).closest(".control-group").removeClass("success").addClass("error")
      return
    unhighlight: (element, errorClass, validClass) ->
      $(element).closest(".control-group").removeClass("error").addClass("success")
      return
    errorElement: "span"
    errorPlacement: (error, element) ->
      error.addClass("help-inline").insertAfter($(element))
      return
    submitHandler: (form) ->
      form.find(".actions input[type='submit']").addClass("disabled")
      return
  )
  return
)
