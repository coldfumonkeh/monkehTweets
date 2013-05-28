<!---
Name: authorize.cfm
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
	returnData	= application.objMonkehTweet.getAccessToken(
									requestToken	= 	session.oAuthToken,
									requestSecret	= 	session.oAuthTokenSecret,
									verifier		=	url.oauth_verifier
								);

if (returnData.success) {
	//Save these off to your database against your User so you can access their account in the future
	session['accessToken']	= returnData.token;
	session['accessSecret']	= returnData.token_secret;
	session['screen_name']	= returnData.screen_name;
	session['user_id']		= returnData.user_id;
}
</cfscript>

<a href="post.cfm">Send a post using monkehTweets and see the CFC in action</a>