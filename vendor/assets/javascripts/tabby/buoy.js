/* =============================================================

	Buoy v1.2
	A simple vanilla JS micro-library by Chris Ferdinandi.
	http://gomakethings.com

	Class handlers by Todd Motto.
	https://github.com/toddmotto/apollo

	Module pattern by Keith Rousseau.
	https://twitter.com/keithtri

	Free to use under the MIT License.
	http://gomakethings.com/mit/

 * ============================================================= */

window.buoy = (function (window, document, undefined) {

	'use strict';

	// Check for classList support
	// Returns Object
	var classList = document.documentElement.classList;

	// Check if an element has a class
	// Public method
	// Boolean: Returns true if element has class
	var hasClass = function (elem, className) {
		if ( classList ) {
			return elem.classList.contains(className);
		} else {
			return new RegExp('(^|\\s)' + className + '(\\s|$)').test(elem.className);
		}
	};

	// Add a class to an element
	// Public method
	// Runs function
	var addClass = function (elem, className) {
		if ( !hasClass(elem, className) ) {
			if ( classList ) {
				elem.classList.add(className);
			} else {
				elem.className += (elem.className ? ' ' : '') + className;
			}
		}
	};

	// Remove a class from an element
	// Public method
	// Runs function
	var removeClass = function (elem, className) {
		if (hasClass(elem, className)) {
			if ( classList ) {
				elem.classList.remove(className);
			} else {
				elem.className = elem.className.replace(new RegExp('(^|\\s)*' + className + '(\\s|$)*', 'g'), '');
			}
		}
	};

	// Toggle a class on an element
	// Public method
	// Runs function
	var toggleClass = function (elem, className) {
		if ( classList ) {
			elem.classList.toggle(className);
		} else {
			if ( hasClass(elem, className ) ) {
				removeClass(elem, className);
			}
			else {
				addClass(elem, className);
			}
		}
	};

	// Get siblings of an element
	// Public method
	// Returns array of nodes
	var getSiblings = function (elem) {
		var siblings = [];
		var sibling = elem.parentNode.firstChild;
		var skipMe = elem;
		for ( ; sibling; sibling = sibling.nextSibling ) {
			if ( sibling.nodeType == 1 && sibling != elem ) {
				siblings.push( sibling );
			}
		}
		return siblings;
	};

	// Return public functions
	return {
		toggleClass: toggleClass,
		removeClass: removeClass,
		addClass: addClass,
		hasClass: hasClass,
		getSiblings: getSiblings
	};

})(window, document);