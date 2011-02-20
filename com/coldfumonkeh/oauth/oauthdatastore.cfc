<!---
$HeadURL: https://oauth.googlecode.com/svn/code/coldfusion/oauth/oauthdatastore.cfc $
$Id: oauthdatastore.cfc 673 2008-09-19 09:48:36Z derrick13 $
Description:
============
	OAuth datastore

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

<cfcomponent displayname="oauthdatastore">
	<cfset variables.sDataSource = "">

	<cffunction name="init" returntype="oauthdatastore" access="public" output="false">
	  	<cfargument name="sDataSource" type="string" required="yes">

		<cfset variables.sDataSource = arguments.sDataSource>
		<cfreturn this>
	</cffunction>

	<cffunction name="lookUpConsumer" access="public" returntype="oauthconsumer">
		<cfargument name="sConsumerKey" required="true" type="string">
		<cfset var qLookUpConsumer = 0>
		<cfset var oResult = "">

		<cfquery name="qLookUpConsumer" datasource="#variables.sDataSource#">
			SELECT	consumer_id, name, ckey, csecret
			FROM	oauth_consumers
			WHERE	ckey = <cfqueryparam value="#arguments.sConsumerKey#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif qLookUpConsumer.recordcount IS 1>
			<cfset oResult = CreateObject("component", "oauthconsumer").init(
				sKey = qLookUpConsumer.ckey,
				sSecret = qLookUpConsumer.csecret,
				iConsumerID = qLookUpConsumer.consumer_id)>
		<cfelse>
			<cfset oResult = CreateObject("component", "oauthconsumer").createEmptyConsumer()>
		</cfif>

		<cfreturn oResult>
	</cffunction>

	<cffunction name="lookUpConsumerID" access="public" returntype="numeric">
		<cfargument name="sConsumerKey" required="true" type="string">
		<cfset var qLookUpConsumer = 0>
		<cfset var iResult = 0/>

		<cfquery name="qLookUpConsumer" datasource="#variables.sDataSource#">
			SELECT	consumer_id
			FROM	oauth_consumers
			WHERE	ckey = <cfqueryparam value="#arguments.sConsumerKey#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif qLookUpConsumer.recordcount IS 1>
			<cfset iResult = qLookUpConsumer.consumer_id>
		</cfif>

		<cfreturn iResult>
	</cffunction>

	<cffunction name="lookUpEditorID" access="public" returntype="numeric">
		<cfargument name="sConsumerKey" required="true" type="string">
		<cfset var qLookUpConsumer = 0>
		<cfset var iResult = 0/>

		<cfquery name="qLookUpConsumer" datasource="#variables.sDataSource#">
			SELECT	editor_id
			FROM	oauth_consumers
			WHERE	ckey = <cfqueryparam value="#arguments.sConsumerKey#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif qLookUpConsumer.recordcount IS 1>
			<cfset iResult = qLookUpConsumer.editor_id>
		</cfif>

		<cfreturn iResult>
	</cffunction>

	<cffunction name="getTokenNonce" access="public" returntype="string">
		<cfargument name="oToken"		required="true"	type="oauthtoken">
		<cfargument name="sTokenType"	required="true"	type="string">

		<cfset var sResult = "">
		<cfset var qData = 0>
		<cfquery name="qData" datasource="#variables.sDataSource#">
			SELECT	tkey, tsecret, nonce
			FROM	oauth_tokens
			WHERE	tkey = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.oToken.getKey()#">
					AND	type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#UCase(arguments.sTokenType)#">
		</cfquery>
		<cfif qData.recordcount IS 1>
			<cfset sResult = qData.nonce>
		</cfif>
		<cfreturn sResult>
	</cffunction>

	<cffunction name="lookUpToken" access="public" returntype="oauthtoken">
		<cfargument name="sTokenType" 	required="true" type="string">
		<cfargument name="oToken" 		required="true" type="oauthtoken">

		<cfset var oResult = "">
		<cfset var qLookUpToken = 0>
		<cfset var aSplitToken = 0>
		<cfset var aSplitTokenKey = 0>
		<cfset var aSplitTokenSecret = 0>
		<cfset var aSplitTokenKeyValue = "">
		<cfset var aSplitTokenSecretValue = "">

		<cfquery name="qLookUpToken" datasource="#variables.sDataSource#">
			SELECT	tkey, tsecret, nonce
			FROM	oauth_tokens
			WHERE	tkey = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.oToken.getKey()#">
					AND	type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#UCase(arguments.sTokenType)#">
		</cfquery>

		<cfif qLookUpToken.recordcount IS 1>
			<cfset oResult = CreateObject("component", "oauthtoken").init(
				sKey = qLookUpToken.tkey,
				sSecret = qLookUpToken.tsecret)>
		<cfelse>
			<cfset oResult = CreateObject("component", "oauthtoken").createEmptyToken()>
		</cfif>

		<cfreturn oResult>
	</cffunction>

	<cffunction name="lookUpNonce" access="public" returntype="boolean" hint="check if nonce already exists">
		<cfargument name="oConsumer" 	required="true" type="oauthconsumer">
		<cfargument name="oToken" 		required="true" type="oauthtoken">
		<cfargument name="sNonce" 		required="true" type="string">
		<cfargument name="timestamp" 	required="true" type="numeric">

		<cfset var bResult = false>
		<cfset var qLookUpNonce = 0>
		<cfset var sErrorMsg = "">

 		<cfquery name="qLookUpNonce" datasource="#variables.sDataSource#">
			SELECT	COUNT(nonce) AS noncesFound
			FROM	oauth_tokens
			WHERE	nonce = <cfqueryparam value="#arguments.sNonce#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif qLookUpNonce.noncesFound IS 1>
			<cfset bResult = true>
		<cfelseif qLookUpNonce.noncesFound GE 2>
			<cfset sErrorMsg = "Multiple nonces found, nonce=[" & arguments.sNonce & "], found = " & qLookUpNonce.noncesFound & ", should be 0 or 1."/>
			<cfthrow message="#sErrorMsg#" type="OAuthException">
		</cfif>

		<cfreturn bResult>
	</cffunction>

	<cffunction name="lookUpNonceValue" access="public" returntype="string" hint="check if nonce already exists return value, else emtpy string">
		<cfargument name="oToken" 		required="true" type="oauthtoken">
		<cfargument name="sNonce" 		required="true" type="string">

		<cfset var sResult = "">
		<cfset var qLookUpNonce = 0>
		<cfset var sErrorMsg = "">

		<cfquery name="qLookUpNonce" datasource="#variables.sDataSource#">
			SELECT	tkey, tsecret, nonce, time_stamp
			FROM	oauth_tokens
			WHERE	nonce = <cfqueryparam value="#arguments.sNonce#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif qLookUpNonce.recordcount IS 1>
			<cfset sResult = qLookUpNonce.nonce>
		<cfelseif qLookUpNonce.recordcount GT 1>
			<cfset sErrorMsg = "ERROR : More than one entry found! tokenkey=" & arguments.oToken.getKey() &  ", tokensecret=" & arguments.oToken.getSecret>
			<cfset sErrorMsg = sErrorMsg & ",nonce=" & arguments.sNonce>
			<cfthrow message="#sErrorMsg#" type="OAuthException">
		</cfif>

		<cfreturn sResult>
	</cffunction>

	<cffunction name="generateTokenKey" access="private" returntype="string">
		<!--- encode current tickcount using SHA-1 --->
		<cfset var timestamp = CreateObject("component", "oauthrequest").generateTimestamp()>
		<cfreturn Hash(timestamp & RandRange(1,1024), "SHA")>
	</cffunction>

	<cffunction name="generateTokenSecret" access="private" returntype="string">
		<!--- double hashed, additional random data needed ? --->
		<cfset var timestamp = CreateObject("component", "oauthrequest").generateTimestamp()>
		<cfreturn Hash(Hash(timestamp + timestamp, "SHA"), "SHA")>
	</cffunction>

	<cffunction name="newToken" access="public" returntype="oauthtoken">
		<cfargument name="oConsumer" required="true" type="oauthconsumer">
		<cfargument name="sTokenType" required="false" type="string" default="REQUEST">
		<cfargument name="sKey" required="false" type="string" default="">
		<cfargument name="sSecret" required="false" type="string" default="">

		<cfset var sErrorMsg = "">
		<cfset var oResult = 0>
		<cfset var sGeneratedKey = arguments.sKey>
		<cfset var sGeneratedSecret = arguments.sSecret>
		<cfset var oDAO = 0>
		<cfset var stCreateData = StructNew()>

		<cfif Len(sGeneratedKey) IS 0>
			<cfset sGeneratedKey = generateTokenKey()>
		</cfif>
		<cfif Len(sGeneratedSecret) IS 0>
			<cfset sGeneratedSecret = generateTokenSecret()>
		</cfif>
		<cfset oResult = CreateObject("component", "oauthtoken").init(
			sKey = sGeneratedKey,
			sSecret = sGeneratedSecret)>

		<!--- consumerkey replaced tokenkey --->
		<cftransaction>
			<cftry>
				<cfset oDAO = CreateObject("component", "oauthtokendao").init(variables.sDataSource)>

				<cfset stCreateData.consumerid = oConsumer.getConsumerID(this)>
				<cfset stCreateData.tokentype = arguments.sTokenType>
				<cfset stCreateData.nonce = CreateObject("component", "oauthrequest").generateNonce()>
				<cfset stCreateData.tokensecret = oResult.getSecret()>
				<cfset stCreateData.tokenkey = oResult.getKey()>

				<cfset oDAO.create(stCreateData)>

				<cfcatch type="database">
					<cfset sErrorMsg = "Failed to create token for consumer [" & arguments.oConsumer.getKey() & "], datasource = " & "[" & variables.sDataSource & "]">
					<cfset sErrorMsg = sErrorMsg & "<br>" &  "token = [" & oResult.getString()>
					<cfset sErrorMsg = sErrorMsg & "<br>Error details:<br>">
					<cfset sErrorMsg = sErrorMsg & "detail :" & cfcatch.Detail & "<br>">
					<cfthrow message="#sErrorMsg#" type="OAuthException">
				</cfcatch>
			</cftry>
		</cftransaction>

		<cfreturn oResult>
	</cffunction>

	<!--- return a new token attached to this consumer --->
	<cffunction name="newRequestToken" access="public" returntype="oauthtoken">
		<cfargument name="oConsumer" 	required="true" type="oauthconsumer" >
		<cfset var oResult = newToken(oConsumer = arguments.oConsumer, sTokenType = "REQUEST")>
		<cfreturn oResult>
	</cffunction>

	<!--- return a new access token attached to this consumer
		for the user associated with this token if the request token is authorized
		should also invalidate the request token --->
	<cffunction name="newAccessToken" access="public" returntype="oauthtoken">
		<cfargument name="oToken" 		required="true" type="oauthtoken">
		<cfargument name="oConsumer" 	required="true" type="oauthconsumer">

		<cfset var oResult = CreateObject("component", "oauthtoken").createEmptyToken()>
		<cfset deleteToken(	sTokenKey = arguments.oToken.getKey(), sTokenType = "REQUEST")>
		<cfset oResult = newToken(oConsumer = arguments.oConsumer, sTokenType = "ACCESS")>
		<cfreturn oResult>
	</cffunction>

	<cffunction name="deleteToken" access="public" returntype="void">
		<cfargument name="sTokenKey" type="string" required="true">
		<cfargument name="sTokenType" type="string" required="false" default="REQUEST">

		<cfset var oDAO = 0>
		<cfset var sErrorMsg = "">

		<cftransaction>
			<cftry>
				<cfset oDAO = CreateObject("component", "oauthtokendao").init(variables.sDataSource)>
				<cfset oDAO.delete(sTokenType = arguments.sTokenType, sTokenKey = arguments.sTokenKey)>

				<cfcatch type="database">
					<cfset sErrorMsg = "Failed to delete token [" & arguments.sTokenKey & "]">
					<cfset sErrorMsg = sErrorMsg & "<br>Error details:<br>">
					<cfset sErrorMsg = sErrorMsg & "detail :" & cfcatch.Detail & "<br>">
					<cfthrow message="#sErrorMsg#" type="OAuthException">
				</cfcatch>
			</cftry>
		</cftransaction>

	</cffunction>

</cfcomponent>