<!---
$HeadURL: https://oauth.googlecode.com/svn/code/coldfusion/oauth/oauthtest.cfc $
$Id: oauthtest.cfc 673 2008-09-19 09:48:36Z derrick13 $
Description:
============
	OAuth test

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

<cfcomponent extends="oauthdatastore" output="false" displayname="oauthtest">
	<cfset variables.oTestConsumer = 0>
	<cfset variables.oTestRequestToken = 0>
	<cfset variables.oTestAccessToken = 0>
	<cfset variables.sNonce = "">
	<cfset variables.bUseSuper = true>

	<cffunction name="init" access="public" returntype="oauthtest">
		<cfargument name="sDataSource" 	type="string" 	required="true">
		<cfargument name="bUseSuper"	type="boolean" 	required="false" default="true">
		<cfset super.init(arguments.sDataSource)>
		<cfset variables.oTestConsumer = CreateObject("component", "oauthconsumer").init(
			sKey = "CONSUMER_KEY",
			sSecret = "CONSUMER_SECRET")>
		<cfset variables.oTestRequestToken = CreateObject("component", "oauthtoken").init(
			sKey = "RequestTokenKey",
			sSecret = "RequestTokenSecret")>
		<cfset variables.oTestAccessToken = CreateObject("component", "oauthtoken").init(
			sKey = "AccessTokenKey",
			sSecret = "AccessTokenSecret")>
		<cfset variables.oNonce = "testnonce">
		<cfset variables.bUseSuper = arguments.bUseSuper>

		<cfreturn this>
	</cffunction>

	<cffunction name="lookUpConsumer" returntype="oauthconsumer">
		<cfargument name="sConsumerKey" required="true" type="string">

		<cfset var oResult = "">
		<cfif variables.bUseSuper>
			<cfset oResult = super.lookUpConsumer(arguments.sConsumerKey)>
		<cfelse>
			<cfset oResult = CreateObject("component", "oauthconsumer").createEmptyConsumer()>
			<cfif Compare(arguments.sConsumerKey, variables.oTestConsumer.getKey()) IS 0>
				<cfset oResult = variables.oTestConsumer>
			</cfif>
		</cfif>

		<cfreturn oResult>
	</cffunction>

	<cffunction name="lookUpToken" returntype="oauthtoken">
		<cfargument name="oConsumer" type="oauthconsumer" required="true">
		<cfargument name="sTokenType" type="string" required="true">
		<cfargument name="oToken" type="oauthtoken" required="true">

		<cfset var oResult = "">
		<cfif variables.bUseSuper>
			<cfset oResult = super.lookUpToken(oConsumer = oConsumer, sTokenType = sTokenType, oToken = oToken)>
		<cfelse>
			<cfset oResult = CreateObject("component", "oauthtoken").createEmptyToken()>

			<cfif Compare(arguments.oConsumer.getKey(), variables.oTestConsumer.getKey()) IS 0>
				<cfif Compare(UCase(arguments.sTokenType), "ACCESS") IS 0 AND
				  Compare(variables.oTestAccessToken.getKey(), arguments.oToken.getKey()) IS 0>
					<cfset oResult = variables.oTestAccessToken>
				</cfif>
				<cfif Compare(UCase(arguments.sTokenType), "REQUEST") IS 0 AND
				  Compare(variables.oTestRequestToken.getKey(), arguments.oToken.getKey()) IS 0>
					<cfset oResult = variables.oTestRequestToken>
				</cfif>
			</cfif>
		</cfif>

		<cfreturn oResult>
	</cffunction>

	<cffunction name="lookUpNonce" returntype="string" access="public">
		<cfargument name="oConsumer" type="oauthconsumer" required="true">
		<cfargument name="oToken" type="oauthtoken" required="true">
		<cfargument name="sNonce" type="string" required="true">
		<cfargument name="iTimestamp" type="numeric" required="true">

		<cfset var sResult = "">
		<cfif Compare(arguments.oConsumer.getKey(), variables.oTestConsumer.getKey()) IS 0
		  AND (
			Compare(oToken.getKey(), variables.oTestRequestToken.getKey()) IS 0 OR
			Compare(oToken.getKey(), variables.oTestAccessToken.getKey()) IS 0
		  )
		  AND Compare(arguments.sNonce, variables.sNonce) IS 0>
			<cfset sResult = variables.sNonce>
		</cfif>
		<cfreturn sResult>
	</cffunction>

	<cffunction name="newRequestToken" access="public" returntype="oauthtoken">
		<cfargument name="oConsumer" required="true" type="oauthconsumer">

		<cfset var oResult = "">
		<cfif variables.bUseSuper>
			<cfset oResult = super.newRequestToken(oConsumer)>
		<cfelse>
			<cfset oResult = CreateObject("component", "oauthtoken").createEmptyToken()>
			<cfif Compare(arguments.oConsumer.getKey(), variables.oTestConsumer.getKey()) IS 0>
				<cfset oResult = variables.oTestRequestToken>
			</cfif>
		</cfif>

		<cfreturn oResult>
	</cffunction>

	<cffunction name="newAccessToken" access="public" returntype="oauthtoken">
		<cfargument name="oToken" required="true" type="oauthtoken">
		<cfargument name="oConsumer" required="true" type="oauthconsumer">

		<cfset var oResult = "">
		<cfif variables.bUseSuper>
			<cfset oResult = super.newAccessToken(oToken, oConsumer)>
		<cfelse>
			<cfset oResult = CreateObject("component", "oauthtoken").createEmptyToken()>
			<cfif Compare(arguments.oConsumer.getKey(), variables.oTestConsumer.getKey()) IS 0 AND
			  Compare(arguments.oToken.getKey(), variables.oTestRequestToken.getKey() IS 0)>
				<cfset oResult = variables.oTestAccessToken>
			</cfif>
		</cfif>

		<cfreturn oResult>
	</cffunction>

</cfcomponent>