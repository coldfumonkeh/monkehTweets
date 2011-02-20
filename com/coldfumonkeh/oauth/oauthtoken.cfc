<!---
$HeadURL: https://oauth.googlecode.com/svn/code/coldfusion/oauth/oauthtoken.cfc $
$Id: oauthtoken.cfc 673 2008-09-19 09:48:36Z derrick13 $
Description:
============
	OAuth token

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

<cfcomponent displayname="oauthtoken">
	<cfset variables.sKey = "">
	<cfset variables.sSecret = "">
	<cfset variables.oUtil = CreateObject("component","oauthutil").init()>

	<cffunction name="init" access="public" returntype="oauthtoken">
		<cfargument name="sKey" required="true" type="string">
		<cfargument name="sSecret" required="true" type="string">

		<cfset setKey(arguments.sKey)>
		<cfset setSecret(arguments.sSecret)>

		<cfreturn this>
	</cffunction>

	<cffunction name="getKey" access="public" returntype="string" output="false">
		<cfreturn variables.sKey>
	</cffunction>
	<cffunction name="setKey" access="public" returntype="void">
		<cfargument name="sKey" type="string" required="yes">
		<cfset variables.sKey = arguments.sKey>
	</cffunction>

	<cffunction name="getSecret" access="public" returntype="string" output="false">
		<cfreturn variables.sSecret>
	</cffunction>
	<cffunction name="setSecret" access="public" returntype="void">
		<cfargument name="sSecret" type="string" required="yes">
		<cfset variables.sSecret = arguments.sSecret>
	</cffunction>

	<cffunction name="createEmptyToken" access="public" returntype="oauthtoken">
		<cfset var oEmptyToken = init(sKey="", sSecret="")>
		<cfreturn oEmptyToken>
	</cffunction>

	<cffunction name="isEmpty" access="public" returntype="boolean">
		<cfset var bResult = false>
		<cfif Len(getSecret()) IS 0 AND Len(getKey()) IS 0>
			<cfset bResult = true>
		</cfif>
		<cfreturn bResult>
	</cffunction>

	<!---
		generates the basic string serialization of a token that a server
		would respond to request_token and access_token calls with
	--->
	<cffunction name="getString" access="public" returntype="string" output="false">
		<cfset var sResult = "oauth_token=" & variables.oUtil.encodePercent(variables.sKey) & "&" &
			"oauth_token_secret=" & variables.oUtil.encodePercent(variables.sSecret)>
		<cfreturn sResult>
	</cffunction>

</cfcomponent>