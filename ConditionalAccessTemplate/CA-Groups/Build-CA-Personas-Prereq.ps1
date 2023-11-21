function Create-CA-Group-BG{
    param (
        [string] $AdministrativeUnitId
    )

    #create break glass group
    $groupName = "CA-Persona-BreakGlassAccount"
    $groupDescription = "Group for Break Glass Account"

    $g = Get-MgBetaGroup -Filter "displayname eq '$groupName'"
    if(!$g){
        $g = New-MgBetaGroup -DisplayName $groupName -Description $groupDescription -SecurityEnabled:$true -MailEnabled:$false -MailNickname $groupName
    }        

    $params = @{
        "@odata.id" = "https://graph.microsoft.com/beta/groups/$($g.id)"
    }

    New-MgBetaAdministrativeUnitMemberByRef -AdministrativeUnitId $AdministrativeUnitId -BodyParameter $params

}

function Create-CA-Group-Persona{
    param (
        [string] $AdministrativeUnitId,
        [string] $persona
    )
    #create persona template groups
    $groups = Get-Content .\Groups-CA-Persona-Template.json | ConvertFrom-Json
    foreach ($group in $groups){
        $groupName = $group.Name.replace("{{PERSONA}}","$persona")
        $groupDescription = $group.Description.replace("{{PERSONA}}","$persona")

        $g = Get-MgBetaGroup -Filter "displayname eq '$groupName'"
        if(!$g){
            $g = New-MgBetaGroup -DisplayName $groupName -Description $groupDescription -SecurityEnabled:$true -MailEnabled:$false -MailNickname $groupName
        }        

        $params = @{
            "@odata.id" = "https://graph.microsoft.com/beta/groups/$($g.id)"
        }
        
        New-MgBetaAdministrativeUnitMemberByRef -AdministrativeUnitId $AdministrativeUnitId -BodyParameter $params
    }

}

function Create-CA-AU{
    $params = @{
        displayName = "CA-Groups"
        description =  "Administrative Unit Restricted user for controlling the conditional access" 
        isMemberManagementRestricted = $true
    }

    #check if AU exists
    $au = Get-MgBetaAdministrativeUnit -Filter "displayName eq '$($params.displayName)'"
    if(!$au){
        $au = New-MgBetaAdministrativeUnit -BodyParameter $params
    }

    return $au
}


function Create-CA-Groups {
    param (
        [string]$persona
    )
    
    #AdministrativeUnit.ReadWrite.All,Group.Create
    $au = Create-CA-AU
    Create-CA-Group-BG -AdministrativeUnitId $au.id
    Create-CA-Groups -persona $persona -AdministrativeUnitId $au.id

}