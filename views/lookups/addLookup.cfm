<cfoutput>
<!--- js --->
<cfsavecontent variable="js">
<cfoutput>
<script type="text/javascript">
	$(document).ready(function() {
	/* Form Validation */
		$('##manageForm').formValidation({
			err_class 	: "invalidLookupInput",
			err_list	: true,
			callback	: 'prepareSubmit'
		});
	});
	function submitForm(){
		$('##manageForm').submit();		
	}
	function prepareSubmit(){
		$('##_buttonbar').slideUp("fast");
		$('##_loader').fadeIn("slow");		
		return true;
	}
</script>
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#js#">
<div id="content">
<!--- Title --->
<h2><img src="#rc.imgPath#/cog.png" align="absmiddle"> Lookup Manager > Add Lookup</h2>
<p></p>

<!--- Render Messagebox. --->
#getPlugin("messagebox").renderit()#

<!--- Configured Lookups --->
<form>
	<fieldset>
	<legend>Configured Lookups:</legend>
	<div>Connected to the <strong>#getDatasource('lookups').getName()#</strong> datasource</div>
	<table class="tablesorter" width="100%" id="setlookupsTable" cellspacing="1" cellpadding="0" border="0">
		<thead>
			<tr>
				<th>Lookup Alias</th>
				<th>Transfer Class</th>
			</tr>
		</thead>
		<tbody>
			<cfloop from="1" to="#ArrayLen(rc.SystemLookupsKeys)#" index="i">
			<tr>
				<td>#rc.SystemLookupsKeys[i]#</td>
				<td>#rc.systemLookups[rc.SystemLookupsKeys[i]]#</td>
			</tr>
			</cfloop>
		</tbody>
	</table>
	</fieldset>
</form>

<!--- New Lokups To Configure --->
<form name="manageForm" id="manageForm" action="#event.buildLink(rc.xehAddColumns)#" method="post">
	<fieldset>
	<legend>Choose Tables To Manage:</legend>
	<p>Please select only the tables you wish to manage that are <strong>NOT</strong> already configured as seen above.
	Please also enter the extra metadata necessary to create the lookup associations. All decorators created will be
	placed in this applications model folder.
	</p>
	
	<p>
		<label for="transferConfigPath">Transfer Config Path:</label>
		This will be the relative location of the transfer config file to modify with new looup information.<br />
		<strong>#getSetting("AppMapping")#/</strong><input type="text" size="80" value="config/transfer.xml.cfm" name="transferConfigPath" id="transferConfigPath">
	</p>
	
	<table class="tablesorter" width="100%" id="setlookupsTable" cellspacing="1" cellpadding="0" border="0">
		<thead>
		<tr>
			<th>Table</th>
			<th title="The alias used by the lookups manager">Lookup Alias</th>
			<th title="The transfer package-object name">Transfer Class</th>
			<th title="The decorator dot path">Decorator Path</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="rc.qTables">
		<cfif rc.qTables.table_type eq "TABLE">
		<tr>
			<td><label><input type="checkbox" name="tables" id="tables" value="#table_name#"> #table_name#</label></td>
			<td><input required="true" type="text" size="25" name="#table_name#_alias" id="#table_name#_alias" value="#capCase(table_name)#"></td>
			<td><input required="true" type="text" size="25" name="#table_name#_class" id="#table_name#_class" value="#Singularize(capCase(table_name))#"></td>
			<td><strong>model.</strong><input required="true" type="text" size="35" name="#table_name#_decorator" id="#table_name#_decorator" value="#Singularize(capCase(table_name))#"></td>
		</tr>
		</cfif>
		</cfloop>
		</tbody>
	</table>
	
	<!--- Hidden Loader --->
	<div id="_loader" class="formloader">
		<p>
			Submitting...<br />
			<img src="#rc.imgPath#/ajax-loader-horizontal.gif" align="absmiddle">
			<img src="#rc.imgPath#/ajax-loader-horizontal.gif" align="absmiddle">
		</p>
	</div>
	
	<!--- Create / Cancel --->
	<div id="_buttonbar">
		<a href="#event.buildLink(rc.xehLookupList,0)#" class="buttonLinks">
			<span>
				<img src="#rc.imgPath#/cancel.png" border="0" align="absmiddle" alt="Cancel" />
				Cancel
			</span>
		</a>
		&nbsp;
		<a href="javascript:submitForm()" class="buttonLinks">
			<span>
				<img src="#rc.imgPath#/add.png" border="0" align="absmiddle" alt="Add" />
				Next Step
			</span>
		</a>
	</div>
	</fieldset>
</form>
</div>
</cfoutput>
