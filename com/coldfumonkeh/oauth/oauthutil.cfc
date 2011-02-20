<cfcomponent displayname="oauthutil" hint="utility functions">

	<cffunction name="init" returntype="oauthutil" output="false">
		<cfreturn this>
	</cffunction>

	<cffunction name="readPropertiesFile" returntype="struct" description="I read a .properties file.">
		<cfargument name="filePath" type="string" required="true" hint="full file path">
		<cfargument name="sCommentDelimiters" type="string" required="false" default="!,##">

		<cfset var stResult = StructNew()>
		<cfset var sFileContents = "">
		<cfset var xmlFileContents = "">
		<cfset var sDumpMessage = "">
		<cfset var sSingleLine = "">
		<cfset var i = 0>
		<cfset var stMatched = StructNew()>
		<cfset var sRegex = "(.+)(=|:)(.+)?">
		<cfset var sKey = "">
		<cfset var sValue = "">

		<cfset stResult["message"] = "">
		<cfset stResult["status"] = "FAILED">
		<cfset stResult["properties"] = StructNew()>

		<cfif FileExists(arguments.filePath)>
			<cftry>
				<cffile action="read" file="#arguments.filePath#" variable="sFileContents">
				<cfif IsXML(sFileContents)>
					<cfset xmlFileContents = XMLParse(sFileContents)>
					<cfif IsDefined('xmlFileContents.xmlRoot.xmlChildren')>
						<cfloop from="1" to="#ArrayLen(xmlFileContents.xmlRoot.xmlChildren)#" index="i">
							<cfset StructInsert(stResult["properties"],
									xmlFileContents.xmlRoot.xmlChildren[i].xmlAttributes.key,
									xmlFileContents.xmlRoot.xmlChildren[i].xmlText,
									true)>
						</cfloop>
						<cfset stResult["message"] = "File read.">
					<cfelse>
						<cfset stResult["message"] = "File read. No entries found. Check file format.">
					</cfif>
					<cfset stResult["status"] = "OK">
				<cfelse>
					<cfloop list="#sFileContents#" index="sSingleLine" delimiters="#chr(10)##chr(13)#">
						<cfif ListContains(arguments.sCommentDelimiters, Left(Trim(sSingleLine),1)) IS 0>
							<cfset stMatched = REFindNoCase(sRegex, sSingleLine, 1, true)>
							<cfif StructKeyExists(stMatched, "pos") AND ArrayLen(stMatched.pos) GTE 4>
								<cfset sKey = Mid(sSingleLine, stMatched.pos[2], stMatched.len[2])>
								<cfset sValue = Mid(sSingleLine, stMatched.pos[4], stMatched.len[4])>
								<cfset StructInsert(stResult["properties"],sKey,sValue)>
							</cfif>
						</cfif>
					</cfloop>
					<cfset stResult["status"] = "OK">
					<cfset stResult["message"] = "File read.">
				</cfif>
			<cfcatch>
				<cfset stResult["message"] =
						"Could not load properties from file : [#arguments.filePath#]."
						& "Expected file encoding ISO 8859-1, for XML files include <!DOCTYPE properties SYSTEM ""http://java.sun.com/dtd/properties.dtd"">.">
				<cfsavecontent variable="sDumpMessage"><cfoutput>#cfcatch#</cfoutput></cfsavecontent>
				<cfset stResult["dump"] = sDumpMessage>
			</cfcatch>
			</cftry>
		<cfelse>
			<cfset stResult["message"] = "File [#arguments.filePath#] does not exist.">
		</cfif>

		<cfreturn stResult>
	</cffunction>


	<cffunction name="toUnicodeChar" access="public" returntype="string" description="I return the ColdFusion representation of an unicode charatacter.">
		<cfargument name="sUnicodeChar" type="string" required="true" hint="Unicode character format: U+XXXX or \uXXXX">
		<cfargument name="iRadix" type="numeric" required="false" default="16" hint="default : hex">

		<cfset var sResult = arguments.sUnicodeChar>

		<cfif Len(arguments.sUnicodeChar) IS 6 AND
			  (Compare(Left(arguments.sUnicodeChar,2),"U+") IS 0 OR Compare(Left(arguments.sUnicodeChar,2),"\u") IS 0)>
			<cfset sResult = Chr(InputBaseN(Right(arguments.sUnicodeChar, 4), arguments.iRadix))>
		</cfif>

		<cfreturn sResult>
	</cffunction>

	<cffunction name="encodePercent" returntype="string" access="public"
				description="RFC 3986 encoding - keep [ALPHA, DIGIT, '-', '.', '_', '~'], %-encode the rest -> decoding '~', correctly encoding spaces('+') and '*'">
		<cfargument name="sValue"		required="true" type="string" hint="value to encode">
		<cfargument name="sEncoding"	required="false" type="string" default="UTF-8" hint="encoding">
		<cfset var sResult = "">
		<!--- using javacast to call the appropriate encode method --->
		<cfif Len(arguments.sValue)>
			<cfset sResult = CreateObject("java","java.net.URLEncoder").
								encode(JavaCast("String",arguments.sValue), JavaCast("String",arguments.sEncoding))>
			<cfset sResult = Replace(sResult,"+","%20","all")>
			<cfset sResult = Replace(sResult,"*","%2A","all")>
			<cfset sResult = Replace(sResult,"%7E","~","all")>
		</cfif>

		<cfreturn sResult>
	</cffunction>

	<cffunction name="decodePercent" returntype="string" access="public" description="">
		<cfargument name="sValue"		required="true" type="string" hint="value to encode">
		<cfargument name="sEncoding"	required="false" type="string" default="UTF-8" hint="encoding">
		<cfset var sResult = "">
		<!--- using javacast to call the appropriate decode method --->
		<cfif Len(arguments.sValue)>
			<cfset sResult = CreateObject("java","java.net.URLDecoder").decode(JavaCast("String",arguments.sValue), JavaCast("String",arguments.sEncoding))>
		</cfif>
		<cfreturn sResult>
	</cffunction>

</cfcomponent>