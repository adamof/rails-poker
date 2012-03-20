window.poker = (function(){

// Statics
var suits = ['spades', 'hearts', 'clubs', 'diamonds'],
	names = ['2', '3', '4', '5', '6', '7', '8', '9', 'jack', 'queen', 'king', 'ace'];

// Mash Table
var mash  = {
	's' : 'spades',
	'h' : 'hearts', 
	'c' : 'clubs',
	'd' : 'diamonds',
	'j' : 'jack',
	'q' : 'queen',
	'k' : 'king',
	'a' : 'ace',
	't' : '10'
};

// Statics
function createCardObjects(input) {
	var output = [];
	
	input.forEach(function(i){
		output.push(hashToCard(i));
	});
	
	return output;
}

function hashToCard(h) {
	if (h == null || h.length == 0)
		return poker.createCard(null, null, false);
	
	var h = h.toLowerCase(),
		name = h[0],
		suit = h[1];
		
	if (name in mash)
		name = mash[name];
	
	if (suit in mash)
		suit = mash[suit];
		
	return poker.createCard(name, suit, true);
}

// Exports
return {
	createCard: function createCard(name, suit, isVisible) {
		if (!arguments.length)
			return this.createCard(names[this.random(names.length)], suits[this.random(suits.length)], true);
			
		return {
			name: name,
			suit: suit,
			visible: isVisible
		};
	},
	
	doTest: function doTest() {
		var sharedCards = [];
		
		for (var i = 0; i < 5; i++)
			sharedCards.push(this.createCard());
		
		var myCards = [];
	
		for (var i = 0; i < 2; i++)
			myCards.push(this.createCard());
			
		var tableState = {
			cardSets: [
				{name: 'shared', cards: sharedCards},
				{name: 'hand'  , cards: myCards}
			]
		};
		
		this.renderTable(tableState, function(responseData){
			$('#a-gameCanvas').append(responseData);
		});
	},
	
	getUrl: function getUrl(relativeUrl) {
		return relativeUrl;
	},
	
	getId: function getId() {
		return poker.__pokerId;
	},
	
	random: function random(ceiling) {
		return Math.floor(Math.random() * ceiling);
	},
	
	renderCards: function renderCards(myHand, sharedCards, asyncFn) {
		myHand = createCardObjects(myHand);
		sharedCards = createCardObjects(sharedCards);
		
		var tableState = {
			cardSets: [
				{name: 'shared', cards: sharedCards},
				{name: 'hand',	 cards: myHand}
			]
		};
		
		this.renderTable(tableState, function(responseData){
			return asyncFn(responseData);
		});
	},
	
	renderHand: function renderHand(handData, asyncFn) {
		return poker.Templates.render('cardCollection', {}, handData, asyncFn);
	},
	
	renderTable: function renderTable(tableState, asyncFn) {
		console.log(tableState);
		return poker.Templates.render('tableState', {
			cardCollection: 'cardCollection'
		}, tableState, asyncFn);
	}
};

})();