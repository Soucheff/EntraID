Connect-MgGraph

#AdministrativeUnit.ReadWrite.All

$params = @{
	displayName = "CA-Groups"
	description =  "Administrative Unit Restricted user for controlling the conditional access" 
	isMemberManagementRestricted = $true
}

#check if AU exists
Get-MgBetaAdministrativeUnit -Filter "displayName eq '$($params.displayName)'"
New-MgBetaAdministrativeUnit -BodyParameter $params