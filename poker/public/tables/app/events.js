poker.events = (function(){

// Imports
var Table = poker.models.Table,
	Player = poker.models.Player,
	HandResults = poker.models.HandResults;
	
// Class
function TableStateHandler(asyncFns) {
	if (!asyncFns)
		asnycFns = {};
	
	if (!asyncFns.player)
		asyncFns.player = {};
	
	if (!asyncFns.channel)
		asyncFns.channel = {};
	
	this._onClosePlayer = asyncFns.player.close 
		|| this._onClosePlayer;
	this._onConnectPlayer = asyncFns.player.connect 
		|| this._onConnectPlayer;
	this._onReconnectPlayer = asyncFns.player.reconnect 
		|| this._onReconnectPlayer;
	this._onNotifyPlayer = asyncFns.player.notify
		|| this._onNotifyPlayer;
		
	this._onCloseChannel = asyncFns.channel.close 
		|| this._onCloseChannel;
	this._onConnectChannel = asyncFns.channel.connect 
		|| this._onConnectChannel;
	this._onReconnectChannel = asyncFns.channel.reconnect 
		|| this._onReconnectChannel;
	this._onNotifyChannel = asyncFns.channel.notify
		|| this._onNotifyChannel;
}

TableStateHandler.eventName = 'onTableStateChange';

TableStateHandler.prototype = {
	_asyncFn: null,
	
	_onClosePlayer: function(){},
	_onCloseChannel: function(){},
	
	_onConnectPlayer: function(){},
	_onConnectChannel: function(){},
	
	_onNotifyPlayer: function(){
		console.log('Notify.Player', arguments);
	},
	_onNotifyChannel: function(){
		console.log('Notify.Channel', arguments);
	},
	
	_onReconnectPlayer: function(){},
	_onReconnectChannel: function(){},
};

// @TODO: Add Player Channel Handler
// List of Cards, When the Table is over: Winners, Highest Hand

// Exports
return {
	TableStateHandler: TableStateHandler
};

})();