$(document).ready ->
	buttons = ['#submitNewPost', '#addTwitterbutton', '#addFacebookbutton', '#messageReplyButton']
	for button in buttons
		$(button).one "click", ()=>
			$(button).click (e)=>
				e.preventDefault()