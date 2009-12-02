********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
HONOR GOES TO GOD ABOVE ALL
********************************************************************************
Because of His grace, this project exits. If you don't like this, then don't read it, its not for you.

"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the 
Holy Ghost which is given unto us. ." Romans 5:5

********************************************************************************
WELCOME TO COLDBOX LOOKUP MANAGER
********************************************************************************
This ColdBox Lookup Manager is used to help in managing and starting applications.

********************************************************************************
RELEASE NOTES
********************************************************************************
VERSION 1.1
 - displayColumn metadata field for relationships can now be a comma-delimmitted
   list.
VERSION 1.0
 - Full relationship support for many to one, one to many and many to many.

********************************************************************************
INSTALLATION & USAGE
********************************************************************************
Requirements:
	- ColdBox 2.6.4 or greater
	- Transfer 1.0 or greater

Goals:
	This lookup manager will help you manage and define which tables you would like
	to manage by creating dynamic scaffolding based on ColdBox and Transfer.
	
Install:
	Just Install the parts in their appropriate locations of your coldbox app or
	just copy this entire coldbox application and use it to begin with.
	
	/Config
		- coldbox.xml (Use this base coldbox.xml or use the settings in the file:StandAloneSettings.xml)
		- StandAloneSettings.xml ( Copy the settings here to your own coldbox.xml )
		- modelMappings (By default it uses model integration, so just copy the alias)
	/handlers
		- lookups.cfc
	/includes
		/lookups/*
	/layouts
		-Layout.Lookups.cfm
	/model
		/lookups/*
	/views
		/lookups/*

	Then make sure you configure the coldbox.xml's datasource.