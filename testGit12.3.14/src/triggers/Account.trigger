trigger Account on Account (before insert) {
	
	System.debug('NND --> trigger.new: ' + trigger.new);
	trigger.new[0].addError('test');

}