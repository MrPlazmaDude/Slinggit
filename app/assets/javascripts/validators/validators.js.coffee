## Module
class Validator

	email: ()->
		$email = @.arg
		mailChecked = =>
			self = @
			result = true
			domains = [ "hotmail.com", "gmail.com", "aol.com", "msn.com", "yahoo.com", "pixorial.com", "slinggit.com" ]
			$email.mailcheck
				domains: domains
				suggested: (element, suggestion) ->
					self.validator.emailMessage.message = "Did you mean #{suggestion.full} <a href='#'>No</a>"
					result = false

				empty: (element)->
					self.validator.emailMessage.message = self.validator.emailMessage.default
					#console.log self.validator.emailMessage.message
					resut = true

			result


		return mailChecked()

	emailMessage:
		message: "How will we reach you if we don't have your email?"
		default: "How will we reach you if we don't have your email?"

	getEmailMessage: =>
		@emailMessage.message


## Exports
@slinggitValidator = ()->
	return new Validator