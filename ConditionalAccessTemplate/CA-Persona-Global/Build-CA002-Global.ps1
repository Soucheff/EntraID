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

function Convert-appNameToId{
    param(
        [string[]] $appsName
    )
    $appsId = @()

    foreach($app in $appsName){
        $appsId += Get-MgBetaServicePrincipal -Filter "DisplayName eq '$app'" -Select appId | Select-Object appId
    }

    return $appsId.appId

}

$policy = New-Object Microsoft.Graph.Beta.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy
#CA
$policy.DisplayName = "C002-GLOBAL-AttackSrufaceReduction-VariosApps-AnyPlatform-Block"
$policy.State = "enabledForReportingButNotEnforced"

#conditions
$policy.Conditions.Users.IncludeUsers = @("all")
$policy.Conditions.Users.ExcludeGroups = Convert-groupNameToId -groupsName @("CA-Persona-BreakGlassAccount")
$policy.Conditions.Applications.IncludeApplications = Convert-appNameToId -appsName @("007 - Teste")
$policy.Conditions.Platforms.IncludePlatforms = @("all")

#grant
$policy.GrantControls.Operator = "OR"
$policy.GrantControls.BuiltInControls = @("block")
 
New-MgBetaIdentityConditionalAccessPolicy -BodyParameter $policy