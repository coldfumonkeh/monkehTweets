component{
	this.name = 'dummy test';

	this.mappings['/mxunit'] = getDirectoryFromPath(getCurrentTemplatePath()) & "../../mxunit";
	this.mappings['/tests'] = getDirectoryFromPath(getCurrentTemplatePath());
	this.mappings['/testbox'] = getDirectoryFromPath(getCurrentTemplatePath()) & "../../testbox/system/testing";
}