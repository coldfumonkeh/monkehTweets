<!---
Name: base.cfc
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


Revision history
================

16.06.2010 - Version 1.1

	- amended format variable to ensure lowercase

10/09/2010 - Version 1.2

	- added OAuth authentication, dealing with HMAC-SHA1 encryption
	- removed deprecated methods from the base component
	- poured blood, sweat and tears (including numerous cups of coffee) into this.
	
13/09/2010 - Version 1.2.1

	- amended callbackURL overwrite issue when authenticating
	- added oauth_verifier to authentication request
	
14/09/2010 - Version 1.2.2

	- revised CF8 inline arrays as arguments to methods
	
21/09/2010 - Version 1.2.4

	- revised a variable naming clash with Railo 3 (thanks to Aaron Longnion)

--->
<cfcomponent displayname="base" output="false" hint="I am the base class containing util methods and common functions">

	<cfset variables.instance = StructNew() />
	
	<cffunction name="init" access="public" output="false" returntype="any" hint="I am the constructor method for the base class">
		<cfargument name="authDetails" 	required="true" 	type="any" 						hint="I am the authDetails class." />
		<cfargument name="parseResults"	required="false" 	type="boolean" default="false" 	hint="A boolean value to determine if the output data is parsed or returned as a string" />
			<cfscript>
				variables.instance.baseURL 		= 'http://twitter.com/';
				variables.instance.apiURL		= 'http://api.twitter.com/1/';
				variables.instance.searchURL 	= 'http://search.twitter.com/';
				variables.instance.parseResults = arguments.parseResults;
				
				// OAuth specific constuctors
				
				variables.instance.consumerKey 		= arguments.authDetails.getConsumerKey();
				variables.instance.consumerSecret 	= arguments.authDetails.getConsumerSecret();				
				
				variables.instance.reqEndpoint		= 'https://api.twitter.com/oauth/request_token';
				variables.instance.authEndpoint		= 'https://api.twitter.com/oauth/authorize';
				variables.instance.accessEndpoint	= 'http://api.twitter.com/oauth/access_token';
				
				variables.instance.reqSigMethodSHA	= CreateObject("component", "oauth.oauthsignaturemethod_hmac_sha1");
				
				variables.instance.consumerToken	= CreateObject("component", "oauth.oauthconsumer").init(
																	  	sKey 	= arguments.authDetails.getConsumerKey(),
																		sSecret = arguments.authDetails.getConsumerSecret()
																	);
				
			</cfscript>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getparseResults" access="public" output="false" returntype="string" hint="I return the parseResults value for use in the method calls.">
		<cfreturn variables.instance.parseResults />
	</cffunction>
	
	<cffunction name="getbaseURL" access="public" output="false" returntype="string" hint="I return the base url for use in the method calls.">
		<cfreturn variables.instance.baseURL />
	</cffunction>
	
	<cffunction name="getapiURL" access="public" output="false" returntype="string" hint="I return the api url for use in the method calls.">
		<cfreturn variables.instance.apiURL />
	</cffunction>
	
	<cffunction name="getsearchURL" access="public" output="false" returntype="string" hint="I return the search url for use in the method calls.">
		<cfreturn variables.instance.searchURL />
	</cffunction>
	
	<cffunction name="matchCount" access="public" output="false" returntype="Array" hint="I run a regex match on the count parameter">
		<cfargument name="count" required="false" default="200" type="string" hint="Specifies the number of statuses to retrieve. May not be greater than 200." />
			<cfset var arrMatch = arrayNew(1) />
			<cfset arrMatch = REMatch('^([01]?[0-9]?[0-9]|2[0][0])$',arguments.count) />
		<cfreturn arrMatch />
	</cffunction>
	
	<cffunction name="handleReturnFormat" access="public" output="false" hint="I handle how the data is returned based upon the provided format">
		<cfargument name="data" 	required="true" 				type="string" hint="The data returned from the API." />
		<cfargument name="format" 	required="true" default="xml" 	type="string" hint="The return format of the data. Commonly XML, JSON or in some cases RSS and ATOM." />
			<cfswitch expression="#arguments.format#">
				<cfcase value="atom">
					<cfif getparseResults()>
						<cfreturn XmlParse(arguments.data) />
					<cfelse>
						<cfreturn arguments.data />
					</cfif>
				</cfcase>
				<cfcase value="rss">
					<cfif getparseResults()>
						<cfreturn XmlParse(arguments.data) />
					<cfelse>
						<cfreturn arguments.data />
					</cfif>
				</cfcase>
				<cfcase value="json">
					<cfif getparseResults()>
						<cfreturn DeserializeJSON(arguments.data) />
					<cfelse>
						<cfreturn serializeJSON(DeserializeJSON(arguments.data)) />
					</cfif>
				</cfcase>
				<cfdefaultcase>
					<cfif getparseResults()>
						<cfreturn XmlParse(arguments.data) />
					<cfelse>
						<cfreturn arguments.data />
					</cfif>
				</cfdefaultcase>
			</cfswitch>
		<cfabort>
	</cffunction>
	
	<cffunction name="buildParamString" access="public" output="false" returntype="String" hint="I loop through a struct to convert to query params for the URL">
		<cfargument name="argScope" required="true" type="struct" hint="I am the struct containing the method params" />
			<cfset var strURLParam 	= '' />
			<cfloop collection="#arguments.argScope#" item="key">
				<cfif len(arguments.argScope[key])>
					<cfif listLen(strURLParam)>
						<cfset strURLParam = strURLParam & '&' />
					</cfif>	
					<cfset strURLParam = strURLParam & lcase(key) & '=' & arguments.argScope[key] />
				</cfif>
			</cfloop>
		<cfreturn strURLParam />
	</cffunction>
	
	<!--- return the correct endpoint for use within the API --->
	<cffunction name="getCorrectEndpoint" access="package" output="false" hint="I return the correct URL string which creates the beginning of the API endpoint.">
		<cfargument name="endpointRef"	required="true" type="string" hint="String representing which URL to use. Base, API or Search" />
			<cfset var strMethod = '' />
				<cfswitch expression="#arguments.endpointRef#">
					<cfcase value="base"><cfset strMethod 	= getBaseURL() /></cfcase>
					<cfcase value="api"><cfset strMethod 	= getapiURL() /></cfcase>
					<cfcase value="search"><cfset strMethod = getsearchURL() /></cfcase>
				</cfswitch>
			<cfreturn strMethod />
	</cffunction>
	
	<cffunction name="makeGetCall" access="package" output="false" returntype="Any" hint="I am the function that makes the cfhttp GET requests">
		<cfargument name="URLEndpoint" 	required="true" type="string" hint="The URL to call for the GET request." />
			<cfset var cfhttp	 = '' />
			<cfhttp url="#arguments.URLEndpoint#" method="get" useragent="monkehTweets" />
			<cfset checkStatusCode(cfhttp) />
		<cfreturn cfhttp.FileContent />
	</cffunction>
	
	<cffunction name="checkStatusCode" access="public" output="false" hint="I check the status code from all API calls">
		<cfargument name="data" required="true" type="struct" hint="The data returned from the API." />
			<cfset var strSuccess 		= false />
			<cfset var strMessage 		= '' />
			<cfset var stuErrInfo		= {} />
			<cfset var arrErrSearch		= [] />
			<cfswitch expression="#arguments.data.Statuscode#">
				<cfcase value="200 OK">
					<cfset strSuccess = true />
					<cfset strMessage = 'Success!' />
				</cfcase>
				<cfcase value="304 Not Modified">
					<cfset strSuccess = false />
					<cfset strMessage = 'There was no new data to return.' />
				</cfcase>
				<cfcase value="400 Bad Request">
					<cfset strSuccess = false />
					<cfset strMessage = 'The request was invalid.' />
				</cfcase>
				<cfcase value="401 Unauthorized">
					<cfset strSuccess = false />
					<cfset strMessage = 'Authentication credentials were missing or incorrect.' />
				</cfcase>
				<cfcase value="403 Forbidden">
					<cfset strSuccess = false />
					<cfset strMessage = 'The request is understood, but it has been refused.' />
				</cfcase>
				<cfcase value="404 Not Found">
					<cfset strSuccess = false />
					<cfset strMessage = 'The URI requested is invalid or the resource requested, such as a user, does not exist.' />
				</cfcase>
				<cfcase value="406 Not Acceptable">
					<cfset strSuccess = false />
					<cfset strMessage = 'Returned by the Search API when an invalid format is specified in the request.' />
				</cfcase>
				<cfcase value="420 Enhance Your Calm">
					<cfset strSuccess = false />
					<cfset strMessage = 'Returned by the Search and Trends API  when you are being rate limited.' />
				</cfcase>
				<cfcase value="500 Internal Server Error">
					<cfset strSuccess = false />
					<cfset strMessage = 'Something is broken.  Please post to the group so the Twitter team can investigate.' />
				</cfcase>
				<cfcase value="502 Bad Gateway">
					<cfset strSuccess = false />
					<cfset strMessage = 'Twitter is down or being upgraded.' />
				</cfcase>
				<cfcase value="503 Service Unavailable">
					<cfset strSuccess = false />
					<cfset strMessage = 'The Twitter servers are up, but overloaded with requests. Try again later.' />
				</cfcase>
			</cfswitch>
			<cfif !strSuccess>
				
				<cfscript>
					
					stuErrInfo.error_message 	= arguments.data.Statuscode & '-' & strMessage;
					arrErrSearch				=	xmlSearch(arguments.data.FileContent,'hash/error');
					stuErrInfo.api_Info 		= {};
					stuErrInfo.api_Info.request = xmlSearch(arguments.data.FileContent,'hash/request')[1].XmlText;
						
					if(arrayLen(arrErrSearch)) {
						stuErrInfo.api_Info.error	=	arrErrSearch[1].XmlText;
					}
					
					stuErrInfo.full_Request		=	arguments.data;
				</cfscript>

				<cfdump var="#stuErrInfo#" />
				<cfabort />
			</cfif>
	</cffunction>	
	
	<!--- OAuth specific methods here --->
	
	<!--- MUTATORS / SETTERS --->
	<cffunction name="setOAuthConsumer" access="public" output="false" hint="I set the values for the consumerKey and consumerSecret.">
		<cfargument name="consumerKey" 		required="true" 	type="string" 	default=""	hint="The consumer key generated by Twitter for the oAuth." />
		<cfargument name="consumerSecret" 	required="true" 	type="string" 	default=""	hint="The consumer secret generated by Twitter for the oAuth." />
			<cfscript>
				variables.instance.consumerKey 		= arguments.consumerKey;
				variables.instance.consumerSecret 	= arguments.consumerSecret;
			</cfscript>
	</cffunction>
	
	<!--- ACCESSORS / GETTERS --->
	<cffunction name="getConsumerKey" access="public" output="false" hint="I return the consumer key from the variables.instance struct.">
		<cfreturn variables.instance.consumerKey />
	</cffunction>
	
	<cffunction name="getConsumerSecret" access="public" output="false" hint="I return the consumer secret from the variables.instance struct.">
		<cfreturn variables.instance.consumerSecret />
	</cffunction>
	
	<cffunction name="httpOAuthCall" description="Allows Scripting of CFHTTP" access="private" output="false" returntype="Struct">
		<cfargument name="url" 			type="string" 	displayname="url" 		hint="URL to request" 		required="true" />
		<cfargument name="method" 		type="string" 	displayname="method" 	hint="Method of HTTP Call" 	required="true" />
		<cfargument name="parameters" 	type="struct" 	displayname="method" 	hint="HTTP parameters" 		required="false" default="#structNew()#" />
		<cfset var returnStruct = {} />
		
		<cfhttp url="#arguments.url#" method="#arguments.method#" result="returnStruct">
			<cfif structKeyExists (arguments.parameters,'Authorization') and arguments.method is 'post'>
				<cfhttpparam type="header" name="Authorization" value="#arguments.parameters.Authorization#" />
			</cfif>
		</cfhttp>
		<cfreturn returnStruct />
	</cffunction>
	
	<cffunction name="queryString2struct" displayname="queryString2Struct" description="Turns a query string into a struct." access="private" output="false" returntype="Struct" >
		<cfargument name="queryString"	type="string" displayname="queryString" hint="Query String to Decihper" required="true" />
		<cfscript>
			var returnStruct 	= {};
			var localPair		= '';
			var localKey		= '';
			var localValue		= '';
				for(i=1; i LTE listLen(arguments.queryString,'&');i=i+1) {
					localPair	= listGetAt(arguments.queryString,i,'&');
					localKey	= listGetAt(localPair,1,'=');
					if (listlen(localPair,'=') EQ 2) {
						localValue	= listGetAt(localPair,2,'=');
					}
					returnStruct[localKey]	= localValue;
				}
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<!--- PUBLIC FUNCTIONS --->
	<cffunction name="getAuthorisation" access="public" output="false" returntype="struct" hint="I make the call to Twitter to request authorisation to access the account.">
		<cfargument name="callBackURL"	type="string" hint="The URL to hit on call back from authorisation" required="false" default="" />
		<cfscript>
			var returnStruct					= {};
			var requestToken					= {};
			var oAuthKeys						= {};
			var callBackURLEncoded				= '';
			var AuthURL							= '';
			var twitRequest							= '';
			
			var stuParams						= {};
			
				stuParams['oauth_callback']			= arguments.callBackURL;
			
				twitRequest								= oAuthAccessObject(token	: '',
																	secret	: '',
																	httpurl	: variables.instance.reqEndpoint,
																	parameters	: stuParams
																	);

				requestToken						= httpOAuthCall(twitRequest.getString(),'GET');
				returnStruct['success']				= false;
				
				// If there is a string for auth token
				if (findNoCase("oauth_token",requestToken.filecontent)) {
					oAuthKeys	= queryString2struct(requestToken.fileContent);
								
					if (arguments.callBackURL NEQ '') {
						arguments.callBackURL	= URLSessionFormat(arguments.callBackURL);
						callBackURLEncoded		= '&oauth_callback=' & URLEncodedFormat(arguments.callBackURL);
					}
					
					// Should get back oauth_token & oauth_token_secret
					AuthURL =  variables.instance.authEndpoint & "?oauth_token=" & oAuthKeys.oauth_token & callBackURLEncoded;
					
					returnStruct['authURL']			= AuthURL;
					returnStruct['token']			= oAuthKeys.oauth_token;
					returnStruct['token_secret']	= oAuthKeys.oauth_token_secret;
					returnStruct['success']			= true;
				}
				else {
					structAppend (returnStruct,requestToken,false);
				}
			
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<cffunction name="getAccessToken" access="public" output="false" returntype="Struct" hint="Gets an Access Token which can be stored and used for future access.">
		<cfargument name="requestToken"		type="string" 	required="true" hint="Request Token needed to get Access Token." />
		<cfargument name="requestSecret"	type="string" 	required="true" hint="Request Token Secret needed to get Access Token." />
		<cfargument name="verifier" 		type="string"	required="true" hint="I am the oauth_verifier string returned from the authentication request." />
		<cfscript>
			var returnStruct		= {};
			var accessToken			= {};
			var oAuthKeys			= {};
			var twitRequest			= '';
			var stuParams			= {};
			
				stuParams['oauth_verifier']		= arguments.verifier;
			
				twitRequest			= oAuthAccessObject( 
										token	: arguments.requestToken,
										secret	: arguments.requestSecret,
										httpurl	: variables.instance.accessEndpoint,
										parameters	: stuParams
									);
			
			returnStruct['success']	= false;

			accessToken				= httpOAuthCall(twitRequest.toURL(),'get');
			
			//If there is a string for auth token
			if (findNoCase("oauth_token",accessToken.filecontent)) {
				oAuthKeys						= queryString2struct(accessToken.fileContent);
				returnStruct['token']			= oAuthKeys.oauth_token;
				returnStruct['token_secret']	= oAuthKeys.oauth_token_secret;
				returnStruct['success']			= true;
				returnStruct['user_id']			= oAuthKeys.user_id;
				returnStruct['screen_name']		= oAuthKeys.screen_name;
			}
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<cffunction name="makeResourceRequest" access="public" output="false" hint="Gets an Access Token which can be stored and used for future access">
		<cfargument name="accessToken"		type="string" 	required="true" 	hint="Request Token needed to get Access Token" />
		<cfargument name="accessSecret"		type="string" 	required="true" 	hint="Request Token Secret needed to get Access Token" />
		<cfargument name="httpurl"			type="string"	required="true"		hint="Parameters for the url to the service"/>
		<cfargument name="httpmethod"		type="string"	required="true"		hint="HTTP Method" />
		<cfargument name="parameters"		type="struct"	required="false"	hint="Parameters for the url to the service" />
		<cfscript>
			var requestResult		= '';
			var twitRequest			= '';
			var stuParams			= {};
						
				twitRequest			= oAuthAccessObject( 
										token		: arguments.accessToken,
										secret		: arguments.accessSecret,
										httpurl		: arguments.httpurl,
										httpmethod	: arguments.httpmethod,
										parameters	: arguments.parameters
									);
									
				stuParams['Authorization']	= twitRequest.toHeader();
																		
			requestResult = httpOAuthCall(twitRequest.toURL(),arguments.httpmethod, stuParams);			
			return requestResult;
		</cfscript>
	</cffunction>
	
	<cffunction name="oAuthAccessObject" access="private" output="false" returntype="Any" hint="Generates an oAuth access object">
		<cfargument name="token"			type="string"	required="false"	displayname="accessToken"		hint="Access Token needed to get access to the users account"								default="" />
		<cfargument name="secret"			type="string"	required="false"	displayname="accessSecret"		hint="Access Token Secret needed to get access to the users account"	default="" />		
		<cfargument name="httpurl"			type="string"	required="false"	displayname="httpurl"			hint="Parameters for the url to the service"	default="#structNew()#" />
		<cfargument name="httpmethod"		type="string"	required="false"	displayname="httpmethod"		hint="HTTP Method"	default="GET" />
		<cfargument name="parameters"		type="struct"	required="false"	displayname="parameters"		hint="Parameters for the url to the service"	default="#structNew()#" />
		<cfscript>
			var returnStruct	= {};
			var authToken 		= '';
			var twitRequest			= '';

			if (arguments.token neq '') {
				authToken		= CreateObject("component", 
												"oauth.oauthtoken")
												.init(
													sKey 	= arguments.token,
													sSecret = arguments.secret
												);
			}
			else {
				authToken		= CreateObject("component", 
												"oauth.oauthtoken")
												.createEmptyToken();
			}
			

			twitRequest			= CreateObject("component", 
												"oauth.oauthrequest")
												.fromConsumerAndToken(
													oConsumer 	= variables.instance.consumerToken,
													oToken 		= authToken,
													sHttpMethod 	= arguments.httpmethod,
													sHttpURL 		= arguments.httpurl,
													stParameters	= arguments.parameters
												);
																								
			twitRequest.signRequest(
								oSignatureMethod 	= variables.instance.reqSigMethodSHA,
								oConsumer 			= variables.instance.consumerToken,
								oToken 				= authToken
							);
							
			return twitRequest;
		</cfscript>
	</cffunction>
	
	<cffunction name="clearEmptyParams" access="public" output="false" hint="I accept the structure of arguments and remove any empty / nulls values before they are sent to the OAuth processing.">
		<cfargument name="paramStructure" required="true" type="Struct" hint="I am a structure containing the arguments / parameters you wish to filter." />
			<cfset var stuRevised = {} />
				<cfloop collection="#arguments.paramStructure#" item="key">
					<cfif len(arguments.paramStructure[key])>
						<cfset structInsert(stuRevised, lcase(key), arguments.paramStructure[key], true) />
					</cfif>
				</cfloop>
		<cfreturn stuRevised />
	</cffunction>
	
	<cffunction name="genericAuthenticationMethod" 	access="public" output="false" hint="I accept the URL, method and parameters and make the required authenticated call to the API.">
		<cfargument name="httpURL" 		required="true" 	type="String" 							hint="I am the URL to which to make the request or post." />
		<cfargument name="httpMethod" 	required="true" 	type="String" 	default="POST"			hint="I am the method of the authenticated request. GET or POST." />
		<cfargument name="parameters" 	required="false" 	type="Struct"	default="#StructNew()#" hint="I am a structure of parameters for the request." />
			<cfset var twitRequest		= {} />
			<cfset var strReturn 		= '' />
				<cfscript>									
					twitRequest = makeResourceRequest(  
							accessToken		: getAuthDetails().getOAuthToken(),
							accessSecret	: getAuthDetails().getOAuthTokenSecret(),
							httpurl			: arguments.httpURL,
							httpmethod		: arguments.httpMethod,
							parameters		: clearEmptyParams(arguments.parameters)
						);
					checkStatusCode(twitRequest);
					strReturn = handleReturnFormat(twitRequest.fileContent, arguments.parameters.format);
				</cfscript>
		<cfreturn strReturn />
	</cffunction>

</cfcomponent>