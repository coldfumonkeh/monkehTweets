<!---
$HeadURL: https://oauth.googlecode.com/svn/code/coldfusion/oauth/oauthserver.cfc $
$Id: oauthserver.cfc 961 2009-04-15 00:18:48Z derrick13 $
Description:
============
	OAuth server

License:
============
Copyright 2008 CONTENS Software GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->

<cfcomponent displayname="oauthserver">

	<cfset variables.iTimestampThreshold = 600000>
	<cfset variables.sOAuthVersion = "1.0">
	<cfset variables.stSignatureMethods = StructNew()>
	<cfset variables.oDataStore = 0>

	<cffunction name="init" access="public" returntype="oauthserver" output="false">
		<cfargument name="oDataStore" required="true" type="oauthdatastore">
		<cfargument name="iTimestampThreshold" required="false" type="numeric" default="0">
		<cfset variables.oDataStore = arguments.oDataStore>
		<cfif arguments.iTimestampThreshold>
			<cfset setTimeout(arguments.iTimestampThreshold)>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="setTimeout" access="public" output="false" returntype="void">
		<cfargument name="iTimestampThreshold"	required="true"	type="numeric">
		<cfset variables.iTimestampThreshold = arguments.iTimestampThreshold>
	</cffunction>

	<cffunction name="getTimeout" access="public" output="false" returntype="numeric">
		<cfreturn variables.iTimestampThreshold>
	</cffunction>

	<cffunction name="addSignatureMethod" access="public" returntype="void">
		<cfargument name="oSignatureMethod"	required="true" type="oauthsignaturemethod">
		<cfset variables.stSignatureMethods[arguments.oSignatureMethod.getName()] = arguments.oSignatureMethod>
	</cffunction>

	<!--- return signature methods supported by server --->
	<cffunction name="getSupportedSignatureMethods" access="public" returntype="struct">
		<cfreturn variables.stSignatureMethods>
	</cffunction>

	<!--- process a Request_Token request, returns the request token on success --->
	<cffunction name="fetchRequestToken" access="public" returntype="oauthtoken">
		<cfargument name="oRequest"	required="true"	type="oauthrequest">

		<cfset var oConsumer = 0>
		<cfset var oEmptyToken = CreateObject("component", "oauthtoken").createEmptyToken()>
		<cfset var oNewToken = 0>

		<cfset getVersion(arguments.oRequest)>
		<cfset oConsumer = getConsumer(arguments.oRequest)>
		<!--- using emtpy token, no token required for the initial token request --->
		<cfset checkSignature(arguments.oRequest, oConsumer, oEmptyToken)>
		<cfset oNewToken = variables.oDataStore.newRequestToken(oConsumer)>
		<cfreturn oNewToken>
	</cffunction>

	<!--- process an access_token request, returns the access token on success --->
	<cffunction name="fetchAccessToken"	access="public" returntype="oauthtoken">
		<cfargument name="oRequest" required="true" type="oauthrequest">

		<cfset var oConsumer = 0>
		<cfset var oToken = 0>
		<cfset var oNewToken = 0>

		<cfset getVersion(arguments.oRequest)>
		<cfset oConsumer = getConsumer(arguments.oRequest)>
		<cfset oToken = getOAuthToken(arguments.oRequest, oConsumer, "REQUEST")>
		<cfset checkSignature(arguments.oRequest, oConsumer, oToken)>
		<cfset oNewToken = variables.oDataStore.newAccessToken(oToken, oConsumer)>

		<cfreturn oNewToken>
  	</cffunction>

	<!--- verify an api call, checks all the parameters --->
	<cffunction name="verifyRequest" access="public" returntype="array">
		<cfargument name="oRequest" required="true" type="oauthrequest">

		<cfset var oConsumer = 0>
		<cfset var oToken = 0>
		<cfset var aResult = ArrayNew(1)>

		<cfset getVersion(arguments.oRequest)>
		<cfset oConsumer = getConsumer(arguments.oRequest)>
		<cfset oToken = getOAuthToken(arguments.oRequest, oConsumer, "ACCESS")>
		<cfset checkSignature(arguments.oRequest, oConsumer, oToken)>
		<cfset ArrayAppend(aResult, oConsumer)>
		<cfset ArrayAppend(aResult, oToken)>

		<cfreturn aResult>
	</cffunction>

	<!--- *********** private functions *********** --->

	<!--- get oauth version --->
	<cffunction name="getVersion" access="private" returntype="string">
		<cfargument name="oRequest" required="true" type="oauthrequest">

		<cfset var sVersion = arguments.oRequest.getParameter("oauth_version")>
		<cfset var sErrorMsg = "">
		<!--- prevent multiple versions --->
		<cfif Len(sVersion) IS 0 OR ListLen(sVersion) GT 1>
			<cfset sVersion = "1.0">
		</cfif>

		<cfif Len(sVersion) AND Compare(sVersion, variables.sOAuthVersion) NEQ 0>
			<cfset sErrorMsg = "OAuth version [" & sVersion & "] not supported!">
			<cfthrow message="#sErrorMsg#" type="OAuthException">
		</cfif>

    	<cfreturn sVersion>
    </cffunction>

	<!--- figure out the signature with some defaults --->
	<cffunction name="getSignatureMethod" access="private" output="false" returntype="oauthsignaturemethod">
		<cfargument name="oRequest" type="oauthrequest"	required="true">

		<cfset var oSignatureMethod = 0>
		<cfset var sSignatureMethod = arguments.oRequest.getParameter("oauth_signature_method")>
		<cfset var sErrorMsg = "">

		<!--- default signature method --->
		<cfif Len(sSignatureMethod) IS 0>
			<cfset sSignatureMethod = "PLAINTEXT">
		</cfif>

		<cfif NOT StructKeyExists(variables.stSignatureMethods, sSignatureMethod)>
			<cfset sErrorMsg = "Signature method [" & sSignatureMethod & "] not supported, try one of the following: " &
				ArrayToList(StructKeyArray(variables.stSignatureMethods), ",") & ".">
			<cfthrow message="#sErrorMsg#" type="OAuthException">
		</cfif>

		<cfset oSignatureMethod = variables.stSignatureMethods[sSignatureMethod]>
		<cfreturn oSignatureMethod>
	</cffunction>

	<!--- try to find the consumer for the provided request's consumer key --->
	<cffunction name="getConsumer" access="private" returntype="oauthconsumer">
		<cfargument name="oRequest" required="true" type="oauthrequest">

		<cfset var sConsumerKey = arguments.oRequest.getParameter("oauth_consumer_key")>
		<cfset var sErrorMsg = "">
		<cfset var oConsumer = CreateObject("component", "oauthconsumer").createEmptyConsumer()>

		<cfif Len(sConsumerKey) IS 0>
			<cfset sErrorMsg = "Invalid consumer key. Check request parameters.">
			<cfthrow message="#sErrorMsg#" type="OAuthException">
		</cfif>

		<cfset oConsumer = variables.oDataStore.lookUpConsumer(sConsumerKey)>

		<cfif oConsumer.isEmpty()>
			<cfset sErrorMsg = "Invalid consumer.">
			<cfthrow message="#sErrorMsg#" type="OAuthException">
		</cfif>

		<cfreturn oConsumer>
	</cffunction>

	<!--- try to find the token for the provided request's token key --->
	<cffunction name="getOAuthToken" access="private" returntype="oauthtoken">
		<cfargument name="oRequest" required="true" type="oauthrequest">
		<cfargument name="oConsumer" required="true" type="oauthconsumer">
		<cfargument name="sTokenType" required="false" type="string" default="ACCESS">

		<cfset var sErrorMsg = "">
		<cfset var sTokenFieldValue = arguments.oRequest.getParameter("oauth_token")>
		<cfset var oToken = CreateObject("component", "oauthtoken").createEmptyToken()>

		<cfif NOT Len(sTokenFieldValue) IS 0>
			<cfset oToken = variables.oDataStore.lookUpToken(
				oConsumer = arguments.oConsumer,
				sTokenType = arguments.sTokenType,
				oToken = CreateObject("component", "oauthtoken").init(
					sKey = sTokenFieldValue,
					sSecret = arguments.oConsumer.getSecret()))>
		</cfif>

		<cfif oToken.isEmpty()>
			<cfset sErrorMsg = "Invalid " & arguments.sTokenType & " token: " & sTokenFieldValue>
			<cfthrow message="#sErrorMsg#" type="OAuthException">
		</cfif>

		<cfreturn oToken>
	</cffunction>

	<!--- all-in-one function to check the signature on a request, should guess the signature method appropriately --->
	<cffunction name="checkSignature" access="public" output="false">
		<cfargument name="oRequest"	required="true" type="oauthrequest">
		<cfargument name="oConsumer" required="true" type="oauthconsumer">
		<cfargument name="oToken" required="true" type="oauthtoken">

		<cfset var iTimestamp = arguments.oRequest.getParameter("oauth_timestamp")>
		<cfset var sNonce = arguments.oRequest.getParameter("oauth_nonce")>
		<cfset var oSignatureMethod = 0>
		<cfset var sSignature = "">
		<cfset var sBuilt = "">
		<cfset var sErrorMsg = "">

		<cfif iTimestamp EQ "">
			<cfset iTimestamp = 0>
		</cfif>

		<cfset checkTimestamp(iTimestamp)>
		<cfset checkNonce(arguments.oConsumer, arguments.oToken, sNonce, iTimestamp)>
		<cfset oSignatureMethod = getSignatureMethod(arguments.oRequest)>
		<cfset sSignature = arguments.oRequest.getParameter("oauth_signature")>

		<cfif Len(oSignatureMethod.getName()) IS 0>
			<cfset sErrorMsg = "Invalid signature method.">
			<cfthrow message="#sErrorMsg#" type="OAuthException">
		</cfif>

		<cfset sBuilt = oSignatureMethod.buildSignature(arguments.oRequest, arguments.oConsumer, arguments.oToken)>
		<!--- $todo: check the signature generation $todo --->
	</cffunction>

	<!--- check that the timestamp is new enough - verify that timestamp is recentish --->
	<cffunction name="checkTimestamp" access="private">
		<cfargument name="iTimestamp" required="true" type="numeric">

		<cfset var iNow = CreateObject("component", "oauthrequest").generateTimestamp()>
		<cfset var sErrorMsg = "">
		<cfset var iDiff = 0>

		<cfset iDiff = iNow - arguments.iTimestamp>
		<cfif iDiff GT variables.iTimestampThreshold>
			<cfset sErrorMsg = "Expired timestamp, yours [" & arguments.iTimestamp & "], ours [" & iNow
				& "], threshold=[" & variables.iTimestampThreshold & "], diff=[" & iDiff & "].">
			<cfthrow message="#sErrorMsg#" type="OAuthException">
		</cfif>
	</cffunction>

	<!--- check that the nonce is not repeated, verify that the nonce is unique --->
	<cffunction name="checkNonce" access="private">
		<cfargument name="oConsumer" required="true" type="oauthconsumer">
		<cfargument name="oToken" required="true" type="oauthtoken">
		<cfargument name="sNonce" required="true" type="string">
		<cfargument name="iTimestamp" required="true" type="numeric">

		<cfset var bFound = false>
		<cfset var sErrorMsg = "">

		<cfset bFound = variables.oDataStore.lookUpNonceValue(arguments.oToken, arguments.sNonce)>
		<cfif bFound NEQ "">
			<cfset sErrorMsg = "Nonce already used : [" & arguments.sNonce & "], [" & bFound & "]">
			<cfthrow message="#sErrorMsg#" type="OAuthException">
		</cfif>
	</cffunction>

</cfcomponent>