<!---
Name: post.cfm
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

--->
<cfscript>
	// We also need to set the values into the authentication class inside monkehTweets
	application.objMonkehTweet.setFinalAccessDetails(
									oauthToken			= 	session['accessToken'],
									oauthTokenSecret	=	session['accessSecret'],
									userAccountName		=	session['screen_name']
								);
	
	// Let's make a test call. This will update the status of the authenticated user.
	// If you are using this for a number of users , you will need to set the details prior to each call
	// using the setFinalAccessDetails() method above.
	
	// If you are using this purely for a single user, you can set all of the 
	// authentication details in the init() constructor method when instantiating the application
	returnData = application.objMonkehTweet.postUpdate("I'm using the awesome ##monkehTweets ColdFusion library from @coldfumonkeh!");
</cfscript>
<cfdump var="#returnData#" label="Returned data from the twitter request" />