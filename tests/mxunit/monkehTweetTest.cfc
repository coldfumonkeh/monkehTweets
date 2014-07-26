component extends="mxunit.framework.TestCase" {

    public any function setup() {
		variables.monkehTweet	=	new monkehTweet.com.coldfumonkeh.monkehTweet(
				consumerKey			=	'jmNKuslFxhRl5hoEOTcw',
				consumerSecret		=	'1LzHvvhGCxf3T2ZtywJBr8UUXYi1tdjr982RYSN0kE',
				oauthToken			=	'244138540-4ADnpe1h4WcnaetNVhl8TrmMucJh7AlMa2uF9YsY',
				oauthTokenSecret	=	'AcKdCmUKfDFcT1GcTXFQmU8ZnU7k20Hiws6QBT46JHJwG',
				userAccountName		=	'randomUser1000',
				parseResults		=	true
			);
		//return this;
	}
	
	public any function apiURLIsHTTPS() {
		var apiEndpoint = variables.monkehTweet.getapiEndpoint();
		assertEquals('https://api.twitter.com/', apiEndpoint);
	}
	
	public any function hashSearch() {
		var dataReturn	=	variables.monkehTweet.search(q=urlDecode('%23ColdFusion'), format='json');
		debug(dataReturn);
		return dataReturn;
	}
	
	public any function searchWithCount() {
		var dataReturn	=	variables.monkehTweet.search(q=urlDecode('%23swag'), count='2', format='json');
		debug(dataReturn);
		return dataReturn;
	}
	public any function geoGetPlaceByID() {
		var dataReturn = variables.monkehTweet.geoGetPlaceByID(place_id='df51dec6f4ee2b2c');
		debug(dataReturn);
		return dataReturn;
	}
	
	public any function geoSearch() {
		var dataReturn = variables.monkehTweet.geoSearch(street_address='Usterstrasse 202, Wetzikon');//geoSearch(query='Twitter%20HQ');
		debug(dataReturn);
		return dataReturn;
	}
	
	public any function geoReverseGeocode() {
		var dataReturn = variables.monkehTweet.geoReverseGeocode(lat='37.76893497', long='-122.42284884');
		debug(dataReturn);
		return dataReturn;
	}
	
	public any function geoSimilarPlaces() {
		var dataReturn = variables.monkehTweet.geoSimilarPlaces(lat='7.7821120598956', long='-122.400612831116', name='Twitter%20HQ');
		debug(dataReturn);
		return dataReturn;
	}
	
	/*public any function update_with_media() {
		var dataReturn	=	variables.monkehTweet.postUpdateWithMedia(status='Updating and testing ##monkehTweet. ##ColdFusion', media="/Applications/ColdFusion9/wwwroot/monkehTweet/test/code.png");
		debug(dataReturn);
		return dataReturn;
	}*/
	
	public any function postUpdate() {
		var dataReturn = variables.monkehTweet.postUpdate('Nothing to see here.. just testing something. Move along.');
		debug(dataReturn);
		return dataReturn;
	}
	
	public any function testDM() {
         dataReturn = variables.monkehTweet.createDM(user="coldfumonkeh", text="Hello World @ #TimeFormat(Now(), 'medium')#!");
		debug(dataReturn);
		return dataReturn;
	}
	
	
	
	public any function getRetweeterIDs() {
		var dataReturn = variables.monkehTweet.getRetweeterIDs(id=427822994769977344);
		debug(dataReturn);
		return dataReturn;
	}
	
	public any function getRetweets() {
		var dataReturn = variables.monkehTweet.getRetweets(id='487224072070504448');
		debug(dataReturn);
	}
	
	public any function getRetweetsOfMe() {
		var dataReturn = variables.monkehTweet.getRetweetsOfMe(include_entities = true, include_user_entities = true );
		debug(dataReturn);
		return dataReturn;
	}
	
	public any function getFollowersIDs() {
		var dataReturn	=	variables.monkehTweet.getFollowersIDs();
		debug(dataReturn);
		return dataReturn;
	}
	
	public any function getFriendsNoRetweetsIDs() {
		var dataReturn	=	variables.monkehTweet.getFriendsNoRetweetsIDs();
		debug(dataReturn);
		return dataReturn;
	}
	
	public any function getFriendsList() {
		var dataReturn	=	variables.monkehTweet.getFriendsList();
		debug(dataReturn);
		return dataReturn;
	}
	
	public any function getFollowersList() {
		var dataReturn	=	variables.monkehTweet.getFollowersList();
		debug(dataReturn);
		return dataReturn;
	}
	
	public any function getListOwnerships() {
		var dataReturn	=	variables.monkehTweet.getListOwnerships();
		debug(dataReturn);
		return dataReturn;
	}
	
	
	public any function searchUser() {
		var dataReturn	=	variables.monkehTweet.search(q='@coldfumonkeh',checkHeader=false);
		debug(dataReturn);
	}
	
	public any function searchHashtag() {
		var dataReturn	=	variables.monkehTweet.search(q='##ColdFusion',checkHeader=false);
		debug(dataReturn);
	}
	
	public any function getMentions() {
		var dataReturn	=	variables.monkehTweet.getMentions(format='json');
		debug(dataReturn);
	}
	
	public any function getHomeTimeline() {
		var dataReturn	=	variables.monkehTweet.getHomeTimeline(checkHeader=false);
		debug(dataReturn);
	}
	
	
	public any function getUserTimeline() {
		var dataReturn	=	variables.monkehTweet.getUserTimeline(checkHeader=false);
		debug(dataReturn);
	}
	
	public any function getStatusByID() {
		var dataReturn	=	variables.monkehTweet.getStatusByID(id='423468800759971841',format='json');//100529622881550336
		debug(dataReturn);
	}
	
	public any function getUserDetails() {
		//var dataReturn	=	variables.monkehTweet.getUserDetails(user_id='14582860',checkHeader=false);
		var dataReturn	=	variables.monkehTweet.getUserDetails(screen_name='coldfumonkeh',checkHeader=false);
		debug(dataReturn);
	}
	
	public any function getUserSuggestions() {
		var dataReturn	=	variables.monkehTweet.getUserSuggestions(slug='music',checkHeader=false);
		debug(dataReturn);
	}
	
	public any function getUserSuggestionsInCategory() {
		var dataReturn	=	variables.monkehTweet.getUserSuggestionsInCategory(slug='news',checkHeader=false);
		debug(dataReturn);
	}
	
	
	/*public any function getUserProfileImage() {
		var dataReturn	=	variables.monkehTweet.getUserProfileImage(screen_name='coldfumonkeh');
		debug(dataReturn);
	}*/
	
	/*public any function getFriendsStatus() {
		var dataReturn	=	variables.monkehTweet.getFriendsStatus(screen_name='@fymd', checkHeader=false);
		debug(dataReturn);
	}*/
	
	/*public any function getFollowersStatus() {
		var dataReturn	=	variables.monkehTweet.getFollowersStatus(screen_name='coldfumonkeh',checkHeader=false);
		debug(dataReturn);
	}*/
	
	/*public any function oauthRateLimitStatus() {
		var dataReturn	=	variables.monkehTweet.oauthRateLimitStatus(listID='6651154',checkHeader=false);
		debug(dataReturn);
	}*/
	
	/*public any function postUpdate() {
		var dataReturn	=	variables.monkehTweet.postUpdate(status="Updating ##monkehTweet tests and fixing stuff.");
		debug(dataReturn);
	}*/
	
	public any function createList() {
		var dataReturn	=	variables.monkehTweet.createList(name='test list of awesomeness', description='this is a test list');
		debug(dataReturn);
	}
	
	public any function getListStatuses() {
		var dataReturn	=	variables.monkehTweet.getListStatuses(list_id='59032657');
		debug(dataReturn);
	}
	
	/*public any function help_test() {
		var dataReturn	=	variables.monkehTweet.test();
		debug(dataReturn);
	}*/
	
	
	public any function getStatusLookup() {
		var dataReturn = variables.monkehTweet.getStatusLookup(id='21', include_entities='true');
		debug(dataReturn);
	}
	
	
	public any function help_configuration() {
		var dataReturn	=	variables.monkehTweet.configuration();
		debug(dataReturn);
	}
	
	public any function help_languages() {
		var dataReturn	=	variables.monkehTweet.languages();
		debug(dataReturn);
	}
	
	public any function help_getPrivacyPolicy() {
		var dataReturn	=	variables.monkehTweet.getPrivacyPolicy();
		debug(dataReturn);
	}
	
	public any function help_getLegalTOS() {
		var dataReturn	=	variables.monkehTweet.getLegalTOS();
		debug(dataReturn);
	}
	
	public any function help_getApplicationRateLimitStatus() {
		var dataReturn	=	variables.monkehTweet.getApplicationRateLimitStatus();
		debug(dataReturn);
	}
	
	
	
	public any function getAllLists() {
		var dataReturn	=	variables.monkehTweet.getAllLists(screen_name='DeeSadler');
		debug(dataReturn);
	}
	
	public any function addMemberToList() {
		var dataReturn	=	variables.monkehTweet.addMemberToList(list_id='59032657', user_id='14234482', screen_name='coldfumonkeh');
		debug(dataReturn);
	}
	
	public any function getListMembers() {
		var dataReturn	=	variables.monkehTweet.getListMembers(list_id='59032657');
		debug(dataReturn);
	}
	
	/*public void function updateProfileImage() {
		var dataReturn = variables.monkehTweet.updateProfileImage(image='/Applications/ColdFusion10/cfusion/wwwroot/monkehTweet/tests/mxunit/random.jpg');
		debug(dataReturn);
	}
	
	
	public void function updateProfileBackgroundImage() {
		var dataReturn = variables.monkehTweet.updateProfileBackgroundImage(image='/Applications/ColdFusion10/cfusion/wwwroot/monkehTweet/tests/mxunit/random.jpg', use=1);
		debug(dataReturn);
	}*/
	
    public void function testDummy() {
        assertTrue(true);
    }
}