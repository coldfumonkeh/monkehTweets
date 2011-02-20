<!---
$HeadURL: https://oauth.googlecode.com/svn/code/coldfusion/oauth/oauthtokendao.cfc $
$Id: oauthtokendao.cfc 673 2008-09-19 09:48:36Z derrick13 $
Description:
============
	Data Access Object for OAuth tokens

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

<cfcomponent hint="Data Access Object for OAuth tokens" output="false">
	<cfset variables.sDataSource = "">

	<!--- dao constructor --->
	<cffunction name="init" access="public" returntype="oauthtokendao" output="false" hint="Constructor - initializes the DAO.">
		<cfargument name="sDataSource" required="true" type="string" hint="database source">
		<cfset variables.sDataSource = arguments.sDataSource>
		<cfreturn this>
	</cffunction>

	<!--- create new record --->
	<cffunction name="create" access="public" returntype="struct" hint="CRUD: Create - Inserts a new record in consumers table.">
		<cfargument name="stCreateData" type="struct" required="yes">

		<cfset var stData = arguments.stCreateData>
		<cfset var qData = 0>

		<cfquery datasource="#variables.sDataSource#" name="qData">
			INSERT	INTO oauth_tokens (tkey, tsecret, type, consumer_id, nonce, time_stamp)
			VALUES 	(
				<cfqueryparam value="#stData.tokenkey#"		cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#stData.tokensecret#"	cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#stData.tokentype#" 	cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#stData.consumerid#"	cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#stData.nonce#" 		cfsqltype="CF_SQL_VARCHAR">,
				CURRENT_TIMESTAMP
			)
		</cfquery>

		<cfset stData._insertOk = true>

		<cfreturn stData>
	</cffunction>

	<!--- read the specified consumer record --->
	<cffunction name="read" access="public" returntype="struct" hint="CRUD: Read - Reads the specified record.">
		<cfargument name="sTokenKey" 	type="string" 	required="yes" hint="The token's key.">

		<cfset var qData = 0>
		<cfset var stData = StructNew()>

		<cfquery name="qData" datasource="#variables.sDataSource#" maxrows="1" blockfactor="1">
			SELECT	tkey, tsecret, type, consumer_id, time_stamp, nonce
			FROM  	oauth_tokens
			WHERE 	tkey = <cfqueryparam value="#arguments.sTokenKey#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif qData.recordCount IS 1>
			<cfset stData.tokenkey		= qData.tkey>
			<cfset stData.tokensecret 	= qData.tsecret>
			<cfset stData.tokentype 	= qData.type>
			<cfset stData.consumerID 	= qData.consumer_id>
			<cfset stData.timestamp 	= qData.time_stamp>
			<cfset stData.nonce 		= qData.nonce>
		</cfif>

		<cfreturn stData>
	</cffunction>

	<!--- delete the specified record --->
	<cffunction name="delete" access="public" returntype="void" output="false"  hint="CRUD: Delete - Deletes the specified record from consumers.">
		<cfargument name="sTokenKey" 	type="string" required="yes" hint="the token's key.">
		<cfargument name="sTokenType" 	type="string" required="yes" hint="the token's type.">

		<cfset var qData = 0>

		<cfquery datasource="#variables.sDataSource#" name="qData">
			DELETE
			FROM	oauth_tokens
			WHERE	tkey = <cfqueryparam value="#arguments.sTokenKey#" cfsqltype="CF_SQL_VARCHAR"> AND
					type = <cfqueryparam value="#UCase(arguments.sTokenType)#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

	</cffunction>

	<!--- list all tokens --->
	<cffunction name="listAll" access="public" returntype="query" hint="returns all consumers">
		<cfset var qData = QueryNew("tkey,tsecret,type,consumer_id,time_stamp,nonce")>

		<cfquery datasource="#variables.sDataSource#" name="qData">
			SELECT		tkey, tsecret, type, consumer_id, time_stamp, nonce
			FROM		oauth_tokens
			ORDER BY 	tkey
		</cfquery>

		<cfreturn qData>
	</cffunction>

	<cffunction name="getTokenCount" access="public" returntype="numeric" output="false" hint="returns the number of consumers">
		<cfset var qData = 0>
		<cfquery name="qData" datasource="#variables.sDataSource#" maxrows="1">
			SELECT 	COUNT(tkey) AS tokenCount
			FROM	oauth_tokens
		</cfquery>

		<cfreturn qData.tokenCount>
	</cffunction>

	<!--- help function, used by update function, currently no token update supported --->
	<cffunction name="isToProcess" access="private" returntype="boolean" output="false" hint="Process a column only if it's in a given columnlist">
		<cfargument name="columnList"	required="Yes" type="string">
		<cfargument name="stData" 		required="yes" type="struct">
		<cfargument name="sColumn" 		required="Yes" type="string">
		<cfif Len(arguments.columnList) AND NOT listFindNoCase(arguments.columnList, arguments.sColumn)>
			<cfreturn false>
		</cfif>
		<cfreturn structKeyExists(arguments.stData, arguments.sColumn)>
	</cffunction>

</cfcomponent>