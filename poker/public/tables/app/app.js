poker.UI = (function(){

// Statics
var tournamentService = new poker.service.TournamentService(),
	tableService = null,
	gameRaiseAmount = 0,
	gameCallAmount = 0,
	gameBigBlind = 0,
	gamePlayerList = [],
	gameMyCards = [],
	gameSharedCards = [];

// Dom Retrievals
var modalMessage = $('#a-modelMessage'),
	modalBackground = $('#a-modalBackground'),
	channelDiv = $('#a-gameChannel'),
	gameOptions = $('#a-gameOptions'),
	gameCanvas = $('#a-gameCanvas');

// Functions
function onDeal() {
	tableService.deal(function(){
		console.log(arguments);
	});
}

function onFold() {
	tableService.fold(function(){
		console.log(arguments);
	});
}

function onCall() {
	tableService.check(function(){
		console.log(arguments);
	});
}

function onRaise() {
	var raiseAmount = prompt('How much (minimum is ' + gameRaiseAmount + ')?', gameRaiseAmount);
	
	if (raiseAmount == null)
		return;
		
	if (raiseAmount < gameRaiseAmount) {
		poker.audio.Error.play();
		poker.UI.log('Game', 'The minimum amount to raise is ' + raiseAmount);
		return;
	}
	
	tableService.raise(raiseAmount, function(){
		console.log(arguments);
	});
}

function onQuit() {
	// @TODO
}

function onStart() {
	var playerId = poker.assignedPlayerId;
	
	if (!playerId)
		playerId = prompt('For testing purposes, input a (unique) player ID');
	
	poker.__playerId = parseInt(playerId);
	
	tournamentService.createTableService(playerId, function(createdService){
		// We have our Table
		tableService = createdService;
		poker.UI.log('System', 'Welcome to Anonymous Poker! You\'ve been assigned to Table #' + tableService.getTableId());
		poker.audio.Welcome.play();
		$('#a-tableIdentifier').text(tableService.getTableId());
		
		// Hide modal
		modalMessage.hide();
		modalBackground.hide();
		
		// Start the Subscription
		tableService.subscribe(new poker.events.TableStateHandler({
			player: {
				close: function(){
					poker.UI.log('Player', 'Connection was closed'); 
					poker.audio.Error.play();
				},
				
				connect: function() {
					poker.UI.log('Player', 'Connected!');
					poker.audio.Notify.play();
				},
				
				reconnect: function() {
					poker.UI.log('Player', 'Connection was re-established!');
					poker.audio.Notify.play();
				},
				
				notify: function(data) {
					data = JSON.parse(data);
					console.log('Received Private Data', data);
					
					if (!data.actions) {
						poker.audio.Error.play();
						poker.UI.log('Error', 'Player channel sent an invalid data stream');
						return;
					}
					
					var canCall = !!data.actions.call,
						canRaise = !!data.actions.raise,
						canFold = canCall || canRaise,
						callAmount = gameCallAmount = data.actions.callAmount,
						raiseAmount = gameCallAmount + gameBigBlind || '0',
						cards = gameMyCards = [data.cards.card1, data.cards.card2];
							
					if (!canFold)
						gameOptions.find('button[name="fold"]').attr('disabled', true);
					else
						gameOptions.find('button[name="fold"]').removeAttr('disabled');
						
					
					if (!canCall)
						gameOptions.find('button[name="call"]').attr('disabled', true).text('Call');
					else
						gameOptions.find('button[name="call"]').removeAttr('disabled').text('Call (Pay ' + callAmount + ')');
					
					if (!canRaise)
						gameOptions.find('button[name="raise"]').attr('disabled', true).text('Raise');
					else
						gameOptions.find('button[name="raise"]').removeAttr('disabled').text('Raise (Minimum of ' + raiseAmount + ')');
						
					// Re-Render Cards
					poker.renderCards(gameMyCards, gameSharedCards, function(responseHtml){
						gameCanvas.find('.m-cardCollection').remove();
						gameCanvas.append(responseHtml);
					});
				}
			},
			
			channel: {
				close: function(){
					poker.UI.log('Table', 'Connection was closed'); 
					poker.audio.Error.play();
				},
				
				connect: function() {
					poker.UI.log('Table', 'Connected!');
				},
				
				reconnect: function() {
					poker.UI.log('Table', 'Connection was re-established!');
				},
				
				notify: function(data) {
					if (typeof data == 'string') {
						var tokens = data.split(' ');
						
						switch (tokens[0]) {
							case 'POT':
								poker.audio.Coin.play();
								return;
							default:
								if (data[0] == '{') {
									poker.UI.log('Debug', data);
									data = JSON.parse(data);
									if (playerId in data) {
										var winAmount = data[playerId];
										poker.audio.Applause.play();
										poker.UI.log('Game', 'You won ' + winAmount + ' credits!');
									} else {
										poker.audio.Fail.play();
									}
									return;
								}
								break;
						}
						
						// poker.audio.Notify.play();
						
						poker.UI.log('Table', data);
					} else if (typeof data == 'object') {
						console.log('Received Public Data', data);
						
						var playerHash = {},
							tableObject = new poker.models.Table(data.table),
							isMyTurn = tableObject.getPlayerTurn() == playerId;
						
						// Static
						gamePlayerList = data.players;
						
						// Get Players (and Decode Them)
						data.players.forEach(function(player){
							playerHash[player.id] = new poker.models.Player(player);
						});
						
						// Find this player
						var thisPlayer = playerHash[playerId];
						
						if (thisPlayer == null || !(playerId in playerHash)) {
							poker.audio.Error.play();
							poker.UI.log('Error', 'We couldn\'t find our player on this table. Did you reset recently?');
							return;
						}
						
						// Update Players
						var playerNum = 0;
						
						gameCanvas.find('li').removeClass('isYou').removeClass('active').removeClass('playing');
						
						for (var iPlayerId in playerHash) {
							var playerElement = gameCanvas.find('li:nth-child(' + (playerNum + 1) + ')')
								.addClass('playing').empty(),
								iPlayer = playerHash[iPlayerId];
							playerElement.append($('<span class="chips">').text(iPlayer.getChips()));
							
							if (iPlayerId == playerId) {
								playerElement.addClass('isYou').append($('<span class="name">You</span>'));
							} else {
								playerElement.append($('<span class="name">' + 
									iPlayer.getName() + '</span>'));
							}
							
							if (iPlayerId == tableObject.getPlayerTurn()) {
								playerElement.addClass('active');
							}
							
							if (iPlayer.getLastAction())
								playerElement.append($('<span class="last">').text(iPlayer.getLastAction()));
							
							playerNum++;
						}
						
						// Update Credits
						gameOptions.find('span[name="amount"]').text(thisPlayer.getChips());
						$('#a-gamePot span').text(tableObject.getPot());
						gameBigBlind = tableObject.getBlindAmount();
						
						var raiseAmount = gameCallAmount + gameBigBlind || '0';
						gameOptions.find('button[name="raise"]').text('Raise (Minimum of ' + raiseAmount + ')');
						
						// Update Cards
						var newSharedCards = tableObject.getSharedCards();
						
						if (newSharedCards.length > gameSharedCards)
							poker.audio.Drop.play();
						
						gameSharedCards = newSharedCards;
						
						// Render Cards
						poker.renderCards(gameMyCards, gameSharedCards, function(responseHtml){
							gameCanvas.find('.m-cardCollection').remove();
							gameCanvas.append(responseHtml);
						});
						
						// End
						if (isMyTurn) {
							poker.audio.Ding.play();
							poker.UI.log('Game', 'It\'s your turn!');
						}
					}
				}
			}
		}));
	});
}

// Bindings
modalMessage.click(onStart);
gameOptions.find('button[name="fold"]').click(onFold);
gameOptions.find('button[name="call"]').click(onCall);
gameOptions.find('button[name="raise"]').click(onRaise);
gameOptions.find('button[name="quit"]').click(onQuit);

return {
	log: function log(from, message) {
		$('<span>').append($('<span class="from">').text(from)).append($('<span class="message">').text(message)).appendTo(channelDiv);
		channelDiv[0].scrollTop = 999999999;
	},
	
	onStart: function onStart() {
	
	}	
};

})();