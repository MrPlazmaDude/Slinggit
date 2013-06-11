
## Module
class EmailValidation extends Backbone.View
	el: "#new_user"

	initialize: (options)->
		# This keeps @ as @ in all of our methods.  Very
  		# handy with jquery event handeling
  		_.bindAll @
  		# localize a some of the input fields into variables to
  		# to keep from searching the dom over and over
  		@$userEmail = $("#user_email")
  		@emailUrl = @options.emailUrl
  		@userUrl = @options.userUrl
  		@resetUrl = @options.resetUrl
  		@noThxUrl = @options.noThxUrl
  		@permissionGranted = @options.granted
  		@noThanks = @options.noThanks
  		@hideFields()
  		if !_.isEmpty @permissionGranted or !_.isEmpty @noThanks then @showHiddenFields()


  	hideFields: ->
  		$(".form_hiddenFields").hide()
  		$("#form_signUpActions").show()
  		$("#emailAvailabilityNotification").hide()
  		$("#usernameAvailabilityNotification").hide()


  	showHiddenFields: ->
  		$(".form_hiddenFields").show()
  		$("#form_signUpActions").hide()
  		if !_.isEmpty @permissionGranted then $("legend").html "You are authenticated with Twitter"

	
	events:
		"blur #user_name":                    "checkUsernameAvailability"
		"blur #user_email":                   "suggestAndValidate"
		#"keyup input":                        "hideErrorsAndNotifications"
		"click #noThanksBTN":                 "callNoThanks"
		"click #twitterBTN":                  "twitterAuthorize"
		"click #signUpStartOverLink":         "startOver"
		"click #emailSuggestionReplaceLink":  "swapEmailWithSuggested"

	checkUsernameAvailability: (e)->
		username = $(e.target).val()
		$.ajax(
			type: "POST"
			url: @userUrl
			data:
				name: username
		).done (response)->
			if response is "unavailable"
				$ "user_name"
				$("#usernameAvailabilityNotification").html "<div id=\"error_explanation\"><ul><li>* That username has already been registered.  <a href=\"/users/password_reset\">forgot password?</a></li></ul></div>"
				$("#usernameAvailabilityNotification").show()
			else
				$("#usernameAvailabilityNotification").html ""
				$("#usernameAvailabilityNotification").hide()


	suggestAndValidate: (e)->
		@checkEmailAddress(e)
		@validateEmail(e)

	checkEmailAddress: (e)->
		domains = [ "hotmail.com", "gmail.com", "aol.com", "msn.com", "yahoo.com", "pixorial.com", "slinggit.com" ]
		$(e.target).mailcheck
		  domains: domains
		  suggested: (element, suggestion) =>
		    $("#emailSuggestion").remove()
		    $(e.target).after "<span id='emailSuggestion'>Did you mean <a href='#' id='emailSuggestionReplaceLink'>" + suggestion.full + "</a></span>"

		  empty: (element) ->
		    $("#emailSuggestion").remove()


	validateEmail: (e)->
		email_address = $(e.target).val()
		#console.log "email #{email_address}"
		emailRegex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
		if emailRegex.test(email_address)
		  $.ajax(
		    type: "POST"
		    url: @emailUrl
		    data:
		      email: email_address
		  ).done (response) ->
		    if response is "unavailable"
		      $ "#user_email"
		      $("#emailAvailabilityNotification").html "<div id=\"error_explanation\"><ul><li>* That email has already been registered.  <a href=\"/users/password_reset\">forgot password?</a></li></ul></div>"
		      $("#emailAvailabilityNotification").show()
		    else
		      $("#emailAvailabilityNotification").html ""
		      $("#emailAvailabilityNotification").hide()

	
	hideErrorsAndNotifications: (e)->
		$("#error_explanation").hide()
		$(".field_with_errors").removeClass "field_with_errors"
		$(".alert").hide()
		$("html, body").animate
		  scrollTop: 0
		, "fast"


	swapEmailWithSuggested: ->
		@$userEmail.val($('#emailSuggestionReplaceLink').text())
		$("#emailSuggestion").remove()


	callNoThanks: (e)->
		e.preventDefault()
		$("#form_signUpActions").hide()
		$(".form_hiddenFields").show()
		@hideErrorsAndNotifications()
		$.ajax url: @noThxUrl


	twitterAuthorize: (e)->
		$("#twitter_authenticate").val(true)
		$("form#new_user").submit()


	startOver: (e)->
		e.preventDefault()
		$(".form_hiddenFields").hide()
		$("#form_signUpActions").show()
		$("#user_name").val ""
		$("#user_email").val ""
		$("legend").html "Create your profile"
		$("#emailSuggestion").remove()
		@hideErrorsAndNotifications()
		$.ajax url: @resetUrl


## Exports
@emailValidationView = (emailUrl, userUrl, resetUrl, noThxUrl, sessionGranted, noThanks)->
	return new EmailValidation({ emailUrl: emailUrl, userUrl: userUrl, resetUrl: resetUrl, noThxUrl: noThxUrl, granted: sessionGranted, noThanks: noThanks })










