/**
* Matt Gifford, Monkeh Works
* www.monkehworks.com
* ---
* This module connects your application to the Twitter API
**/
component {

	// Module Properties
	this.title 				= "Twitter API";
	this.author 			= "Matt Gifford";
	this.webURL 			= "https://www.monkehworks.com";
	this.description 		= "This SDK will provide you with connectivity to the Twitter API for any ColdFusion (CFML) application.";
	this.version			= "@version.number@+@build.number@";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	this.entryPoint			= 'monkehTweet';
	this.modelNamespace		= 'monkehTweet';
	this.cfmapping			= 'monkehTweet';
	this.autoMapModels 		= false;

	/**
	 * Configure
	 */
	function configure(){

		// Settings
		settings = {
			consumerKey = '',
			consumerSecret = '',
			oauthToken =	'',
			oauthTokenSecret =	'',
			userAccountName =	'',
			parseResults = true
		};
	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		parseParentSettings();
		var monkehSettings = controller.getConfigSettings().monkehTweet;

		// Map Library
		binder.map( "MonkehTweet@monkehTweet" )
			.to( "#moduleMapping#.monkehTweet" )
			.initArg( name="consumerKey", 			value=monkehSettings.consumerKey )
			.initArg( name="consumerSecret", 		value=monkehSettings.consumerSecret )
			.initArg( name="oauthToken", 			value=monkehSettings.oauthToken )
			.initArg( name="oauthTokenSecret", 		value=monkehSettings.oauthTokenSecret )
			.initArg( name="userAccountName", 		value=monkehSettings.userAccountName )
			.initArg( name="parseResults", 			value=monkehSettings.parseResults );
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){
	}

	/**
	* parse parent settings
	*/
	private function parseParentSettings(){
		var oConfig 		= controller.getSetting( "ColdBoxConfig" );
		var configStruct 	= controller.getConfigSettings();
		var tweetDSL 		= oConfig.getPropertyMixin( "monkehTweet", "variables", structnew() );

		//defaults
		configStruct.monkehTweet = variables.settings;

		// incorporate settings
		structAppend( configStruct.monkehTweet, tweetDSL, true );
	}

}
