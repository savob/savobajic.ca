
var body = document.body;

// Check if there is a preference present
if ('darkMode' in localStorage) {
	// There is a stored preference, maintain user preference on page reload
	if (localStorage.getItem('darkMode')) {
		body.classList.add('darkMode');
	}
}
else {
	// No preference present, determine from user's browser preferences
  
	var match = window.matchMedia('(prefers-color-scheme: dark)');
  
  // If there are matches or not
  if (match.matches == 0) {
  	// No matches, user doesn't prefer dark mode, use lightmode
  	body.classList.remove('darkMode');
		localStorage.setItem('darkMode', 'false');
  }
  else {
  	localStorage.setItem('darkMode', 'true');
  	body.classList.add('darkMode');
  }
}


window.onload = function() {
// Click on dark mode toggle. Add dark mode classes and wrappers. Store user preference through sessions
const switcher = document.getElementById("darkModeToggleSwitch");

switcher.addEventListener("click", function() {
		
		//If dark mode is selected
		if (localStorage.getItem('darkMode') == 'true') {
			body.classList.remove('darkMode');
			localStorage.setItem('darkMode', 'false');
		}
		else {
			localStorage.setItem('darkMode', 'true');
			body.classList.add('darkMode');
		}
})
}






