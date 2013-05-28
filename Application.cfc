<!---
Name: Application.cfc
Author: Matt Gifford AKA coldfumonkeh (http://www.mattgifford.co.uk)
Date: 10.09.2010

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


Usage: The monkehTweet component accepts two required parameters in the constructor;

	1) the consumer key
	2) the consumer secret

both of which are obtained from the application page (if added) on http://dev.twitter.com

All methods and parameters within the monkehTweet component are documented and hints provided to assist with use.

--->
<cfcomponent output="true">

	<!--- Set up the application. --->
	<cfscript>
		this.Name 				= "monkehTweet_V1.3.1";
		this.ApplicationTimeout = CreateTimeSpan( 0, 0, 1, 0 );
		this.SessionManagement 	= true;
		this.SetClientCookies 	= true;
		//do this for CF7
		this.mappings 			= structnew();
		//do this for CF 8+
		this.mappings['/com'] 	= GetDirectoryFromPath(GetCurrentTemplatePath()) & "/com";
	</cfscript>


	<cffunction name="OnApplicationStart" access="public" returntype="boolean" output="false">
 		<cfscript>
 			/*
				If you are using this for a number of different accounts (allowing numerous users to acces Twitter)
				you will need to specify only the consumerKey and consumerSecret

				If you are using this for a single account only, set the oauthToken, oauthTokenSecret and your account name
				in the init() method too, like this:

					consumerKey			=	'',
					consumerSecret		=	'',
					oauthToken			=	'',
					oauthTokenSecret	=	'',
					userAccountName		=	'',
					parseResults		=	true
			*/
			/*application.objMonkehTweet = createObject('component',
		        'com.coldfumonkeh.monkehTweet')
				.init(
					consumerKey			=	'< your consumer key >',
					consumerSecret		=	'< your consumer secret >',
					parseResults		=	true
				);*/

			return true;
		</cfscript>
	</cffunction>

	<cffunction name="onrequestStart">
		<cfscript>
		if(structKeyExists(url, 'reinit')) {
			onApplicationStart();
		}
		</cfscript>
	</cffunction>

</cfcomponent>