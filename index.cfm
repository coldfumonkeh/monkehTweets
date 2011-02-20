<!---
Name: index.cfm
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
1) twitter username
2) password associated with the account

The underlying classes relative to the available methods are instantiated within this facade component.
The developer / user simply needs to call a method from the monkehTweet CFC to perform the function.
All methods and parameters within the monkehTweet component are documented and hints provided to assist with use.

--->

<cfscript>
/*
	Firstly we need to have the user grant access to our application.
	We do this (using OAuth) through the getAuthorisation() method.
	The callbackURL is optional. If not sent through, Twitter will use the callback URL it has stored for your application.
*/
authStruct = application.objMonkehTweet.getAuthorisation(callbackURL='http://[yourdomain]/authorize.cfm');

if (authStruct.success){
	//	Here, the returned information is being set into the session scope.
	//	You could also store these into a DB (if running an application for multiple users)
	session.oAuthToken			= authStruct.token;
	session.oAuthTokenSecret	= authStruct.token_secret;
}
</cfscript>
<!--- Now, we need to relocate the user to Twitter to perform the authorisation for us --->
<cflocation url="#authStruct.authURL#" addtoken="false" />