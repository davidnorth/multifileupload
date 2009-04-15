
Array.prototype.inject = function(memo, iterator) {
    this.forEach(function(value, index) {
      memo = iterator(memo, value, index);
    });
    return memo;
  },


// Sum the specified property for all items in the array
Array.prototype.sum = function() {
	if(arguments.length == 1) {
		var property = arguments[0];
		var values = this.map( function(item){ return item[property] } );
	}
	else {
		values = this;
	}
	return values.inject(0, function(a,b){return a+b});
  }

Array.prototype.remove = function(item){
	this.splice(this.indexOf(item),1);
}

Array.prototype.removeItemAt = function(index){
	this.splice(index,1);
}
