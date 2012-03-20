poker.audio = (function(){

return {
	Applause: new buzz.sound('/res/applause', { formats: ['mp3'] }),
	Button:	  new buzz.sound('/res/button', { formats: ['mp3'] }),
	Coin:	  new buzz.sound('/res/coin', { formats: ['mp3'] }),
	Ding: 	  new buzz.sound('/res/ding', { formats: ['mp3'] }),
	Drop:	  new buzz.sound('/res/drop', { formats: ['mp3'] }),
	Error:	  new buzz.sound('/res/error', { formats: ['mp3'] }),
	Fail:	  new buzz.sound('/res/fail', { formats: ['mp3'] }),
	Notify:   new buzz.sound('/res/notify', { formats: ['mp3'] }),
	Shuffle:  new buzz.sound('/res/shuffle', { formats: ['mp3'] }),
	Welcome:  new buzz.sound('/res/welcome', { formats: ['mp3'] })
};

})();