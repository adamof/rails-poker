poker.models = (function($){

// Classes

function Table(tableData) {
	// playerTurn 		==> int
	this._playerTurn = parseInt(tableData.playerTurn);
	// button	  		==> int 		(who is the dealer, playerId)
	this._whoIsDealer = parseInt(tableData.button);
	// tableNumber		==> int			(channel)
	// blindAmount		==> int			(cost of blind, increases over time)
	this._blindAmount = parseInt(tableData.blindAmount);
	// sharedCards		==> array of strings
	//						"3D", "KH"
	this._sharedCards = Table.createCards(tableData.sharedCards);
	// pot				==> int			(money on table, logic like side-pots handled otherwise)
	this._pot = parseInt(tableData.pot);
	// player			==> [player]
	// this._player = new Player(tableData.player);
}

Table.createCards = function createCards(sharedCards) {
	return sharedCards;
};

Table.prototype = {
	getPlayerTurn: function getPlayerTurn() {
		return this._playerTurn;
	},
	
	getDealer: function getDealer() {
		return this._whoIsDealer;
	},
	
	getBlindAmount: function getBlindAmount() {
		return this._blindAmount;
	},
	
	getSharedCards: function getSharedCards() {
		return this._sharedCards;
	},
	
	getPot: function getPot() {
		return this._pot;
	},
	
	getPlayer: function getPlayer() {
		return this._player;
	},
	
	// Custom Methods
	getSmallBlind: function getSmallBlind() {
		var dealerId = this.getDealer() - 1;
		
		return dealerId < 1 ? 8 - Math.abs(dealerId) : dealerId;
	},
	
	getBigBlind: function getBigBlind() {
		var dealerId = this.getDealer() - 2;
		
		return dealerId < 1 ? 8 - Math.abs(dealerId) : dealerId;
	}
};

function Player(playerData) {
	// id				==> int
	this._id = parseInt(playerData.id);
	// name				==> string
	this._name = playerData.name;
	// chips			==> int			(money they have sitting in front of them)
	this._chips = parseInt(playerData.chips);
	// lastAction		==> string		(fold, call, raise)
	this._lastAction = playerData.lastAction;
	// possibleActions	==> [action]
	//						check: t/f, call: t/f, raise: t/f, callAmount: int
	this._possibleActions = playerData.possibleActions;
}	

Player.prototype = {
	getId: function getId() {
		return this._id;
	},
	
	getName: function getName() {
		if (this._name)
			return this._name.split('@')[0];
		
		return 'Player ID#' + this.getId();
	},
	
	getChips: function getChips() {
		return this._chips;
	},
	
	getLastAction: function getLastAction() {
		return this._lastAction;
	},
	
	getPossibleActions: function getPossibleActions() {
		return this._possibleActions;
	}
};

Player.createArray = function createArray(playersData) {
	var playerObjects = [];
	
	playersData.forEach(function(playerData){
		playerObjects.push(new Player(playerData));
	});
	
	return playerObjects;
};

function HandResults(handData) {
	// winningHand:		==> "3D", "KH"
	// potDistribution: ==> { playerId: amountWonInteger, ... }
}

// Exports
return {
	Table: Table,
	Player: Player,
	HandResults: HandResults
};

})(jQuery);