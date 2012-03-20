poker.service = (function($){

// Statics
var serverUrl = 'http://poker.lurey.org:3000';

// Class
function TableService(playerId, tableId) {
	this._playerId = playerId;
	this._tableId = tableId;
}

TableService.prototype = {
	fold: function fold(asyncFn) {
		$.post(serverUrl + '/fold', {id: this._playerId}, asyncFn, 'jsonp');
	},
	
	check: function check(asyncFn) {
		$.post(serverUrl + '/check', {id: this._playerId}, asyncFn, 'jsonp');
	},
	
	deal: function deal(asyncFn) {
		$.post(serverUrl + '/deal', {id: this._playerId}, asyncFn, 'jsonp');
	},
	
	raise: function raise(amount, asyncFn) {
		$.post(serverUrl + '/raise', {id: this._playerId, amount: amount}, asyncFn, 'jsonp');
	},
	
	exit: function exit() {
		this._tableHandler._onClose.call(this._tableHandler);
	},
	
	subscribe: function subscribe(tableStateHandler) {
		var playerSub = this._playerSub = new Juggernaut({
			host: 'poker.lurey.org',
			port: 8080
		});
		
		this._tableHandler = tableStateHandler;
		
		playerSub.meta = {player_id:	this._playerId, table_id: this._tableId};
		playerSub.on('connect', tableStateHandler._onConnectPlayer.bind(tableStateHandler));
		playerSub.on('disconnect', tableStateHandler._onClosePlayer.bind(tableStateHandler));
		playerSub.on('reconnect', tableStateHandler._onReconnectPlayer.bind(tableStateHandler));
		playerSub.subscribe(this._tableId + '/' + this._playerId, tableStateHandler._onNotifyPlayer.bind(tableStateHandler));
		
		var channelSub = this._channelSub = new Juggernaut({
			host: 'poker.lurey.org',
			port: 8080
		});
		
		channelSub.meta = {player_id: this._playerId, table_id: this._tableId, table: true};
		channelSub.on('connect', tableStateHandler._onConnectChannel.bind(tableStateHandler));
		channelSub.on('disconnect', tableStateHandler._onCloseChannel.bind(tableStateHandler));
		channelSub.on('reconnect', tableStateHandler._onReconnectChannel.bind(tableStateHandler));
		channelSub.subscribe(this._tableId.toString(), tableStateHandler._onNotifyChannel.bind(tableStateHandler));
	},
	
	getTableId: function getTableId() {
		return this._tableId;
	}
};

// Class
function TournamentService() {

}

TournamentService.prototype = {
	createTableService: function createTableService(playerId, asyncFn) {
		$.post(serverUrl + '/sign_ajax', {player_id: playerId}, function(data){
			return asyncFn(new TableService(data.player_id, data.table_id));
		}, 'jsonp');
	}
};

// Exports
return {
	TableService: TableService,
	TournamentService: TournamentService
};

})(jQuery);