<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_3.0.0.xsd">
	<Settings>
		<!-- Application Setup-->
		<Setting name="AppName" value="LookupManager"/>
		<!-- <Setting name="AppMapping"					value=""/> -->
		<Setting name="EventName" value="event"/>
		
		<!-- Development Settings -->
		<Setting name="DebugMode" value="false"/>
		<Setting name="DebugPassword" value=""/>
		<Setting name="ReinitPassword" value=""/>
		<Setting name="HandlersIndexAutoReload" value="true"/>
		<Setting name="ConfigAutoReload" value="false"/>
		
		<!-- Implicit Events -->
		<Setting name="DefaultEvent" 				value="lookups.display"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler" 	value=""/>
		<Setting name="SessionStartHandler" 		value=""/>
		<Setting name="SessionEndHandler" 			value=""/>
		<Setting name="MissingTemplateHandler"		value=""/>
		
		<!-- Caching Directives -->
		<Setting name="HandlerCaching" 				value="false"/>
		<Setting name="EventCaching" 				value="false"/>
		<Setting name="ProxyReturnCollection" 		value="false"/>
		<Setting name="FlashURLPersistScope" 		value="session"/>
	</Settings>
	
	<YourSettings>
		<!-- Lookups Settings -->
		<Setting name="lookups_tables" value=""/>		
		<Setting name="lookups_imgPath" value="includes/lookups/images"/>
		<Setting name="lookups_cssPath" value="includes/lookups/styles"/>
		<Setting name="lookups_jsPath" value="includes/lookups/js"/>
		<!-- Leave empty if handlers and views not in a package -->
		<Setting name="lookups_packagePath" value=""/>
	</YourSettings>
	
	<!--Model Integration -->
	<Models>
		<DefinitionFile>config/ModelMappings.cfm</DefinitionFile>
		<StopRecursion>transfer.com.TransferDecorator</StopRecursion>		
		<ObjectCaching>false</ObjectCaching>
	</Models>

	<Layouts>
		<DefaultLayout>Layout.Lookups.cfm</DefaultLayout>
		<!-- Lookups Layout -->
		<Layout file="Layout.Lookups.cfm" name="Lookups">
			<Folder>lookups</Folder>
		</Layout>
	</Layouts>

	<Datasources>
		<Datasource alias="lookups" dbtype="mysql" name="lookups" password="" username=""/>
	</Datasources>
	
	<Interceptors>
		<!-- USE AUTOWIRING -->
		<Interceptor class="coldbox.system.interceptors.autowire">
			<Property name="enableSetterInjection">true</Property>
		</Interceptor>
		<!-- USE SES -->
		<Interceptor class="coldbox.system.interceptors.ses">
			<Property name="configFile">config/routes.cfm</Property>
		</Interceptor>
		<!-- Transfer Loader : ColdBox 3.0.0 > -->
		<Interceptor class="coldbox.system.orm.transfer.TransferLoader">
		        <Property name="ConfigPath">/${AppMapping}/config/transfer.xml.cfm</Property>
		        <Property name="definitionPath">/${AppMapping}/config/definitions</Property>
		        <Property name="datasourceAlias">lookups</Property>
		        <Property name="LoadBeanInjector">true</Property>
		        <Property name="BeanInjectorProperties">{'useSetterInjection':'false','stopRecursion':'${ModelsStopRecursion}'}</Property>
		</Interceptor>				
	</Interceptors>
	
</Config>