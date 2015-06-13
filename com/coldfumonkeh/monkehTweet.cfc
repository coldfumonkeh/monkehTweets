<!---
Name: monkehTweet.cfc
Author: Matt Gifford AKA coldfumonkeh (http://www.mattgifford.co.uk)
Date: 30.01.2010

Copyright 2010 Matt Gifford AKA coldfumonkeh. All rights reserved.
Product and company names mentioned herein may be
trademarks or trade names of their respective owners.

Subject to the conditions below, you may, without charge:

Use, copy, modify and/or merge copies of this software and
associated documentation files (the 'Software')

Any person dealing with the Software shall not misrepresent the source of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

================

Got a lot out of this package? Saved you time and money?
Share the love and visit Matt's wishlist: http://www.amazon.co.uk/wishlist/B9PFNDZNH4PY


Revision history
================

10/09/2010 - Version 1.2

	- added OAuth authentication, dealing with HMAC-SHA1 encryption
	- revised complete method list to update the available API functions and amended arguments
	- removed deprecated methods
	- amended underlying architecture of the package (although public-facing methods remain the same for consistency)
	- poured blood, sweat and tears (including numerous cups of coffee) into this.

21/09/2010 - Version 1.2.4

	- amended issue with incorrect argument names in deleteStatus() and retweet() methods

11/04/2011 - Version 1.2.5

	- additional methods added
		- getRetweets()
		- retweetedBy()
		- retweetedByIDs()
		- geoSearch()
		- geoSimilarPlaces()
		- addMemberToList()
		- deleteListMember()
	- resolved minor authentication issues with getUserTimeline() and friendshipExists() methods
	- revised spelling mistake in geoReverseGeocode() method name

01/05/2011 - Version 1.2.6

	- additional method added
		- search()

10/06/2011 - Version 1.2.7

	- resolved issue with getUserTimeline() 401 error

29/06/2011 - Version 1.2.8

	- revised error handling and message return information (thanks to Joel (cajunjoel)) for the enhancement request.

08/08/2011 - Version 1.2.9

	- rate limit through authenticated requests issues resolved with revision of request handling and parameters being sent in URL query string
	- addition of checkHeader argument to the majority of functions to assist in debugging headers

	Thanks to Gary Stanton and Ray Majoran for finding the issue with the rate limits on authenticated requests.

22/11/2011 - Version 1.3

	- addition of new arguments and parameters to many of the functions to keep inline with Twitter documentation and updates
	- resolved a minor issue in the search method to allow for hashtag searching. Thanks to Andrew Myers for finding that one.
	- removed deprecated methods - Please check https://dev.twitter.com/docs/api#deprecated to see what has been removed and which function to now use instead
	- organisation of methods and functions to enable quicker updates and maintenance for future revisions
	- inclusion of (amongst others) the update_with_media function to send a photo / image as part of the status update

	=====
	NOTE:

	Some argument names have been changed in the 1.3 release to match the native counterparts.
	Please check your argument names and amend if required.

	=====

05/01/2012 - Version 1.3.1

	- addition of @Anywhere functionality for front-end enhancements (hovercards, linkifying users, tweet box and authentication login)

28/05/2012 - Version 1.3.2

	- addition of new functions:
		- getOEmbed (GET statuses/oembed) to return information allowing the creation of an embedded representation of a Tweet on third party sites
		- destoryAllListMembers (POST lists/members/destroy_all) to remove multiple members from a list, by specifying a comma-separated list of member ids or screen names.


26/10/2012 - Version 1.4.0

	- changed to API v1.1
		- getAllLists method endpoint changed from lists/all to lists/list
		- ALL methods now go through the authentication process, as required in the v1.1 documentation
		- ALL methods now return JSON format only (no more XML). Make sure to update your applications accordingly if you use XML.
		- DELETED a butt-load (official terminology) of methods that have been removed / deprecated in v1.1 API.

27/01/2014 - Version 1.4.4

	- addition of the following methods:
		- getRetweeterIDs
		- getRetweetsOfMe
		- getFriendsNoRetweetsIDs
		- getFriendsList
		- getFollowersList
		- getListOwnerships
	- fixed endpoint for reportSpam() method

26/03/2014 - Version 1.4.5

	- fixed an issue with the geo functions that were passing to a non-existant request method as they now need authentication. Thanks to Allan Schumann for finding this.

10/07/2014 - Version 1.4.6

	- fixed an issue with the updateProfileBackgroundImage and updateProfileImage methods producing a 414 error. Thanks to @DanielElmore for finding and reporting this.
	- fixed an issue with the getRetweets method using the incorrect HTTP method. Resolved to now use GET. Thanks to Tracy for finding and reporting this.

26/07/2014 - Version 1.4.7

	- addition of new method getStatusLookup which covers the Twitter GET statuses/lookup method
	- merged updated from Mark Hetherington to fix issue with symbols entity values. Thanks Mark!

03/02/2015 - Version 1.4.8

	- addition of cfhttp timeout value set in the constructor to help protect against hanging requests as raised by Tom Chiverton: https://github.com/coldfumonkeh/monkehTweets/issues/22

--->
<cfcomponent output="false" displayname="monkehTweet" hint="I am the main facade / service object for the twitter api." extends="base">

	<cfproperty name="authDetails" type="any" default="" />

	<cfset variables.instance = structNew() />

	<cffunction name="init" access="public" output="false" returntype="any" hint="I am the constructor method for the monkehTweet object.">
		<cfargument name="consumerKey" 		required="true" 	type="string" 	default=""		hint="The consumer key generated by Twitter for the oAuth." />
		<cfargument name="consumerSecret" 	required="true" 	type="string" 	default=""		hint="The consumer secret generated by Twitter for the oAuth." />
		<cfargument name="oauthToken" 		required="false" 	type="string" 	default="" 		hint="The access token (oauth_token) generated by Twitter for the oAuth." />
		<cfargument name="oauthTokenSecret" required="false" 	type="string" 	default="" 		hint="The access token secret (oauth_token_secret) generated by Twitter for the oAuth." />
		<cfargument name="userAccountName" 	required="false" 	type="string" 	default=""		hint="The account name for the user. This is needed to access certain methods, including list-related functions." />
		<cfargument name="parseResults"		required="false" 	type="boolean" 	default="false"	hint="A boolean value to determine if the output data is parsed or returned as a string" />
		<cfargument name="timeout" required="false"	type="string" default="30" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
		<cfscript>
				setAuthDetails(
							consumerKey			= 	arguments.consumerKey,
							consumerSecret		= 	arguments.consumerSecret,
							oauthToken			= 	arguments.oauthToken,
							oauthTokenSecret	=	arguments.oauthTokenSecret,
							userAccountName		=	arguments.userAccountName
						);
				setTimeout(arguments.timeout);
				setParseResults(arguments.parseResults);
				super.init(getAuthDetails(),arguments.parseResults,arguments.timeout);
			</cfscript>
		<cfreturn this />
	</cffunction>

	<!--- MUTATORS --->
	<cffunction name="setAuthDetails" access="private" output="false" hint="I set the twitter account access details">
		<cfargument name="consumerKey" 		required="true" 	type="string" 				hint="The consumer key generated by Twitter for the oAuth." />
		<cfargument name="consumerSecret" 	required="true" 	type="string" 				hint="The consumer secret generated by Twitter for the oAuth." />
		<cfargument name="oauthToken" 		required="false" 	type="string" 	default="" 	hint="The access token (oauth_token) generated by Twitter for the oAuth." />
		<cfargument name="oauthTokenSecret" required="false" 	type="string" 	default="" 	hint="The access token secret (oauth_token_secret) generated by Twitter for the oAuth." />
		<cfargument name="userAccountName" 	required="false" 	type="string" 	default=""	hint="The account name for the user. This is needed to access certain methods, including list-related functions." />
			<cfset variables.instance.authDetails = createObject('component', 'authDetails')
						.init(argumentCollection=arguments) />
	</cffunction>

	<cffunction name="setParseResults" access="private" output="false" hint="I set the parseResult boolean value">
		<cfargument name="parseResults"	required="false" default="false" type="boolean" hint="A boolean value to determine if the output data is parsed or returned as a string" />
		<cfset variables.instance.parseResults = arguments.parseResults />
	</cffunction>

	<cffunction name="setTimeout" access="private" output="false" hint="I set the timeout value">
		<cfargument name="timeout" required="false"	type="string" default="30" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
		<cfset variables.instance.timeout = arguments.timeout />
	</cffunction>

	<!--- ACCESSORS --->
	<cffunction name="getAuthDetails" access="public" output="false" hint="I get the twitter account access details">
		<cfreturn variables.instance.authDetails />
	</cffunction>

	<cffunction name="getParseResults" access="public" output="false" returntype="boolean" hint="I get the parseResult boolean value">
		<cfreturn variables.instance.parseResults />
	</cffunction>

	<cffunction name="getTimeout" access="public" output="false" returntype="boolean" hint="I get the timeout value">
		<cfreturn variables.instance.timeout />
	</cffunction>

	<!--- PUBLIC METHODS --->
	<cffunction name="setFinalAccessDetails" access="public" output="false" hint="I set the value of the oauthToken, oauthTokenSecret and authenticated user's screenname after a successful authentication.">
		<cfargument name="oauthToken" 		required="true" 	type="string" hint="The access token (oauth_token) generated by Twitter for the oAuth." />
		<cfargument name="oauthTokenSecret" required="true" 	type="string" hint="The access token secret (oauth_token_secret) generated by Twitter for the oAuth." />
		<cfargument name="userAccountName" 	required="true" 	type="string" hint="The account name for the user. This is needed to access certain methods, including list-related functions." />
			<cfscript>
				variables.instance.authDetails.setOAuthToken(arguments.oauthToken);
				variables.instance.authDetails.setOAuthTokenSecret(arguments.oauthTokenSecret);
				variables.instance.authDetails.setUserAccountName(arguments.userAccountName);
			</cfscript>
	</cffunction>

	<!--- Timelines --->
	<!--- Timelines are collections of Tweets, ordered with the most recent first. --->

	<!--- GET statuses/lookup --->
	<cffunction name="getStatusLookup" access="public" output="false" hint="Returns fully-hydrated tweet objects for up to 100 tweets per request, as specified by comma-separated values passed to the id parameter. This method is especially useful to get the details (hydrate) a collection of Tweet IDs. GET statuses/show/:id is used to retrieve a single tweet object.">
		<cfargument name="id" 						required="true" 	type="string" 					hint="A comma separated list of tweet IDs, up to 100 are allowed in a single request. Example Values: 20, 432656548536401920" />
		<cfargument name="include_entities"			required="false" 	default=""		type="string" 	hint="The entities node that may appear within embedded statuses will be disincluded when set to false." />
		<cfargument name="trim_user" 				required="false"	default=""		type="string"	hint="When set to either true, t or 1, each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object." />
		<cfargument name="map"						required="false"	default=""		type="string"	hint="When using the map parameter, tweets that do not exist or cannot be viewed by the current user will still have their key represented but with an explicitly null value paired with it" />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the headers and sent information for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'statuses/lookup.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET statuses/mentions_timeline --->
	<cffunction name="getMentions" access="public" output="false" hint="Returns the 20 most recent mentions (status containing @username) for the authenticating user.">
		<cfargument name="count" 					required="false" 	default="" 		type="string" 	hint="Specifies the number of statuses to retrieve. May not be greater than 200." />
		<cfargument name="since_id"					required="false" 	default=""		type="string" 	hint="Returns only statuses with an ID greater than (that is, more recent than) the specified ID." />
		<cfargument name="max_id"					required="false" 	default=""		type="string" 	hint="Returns only statuses with an ID less than (that is, older than) or equal to the specified ID." />
		<cfargument name="trim_user"				required="false" 	default=""		type="string" 	hint="When set to either true, t or 1, each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object." />
		<cfargument name="contributor_details"		required="false" 	default=""		type="string" 	hint="This parameter enhances the contributors element of the status response to include the screen_name of the contributor. By default only the user_id of the contributor is included." />
		<cfargument name="include_entities"			required="false" 	default=""		type="string" 	hint="When set to either true, t or 1, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags. While entities are opt-in on timelines at present, they will be made a default component of output in the future." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the headers and sent information for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'statuses/mentions_timeline.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET statuses/user_timeline --->
	<cffunction name="getUserTimeline" access="public" output="false" hint="Returns the 20 most recent statuses posted from the authenticating user. It's also possible to request another user's timeline via the id parameter. This is the equivalent of the Web /<user> page for your own user, or the profile page for a third party.">
		<cfargument name="user_id"					required="false"	default="" 		type="string" 	hint="Specfies the ID of the user for whom to return the user_timeline. Helpful for disambiguating when a valid user ID is also a valid screen name. " />
		<cfargument name="screen_name"				required="false"	default="" 		type="string" 	hint="Specfies the screen name of the user for whom to return the user_timeline. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="since_id"					required="false" 	default=""		type="string" 	hint="Returns only statuses with an ID greater than (that is, more recent than) the specified ID." />
		<cfargument name="count" 					required="false" 	default="" 		type="string" 	hint="Specifies the number of statuses to retrieve. May not be greater than 200." />
		<cfargument name="max_id"					required="false" 	default=""		type="string" 	hint="Returns only statuses with an ID less than (that is, older than) or equal to the specified ID." />
		<cfargument name="trim_user" 				required="false"	default=""		type="string"	hint="When set to either true, t or 1, each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object." />
		<cfargument name="exclude_replies" 			required="false"	default=""		type="string"	hint="This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets — this is because the count parameter retrieves that many tweets before filtering out retweets and replies." />
		<cfargument name="contributor_details" 		required="false"	default=""		type="string"	hint="This parameter enhances the contributors element of the status response to include the screen_name of the contributor. By default only the user_id of the contributor is included." />
		<cfargument name="include_rts" 				required="false"	default=""		type="string"	hint="When set to either true, t or 1,the timeline will contain native retweets (if they exist) in addition to the standard stream of tweets. The output format of retweeted tweets is identical to the representation you see in home_timeline. Note: If you're using the trim_user parameter in conjunction with include_rts, the retweets will still contain a full user object." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = '' />
				<cfscript>
					// Conditional discrepancy found by @aqlong - Thanks, Aaron!
					if(!len(arguments.screen_name) AND !len(arguments.user_id)) {
						arguments.screen_name	=	getAuthDetails().getUserAccountName();
					}
					strTwitterMethod = getCorrectEndpoint('api') & 'statuses/user_timeline.json';
				</cfscript>
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET statuses/home_timeline --->
	<cffunction name="getHomeTimeline" access="public" output="false" hint="Returns the 20 most recent statuses, including retweets, posted by the authenticating user and that user's friends. This is the equivalent of /timeline/home on the Web. Usage note: This home_timeline is identical to statuses/friends_timeline except it also contains retweets, which statuses/friends_timeline does not (for backwards compatibility reasons).">
		<cfargument name="count" 					required="false" 	default=""			type="string" 	hint="Specifies the number of statuses to retrieve. May not be greater than 200." />
		<cfargument name="since_id"					required="false" 	default=""			type="string" 	hint="Returns only statuses with an ID greater than (that is, more recent than) the specified ID." />
		<cfargument name="max_id"					required="false" 	default=""			type="string" 	hint="Returns only statuses with an ID less than (that is, older than) or equal to the specified ID." />
		<cfargument name="trim_user"				required="false" 	default=""			type="string" 	hint="When set to either true, t or 1, each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object." />
		<cfargument name="exclude_replies"			required="false" 	default=""			type="string" 	hint="This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets — this is because the count parameter retrieves that many tweets before filtering out retweets and replies." />
		<cfargument name="contributor_details"		required="false" 	default=""			type="string" 	hint="This parameter enhances the contributors element of the status response to include the screen_name of the contributor. By default only the user_id of the contributor is included." />
		<cfargument name="include_entities"			required="false" 	default=""			type="string" 	hint="When set to either true, t or 1, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags. While entities are opt-in on timelines at present, they will be made a default component of output in the future." />
		<cfargument name="checkHeader"				required="false" 	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'statuses/home_timeline.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET statuses/retweets_of_me --->
	<cffunction name="getRetweetsOfMe" access="public" output="false" hint="Returns the most recent tweets authored by the authenticating user that have been retweeted by others. This timeline is a subset of the user's GET statuses/user_timeline.">
		<cfargument name="count" 					required="false" 	default=""			type="string" 	hint="Specifies the number of statuses to retrieve. May not be greater than 200." />
		<cfargument name="since_id"					required="false" 	default=""			type="string" 	hint="Returns only statuses with an ID greater than (that is, more recent than) the specified ID." />
		<cfargument name="max_id"					required="false" 	default=""			type="string" 	hint="Returns only statuses with an ID less than (that is, older than) or equal to the specified ID." />
		<cfargument name="trim_user"				required="false" 	default=""			type="string" 	hint="When set to either true, t or 1, each tweet returned in a timeline will include a user object including only the status authors numerical ID. Omit this parameter to receive the complete user object." />
		<cfargument name="exclude_replies"			required="false" 	default=""			type="string" 	hint="This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets — this is because the count parameter retrieves that many tweets before filtering out retweets and replies." />
		<cfargument name="contributor_details"		required="false" 	default=""			type="string" 	hint="This parameter enhances the contributors element of the status response to include the screen_name of the contributor. By default only the user_id of the contributor is included." />
		<cfargument name="include_entities"			required="false" 	default=""			type="string" 	hint="When set to either true, t or 1, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags. While entities are opt-in on timelines at present, they will be made a default component of output in the future." />
		<cfargument name="include_user_entities"	required="false" 	default=""			type="string" 	hint="The user entities node will be disincluded when set to false." />
		<cfargument name="checkHeader"				required="false" 	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'statuses/retweets_of_me.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End Timelines --->

	<!--- Tweets --->
	<!--- Tweets are the atomic building blocks of Twitter, 140-character status updates with additional associated metadata. People tweet for a variety of reasons about a multitude of topics. --->

	<!--- GET statuses/retweets/:id --->
	<cffunction name="getRetweets" access="public" output="false" hint="Returns up to 100 of the first retweets of a given tweet.">
		<cfargument name="id" 						required="true" 	type="string" 					hint="The numerical ID of the desired status." />
		<cfargument name="count" 					required="false" 	type="Numeric" 	default="100"	hint="Specifies the number of records to retrieve. must be less than or equal to 100." />
		<cfargument name="trim_user" 				required="false" 	type="Boolean"	default="false" hint="When set to true, each tweet returned in a timeline will include a user object including ONLY the status author's numerical ID, otherwise you will receive the complete user object." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'statuses/retweets/' & arguments.id & '.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET statuses/show/:id --->
	<cffunction name="getStatusByID" access="public" output="false" hint="Returns a single status, specified by the id parameter below. The status's author will be returned inline.">
		<cfargument name="id" 						required="true" 	type="String" 					hint="I am the numerical ID of the desired status." />
		<cfargument name="trim_user" 				required="false" 	type="Boolean"	default="false" hint="When set to true, each tweet returned in a timeline will include a user object including ONLY the status author's numerical ID, otherwise you will receive the complete user object." />
		<cfargument name="include_my_retweet" 		required="false" 	type="Boolean"	default="false" hint="When set to true, any Tweets returned that have been retweeted by the authenticating user will include an additional current_user_retweet node, containing the ID of the source status for the retweet." />
		<cfargument name="include_entities" 		required="false" 	type="Boolean"	default="false" hint="The entities node will be disincluded when set to false." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'statuses/show/' & arguments.id & '.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST statuses/destroy/:id --->
	<cffunction name="deleteStatus" access="public" output="false" hint="Destroys the status specified by the required ID parameter. The authenticating user must be the author of the specified status.">
		<cfargument name="id" 						required="true" 	type="string" 					hint="The ID of the status to destroy." />
		<cfargument name="trim_user" 				required="false" 	type="Boolean"	default="false" hint="When set to true, each tweet returned in a timeline will include a user object including ONLY the status author's numerical ID, otherwise you will receive the complete user object." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'statuses/destroy/' & arguments.id & '.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST statuses/update --->
	<cffunction name="postUpdate" access="public" output="false" hint="Updates the authenticating user's status. Request must be a POST.  A status update with text identical to the authenticating user's current status will be ignored to prevent duplicates.">
		<cfargument name="status" 					required="true" 	type="String" 					hint="The text of your status update. URL encode as necessary. Statuses over 140 characters will be forceably truncated." />
		<cfargument name="in_reply_to_status_id" 	required="false" 	type="String" 					hint="The ID of an existing status that the update is in reply to." />
		<cfargument name="lat" 						required="false" 	type="String" 					hint="The location's latitude that this tweet refers to." />
		<cfargument name="long" 					required="false" 	type="String" 					hint="The location's longitude that this tweet refers to." />
		<cfargument name="place_id" 				required="false" 	type="String" 					hint="A place in the world. These IDs can be retrieved from geo/reverse_geocode." />
		<cfargument name="display_coordinates" 		required="false" 	type="String" 					hint="Whether or not to put a pin on the exact coordinates a tweet has been sent from." />
		<cfargument name="trim_user" 				required="false" 	type="Boolean"	default="false" hint="When set to true, each tweet returned in a timeline will include a user object including ONLY the status author's numerical ID, otherwise you will receive the complete user object." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'statuses/update.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST', parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST statuses/retweet/:id --->
	<cffunction name="retweet" access="public" output="false" hint="Retweets a tweet. Requires the id parameter of the tweet you are retweeting. Returns the original tweet with retweet details embedded.">
		<cfargument name="id" 						required="true" 	type="string" 					hint="The numerical ID of the tweet you are retweeting." />
		<cfargument name="trim_user" 				required="false" 	type="Boolean"	default="false" hint="When set to true, each tweet returned in a timeline will include a user object including ONLY the status author's numerical ID, otherwise you will receive the complete user object." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'statuses/retweet/' & arguments.id & '.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST statuses/update_with_media --->
	<cffunction name="postUpdateWithMedia" access="public" output="false" hint="Updates the authenticating user's status. Request must be a POST.  A status update with text identical to the authenticating user's current status will be ignored to prevent duplicates.">
		<cfargument name="status" 					required="true" 	type="String" 					hint="The text of your status update. URL encode as necessary. Statuses over 140 characters will be forceably truncated." />
		<cfargument name="media" 					required="true"		type="string"					hint="Up to max_media_per_upload files may be specified in the request, each named media[]. Supported image formats are PNG, JPG and GIF. Animated GIFs are not supported." />
		<cfargument name="possibly_sensitive"		required="false"	type="boolean"	default="false"	hint="Set to true for content which may not be suitable for every audience." />
		<cfargument name="in_reply_to_status_id" 	required="false" 	type="String" 					hint="The ID of an existing status that the update is in reply to." />
		<cfargument name="lat" 						required="false" 	type="String" 					hint="The location's latitude that this tweet refers to." />
		<cfargument name="long" 					required="false" 	type="String" 					hint="The location's longitude that this tweet refers to." />
		<cfargument name="place_id" 				required="false" 	type="String" 					hint="A place in the world. These IDs can be retrieved from geo/reverse_geocode." />
		<cfargument name="display_coordinates" 		required="false" 	type="String" 					hint="Whether or not to put a pin on the exact coordinates a tweet has been sent from." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = '' />
				<cfset arguments["media[]"] = arguments.media />
				<cfset structDelete(arguments,'media') />
				<cfset strTwitterMethod = getCorrectEndpoint('api') & 'statuses/update_with_media.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST', parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET statuses/oembed --->
	<cffunction name="getOEmbed" access="public" output="false" hint="Returns information allowing the creation of an embedded representation of a Tweet on third party sites. See the oEmbed specification (http://oembed.com/) for information about the response format. While this endpoint allows a bit of customization for the final appearance of the embedded Tweet, be aware that the appearance of the rendered Tweet may change over time to be consistent with Twitter's Display Guidelines. Do not rely on any class or id parameters to stay constant in the returned markup.">
		<cfargument name="id" 						required="false" 	type="string" 	default=""		hint="The Tweet/status ID to return embed code for." />
		<cfargument name="url" 						required="false" 	type="string" 	default=""		hint="The URL of the Tweet/status to be embedded." />
		<cfargument name="maxwidth" 				required="false" 	type="string" 					hint="The maximum width in pixels that the embed should be rendered at. This value is constrained to be between 250 and 550 pixels. Note that Twitter does not support the oEmbed maxheight parameter. Tweets are fundamentally text, and are therefore of unpredictable height that cannot be scaled like an image or video. Relatedly, the oEmbed response will not provide a value for height. Implementations that need consistent heights for Tweets should refer to the hide_thread and hide_media parameters below." />
		<cfargument name="hide_media" 				required="false" 	type="string" 					hint="Specifies whether the embedded Tweet should automatically expand images which were uploaded via POST statuses/update_with_media. When set to either true, t or 1 images will not be expanded. Defaults to false." />
		<cfargument name="hide_thread" 				required="false" 	type="string" 					hint="Specifies whether the embedded Tweet should automatically show the original message in the case that the embedded Tweet is a reply. When set to either true, t or 1 the original Tweet will not be shown. Defaults to false." />
		<cfargument name="omit_script" 				required="false" 	type="string" 					hint="Specifies whether the embedded Tweet HTML should include a <script> element pointing to widgets.js. In cases where a page already includes widgets.js, setting this value to true will prevent a redundant script element from being included. When set to either true, t or 1 the <script> element will not be included in the embed HTML, meaning that pages must include a reference to widgets.js manually. Defaults to false." />
		<cfargument name="align" 					required="false" 	type="string" 					hint="Specifies whether the embedded Tweet should be left aligned, right aligned, or centered in the page. Valid values are left, right, center, and none. Defaults to none, meaning no alignment styles are specified for the Tweet." />
		<cfargument name="related" 					required="false" 	type="string" 					hint="A value for the TWT related parameter, as described in Web Intents. This value will be forwarded to all Web Intents calls. Examples: twitterapi,twittermedia,twitter." />
		<cfargument name="lang" 					required="false" 	type="string" 					hint="Language code for the rendered embed. This will affect the text and localization of the rendered HTML. Examples: fr." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'statuses/oembed.json?' & buildParamString(arguments) />
			<cfif !len(arguments.id) AND !len(arguments.url)>
				<cfabort showerror="Please supply either an id or a URL of the Tweet you wish to embed." />
			</cfif>
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET', parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET statuses/retweeters/ids --->
	<cffunction name="getRetweeterIDs" access="public" output="false" hint="Returns a collection of up to 100 user IDs belonging to users who have retweeted the tweet specified by the id parameter. This method offers similar data to GET statuses/retweets/:id and replaces API v1's GET statuses/:id/retweeted_by/ids method.">
		<cfargument name="id" 				required="true" 	type="string" 					hint="The numerical ID of the desired status." />
		<cfargument name="cursor" 			required="false" 	type="string"	default="-1"	hint="Causes the list of IDs to be broken into pages of no more than 100 IDs at a time. The number of IDs returned is not guaranteed to be 100 as suspended users are filterd out after connections are queried. To begin paging provide a value of -1 as the cursor. The response from the API will include a previous_cursor and next_cursor to allow paging back and forth." />
		<cfargument name="stringify_ids" 	required="false" 	type="boolean"	default="false"	hint="Many programming environments will not consume our ids due to their size. Provide this option to have ids returned as strings instead." />
		<cfargument name="checkHeader"		required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'statuses/retweeters/ids.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End Tweets --->


	<!--- Search --->
	<!--- Find relevant Tweets based on queries performed by your users. --->

	<!--- GET search/tweets --->
	<cffunction name="search" access="public" output="false" hint="Returns tweets that match a specified query.">
		<cfargument name="q" 						required="true" 					type="String" 	hint="Search query. Should be URL encoded. Queries will be limited by complexity." />
		<cfargument name="geocode" 					required="false" 					type="String" 	hint="Returns tweets by users located within a given radius of the given latitude/longitude. The location is preferentially taking from the Geotagging API, but will fall back to their Twitter profile. The parameter value is specified by 'latitude,longitude,radius', where radius units must be specified as either 'mi' (miles) or 'km' (kilometers). Note that you cannot use the near operator via the API to geocode arbitrary locations; however you can use this geocode parameter to search near geocodes directly." />
		<cfargument name="lang" 					required="false" 					type="String" 	hint="Restricts tweets to the given language, given by an ISO 639-1 code." />
		<cfargument name="locale" 					required="false" 					type="String" 	hint="Specify the language of the query you are sending (only ja is currently effective). This is intended for language-specific clients and the default should work in the majority of cases." />
		<cfargument name="result_type" 				required="false" 	default="mixed"	type="String" 	hint="Optional. Specifies what type of search results you would prefer to receive. The current default is 'mixed.' Valid values include: mixed: Include both popular and real time results in the response. recent: return only the most recent results in the response popular: return only the most popular results in the response. http://search.twitter.com/search.json?result_type=mixed http://search.twitter.com/search.json?result_type=recent http://search.twitter.com/search.json?result_type=popular" />
		<cfargument name="count" 						required="false" 					type="String" 	hint="The number of tweets to return per page, up to a max of 100." />
		<cfargument name="until" 					required="false" 					type="String" 	hint="Optional. Returns tweets generated before the given date. Date should be formatted as YYYY-MM-DD." />
		<cfargument name="since_id" 				required="false" 					type="String" 	hint="Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available." />
		<cfargument name="max_id"					required="false" 	default=""			type="string" 	hint="Returns only statuses with an ID less than (that is, older than) or equal to the specified ID." />
		<cfargument name="include_entities" 		required="false" 	default="true"	type="String" 	hint="Optional. When set to either true, t or 1, each tweet will include a node called 'entities,'. This node offers a variety of metadata about the tweet in a discreet structure, including: urls, media and hashtags. Note that user mentions are currently not supported for search and there will be no 'user_mentions' key in the entities map." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod	= getCorrectEndpoint('api') & 'search/tweets.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End of Search --->

	<!--- Direct Messages --->
	<!--- Direct Messages are short, non-public messages sent between two users. Access to Direct Messages is governed by the The Application Permission Model. --->

	<!--- GET direct_messages --->
	<cffunction name="getDirectMessages" access="public" output="false" returntype="Any" hint="Returns a list of the 20 most recent direct messages sent to the authenticating user.  The XML and JSON versions include detailed information about the sending and recipient users.">
		<cfargument name="since_id"					required="false" 	default=""			type="string" 	hint="Returns only direct messages with an ID greater than (that is, more recent than) the specified ID." />
		<cfargument name="max_id"					required="false" 	default=""			type="string" 	hint="Returns only statuses with an ID less than (that is, older than) or equal to the specified ID." />
		<cfargument name="count" 					required="false" 	default="200" 		type="string" 	hint="Specifies the number of statuses to retrieve. May not be greater than 200." />
		<cfargument name="page" 					required="false" 	default="" 			type="string" 	hint="Specifies the page or results to retrieve." />
		<cfargument name="include_entities" 		required="false" 	default="false" 	type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	default="" 			type="string"	hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'direct_messages.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET direct_messages/sent --->
	<cffunction name="getDirectMessagesSent" access="public" output="false" returntype="Any" hint="Returns a list of the 20 most recent direct messages sent by the authenticating user.  The XML and JSON versions include detailed information about the sending and recipient users.">
		<cfargument name="since_id"					required="false" 	default=""			type="string" 	hint="Returns only direct messages with an ID greater than (that is, more recent than) the specified ID." />
		<cfargument name="max_id"					required="false" 	default=""			type="string" 	hint="Returns only statuses with an ID less than (that is, older than) or equal to the specified ID." />
		<cfargument name="count" 					required="false" 	default="200" 		type="string" 	hint="Specifies the number of statuses to retrieve. May not be greater than 200." />
		<cfargument name="page" 					required="false" 	default="" 		t	ype="string" 	hint="Specifies the page or results to retrieve." />
		<cfargument name="include_entities" 		required="false" 	default="false" 	type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'direct_messages/sent.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET direct_messages/show --->
	<cffunction name="getDirectMessagesByID" access="public" output="false" returntype="Any" hint="Returns a single direct message, specified by an id parameter. Like the /1/direct_messages.format request, this method will include the user objects of the sender and recipient.">
		<cfargument name="id"						required="true" 	default=""			type="string" 	hint="The ID of the direct message." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'direct_messages/show.json?id=' & arguments.id />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST direct_messages/destroy --->
	<cffunction name="deleteDM" access="public" output="false" returntype="Any" hint="Destroys the direct message specified in the required ID parameter.  The authenticating user must be the recipient of the specified direct message.">
		<cfargument name="id" 						required="true" 						type="string" 	hint="The ID of the direct message to destroy." />
		<cfargument name="include_entities" 		required="false" 	default="false" 	type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'direct_messages/destroy.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST direct_messages/new --->
	<cffunction name="createDM" access="public" output="false" returntype="Any" hint="Sends a new direct message to the specified user from the authenticating user. Requires both the user and text parameters. Request must be a POST. Returns the sent message in the requested format when successful.">
		<cfargument name="screen_name" 				required="false" 			 			type="string" 	hint="The screen name of the user who should receive the direct message. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="user_id" 					required="false" 			 			type="string" 	hint="The ID of the user who should receive the direct message. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="text" 					required="true" 			 			type="string" 	hint="The text of your direct message.  Under 140 characters." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'direct_messages/new.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End Direct Messages --->

	<!--- Friends & Followers --->
	<!--- Users follow their interests on Twitter through both one-way and mutual following relationships. --->


	<!--- GET friendships/no_retweets/ids --->
	<cffunction name="getFriendsNoRetweetsIDs" access="public" output="false" returntype="Any" hint="Returns a collection of user_ids that the currently authenticated user does not want to receive retweets from. Use POST friendships/update to set the 'no retweets' status for a given user account on behalf of the current user.">
		<cfargument name="stringify_ids" 			required="false" 	default="false"	type="boolean" 	hint="Many programming environments will not consume our ids due to their size. Provide this option to have ids returned as strings instead." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'friendships/no_retweets/ids.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>


	<!--- GET friends/ids --->
	<cffunction name="getFriendsIDs" access="public" output="false" returntype="Any" hint="Returns an array of numeric IDs for every user the specified user is following. This method is powerful when used in conjunction with users/lookup.">
		<cfargument name="user_id" 					required="false" 			 		type="string" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 			 		type="string" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="cursor" 					required="false" 	default="-1"	type="string" 	hint="Causes the list of connections to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filterd out after connections are queried. To begin paging provide a value of -1 as the cursor. The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. If the cursor is not provided the API will attempt to return all IDs. For users with many connections this will probably fail. Querying without the cursor parameter is deprecated and should be avoided. The API is being updated to force the cursor to be -1 if it isn't supplied." />
		<cfargument name="stringify_ids" 			required="false" 	default="false"	type="boolean" 	hint="Many programming environments will not consume our ids due to their size. Provide this option to have ids returned as strings instead." />
		<cfargument name="count" 					required="false" 	default="200" 	type="string" 	hint="Specifies the number of IDs attempt retrieval of, up to a maximum of 5,000 per distinct request. The value of count is best thought of as a limit to the number of results to return. When using the count parameter with this method, it is wise to use a consistent count value across all requests to the same user's collection. Usage of this parameter is encouraged in environments where all 5,000 IDs constitutes too large of a response." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'friends/ids.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET followers/ids --->
	<cffunction name="getFollowersIDs" access="public" output="false" returntype="Any" hint="Returns an array of numeric IDs for every user following the specified user. This method is powerful when used in conjunction with users/lookup.">
		<cfargument name="user_id" 					required="false" 			 		type="string" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 			 		type="string" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="cursor" 					required="false" 	default="-1"	type="string" 	hint="Causes the list of connections to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filterd out after connections are queried. To begin paging provide a value of -1 as the cursor. The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. If the cursor is not provided the API will attempt to return all IDs. For users with many connections this will probably fail. Querying without the cursor parameter is deprecated and should be avoided. The API is being updated to force the cursor to be -1 if it isn't supplied." />
		<cfargument name="stringify_ids" 			required="false" 	default="false"	type="boolean" 	hint="Many programming environments will not consume our ids due to their size. Provide this option to have ids returned as strings instead." />
		<cfargument name="count" 					required="false" 	default="200" 	type="string" 	hint="Specifies the number of IDs attempt retrieval of, up to a maximum of 5,000 per distinct request. The value of count is best thought of as a limit to the number of results to return. When using the count parameter with this method, it is wise to use a consistent count value across all requests to the same user's collection. Usage of this parameter is encouraged in environments where all 5,000 IDs constitutes too large of a response." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'followers/ids.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET friendships/lookup --->
	<cffunction name="getFriendshipsLookup" access="public" output="false" returntype="Any" hint="Returns the relationship of the authenticating user to the comma separated list of up to 100 screen_names or user_ids provided. Values for connections can be: following, following_requested, followed_by, none.">
		<cfargument name="screen_name" 				required="false" 			 		type="string" 	hint="A comma separated list of screen names, up to 100 are allowed in a single request." />
		<cfargument name="user_id" 					required="false" 			 		type="string" 	hint="A comma separated list of user IDs, up to 100 are allowed in a single request." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'friendships/lookup.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET friendships/incoming --->
	<cffunction name="getIncomingFriendships" access="public" output="false" returntype="Any" hint="Returns an array of numeric IDs for every user who has a pending request to follow the authenticating user.">
		<cfargument name="cursor" 					required="false" 			 		type="string" 	hint="Breaks the results into pages. This is recommended for users who are following many users. Provide a value of -1 to begin paging. Provide values as returned in the response body's next_cursor and previous_cursor attributes to page back and forth in the list." />
		<cfargument name="stringify_ids" 			required="false" 	default="false"	type="boolean" 	hint="Many programming environments will not consume our ids due to their size. Provide this option to have ids returned as strings instead." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'friendships/incoming.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET friendships/outgoing --->
	<cffunction name="getOutgoingFriendships" access="public" output="false" returntype="Any" hint="Returns an array of numeric IDs for every protected user for whom the authenticating user has a pending follow request.">
		<cfargument name="cursor" 					required="false" 			 		type="string" 	hint="Breaks the results into pages. This is recommended for users who are following many users. Provide a value of -1 to begin paging. Provide values as returned in the response body's next_cursor and previous_cursor attributes to page back and forth in the list." />
		<cfargument name="stringify_ids" 			required="false" 	default="false"	type="boolean" 	hint="Many programming environments will not consume our ids due to their size. Provide this option to have ids returned as strings instead." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'friendships/outgoing.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST friendships/create --->
	<cffunction name="followUser" access="public" output="false" returntype="Any" hint="Allows the authenticating users to follow the user specified in the ID parameter.  Returns the befriended user in the requested format when successful.  Returns a string describing the failure condition when unsuccessful. If you are already friends with the user an HTTP 403 will be returned.">
		<cfargument name="user_id" 					required="false" 			 			type="string" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name"				required="false" 			 			type="string" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="follow" 					required="false" 						type="string" 	hint="Enable notifications for the target user." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'friendships/create.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST friendships/destroy --->
	<cffunction name="unfollowUser" access="public" output="false" returntype="Any" hint="Allows the authenticating users to unfollow the user specified in the ID parameter. Returns the unfollowed user in the requested format when successful.  Returns a string describing the failure condition when unsuccessful.">
		<cfargument name="user_id" 					required="false" 			 			type="string" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name"				required="false" 			 			type="string" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="include_entities" 		required="false" 	default="false" 	type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'friendships/destroy.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST friendships/update --->
	<cffunction name="updateFriendships" access="public" output="false" returntype="Any" hint="Allows one to enable or disable retweets and device notifications from the specified user.">
		<cfargument name="user_id" 					required="false" 			 			type="string" 	hint="Specifies the ID of the user to befriend. Helpful for disambiguating when a valid user ID is also a valid screen name. The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name"				required="false" 			 			type="string" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="device" 					required="false" 	default="false" 	type="Boolean"	hint="Enable/disable device notifications from the target user." />
		<cfargument name="retweets" 				required="false" 	default="false" 	type="Boolean"	hint="Enable/disable device notifications from the target user." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'friendships/update.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET friendships/show --->
	<cffunction name="showFriendships" access="public" output="false" returntype="Any" hint="Returns detailed information about the relationship between two users.">
		<cfargument name="source_id" 				required="false" 			 		type="string" 	hint="The user_id of the subject user." />
		<cfargument name="source_screen_name" 		required="false" 			 		type="string" 	hint="The screen_name of the subject user." />
		<cfargument name="target_id" 				required="false" 			 		type="string" 	hint="The user_id of the target user." />
		<cfargument name="target_screen_name" 		required="false" 			 		type="string" 	hint="The screen_name of the target user." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'friendships/show.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET friends/list --->
	<cffunction name="getFriendsList" access="public" output="false" returntype="Any" hint="Returns a cursored collection of user objects for every user the specified user is following (otherwise known as their 'friends'). At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 20 users and multiple 'pages' of results can be navigated through using the next_cursor value in subsequent requests. ">
		<cfargument name="user_id" 					required="false" 			 		type="string" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 			 		type="string" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="cursor" 					required="false" 	default="-1"	type="string" 	hint="Causes the list of results to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filterd out after connections are queried. To begin paging provide a value of -1 as the cursor. The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. If the cursor is not provided the API will attempt to return all IDs. For users with many connections this will probably fail. Querying without the cursor parameter is deprecated and should be avoided. The API is being updated to force the cursor to be -1 if it isn't supplied." />
		<cfargument name="count" 					required="false" 	default="20"	type="string" 	hint="The number of users to return per page, up to a maximum of 200. Defaults to 20." />
		<cfargument name="skip_status" 				required="false" 					type="boolean" 	hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="include_user_entities"	required="false"					type="boolean"	hint="The user object entities node will be disincluded when set to false." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'friends/list.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET followers/list --->
	<cffunction name="getFollowersList" access="public" output="false" returntype="Any" hint="Returns a cursored collection of user objects for users following the specified user. At this time, results are ordered with the most recent following first — however, this ordering is subject to unannounced change and eventual consistency issues. Results are given in groups of 20 users and multiple 'pages' of results can be navigated through using the next_cursor value in subsequent requests. ">
		<cfargument name="user_id" 					required="false" 			 		type="string" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 			 		type="string" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="cursor" 					required="false" 	default="-1"	type="string" 	hint="Causes the list of results to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filterd out after connections are queried. To begin paging provide a value of -1 as the cursor. The response from the API will include a previous_cursor and next_cursor to allow paging back and forth. If the cursor is not provided the API will attempt to return all IDs. For users with many connections this will probably fail. Querying without the cursor parameter is deprecated and should be avoided. The API is being updated to force the cursor to be -1 if it isn't supplied." />
		<cfargument name="count" 					required="false" 	default="20"	type="string" 	hint="The number of users to return per page, up to a maximum of 200. Defaults to 20." />
		<cfargument name="skip_status" 				required="false" 					type="boolean" 	hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="include_user_entities"	required="false"					type="boolean"	hint="The user object entities node will be disincluded when set to false." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'followers/list.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End Friends & Followers --->


	<!--- Users --->
	<!--- Users are at the center of everything Twitter: they follow, they favorite, and tweet & retweet. --->

	<!--- GET account/settings --->
	<cffunction name="getAccountSettings" access="public" output="false" hint="Returns settings (including current trend, geo and sleep time information) for the authenticating user.">
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'account/settings.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET account/verify_credentials --->
	<cffunction name="verifyCredentials" access="public" output="false" returntype="any" hint="Returns an HTTP 200 OK response code and a representation of the requesting user if authentication was successful; returns a 401 status code and an error message if not.  Use this method to test if supplied user credentials are valid.">
		<cfargument name="include_entities" 		required="false" 	default="false" 	type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	default="" 			type="string"	hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'account/verify_credentials.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST account/settings --->
	<cffunction name="updateAccountSettings" access="public" output="false" returntype="any" hint="Updates the authenticating user's settings.">
		<cfargument name="trend_location_woeid" 	required="true" 	default="" 			type="string" 	hint="The Yahoo! Where On Earth ID to use as the user's default trend location. Global information is available by using 1 as the WOEID. The woeid must be one of the locations returned by GET trends/available." />
		<cfargument name="sleep_time_enabled" 		required="false" 	default="" 			type="string"	hint="When set to true, t or 1, will enable sleep time for the user. Sleep time is the time when push or SMS notifications should not be sent to the user." />
		<cfargument name="start_sleep_time" 		required="false" 	default="" 			type="string"	hint="The hour that sleep time should begin if it is enabled. The value for this parameter should be provided in ISO8601 format (i.e. 00-23). The time is considered to be in the same timezone as the user's time_zone setting." />
		<cfargument name="end_sleep_time" 			required="false" 	default="" 			type="string"	hint="The hour that sleep time should end if it is enabled. The value for this parameter should be provided in ISO8601 format (i.e. 00-23). The time is considered to be in the same timezone as the user's time_zone setting." />
		<cfargument name="time_zone" 				required="false" 	default="" 			type="string"	hint="The timezone dates and times should be displayed in for the user. The timezone must be one of the Rails TimeZone names. Example: Europe/Copenhagen, Pacific/Tongatapu" />
		<cfargument name="lang" 					required="false" 	default="" 			type="string"	hint="The language which Twitter should render in for this user. The language must be specified by the appropriate two letter ISO 639-1 representation. Currently supported languages are provided by GET help/languages." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'account/settings.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST account/update_profile --->
	<cffunction name="updateProfile" access="public" output="false" returntype="any" hint="Sets values that users are able to set under the 'Account' tab of their settings page. Only the parameters specified will be updated.">
		<cfargument name="name" 					required="false" 						type="string" 	hint="Full name associated with the profile. Maximum of 20 characters." />
		<cfargument name="url" 						required="false" 						type="string" 	hint="URL associated with the profile. Will be prepended with 'http://' if not present. Maximum of 100 characters." />
		<cfargument name="location" 				required="false" 						type="string" 	hint="The city or country describing where the user of the account is located. The contents are not normalized or geocoded in any way. Maximum of 30 characters." />
		<cfargument name="description" 				required="false" 						type="string" 	hint="A description of the user owning the account. Maximum of 160 characters." />
		<cfargument name="include_entities" 		required="false" 	default="false" 	type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	default="" 			type="string"	hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'account/update_profile.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST account/update_profile_background_image --->
	<cffunction name="updateProfileBackgroundImage" access="public" output="false" returntype="any" hint="Updates the authenticating user's profile background image. This method can also be used to enable or disable the profile background image. Although each parameter is marked as optional, at least one of image, tile or use must be provided when making this request.">
		<cfargument name="image" 					required="false" 	default="" 			type="string" 	hint="The background image for the profile, base64-encoded. Must be a valid GIF, JPG, or PNG image of less than 800 kilobytes in size. Images with width larger than 2048 pixels will be forcibly scaled down. The image must be provided as raw multipart data, not a URL." />
		<cfargument name="tile" 					required="false" 	default="" 			type="string" 	hint="Whether or not to tile the background image. If set to true, t or 1 the background image will be displayed tiled. The image will not be tiled otherwise." />
		<cfargument name="include_entities" 		required="false" 	default="false" 	type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	default="" 			type="string"	hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="use" 						required="false" 	default="" 			type="string"	hint="Determines whether to display the profile background image or not. When set to true, t or 1 the background image will be displayed if an image is being uploaded with the request, or has been uploaded previously. An error will be returned if you try to use a background image when one is not being uploaded or does not exist. If this parameter is defined but set to anything other than true, t or 1, the background image will stop being used." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'account/update_profile_background_image.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST account/update_profile_colors --->
	<cffunction name="updateProfileColors" access="public" output="false" returntype="any" hint="Sets one or more hex values that control the color scheme of the authenticating user's profile page on twitter.com. Each parameter's value must be a valid hexidecimal value, and may be either three or six characters (ex: ##fff or ##ffffff).">
		<cfargument name="profile_background_color" 	required="false" 	default="" 			type="string" 	hint="Must be a valid hexidecimal value, and may be either three or six characters (ex: fff or ffffff)" />
		<cfargument name="profile_link_color" 			required="false" 	default="" 			type="string" 	hint="Must be a valid hexidecimal value, and may be either three or six characters (ex: fff or ffffff)" />
		<cfargument name="profile_sidebar_border_color" required="false" 	default="" 			type="string" 	hint="Must be a valid hexidecimal value, and may be either three or six characters (ex: fff or ffffff)" />
		<cfargument name="profile_sidebar_fill_color" 	required="false" 	default="" 			type="string" 	hint="Must be a valid hexidecimal value, and may be either three or six characters (ex: fff or ffffff)" />
		<cfargument name="profile_text_color" 			required="false" 	default="" 			type="string" 	hint="Must be a valid hexidecimal value, and may be either three or six characters (ex: fff or ffffff)" />
		<cfargument name="include_entities" 			required="false" 	default="false" 	type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 					required="false" 	default="" 			type="string"	hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"					required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'account/update_profile_colors.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST account/update_profile_image --->
	<cffunction name="updateProfileImage" access="public" output="false" returntype="any" hint="Updates the authenticating user's profile image. Note that this method expects raw multipart data, not a URL to an image. This method asynchronously processes the uploaded file before updating the user's profile image URL. You can either update your local cache the next time you request the user's information, or, at least 5 seconds after uploading the image, ask for the updated URL using GET users/profile_image/:screen_name.">
		<cfargument name="image" 					required="true" 	default="" 			type="any" 		hint="The avatar image for the profile, base64-encoded. Must be a valid GIF, JPG, or PNG image of less than 700 kilobytes in size. Images with width larger than 500 pixels will be scaled down. Animated GIFs will be converted to a static GIF of the first frame, removing the animation." />
		<cfargument name="include_entities" 		required="false" 	default="false" 	type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	default="" 			type="string"	hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'account/update_profile_image.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET blocks/list --->
	<cffunction name="getBlockedUsers" access="public" output="false" returntype="Any" hint="Returns an array of user objects that the authenticating user is blocking. Consider using GET blocks/blocking/ids with GET users/lookup instead of this method.">
		<cfargument name="include_entities" 		required="false" 	type="Boolean"	default="true"	hint="The entities node will not be included when set to false." />
		<cfargument name="skip_status" 				required="false" 	type="string"	default=""		hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="cursor" 					required="false" 	type="string"	default=""		hint="Causes the list of blocked users to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filtered out after connections are queried. If no cursor is provided, a value of -1 will be assumed, which is the first 'page.' The response from the API will include a previous_cursor and next_cursor to allow paging back and forth." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'blocks/list.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET blocks/ids --->
	<cffunction name="getBlockingIDs" access="public" output="false" returntype="Any" hint="Returns a collection of user objects that the authenticating user is blocking.">
		<cfargument name="stringify_ids" 			required="false" 	type="Boolean"	default="false" 	hint="Many programming environments will not consume our Tweet ids due to their size. Provide this option to have ids returned as strings instead." />
		<cfargument name="cursor" 					required="false" 	type="string"	default=""			hint="Causes the list of blocked users to be broken into pages of no more than 5000 IDs at a time. The number of IDs returned is not guaranteed to be 5000 as suspended users are filtered out after connections are queried. If no cursor is provided, a value of -1 will be assumed, which is the first 'page.' The response from the API will include a previous_cursor and next_cursor to allow paging back and forth." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" 	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'blocks/ids.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST blocks/create --->
	<cffunction name="blockUser" access="public" output="false" returntype="Any" hint="Blocks the user specified in the ID parameter as the authenticating user. Destroys a friendship to the blocked user if it exists. Returns the blocked user in the requested format when successful">
		<cfargument name="user_id" 					required="false" 	type="string" 					hint="The ID of the potentially blocked user. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 	type="string" 					hint="The screen name of the potentially blocked user. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="include_entities" 		required="false" 	type="Boolean"					hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	type="string"	default=""		hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'blocks/create.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST blocks/destroy --->
	<cffunction name="unblockUser" access="public" output="false" returntype="Any" hint="Un-blocks the user specified in the ID parameter for the authenticating user.  Returns the un-blocked user in the requested format when successful.">
		<cfargument name="user_id" 					required="false" 	type="string" 					hint="The ID of the potentially blocked user. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 	type="string" 					hint="The screen name of the potentially blocked user. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="include_entities" 		required="false" 	type="Boolean"					hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	type="string"	default=""		hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'blocks/destroy.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET users/lookup --->
	<cffunction name="lookupUser" access="public" output="false" returntype="any" hint="Return up to 100 users worth of extended information, specified by either ID, screen name, or combination of the two. The author's most recent status (if the authenticating user has permission) will be returned inline.">
		<cfargument name="user_id" 					required="false" 	type="string" 					hint="A comma separated list of user IDs, up to 100 are allowed in a single request." />
		<cfargument name="screen_name" 				required="false" 	type="string" 					hint="A comma separated list of screen names, up to 100 are allowed in a single request." />
		<cfargument name="include_entities" 		required="false" 	type="Boolean"	default="false" hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'users/lookup.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET users/show --->
	<cffunction name="getUserDetails" access="public" output="false" returntype="any" hint="Returns extended information of a given user, specified by ID or screen name as per the required id parameter. The author's most recent status will be returned inline.">
		<cfargument name="user_id" 					required="false" 	type="string" 					hint="The ID of the user for whom to return results for. Either an id or screen_name is required for this method." />
		<cfargument name="screen_name" 				required="false" 	type="string" 					hint="The screen name of the user for whom to return results for. Either a id or screen_name is required for this method." />
		<cfargument name="include_entities" 		required="false" 	type="Boolean"	default="false" hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'users/show.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET users/search --->
	<cffunction name="searchForUser" access="public" output="false" returntype="any" hint="Runs a search for users similar to Find People button on Twitter.com. The results returned by people search on Twitter.com are the same as those returned by this API request. Note that unlike GET search, this method does not support any operators. Only the first 1000 matches are available.">
		<cfargument name="q"						required="true"				 		type="string" 	hint="The query to run against people search" />
		<cfargument name="page"						required="false"	default="1" 	type="string" 	hint="Specifies the page of results to retrieve." />
		<cfargument name="count"					required="false"	default="20" 	type="string" 	hint="The number of potential user results to retrieve per page. This value has a maximum of 20." />
		<cfargument name="include_entities" 		required="false" 	default="false" type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'users/search.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET users/contributees --->
	<cffunction name="getUserContributees" access="public" output="false" returntype="any" hint="Returns an array of users that the specified user can contribute to.">
		<cfargument name="user_id" 					required="false" 	type="string" 					hint="The ID of the user for whom to return results for. Either an id or screen_name is required for this method." />
		<cfargument name="screen_name" 				required="false" 	type="string" 					hint="The screen name of the user for whom to return results for. Either a id or screen_name is required for this method." />
		<cfargument name="include_entities" 		required="false" 	type="Boolean"	default="false" hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	type="string"	default=""		hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'users/contributees.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET users/contributors --->
	<cffunction name="getUserContributers" access="public" output="false" returntype="any" hint="Returns an array of users who can contribute to the specified account.">
		<cfargument name="user_id" 					required="false" 	type="string" 					hint="The ID of the user for whom to return results for. Either an id or screen_name is required for this method." />
		<cfargument name="screen_name" 				required="false" 	type="string" 					hint="The screen name of the user for whom to return results for. Either a id or screen_name is required for this method." />
		<cfargument name="include_entities" 		required="false" 	type="Boolean"	default="false" hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	type="string"	default=""		hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false" hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'users/contributors.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End Users --->

	<!--- Suggested Users --->
	<!--- Categorical organization of users that others may be interested to follow. --->

	<!--- GET users/suggestions/:slug --->
	<cffunction name="getUserSuggestionsInCategory" access="public" output="false" returntype="any" hint="Access the users in a given category of the Twitter suggested user list. It is recommended that end clients cache this data for no more than one hour.">
		<cfargument name="slug" 					required="true" 	type="String" 						hint="The short name of list or a category." />
		<cfargument name="lang" 					required="false" 	type="String" 	default="en"		hint="Restricts the suggested categories to the requested language. The language must be specified by the appropriate two letter ISO 639-1 representation." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false"		hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'users/suggestions/' & arguments.slug & '.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET users/suggestions --->
	<cffunction name="getUserSuggestions" access="public" output="false" returntype="any" hint="Access to Twitter's suggested user list. This returns the list of suggested user categories. The category can be used in GET users/suggestions/:slug to get the users in that category.">
		<cfargument name="lang" 					required="false" 	type="String" 	default="en"		hint="Restricts the suggested categories to the requested language. The language must be specified by the appropriate two letter ISO 639-1 representation." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false"		hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'users/suggestions.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET users/suggestions/:slug/members.format --->
	<cffunction name="getUserSuggestionsInCategoryWithStatus" access="public" output="false" returntype="any" hint="Access the users in a given category of the Twitter suggested user list and return their most recent status if they are not a protected user.">
		<cfargument name="slug" 					required="true" 	type="String" 						hint="The short name of list or a category." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false"		hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = '' />
				<cfscript>
					strTwitterMethod = getCorrectEndpoint('api') & 'users/suggestions' & '/' & arguments.slug;
					strTwitterMethod = strTwitterMethod & '/members.json';
				</cfscript>
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End Suggested Users --->

	<!--- Favourites --->
	<!--- Users favorite tweets to give recognition to awesome tweets, to curate the best of Twitter, to save for reading later, and a variety of other reasons. Likewise, developers make use of "favs" in many different ways. --->

	<!--- GET favorites/list --->
	<cffunction name="favorites" access="public" output="false" returntype="Any" hint="Returns the 20 most recent Tweets favorited by the authenticating or specified user.">
		<cfargument name="user_id" 					required="false" 						type="string" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 						type="string" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="count" 					required="false" 	default="200" 		type="string" 	hint="Specifies the number of statuses to retrieve. May not be greater than 200." />
		<cfargument name="since_id"					required="false" 	default=""			type="string" 	hint="Returns only direct messages with an ID greater than (that is, more recent than) the specified ID." />
		<cfargument name="max_id"					required="false" 	default=""			type="string" 	hint="Returns only statuses with an ID less than (that is, older than) or equal to the specified ID." />
		<cfargument name="include_entities" 		required="false" 	default="false" 	type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'favorites/list.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST favorites/destroy --->
	<cffunction name="removeFromFavorites" access="public" output="false" returntype="Any" hint="Un-favorites the status specified in the ID parameter as the authenticating user. Returns the un-favorited status in the requested format when successful.">
		<cfargument name="id" 						required="true" 					type="string" 	hint="The numerical ID of the desired status." />
		<cfargument name="include_entities" 		required="false" 	default="false" type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset arguments.action = 'destroy' />
		<cfreturn handleFavorites(argumentCollection=arguments) />
	</cffunction>

	<!--- POST favorites/create --->
	<cffunction name="addToFavorites" access="public" output="false" returntype="Any" hint="Favorites the status specified in the ID parameter as the authenticating user. Returns the favorite status when successful.">
		<cfargument name="id" 						required="true" 						type="string" 	hint="The numerical ID of the desired status." />
		<cfargument name="include_entities" 		required="false" 	default="false" 	type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="checkHeader"				required="false"	default="false"		type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset arguments.action = 'create' />
		<cfreturn handleFavorites(argumentCollection=arguments) />
	</cffunction>

	<cffunction name="handleFavorites" access="private" output="false" returntype="Any" hint="I am the private method that handles the 'favorites' methods.">
		<cfargument name="id" 						required="true"  	type="string" 					hint="The numerical ID of the desired status." />
		<cfargument name="include_entities" 		required="false" 	type="Boolean"					hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="action" 					required="true"  	type="String" 					hint="I am the action to take on this favorite. CREATE or DESTROY." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'favorites/' & arguments.action & '.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End Favourites --->

	<!--- List resources : list-specific methods --->
	<!--- Lists are collections of tweets, culled from a curated list of Twitter users. List timeline methods include tweets by all members of a list. --->

	<!--- GET lists/list --->
	<cffunction name="getAllLists" access="public" output="false" hint="Returns all lists the authenticating or specified user subscribes to, including their own. The user is specified using the user_id or screen_name parameters. If no user is given, the authenticating user is used.">
		<cfargument name="user_id" 					required="false" 						type="string" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 						type="string" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="checkHeader"				required="false"	default="false" 	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/list.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET lists/statuses --->
	<cffunction name="getListStatuses" access="public" output="false" hint="Returns tweet timeline for members of the specified list. Historically, retweets were not available in list timeline responses but you can now use the include_rts=true parameter to additionally receive retweet objects.">
		<cfargument name="list_id" 					required="true" 	default=""			type="string" 	hint="The numerical id of the list." />
		<cfargument name="slug" 					required="false" 	default=""			type="string" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="owner_screen_name" 		required="false" 	default=""			type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""			type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="since_id" 				required="false" 	default=""			type="string" 	hint="Returns results with an ID greater than (that is, more recent than) the specified ID. There are limits to the number of Tweets which can be accessed through the API. If the limit of Tweets has occured since the since_id, the since_id will be forced to the oldest ID available." />
		<cfargument name="max_id" 					required="false" 	default=""			type="string" 	hint="Returns results with an ID less than (that is, older than) or equal to the specified ID." />
		<cfargument name="count" 					required="false" 	default=""			type="string" 	hint="Specifies the number of results to retrieve per page." />
		<cfargument name="include_entities" 		required="false" 	default=""			type="string" 	hint="When set to either true, t or 1, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags. While entities are opt-in on timelines at present, they will be made a default component of output in the future" />
		<cfargument name="include_rts" 				required="false" 	default=""			type="string" 	hint="When set to either true, t or 1, the list timeline will contain native retweets (if they exist) in addition to the standard stream of tweets. The output format of retweeted tweets is identical to the representation you see in home_timeline." />
		<cfargument name="checkHeader"				required="false"	default="false" 	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/statuses.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST lists/members/destroy --->
	<cffunction name="deleteListMember" access="public" output="false" hint="Removes the specified member from the list. The authenticated user must be the list's owner to remove members from the list.">
		<cfargument name="list_id" 					required="false" 	default=""		type="string" 	hint="The numerical id of the list." />
		<cfargument name="slug" 					required="false"	default="" 		type="String" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="user_id" 					required="false" 	default=""		type="String" 	hint="The ID of the user to remove from the list. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 	default=""		type="String" 	hint="The screen name of the user for whom to remove from the list. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="owner_screen_name" 		required="false" 	default=""		type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""		type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/members/destroy.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='DELETE',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET lists/memberships --->
	<cffunction name="getListMemberships" access="public" output="false" hint="List the lists the specified user has been added to.">
		<cfargument name="user_id" 					required="false" 	default=""		type="String" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 	default=""		type="String" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="cursor" 					required="false" 	default="-1" 	type="string" 	hint="Optional. Breaks the results into pages. A single page contains 20 lists. Provide a value of -1 to begin paging. Provide values as returned to in the response body's next_cursor and previous_cursor attributes to page back and forth in the list." />
		<cfargument name="filter_to_owned_lists"	required="false"	default="false" type="boolean"	hint="When set to true, t or 1, will return just lists the authenticating user owns, and the user represented by user_id or screen_name is a member of." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & getAuthDetails().getUserAccountName() & '/lists/memberships.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET lists/subscribers --->
	<cffunction name="getListSubscribers" access="public" output="false" hint="Returns the subscribers of the specified list.">
		<cfargument name="list_id" 					required="true" 	default="" 		type="string" 	hint="The numerical id of the list." />
		<cfargument name="slug" 					required="false"	default="" 		type="String" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="owner_screen_name" 		required="false" 	default=""		type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""		type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="cursor" 					required="false" 	default="-1" 	type="string" 	hint="Breaks the results into pages. A single page contains 20 lists. Provide a value of -1 to begin paging. Provide values as returned to in the response body's next_cursor and previous_cursor attributes to page back and forth in the list." />
		<cfargument name="include_entities" 		required="false" 					type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	default="" 		type="string"	hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/subscribers.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST lists/subscribers/create --->
	<cffunction name="addListSubscriber" access="public" output="false" hint="Subscribes the authenticated user to the specified list.">
		<cfargument name="owner_screen_name" 		required="false" 	default=""		type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""		type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="list_id" 					required="false" 	default="" 		type="string" 	hint="The id or slug of the list." />
		<cfargument name="slug" 					required="false"	default="" 		type="String" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/subscribers/create.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET lists/subscribers/show --->
	<cffunction name="showListSubscriber" access="public" output="false" hint="Check if the specified user is a subscriber of the specified list. Returns the user if they are subscriber.">
		<cfargument name="owner_screen_name" 		required="false" 	default=""		type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""		type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="list_id" 					required="true" 	default="" 		type="string" 	hint="The numerical id of the list." />
		<cfargument name="slug" 					required="false"	default="" 		type="String" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="user_id" 					required="false" 	default=""		type="String" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 	default=""		type="String" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="include_entities" 		required="false" 					type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	default="" 		type="string"	hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/subscribers/show.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST lists/subscribers/destroy --->
	<cffunction name="deleteListSubscriber" access="public" output="false" hint="Unsubscribes the authenticated user form the specified list.">
		<cfargument name="list_id" 					required="false" 	default=""		type="string" 	hint="The numerical id of the list." />
		<cfargument name="slug" 					required="false"	default="" 		type="String" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="owner_screen_name" 		required="false" 	default=""		type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""		type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'list/subscribers/destroy.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='DELETE',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST lists/members/create_all --->
	<cffunction name="addMultipleMembersToList" access="public" output="false" hint="Adds multiple members to a list, by specifying a comma-separated list of member ids or screen names. The authenticated user must own the list to be able to add members to it. Note that lists can't have more than 500 members, and you are limited to adding up to 100 members to a list at a time with this method.">
		<cfargument name="list_id" 					required="false" 	default=""		type="string" 	hint="The id or slug of the list." />
		<cfargument name="slug" 					required="false"	default="" 		type="String" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="user_id" 					required="false" 	default=""		type="String" 	hint="A comma separated list of user IDs, up to 100 are allowed in a single request." />
		<cfargument name="screen_name" 				required="false" 	default=""		type="String" 	hint="A comma separated list of screen names, up to 100 are allowed in a single request." />
		<cfargument name="owner_screen_name" 		required="false" 	default=""		type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""		type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/subscribers/create_all.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET lists/members/show --->
	<cffunction name="checkListMember" access="public" output="false" hint="Check if the specified user is a member of the specified list.">
		<cfargument name="list_id" 					required="false" 	default="" 		type="string" 	hint="The id or slug of the list." />
		<cfargument name="slug" 					required="false"	default="" 		type="String" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="user_id" 					required="false" 	default=""		type="String" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 	default=""		type="String" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="owner_screen_name" 		required="false" 	default=""		type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""		type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="include_entities" 		required="false" 					type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="skip_status" 				required="false" 	default="" 		type="string"	hint="When set to either true, t or 1 statuses will not be included in the returned user objects." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/members/show.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET lists/members --->
	<cffunction name="getListMembers" access="public" output="false" hint="Returns the members of the specified list.">
		<cfargument name="list_id" 					required="true" 					type="string" 	hint="The id or slug of the list." />
		<cfargument name="cursor" 					required="false" 	default="-1"	type="string" 	hint="Breaks the results into pages. A single page contains 20 lists. Provide a value of -1 to begin paging. Provide values as returned to in the response body's next_cursor and previous_cursor attributes to page back and forth in the list." />
		<cfargument name="include_entities" 		required="false" 					type="Boolean"	hint="When set to true, each tweet will include a node called 'entities'. This node offers a variety of metadata about the tweet in a discreet structure, including: user_mentions, urls, and hashtags." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/members.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST lists/members/create --->
	<cffunction name="addMemberToList" access="public" output="false" hint="Add a member to a list. The authenticated user must own the list to be able to add members to it. Lists are limited to having 500 members.">
		<cfargument name="list_id" 					required="true" 					type="string" 	hint="The numerical id of the list." />
		<cfargument name="slug" 					required="true"		default=""		type="String" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="user_id" 					required="false" 	default=""		type="String" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 	default=""		type="String" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="owner_screen_name" 		required="false" 	default=""		type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""		type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/members/create.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST lists/destroy --->
	<cffunction name="deleteList" access="public" output="false" hint="Deletes the specified list. The authenticated user must own the list to be able to destroy it.">
		<cfargument name="owner_screen_name" 		required="false" 	default=""		type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""		type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="list_id" 					required="false" 	default=""		type="string" 	hint="The numerical id of the list." />
		<cfargument name="slug" 					required="false"	default="" 		type="String" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/destroy.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='DELETE',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST lists/update --->
	<cffunction name="updateList" access="public" output="false" hint="Updates the specified list. The authenticated user must own the list to be able to update it.">
		<cfargument name="list_id" 					required="false" 	default=""			type="string" 	hint="The numerical id of the list." />
		<cfargument name="slug" 					required="false"	default="" 			type="String" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="name" 					required="false" 	default=""			type="string" 	hint="The name for the list." />
		<cfargument name="mode" 					required="false" 	default="public"	type="string" 	hint="Whether your list is public or private. Values can be public or private. Lists are public by default if no mode is specified." />
		<cfargument name="description" 				required="false" 	default=""			type="string" 	hint="The description of the list you are creating." />
		<cfargument name="owner_screen_name" 		required="false" 	default=""			type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""			type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="checkHeader"				required="false"	default="false" 	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/update.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST lists/create --->
	<cffunction name="createList" access="public" output="false" hint="Creates a new list for the authenticated user. Note that you can't create more than 20 lists per account.">
		<cfargument name="name" 					required="true" 						type="string" 	hint="The name of the list you are creating." />
		<cfargument name="mode" 					required="false" 	default="public"	type="string" 	hint="Whether your list is public or private. Values can be public or private. Lists are public by default if no mode is specified." />
		<cfargument name="description" 				required="false" 						type="string" 	hint="The description of the list you are creating." />
		<cfargument name="checkHeader"				required="false"	default="false" 	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/create.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET lists/show --->
	<cffunction name="getListByID" access="public" output="false" hint="Returns the specified list. Private lists will only be shown if the authenticated user owns the specified list.">
		<cfargument name="list_id" 					required="false" 	default=""			type="string" 	hint="The numerical id of the list." />
		<cfargument name="slug" 					required="false"	default="" 			type="String" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that you'll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="owner_screen_name" 		required="false" 	default=""			type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""			type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/show.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET lists/subscriptions --->
	<cffunction name="getListSubscriptions" access="public" output="false" hint="Obtain a collection of the lists the specified user is subscribed to, 20 lists per page by default. Does not include the user's own lists.">
		<cfargument name="user_id" 					required="false" 	default=""		type="string" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 	default=""		type="string" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="count" 					required="false" 	default="20" 	type="string" 	hint="The amount of results to return per page. Defaults to 20. Maximum of 1,000 when using cursors." />
		<cfargument name="cursor" 					required="false" 	default="-1" 	type="string" 	hint="Breaks the results into pages. A single page contains 20 lists. Provide a value of -1 to begin paging. Provide values as returned to in the response body's next_cursor and previous_cursor attributes to page back and forth in the list." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/subscriptions.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST lists/members/destroy_all --->
	<cffunction name="destoryAllListMembers" access="public" output="false" hint="Removes multiple members from a list, by specifying a comma-separated list of member ids or screen names. The authenticated user must own the list to be able to remove members from it. Note that lists can't have more than 500 members, and you are limited to removing up to 100 members to a list at a time with this method. Please note that there can be issues with lists that rapidly remove and add memberships. Take care when using these methods such that you are not too rapidly switching between removals and adds on the same list.">
		<cfargument name="list_id" 					required="false" 	default=""			type="string" 	hint="The numerical id of the list." />
		<cfargument name="slug" 					required="false"	default="" 			type="string" 	hint="You can identify a list by its slug instead of its numerical id. If you decide to do so, note that youll also have to specify the list owner using the owner_id or owner_screen_name parameters." />
		<cfargument name="user_id" 					required="false" 	default=""			type="string" 	hint="TA comma separated list of user IDs, up to 100 are allowed in a single request." />
		<cfargument name="screen_name" 				required="false" 	default=""			type="string" 	hint="A comma separated list of screen names, up to 100 are allowed in a single request." />
		<cfargument name="owner_screen_name" 		required="false" 	default=""			type="string" 	hint="The screen name of the user who owns the list being requested by a slug." />
		<cfargument name="owner_id" 				required="false" 	default=""			type="string" 	hint="The user ID of the user who owns the list being requested by a slug." />
		<cfargument name="checkHeader"				required="false"	default="false" 	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/members/destroy_all.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET lists/ownerships --->
	<cffunction name="getListOwnerships" access="public" output="false" hint="Returns the lists owned by the specified Twitter user. Private lists will only be shown if the authenticated user is also the owner of the lists.">
		<cfargument name="user_id" 					required="false" 	default=""		type="string" 	hint="The ID of the user for whom to return results for. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 	default=""		type="string" 	hint="The screen name of the user for whom to return results for. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="count" 					required="false" 	default="20" 	type="string" 	hint="The amount of results to return per page. Defaults to 20. Maximum of 1,000 when using cursors." />
		<cfargument name="cursor" 					required="false" 	default="-1" 	type="string" 	hint="Breaks the results into pages. A single page contains 20 lists. Provide a value of -1 to begin paging. Provide values as returned to in the response body's next_cursor and previous_cursor attributes to page back and forth in the list." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'lists/ownerships.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End of List resources : list-specific methods --->

	<!--- Saved Searches --->
	<!--- Allows users to save references to search criteria for reuse later. --->

	<!--- GET saved_searches/list --->
	<cffunction name="getSavedSearches" access="public" output="false" returntype="Any" hint="Returns the authenticated user's saved search queries.">
		<cfargument name="checkHeader"				required="false"	default="false" 	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'saved_searches/list.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET saved_searches/show/:id --->
	<cffunction name="getSearchByID" access="public" output="false" returntype="Any" hint="Retrieve the information for the saved search represented by the given id. The authenticating user must be the owner of saved search ID being requested.">
		<cfargument name="id" 						required="true" 			 			type="string" 	hint="The id of the saved search to be retrieved." />
		<cfargument name="checkHeader"				required="false"	default="false" 	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'saved_searches/show/' & arguments.id & '.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST saved_searches/create --->
	<cffunction name="saveThisSearch" access="public" output="false" returntype="Any" hint="Create a new saved search for the authenticated user. A user may only have 25 saved searches.">
		<cfargument name="query" 					required="true" 			 			type="string" 	hint="The query of the search the user would like to save." />
		<cfargument name="checkHeader"				required="false"	default="false" 	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'saved_searches/create.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST saved_searches/destroy/:id --->
	<cffunction name="deleteSavedSearch" access="public" output="false" returntype="Any" hint="Destroys a saved search for the authenticating user. The authenticating user must be the owner of saved search id being destroyed.">
		<cfargument name="id" 						required="true" 			 			type="string" 	hint="The id of the saved search to be deleted." />
		<cfargument name="checkHeader"				required="false"	default="false" 	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'saved_searches/destroy/' & arguments.id & '.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End Saved Searches --->

	<!--- Places & Geo --->
	<!--- Users tweet from all over the world. These methods allow you to attach location data to tweets and discover tweets & locations. --->

	<!--- GET geo/id/:place_id --->
	<cffunction name="geoGetPlaceByID" access="public" output="false" returntype="Any" hint="Returns all the information about a known place.">
		<cfargument name="place_id" 		required="true" 	type="String" 				 	hint="A place in the world. These IDs can be retrieved from the geoReversGeocode() method." />
		<cfargument name="checkHeader"		required="false"	type="boolean"	default="false"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'geo/id/' & arguments.place_id & '.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET geo/reverse_geocode --->
	<cffunction name="geoReverseGeocode" access="public" output="false" returntype="Any" hint="Given a latitude and a longitude, searches for up to 20 places that can be used as a place_id when updating a status. This request is an informative call and will deliver generalized results about geography.">
		<cfargument name="lat" 						required="true" 	type="String" 				 	hint="The latitude to search around. This parameter will be ignored unless it is inside the range -90.0 to +90.0 (North is positive) inclusive. It will also be ignored if there isn't a corresponding long parameter." />
		<cfargument name="long" 					required="true" 	type="String" 				 	hint="The longitude to search around. The valid ranges for longitude is -180.0 to +180.0 (East is positive) inclusive. This parameter will be ignored if outside that range, if it is not a number, if geo_enabled is disabled, or if there not a corresponding lat parameter." />
		<cfargument name="granularity" 				required="false" 	type="String" 				 	hint="This is the minimal granularity of place types to return and must be one of: poi, neighborhood, city, admin or country. If no granularity is provided for the request neighborhood is assumed. Setting this to city, for example, will find places which have a type of city, admin or country." />
		<cfargument name="accuracy" 				required="false" 	type="String" 				 	hint="A hint on the 'region' in which to search. If a number, then this is a radius in meters, but it can also take a string that is suffixed with ft to specify feet. If this is not passed in, then it is assumed to be 0m. If coming from a device, in practice, this value is whatever accuracy the device has measuring its location (whether it be coming from a GPS, WiFi triangulation, etc.)." />
		<cfargument name="max_results" 				required="false" 	type="String" 				 	hint="A hint as to the number of results to return. This does not guarantee that the number of results returned will equal max_results, but instead informs how many 'nearby' results to return. Ideally, only pass in the number of places you intend to display to the user here." />
		<cfargument name="callback" 				required="false" 	type="String" 				 	hint="If supplied, the response will use the JSONP format with a callback of the given name." />
		<cfargument name="checkHeader"				required="false"	type="boolean" default="false"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'geo/reverse_geocode.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET geo/search --->
	<cffunction name="geoSearch" access="public" output="false" returntype="Any" hint="Search for places that can be attached to a statuses/update. Given a latitude and a longitude pair, an IP address, or a name, this request will return a list of all the valid places that can be used as the place_id when updating a status.">
		<cfargument name="lat" 						required="false" 	type="String" 					hint="The latitude to search around. This parameter will be ignored unless it is inside the range -90.0 to +90.0 (North is positive) inclusive. It will also be ignored if there isn't a corresponding long parameter." />
		<cfargument name="long" 					required="false" 	type="String" 					hint="The longitude to search around. The valid ranges for longitude is -180.0 to +180.0 (East is positive) inclusive. This parameter will be ignored if outside that range, if it is not a number, if geo_enabled is disabled, or if there not a corresponding lat parameter." />
		<cfargument name="query" 					required="false" 	type="String" 					hint="Free-form text to match against while executing a geo-based query, best suited for finding nearby locations by name. Remember to URL encode the query." />
		<cfargument name="ip" 						required="false" 	type="String" 					hint="An IP address. Used when attempting to fix geolocation based off of the user's IP address." />
		<cfargument name="granularity" 				required="false" 	type="String" 					hint="This is the minimal granularity of place types to return and must be one of: poi, neighborhood, city, admin or country. If no granularity is provided for the request neighborhood is assumed. Setting this to city, for example, will find places which have a type of city, admin or country." />
		<cfargument name="accuracy" 				required="false" 	type="String" 					hint="A hint on the 'region' in which to search. If a number, then this is a radius in meters, but it can also take a string that is suffixed with ft to specify feet. If this is not passed in, then it is assumed to be 0m. If coming from a device, in practice, this value is whatever accuracy the device has measuring its location (whether it be coming from a GPS, WiFi triangulation, etc.)." />
		<cfargument name="max_results" 				required="false" 	type="String" 					hint="A hint as to the number of results to return. This does not guarantee that the number of results returned will equal max_results, but instead informs how many 'nearby' results to return. Ideally, only pass in the number of places you intend to display to the user here." />
		<cfargument name="contained_within" 		required="false" 	type="String" 					hint="This is the place_id which you would like to restrict the search results to. Setting this value means only places within the given place_id will be found. Specify a place_id. For example, to scope all results to places within 'San Francisco, CA USA', you would specify a place_id of '5a110d312052166f'." />
		<cfargument name="street_address" 			required="false" 	type="String" 					hint="This parameter searches for places which have this given street address. There are other well-known, and application specific attributes available. Custom attributes are also permitted." />
		<cfargument name="callback" 				required="false" 	type="String" 					hint="If supplied, the response will use the JSONP format with a callback of the given name." />
		<cfargument name="checkHeader"				required="false"	type="boolean" default="false"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'geo/search.json' />
				<cfscript>
					if(structKeyExists(arguments, 'street_address') AND len(arguments.street_address)) {
					arguments["attribute:street_address"] = arguments.street_address;
					structDelete(arguments,'street_address');
					}
				</cfscript>
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET geo/similar_places --->
	<cffunction name="geoSimilarPlaces" access="public" output="false" returntype="Any" hint="Locates places near the given coordinates which are similar in name.">
		<cfargument name="lat" 						required="true" 	type="String" 					hint="The latitude to search around. This parameter will be ignored unless it is inside the range -90.0 to +90.0 (North is positive) inclusive. It will also be ignored if there isn't a corresponding long parameter." />
		<cfargument name="long" 					required="true" 	type="String" 					hint="The longitude to search around. The valid ranges for longitude is -180.0 to +180.0 (East is positive) inclusive. This parameter will be ignored if outside that range, if it is not a number, if geo_enabled is disabled, or if there not a corresponding lat parameter." />
		<cfargument name="name" 					required="true" 	type="String" 					hint="The name a place is known as." />
		<cfargument name="contained_within" 		required="false" 	type="String" 					hint="This is the place_id which you would like to restrict the search results to. Setting this value means only places within the given place_id will be found. Specify a place_id. For example, to scope all results to places within 'San Francisco, CA USA', you would specify a place_id of '5a110d312052166f'." />
		<cfargument name="street_address" 			required="false" 	type="String" 					hint="This parameter searches for places which have this given street address. There are other well-known, and application specific attributes available. Custom attributes are also permitted." />
		<cfargument name="callback" 				required="false" 	type="String" 					hint="If supplied, the response will use the JSONP format with a callback of the given name." />
		<cfargument name="checkHeader"				required="false"	type="boolean" default="false"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'geo/similar_places.json' />
				<cfscript>
					if(structKeyExists(arguments, 'street_address') AND len(arguments.street_address)) {
					arguments["attribute:street_address"] = arguments.street_address;
					structDelete(arguments,'street_address');
					}
				</cfscript>
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- POST geo/place --->
	<cffunction name="createPlace" access="public" output="false" hint="Creates a new place object at the given latitude and longitude. Before creating a place you need to query GET geo/similar_places with the latitude, longitude and name of the place you wish to create. The query will return an array of places which are similar to the one you wish to create, and a token. If the place you wish to create isn't in the returned array you can use the token with this method to create a new one.">
		<cfargument name="name" 					required="true" 	 				type="string" 	hint="The name a place is known as. Example Twitter%20HQ." />
		<cfargument name="contained_within" 		required="true" 					type="string" 	hint="The place_id within which the new place can be found. Try and be as close as possible with the containing place. For example, for a room in a building, set the contained_within as the building place_id." />
		<cfargument name="token"					required="false" 					type="string" 	hint="The token found in the response from geo/similar_places." />
		<cfargument name="lat"						required="false" 					type="string" 	hint="The latitude the place is located at. This parameter will be ignored unless it is inside the range -90.0 to +90.0 (North is positive) inclusive. It will also be ignored if there isn't a corresponding long parameter." />
		<cfargument name="long"						required="false" 					type="string" 	hint="The longitude the place is located at. The valid ranges for longitude is -180.0 to +180.0 (East is positive) inclusive. This parameter will be ignored if outside that range, if it is not a number, if geo_enabled is disabled, or if there not a corresponding lat parameter." />
		<cfargument name="street_address" 			required="false" 					type="String" 	hint="This parameter searches for places which have this given street address. There are other well-known, and application specific attributes available. Custom attributes are also permitted." />
		<cfargument name="callback"					required="false" 					type="string" 	hint="If supplied, the response will use the JSONP format with a callback of the given name." />
		<cfargument name="checkHeader"				required="false"	default="false" type="boolean"	hint="If set to true, I will abort the request and return the headers and sent information for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'geo/place.json' />
				<cfscript>
					if(structKeyExists(arguments, 'street_address') AND len(arguments.street_address)) {
					arguments["attribute:street_address"] = arguments.street_address;
					structDelete(arguments,'street_address');
					}
				</cfscript>
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End Places & Geo --->

	<!--- Trends --->
	<!--- With so many tweets from so many users, themes are bound to arise from the zeitgeist. The Trends methods allow you to explore what's trending on Twitter. --->

	<!--- GET trends/place --->
	<cffunction name="trendByLocation" access="public" output="false" returntype="Any" hint="Returns the top 10 trending topics for a specific location Twitter has trending topic information for. The response is an array of 'trend' objects that encode the name of the trending topic, the query parameter that can be used to search for the topic on Search, and the direct URL that can be issued against Search. This information is cached for five minutes, and therefore users are discouraged from querying these endpoints faster than once every five minutes.  Global trends information is also available from this API by using a WOEID of 1.">
		<cfargument name="woeid" 					required="true" 			   		type="string" 	hint="The WOEID of the location to be querying for. (a Yahoo! Where On Earth ID)" />
		<cfargument name="exclude" 					required="false" 			   		type="string" 	hint="Setting this equal to hashtags will remove all hashtags from the trends list." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'trends/place.json?id=' &  arguments.woeid />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET trends/available --->
	<cffunction name="availableTrends" access="public" output="false" returntype="Any" hint="Returns the locations that Twitter has trending topic information for. The response is an array of 'locations' that encode the location's WOEID (a Yahoo! Where On Earth ID) and some other human-readable information such as a canonical name and country the location belongs in.">
		<cfargument name="lat" 						required="false" 	default="" 		type="String" 	hint="If passed in conjunction with long, then the available trend locations will be sorted by distance to the lat and long passed in.  The sort is nearest to furthest." />
		<cfargument name="long" 					required="false" 	default="" 		type="String" 	hint="If passed in conjunction with lat, then the available trend locations will be sorted by distance to the lat and long passed in.  The sort is nearest to furthest." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'trends/available.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- GET trends/closest --->
	<cffunction name="closestTrends" access="public" output="false" returntype="Any" hint="Returns the locations that Twitter has trending topic information for, closest to a specified location. The response is an array of 'locations' that encode the location's WOEID and some other human-readable information such as a canonical name and country the location belongs in.">
		<cfargument name="lat" 						required="false" 	default="" 		type="String" 	hint="If passed in conjunction with long, then the available trend locations will be sorted by distance to the lat and long passed in.  The sort is nearest to furthest." />
		<cfargument name="long" 					required="false" 	default="" 		type="String" 	hint="If passed in conjunction with lat, then the available trend locations will be sorted by distance to the lat and long passed in.  The sort is nearest to furthest." />
		<cfargument name="checkHeader"				required="false"	default="false"	type="boolean"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'trends/closest.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET',parameters=arguments, checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End Trends --->

	<!--- Spam Reporting --->
	<!--- These methods are used to report user accounts as spam accounts. --->

	<!--- POST users/report_spam --->
	<cffunction name="reportSpam" access="public" output="false" hint="The user specified in the id is blocked by the authenticated user and reported as a spammer.">
		<cfargument name="user_id" 					required="false" 	type="string" 					hint="The ID of the user you want to report as a spammer. Helpful for disambiguating when a valid user ID is also a valid screen name." />
		<cfargument name="screen_name" 				required="false" 	type="string" 					hint="The ID or screen_name of the user you want to report as a spammer. Helpful for disambiguating when a valid screen name is also a user ID." />
		<cfargument name="checkHeader"				required="false"	type="boolean"	default="false"	hint="If set to true, I will abort the request and return the response headers for debugging." />
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
			<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'users/report_spam.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='POST',parameters=arguments,checkHeader=arguments.checkHeader) />
	</cffunction>

	<!--- End Spam Reporting --->

	<!--- Help / Configuration methods --->
	<!--- These methods assist you in working & debugging with the Twitter API. --->

	<!--- GET help/configuration --->
	<cffunction name="configuration" access="public" output="false" hint="Returns the current configuration used by Twitter including twitter.com slugs which are not usernames, maximum photo resolutions, and t.co URL lengths. It is recommended applications request this endpoint when they are loaded, but no more than once a day.">
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
		<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'help/configuration.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET') />
	</cffunction>

	<!--- GET help/languages --->
	<cffunction name="languages" access="public" output="false" hint="Returns the list of languages supported by Twitter along with their ISO 639-1 code. The ISO 639-1 code is the two letter value to use if you include lang with any of your requests.">
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
		<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'help/languages.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET') />
	</cffunction>

	<!--- GET help/privacy --->
	<cffunction name="getPrivacyPolicy" access="public" output="false" returntype="Any" hint="Returns Twitter's Privacy Policy in the requested format.">
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
		<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'help/privacy.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET') />
	</cffunction>

	<!--- GET help/tos --->
	<cffunction name="getLegalTOS" 	access="public" output="false" returntype="Any" hint="Returns Twitter's' Terms of Service in the requested format. These are not the same as the Developer Terms of Service.">
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
		<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'help/tos.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET') />
	</cffunction>

	<!--- GET application/rate_limit_status --->
	<cffunction name="getApplicationRateLimitStatus" access="public" output="false" hint="Returns the current rate limits for methods belonging to the specified resource families.">
		<cfargument name="timeout" required="false"	type="string" default="#variables.instance.timeout#" hint="An optional timeout value, in seconds, that is the maximum time the cfhttp requests can take. If the time-out passes without a response, ColdFusion considers the request to have failed." />
		<cfset var strTwitterMethod = getCorrectEndpoint('api') & 'application/rate_limit_status.json' />
		<cfreturn genericAuthenticationMethod(timeout=getTimeout(), httpURL=strTwitterMethod,httpMethod='GET') />
	</cffunction>

	<!--- End of Help / Configuration methods --->

	<!--- @Anywhere methods --->

	<cffunction name="twitAnywhere" access="public" output="false" hint="I build the JS script block and populate the required calls to the @Anywhere service.">
		<cfargument name="params" 				required="true" 	type="struct" 					hint="I am a structure of method names and their parameters that you send through to this function." />
		<cfargument name="includHeaderScript" 	required="false" 	type="boolean" 	default="true"  hint="I include the required remote Javascript file with your consumer key into the page." />
			<cfset var strReturn 		= 	'' />
			<cfset var strContent		=	'' />
			<cfset var methodResult		=	'' />
				<!--- Loop over the provided params to invoke the methods --->
				<cfloop collection="#arguments.params#" item="local.item">
					<cftry>
						<cfset structInsert(arguments.params[item],'individual',false) />
						<!--- Make the call to the method and assign the results to the content variable. --->
						<cfinvoke method="#item#" argumentcollection="#arguments.params[item]#" returnvariable="methodResult" />
						<cfset strContent = strContent & methodResult />
						<!--- Just to catch any erroneous method names that may be passed through. --->
						<cfcatch></cfcatch>
					</cftry>
				</cfloop>
				<cfif arguments.includHeaderScript>
					<cfset strReturn	=	anywhereScriptHeader() />
				</cfif>
				<cfset strReturn		=	strReturn & getOpeningScript() & strContent & getClosingScript() />
 		<cfreturn strReturn />
	</cffunction>

	<cffunction name="linkifyUsers" access="public" output="false" hint="">
		<cfargument name="htmlSection" 	required="false" type="string" 	default="" 		hint="The ID of the document element to apply the linkifyUsers to. If left blank, all Twitter names within the document will be linkified." />
		<cfargument name="className" 	required="false" type="string" 	default="" 		hint="By default, linkifying usernames will wrap matched names in an anchor element with a class of 'twitter-anywhere-user'. Here you can specify an alternate class name to adjust to suit your CSS." />
		<cfargument name="individual"	required="false" type="boolean"	default="true" 	hint="If set to true, this method will generate purely the function to deal with the linkification of users." />
			<cfset var strReturn		=	'' />
				<cfif arguments.individual>
					<cfset strReturn	=	anywhereScriptHeader() & chr(10) & getOpeningScript() />
				</cfif>
				<cfset strReturn		=	strReturn & 'T' />
				<cfif len(arguments.htmlSection)>
					<cfset strReturn 	= strReturn & '("###arguments.htmlSection#")' />
				</cfif>
				<cfset strReturn		=	strReturn & '.linkifyUsers(_className_);' />
				<cfif len(arguments.className)>
					<cfset strReturn 	= replaceNoCase(strReturn,"_className_","{ className: '#arguments.className#' }") />
				<cfelse>
					<cfset strReturn 	= replaceNoCase(strReturn,'_className_',' ') />
				</cfif>
				<cfif arguments.individual>
					<cfset strReturn	=	strReturn & chr(10) & getClosingScript() />
				</cfif>
		<cfreturn strReturn />
	</cffunction>

	<cffunction name="hovercards" access="public" output="false" hint="Hovercard is a small, context-aware tooltip that provides access to data about a particular Twitter user. Hovercards also allows a user to take action upon a Twitter user such as following and unfollowing, as well as toggling device updates.">
		<cfargument name="htmlSection" 	required="false" type="string" 	default="" 		hint="The ID of the document element to apply the hovercard to. If left blank, all Twitter names within the document will be converted." />
		<cfargument name="linkify" 		required="false" type="boolean" default="true" 	hint="If Twitter names have already been linkified elsewhere, set to false." />
		<cfargument name="infer" 		required="false" type="boolean" default="false"	hint="Use the infer option to trigger Hovercards on elements whose text contains a Twitter username. When the infer option is used, the hovercards method will not call the linkifyUsers method. This is useful when Twitter usernames have already been linkified by some other means. For example: <a ...>Follow @coldfumonkeh on Twitter!</a>." />
		<cfargument name="expanded" 	required="false" type="boolean" default="false"	hint="Set to true to render the hovercards in expanded state by default." />
		<cfargument name="individual"	required="false" type="boolean"	default="true" 	hint="If set to true, this method will generate purely the function to deal with the hovercards." />
			<cfset var strReturn		=	'' />
			<cfset var strParamList		=	'' />
				<cfif arguments.individual>
					<cfset strReturn	=	anywhereScriptHeader() & chr(10) & getOpeningScript() />
				</cfif>
				<cfset strReturn		=	strReturn & 'T' />
				<cfif !arguments.linkify><cfset strParamList 	= listAppend(strParamList,'linkify: #arguments.linkify#') /></cfif>
				<cfif arguments.infer><cfset strParamList 		= listAppend(strParamList,'infer: #arguments.infer#') /></cfif>
				<cfif arguments.expanded><cfset strParamList 	= listAppend(strParamList,'expanded: #arguments.expanded#') /></cfif>
				<cfif len(arguments.htmlSection)>
					<cfset strReturn 	= strReturn & '("###arguments.htmlSection#")' />
				</cfif>
				<cfset strReturn 		= strReturn & '.hovercards({ #strParamList# });' />
				<cfif arguments.individual>
					<cfset strReturn	=	strReturn & chr(10) & getClosingScript() />
				</cfif>
		<cfreturn strReturn />
	</cffunction>

	<cffunction name="followButton" access="public" output="false" hint="Follow buttons make it easy to provide users of your site or application with a way to follow users on Twitter.">
		<cfargument name="htmlSection" 	required="true" 	type="string" 					hint="The ID of the document element to apply the follow button to." />
		<cfargument name="twittername" 	required="true" 	type="string" 					hint="The Twitter username you wish the follow button to follow." />
		<cfargument name="individual"	required="false" 	type="boolean"	default="true" 	hint="If set to true, this method will generate purely the function to deal with the follow button." />
			<cfset var strReturn		=	'' />
				<cfif arguments.individual>
					<cfset strReturn	=	anywhereScriptHeader() & chr(10) & getOpeningScript() />
				</cfif>
				<cfset strReturn		=	strReturn & 'T' />
				<cfif len(arguments.htmlSection)>
					<cfset strReturn 	= strReturn & '("###arguments.htmlSection#")' />
				</cfif>
				<cfset strReturn 		= strReturn & '.followButton("#arguments.twittername#");' />
				<cfif arguments.individual>
					<cfset strReturn	=	strReturn & chr(10) & getClosingScript() />
				</cfif>
		<cfreturn strReturn />
	</cffunction>

	<cffunction name="tweetBox" access="public" output="false" hint="The Tweet Box allows Twitter users to tweet directly from within your web site or web application.">
		<cfargument name="htmlSection" 		required="true" 	type="string" 								hint="The ID of the document element to apply the tweetbox to." />
		<cfargument name="counter" 			required="true" 	type="boolean" 	default="true" 				hint="Display a counter in the Tweet Box for counting characters. True or false." />
		<cfargument name="height" 			required="false" 	type="numeric" 	default="65" 				hint="The height of the Tweet Box in pixels." />
		<cfargument name="width" 			required="false" 	type="numeric" 	default="515" 				hint="The width of the Tweet Box in pixels." />
		<cfargument name="label" 			required="false" 	type="string"	default="What's happening?" hint="The text above the Tweet Box, a call to action." />
		<cfargument name="defaultContent" 	required="false" 	type="string"	default="" 					hint="Pre-populated text in the Tweet Box. Useful for an @mention, a ##hashtag, a link, etc." />
		<cfargument name="onTweet"			required="false"	type="string"	default=""					hint="Specify a listener for when a tweet is sent from the Tweet Box. The listener receives two arguments: a plaintext tweet and an HTML tweet." />
		<cfargument name="data"				required="false"	type="struct"	default="#structNew()#"		hint="Key + value pairs representing any of the additional metadata that can be set when updating a user's status. See the REST API documentation for a complete list of the possible options." />
		<cfargument name="individual"		required="false" 	type="boolean"	default="true" 				hint="If set to true, this method will generate purely the function to deal with the tweetbox." />
			<cfset var strReturn	=	'' />
				<cfif arguments.individual>
					<cfset strReturn	=	anywhereScriptHeader() & chr(10) & getOpeningScript() />
				</cfif>
				<cfset strReturn	=	strReturn & 'T("###arguments.htmlSection#").tweetBox({
											counter: 		#arguments.counter#,
											height: 		#arguments.height#,
											width: 			#arguments.width#,
											label: 			"#arguments.label#",
											defaultContent: "#arguments.defaultContent#",
											onTweet:		function(plaintext, html) {
												#arguments.onTweet#
											},
											data:			#lcase(serializeJSON(arguments.data))#
										});' />
				<cfif arguments.individual>
					<cfset strReturn	=	strReturn & chr(10) & getClosingScript() />
				</cfif>

		<cfreturn strReturn />
	</cffunction>

	<cffunction name="login" access="public" output="false" hint="The 'Connect with Twitter' button provides a method for users to authenticate securely with Twitter, yielding your application with an access token for use in API calls.">
		<cfargument name="htmlSection" 	required="true" 	type="string" 						hint="The ID of the document element to apply the login button to." />
		<cfargument name="size" 		required="false" 	type="string" 	default="medium" 	hint="A range of sizes to choose from: small, medium, large, xlarge. 'medium' is the default size." />
		<cfargument name="authComplete"	required="false"	type="string"	default=""			hint="I am the JS code to run when authorisation is complete." />
		<cfargument name="signOut"		required="false"	type="string"	default=""			hint="I am the JS code to run when a user signs out." />
		<cfargument name="custom"		required="false"	type="boolean"	default="false"		hint="If set to true, the @Anywhere signIn() method will be applied to the supplied htmlSection DOM element." />
		<cfargument name="individual"	required="false" 	type="boolean"	default="true" 		hint="If set to true, this method will generate purely the function to deal with the login button." />
			<cfset var strReturn 		= '' />
				<cfif arguments.individual>
					<cfset strReturn	=	anywhereScriptHeader() & chr(10) & getOpeningScript() />
				</cfif>
				<cfif arguments.custom>
					<cfset strReturn	=	strReturn & 'document.getElementById("#arguments.htmlSection#").onclick = function () { T.signIn(); };' />
				<cfelse>
					<cfset strReturn	=	strReturn & 'T("###arguments.htmlSection#").connectButton({
												size: "#arguments.size#",
												authComplete: function(user) {
											        // triggered when auth completed successfully
											        #arguments.authComplete#
  												},
  												signOut: function(user) {
										        	// triggered when user logs out
										        	#arguments.signOut#
										        }
  											});' />
				</cfif>
				<cfif arguments.individual>
					<cfset strReturn	=	strReturn & chr(10) & getClosingScript() />
				</cfif>
		<cfreturn strReturn />
	</cffunction>

	<cffunction name="anywhereScriptHeader" access="public" output="false" returntype="String" hint="I return the required script tag for the @Anywhere api.">
		<cfargument name="consumerKey" required="true" type="string" default="#getAuthDetails().getConsumerKey()#" />
		<cfreturn "<script src='http://platform.twitter.com/anywhere.js?id=#arguments.consumerKey#&v=1' type='text/javascript'></script>" />
	</cffunction>

	<cffunction name="getOpeningScript" access="private" otput="false" hint="I return the opening portion of the @Anywhere script.">
		<cfreturn '<script type="text/javascript">twttr.anywhere(function (T) {' />
	</cffunction>

	<cffunction name="getClosingScript" access="private" otput="false" hint="I return the closing portion of the @Anywhere script.">
		<cfreturn '});</script>' />
	</cffunction>

	<!--- End of @Anywhere methods --->

</cfcomponent>
