function Convert-groupNameToId{
    param(
        [string[]] $groupsName
    )
    $groupsId = @()

    foreach($g in $groupsName){
        
        $groupsId += Get-MgBetaGroup -Filter "displayName eq '$g'" -Select Id | Select-Object id
    }

    return $groupsId.id

}

$policy = New-Object Microsoft.Graph.Beta.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy

#CA
$policy.displayName = "C001-GLOBAL-BaseProtection-AllApps-AnyPlatform-BlockNonPersonas"
$policy.state = "enabledForReportingButNotEnforced" #disabled,enabled

#conditions
$policy.conditions.users.includeUsers = @("all")
$policy.conditions.users.excludeGroups = Convert-groupNameToId -groupsName @("CA-Persona-Admins","CA-Persona-AzureServiceAccounts","CA-Persona-BreakGlassAccount","CA-Persona-CorpServiceAccounts","CA-Persona-Developers","CA-Persona-Externals","CA-Persona-Guests","CA-Persona-GuestsAdmins","CA-Persona-Internals","CA-Persona-Microsoft365ServiceAccounts","CA-Persona-WorkloadIdentities")
$policy.conditions.applications.includeApplications = @("all")
$policy.conditions.platforms.includePlatforms = @("all")

#grant
$policy.GrantControls.Operator = "OR"
$policy.GrantControls.builtInControls = @("block")

if($check){
    Get-MgBetaIdentityConditionalAccessPolicy -Filter "displayName eq '$($policy.displayName)'"
}else{
    New-MgBetaIdentityConditionalAccessPolicy -BodyParameter $policy
}
 
