<!---
$HeadURL: https://oauth.googlecode.com/svn/code/coldfusion/oauth/oauthconsumer.cfc $
$Id: oauthconsumer.cfc 1225 2010-06-07 10:25:05Z derrick13 $
Description:
============
	OAuth consumer

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

<cfcomponent displayname="oauthconsumer">

	<cfset variables.sKey = "">
	<cfset variables.sSecret = "">
	<cfset variables.sCallbackURL = "">
	<cfset variables.iConsumerID = 0>
	<cfset variables.iEditorID = 1>

	<cffunction name="init"	access="public" returntype="oauthconsumer">
		<cfargument name="sKey"			required="true"		type="string"	hint="consumer key">
		<cfargument name="sSecret" 		required="true" 	type="string" 	hint="consumer secret">
		<cfargument name="sCallbackURL" required="false" 	type="string" 	hint="consumer callback URL" 	default="">
		<cfargument name="iConsumerID"	required="false"	type="numeric"	hint="consumer id" 				default="0">
		<cfargument name="iEditorID"	required="false"	type="numeric"	hint="consumer id" 				default="1">

		<cfset setKey(arguments.sKey)>
		<cfset setSecret(arguments.sSecret)>
		<cfset setCallbackURL(arguments.sCallbackURL)>
		<cfset setConsumerID(arguments.iConsumerID)>
		<cfset setEditorID(arguments.iEditorID)>
		<cfreturn this>
	</cffunction>

	<cffunction name="getKey" access="public" returntype="string">
		<cfreturn variables.sKey>
	</cffunction>
	<cffunction name="setKey" access="public" returntype="void">
		<cfargument name="sKey" type="string" required="yes">
		<cfset variables.sKey = trim(arguments.sKey)>
	</cffunction>

	<cffunction name="getSecret" access="public" returntype="string">
		<cfreturn variables.sSecret>
	</cffunction>
	<cffunction name="setSecret" access="public" returntype="void">
		<cfargument name="sSecret" type="string" required="yes">
		<cfset variables.sSecret = trim(arguments.sSecret)>
	</cffunction>

	<cffunction name="getCallbackURL" access="public" returntype="string">
		<cfreturn variables.sCallbackURL>
	</cffunction>
	<cffunction name="setCallbackURL" access="public" returntype="void">
		<cfargument name="sCallbackURL" type="string" required="yes">
		<cfset variables.sCallbackURL = arguments.sCallbackURL>
	</cffunction>

	<cffunction name="getConsumerID" access="public" returntype="numeric">
		<cfargument name="oDataStore" required="false" type="oauthdatastore">
		<cfif StructKeyExists(arguments, "oDataStore")>
			<cfset setConsumerID(arguments.oDataStore.lookUpConsumerID(sConsumerKey = getKey()))>
		</cfif>
		<cfreturn variables.iConsumerID>
	</cffunction>
	<cffunction name="setConsumerID" access="public" returntype="void">
		<cfargument name="iConsumerID" required="true" type="numeric">
		<cfset variables.iConsumerID = arguments.iConsumerID>
	</cffunction>

	<cffunction name="getEditorID" access="public" returntype="numeric">
		<cfargument name="oDataStore" required="false" type="oauthdatastore">
		<cfif StructKeyExists(arguments, "oDataStore")>
			<cfset setEditorID(arguments.oDataStore.lookUpEditorID(sConsumerKey = getKey()))>
		</cfif>
		<cfreturn variables.iEditorID>
	</cffunction>
	<cffunction name="setEditorID" access="public" returntype="void">
		<cfargument name="iEditorID" required="true" type="numeric">
		<cfset variables.iEditorID = arguments.iEditorID>
	</cffunction>


	<cffunction name="createEmptyConsumer" access="public" returntype="oauthconsumer">
		<cfset var oResult = init(sKey = "", sSecret = "")>
		<cfreturn oResult>
	</cffunction>

	<cffunction name="isEmpty" access="public" returntype="boolean">
		<cfset var bResult = false>
		<cfif Len(getKey()) IS 0 AND Len(getSecret()) IS 0>
			<cfset bResult = true>
		</cfif>
		<cfreturn bResult>
	</cffunction>

</cfcomponent>