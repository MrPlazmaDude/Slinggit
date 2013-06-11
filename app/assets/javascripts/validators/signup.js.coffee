## Imports
#validator = window.slinggitValidator()

## Module
class SignupValidator
	constructor: (@validator)->
		$("form#new_user").isHappy fields:
			"#user_name":
				required: true
				message: "Might we ask you for a username :)"

			"#user_email":
				required: true
				message: @validator.getEmailMessage
				test: @validator.email
				arg: $("#user_email").val()
				validator: @validator


# Exports
@signupValidator = (validator)->
	new SignupValidator(validator)