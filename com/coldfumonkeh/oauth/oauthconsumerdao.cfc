<!---
$HeadURL: https://oauth.googlecode.com/svn/code/coldfusion/oauth/oauthconsumerdao.cfc $
$Id: oauthconsumerdao.cfc 673 2008-09-19 09:48:36Z derrick13 $
Description:
============
	Data Access Object for OAuth consumers

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

<cfcomponent hint="Data Access Object for OAuth consumers" output="false">
	<cfset variables.sDataSource = "">

	<!--- dao constructor --->
	<cffunction name="init" access="public" returntype="oauthconsumerdao" output="false" hint="Constructor - initializes the DAO.">
		<cfargument name="sDataSource" required="true" type="string" hint="database source">
		<cfset variables.sDataSource = arguments.sDataSource>
		<cfreturn this>
	</cffunction>

	<cffunction name="getNextConsumerID" access="private" returntype="numeric" hint="retrieves next valid consumer id">
		<cfset var iResult = 1>
		<cfset var qData = 0>

		<cfquery datasource="#variables.sDataSource#" name="qData">
			SELECT	MAX(consumer_id) AS maxID
			FROM	oauth_consumers
		</cfquery>

		<cfif qData.recordcount IS 1 AND Val(qData.maxID)>
			<cfset iResult = qData.maxID + 1>
		</cfif>

		<cfreturn iResult>
	</cffunction>

	<!--- create new record --->
	<cffunction name="create" access="public" returntype="struct" output="false"  hint="CRUD: Create - Inserts a new record in consumers table.">
		<cfargument name="stCreateData" type="struct" required="yes">

		<cfset var stData = arguments.stCreateData>
		<cfset var qData = 0>
		<cfset var iConsumerID = getNextConsumerID()>
		<cfset var iEditorID = 1>
		<cfif StructKeyExists(stData, "editorid")>
			<cfset iEditorID = StructFind(stData, "editorid")>
		</cfif>

		<cfquery datasource="#variables.sDataSource#" name="qData">
			INSERT INTO oauth_consumers	(consumer_id, name, fullname, email, ckey, csecret, editor_id, datecreated)
			VALUES (
				<cfqueryparam value="#iConsumerID#" 			cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#stData.consumername#" 	cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#stData.consumerfullname#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#stData.consumeremail#" 	cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#stData.consumerkey#" 		cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#stData.consumersecret#"	cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#iEditorID#" 		cfsqltype="CF_SQL_INTEGER">,
				CURRENT_TIMESTAMP
			)
		</cfquery>

		<cfset stData._insertOk = true>

		<cfreturn stData>
	</cffunction>

	<!--- read the specified consumer record --->
	<cffunction name="read" access="public" returntype="struct" output="false"	hint="CRUD: Read - Reads the specified record.">
		<cfargument name="sConsumerKey"	type="string" required="yes" hint="The consumer's key.">

		<cfset var qData = 0>
		<cfset var stData = StructNew()>

		<cfquery name="qData" datasource="#variables.sDataSource#" maxrows="1" blockfactor="1">
			SELECT	consumer_id, name, fullname, email, ckey, csecret, editor_id, datecreated
			FROM  	oauth_consumers
			WHERE 	ckey = <cfqueryparam value="#arguments.sConsumerKey#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif qData.recordCount IS 1>
			<cfset stData.consumerID 		= qData.consumer_id>
			<cfset stData.consumername 		= qData.name>
			<cfset stData.consumerfullname 	= qData.fullname>
			<cfset stData.consumeremail 	= qData.email>
			<cfset stData.consumerkey 		= qData.ckey>
			<cfset stData.consumersecret 	= qData.csecret>
			<cfset stData.editorid 			= qData.editor_id>
			<cfset stData.datecreated 		= qData.datecreated>
		</cfif>

		<cfreturn stData>
	</cffunction>

	<!--- updates the specified consumer record --->
	<cffunction name="update" access="public" returntype="struct" hint="CRUD: Update - Updates the data of a single record in consumers.">
		<cfargument name="stUpdateData"	type="struct" required="yes" hint="The data to update; key=column name.">
		<cfargument name="columnList" 	type="string" requried="yes" hint="List of columns to update; empty=all." default="">

		<cfset var stData = arguments.stUpdateData>
		<cfset var sComma = "">

		<cfquery datasource="#variables.sDataSource#">
		UPDATE oauth_consumers
		SET
			<cfif isToProcess(arguments.columnList, stData, "consumername")>
				#sComma# name = <cfqueryparam value="#stData.consumername#"	cfsqltype="CF_SQL_VARCHAR">
				<cfset sComma = ",">
			</cfif>
			<cfif isToProcess(arguments.columnList, stData, "consumerfullname")>
				#sComma# fullname = <cfqueryparam value="#stData.consumerfullname#" cfsqltype="CF_SQL_VARCHAR">
				<cfset sComma = ",">
			</cfif>
			<cfif isToProcess(arguments.columnList, stData, "consumeremail")>
				#sComma# email = <cfqueryparam value="#stData.consumeremail#" cfsqltype="CF_SQL_VARCHAR">
				<cfset sComma = ",">
			</cfif>
			<cfif isToProcess(arguments.columnList, stData, "consumersecret")>
				#sComma# csecret = <cfqueryparam value="#stData.consumersecret#" cfsqltype="CF_SQL_VARCHAR">
				<cfset sComma = ",">
			</cfif>
			<cfif isToProcess(arguments.columnList, stData, "consumerkey")>
				#sComma# ckey = <cfqueryparam value="#stData.consumerkey#" cfsqltype="CF_SQL_VARCHAR">
				<cfset sComma = ",">
			</cfif>
			<cfif isToProcess(arguments.columnList, stData, "editorid")>
				#sComma# editor_id = <cfqueryparam value="#stData.editorid#" cfsqltype="CF_SQL_VARCHAR">
				<cfset sComma = ",">
			</cfif>
			#sComma# datecreated = CURRENT_TIMESTAMP
		WHERE	consumer_id = <cfqueryparam value="#stData.consumerID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfset stData._updateOk = true>

		<cfreturn stData>
	</cffunction>

	<!--- delete the specified record --->
	<cffunction name="delete" access="public" returntype="void" output="false"  hint="CRUD: Delete - Deletes the specified record from consumers.">
		<cfargument name="iConsumerID"	type="numeric" 	required="true" hint="consumer id">
		<cfset var qData = 0>

		<cfquery datasource="#variables.sDataSource#" name="qData">
			DELETE
			FROM	oauth_consumers
			WHERE	consumer_id = <cfqueryparam value="#arguments.iConsumerID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cffunction>

	<!--- list all consumers --->
	<cffunction name="listAll" access="public" returntype="query" output="false" hint="returns all consumers">
		<cfargument name="iColumnNr" required="false" type="numeric" default="0">
		<cfset var qData = 0>
		<cfset var iColumn = arguments.iColumnNr>

		<cfquery datasource="#variables.sDataSource#" name="qData">
			SELECT	consumer_id, name, fullname, email, csecret, ckey, editor_id, datecreated
			FROM	oauth_consumers
			<cfif iColumn IS 1>
				ORDER BY consumer_id
			<cfelseif iColumn IS 2>
				ORDER BY name
			<cfelseif iColumn IS 3>
				ORDER BY fullname
			<cfelseif iColumn IS 4>
				ORDER BY email
			<cfelseif iColumn IS 5>
				ORDER BY ckey
			<cfelseif iColumn IS 6>
				ORDER BY csecret
			<cfelseif iColumn IS 7>
				ORDER BY datecreated
			<cfelseif iColumn IS 8>
				ORDER BY editor_id
			<cfelse>
				ORDER BY datecreated, consumer_id ASC
			</cfif>
		</cfquery>

		<cfreturn qData>
	</cffunction>

	<cffunction name="getConsumerCount" access="public" returntype="numeric" output="false" hint="returns the number of consumers">
		<cfset var qData = 0>
		<cfquery name="qData" datasource="#variables.sDataSource#" maxrows="1">
			SELECT 	COUNT(consumer_id) AS consumerCount
			FROM	oauth_consumers
		</cfquery>

		<cfreturn qData.consumerCount>
	</cffunction>

	<!--- helper function --->
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