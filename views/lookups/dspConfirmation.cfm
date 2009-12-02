<cfoutput>
<div id="content">
<!--- Title --->
<h2><img src="#rc.imgPath#/cog.png" align="absmiddle"> Lookup Manager > Creation Formation</h2>
<p></p>

<!--- Render Messagebox. --->
#getPlugin("messagebox").renderit()#

<!--- Configured Lookups --->
<form>
	<fieldset>
	<legend>Last Step:</legend>
	<div>The application has been marked for restart.  If you refresh this page or click on the 
		Back to Listing button below, the application will try to restart itself with the new information.
		If an error ocurrs, please make sure all the files are generated correctly.
	</div>
	<br />
	&nbsp;
	<a href="#event.buildLink(rc.xehLookupList)#" class="buttonLinks">
		<span>
			<img src="#rc.imgPath#/arrow_refresh.png" border="0" align="absmiddle" alt="Add" />
			Back To Listing
		</span>
	</a>
	
	</fieldset>
</form>

</div>
</cfoutput>
