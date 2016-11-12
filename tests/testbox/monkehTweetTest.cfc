/**
* My xUnit Test
*/
component extends="testbox.system.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all test cases
	function beforeTests(){
		variables.accountName = 'randomUser1000';
		variables.monkehTweet	=	new com.coldfumonkeh.monkehTweet(
				consumerKey			=	'jmNKuslFxhRl5hoEOTcw',
				consumerSecret		=	'1LzHvvhGCxf3T2ZtywJBr8UUXYi1tdjr982RYSN0kE',
				oauthToken			=	'244138540-4ADnpe1h4WcnaetNVhl8TrmMucJh7AlMa2uF9YsY',
				oauthTokenSecret	=	'AcKdCmUKfDFcT1GcTXFQmU8ZnU7k20Hiws6QBT46JHJwG',
				userAccountName		=	variables.accountName,
				parseResults		=	true,
        timeout = 250
			);
	}

	// executes after all test cases
	function afterTests(){
	}

	// executes before every test case
	function setup( currentMethod ){
	}

	// executes after every test case
	function teardown( currentMethod ){
	}

/*********************************** TEST CASES BELOW ***********************************/

	<!--- function test_APIURLIsHTTPS() {
		var apiEndpoint = variables.monkehTweet.getapiEndpoint();
		expect(apiEndpoint).toBe('https://api.twitter.com/');
	}

	function test_HashSearch() {
		var dataReturn	=	variables.monkehTweet.search(q=urlDecode('%23ColdFusion'), format='json');
		expect(dataReturn.search_metadata.query).toBe('%23ColdFusion');
		expect(arrayLen(dataReturn.statuses)).toBeGTE(1);
	}

	function test_SearchWithCount() {
		var dataReturn	=	variables.monkehTweet.search(q=urlDecode('%23ColdFusion'), count='2', format='json');
		expect(dataReturn.search_metadata.query).toBe('%23ColdFusion');
		expect(arrayLen(dataReturn.statuses)).toBeGTE(1);
	} --->

	<!--- function test_geoGetPlaceByID() {
		var dataReturn = variables.monkehTweet.geoGetPlaceByID(place_id='df51dec6f4ee2b2c');
		expect(dataReturn.id).toBe('df51dec6f4ee2b2c');
		expect(arrayLen(dataReturn.contained_within)).toBeGTE(1);
		debug(dataReturn);
		return dataReturn;
	} --->

	<!--- function test_geoSearch() {
		var dataReturn = variables.monkehTweet.geoSearch(query='Toronto');//geoSearch(query='Twitter%20HQ');
		expect(arrayLen(dataReturn.places)).toBeGTE(1);
		expect(dataReturn.query.type).toBe('search');
		expect(dataReturn.query.params.query).toBe('Toronto');
	} --->

	<!--- function test_geoReverseGeocode() {
		var dataReturn = variables.monkehTweet.geoReverseGeocode(lat='37.76893497', long='-122.42284884');
		expect(arrayLen(dataReturn.result.places)).toBeGTE(1);
		expect(dataReturn.query.type).toBe('reverse_geocode');
		expect(dataReturn.query.params.coordinates.coordinates).toBe(['-122.42284884', '37.76893497']);
	} --->

	<!--- function test_geoSimilarPlaces() {
		var dataReturn = variables.monkehTweet.geoSimilarPlaces(name='San Francisco', lat='37.76893497', long='-122.42284884');
		expect(arrayLen(dataReturn.result.places)).toBeGTE(1);
		expect(dataReturn.query.type).toBe('similar_places');
		expect(dataReturn.query.params.coordinates.coordinates).toBe(['-122.42284884', '37.76893497']);
		expect(dataReturn.query.params.name).toBe('San Francisco');
	} --->

	<!--- function test_update_with_media() {
		<!---var mayoMedia = expandPath("/./tests/testbox/mayo.JPG");
		var dataReturn	=	variables.monkehTweet.postUpdateWithMedia(status='Image update test', media=mayoMedia);--->
		var media = expandPath("/./tests/testbox/random.jpg");
		var dataReturn	=	variables.monkehTweet.postUpdateWithMedia(status='Image update test', media=media);
		expect(arrayLen(dataReturn.entities.media)).toBe(1);
		expect(arrayLen(dataReturn.extended_entities.media)).toBe(1);
		expect(dataReturn.entities.media[1].id).toBe(dataReturn.extended_entities.media[1].id);
	} --->

	<!--- function test_postUpdate() {
		var now = now();
		var dataReturn = variables.monkehTweet.postUpdate('Nothing to see here.. just testing something. Move along. #now#');
		expect(dataReturn.text).toBe('Nothing to see here.. just testing something. Move along. #now#');
		expect(dataReturn.id).toBe(dataReturn.id_str);
		expect(dataReturn.user.screen_name).toBe(variables.accountName);
	} --->

	<!--- function test_DM() {
		var now = TimeFormat(Now(), 'medium');
    var dataReturn = variables.monkehTweet.createDM(user=variables.accountName, text="Hello World @ #now#!");
		expect(dataReturn.text).toBe('Hello World @ #now#!');
		expect(dataReturn.id).toBe(dataReturn.id_str);
	} --->


	function test_getRetweeterIDs() {
		var dataReturn = variables.monkehTweet.getRetweeterIDs(id=327473909412814850);
		debug(dataReturn);
		return dataReturn;
	}

}
