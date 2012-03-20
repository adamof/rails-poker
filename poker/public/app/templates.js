poker.Templates = (function($){

// Class
function Templates() {

}

// Prototype
Templates.prototype = {
	getTemplate: function getTemplate(templateName, asyncFn) {
		$.get(poker.getUrl('templates/' + templateName + '.htm'), function onResponse(responseData){
			return asyncFn(responseData);
		});
	},
	
	render: function render(templateName, partialsList, renderData, asyncFn) {
		var loadCount = 1,
			coreTemplate = null;
		
		function onLoaded() {
			if (--loadCount == 0) {
				// console.log(coreTemplate, renderData, partialsList);
				asyncFn($(Mustache.render(coreTemplate, renderData, partialsList)));
			}
		}
		
		for (var k in partialsList) {
			loadCount++;
			
			this.getTemplate(partialsList[k], function onTemplate_Partials(templateData){
				partialsList[k] = templateData;
				onLoaded();
			});
		}
		
		this.getTemplate(templateName, function onTemplate_Core(templateData) {
			coreTemplate = templateData;
			onLoaded();
		});
	}
};

// Singleton
// Exports
return new Templates();

})(jQuery);