Function Repair-AzureTags($resourceName,$resourceGroupName,$badKey,$correctKey){
   $target = Get-AzResource -ResourceGroupName $resourceGroupName -Name $resourceName
   $previousValue = $target.Tags.$badKey
   $target.Tags.Remove($badKey)
   $target.Tags.$correctKey = $previousValue
   $target | Set-AzResource -Tag $target.Tags -Force
}


Function Repair-AzureTags($oldKey,$newKey){
    $targets_resources = Get-AzResource | Where-Object{$_.Tags.Keys -match $oldKey} 
    $targets_resources | ForEach-Object {
        $OldKeyValue = $_.Tags.$oldKey
        $NewTag = @{$newKey=$OldKeyValue}
        $OldTag = @{$oldKey=$OldKeyValue}
        $resourceID = $_.ResourceId
        Update-AzTag -ResourceId $resourceID -Tag $NewTag -Operation Merge
        $Check = Get-AzResource -Id $resourceID | Where-Object {$_.Tags.Keys -match $newKey}
        if ($Check) {
            Update-AzTag -ResourceId $resourceID -Tag $OldTag -Operation Delete
        }
    }
}

Repair-AzureTags -oldKey Application_Owner -newKey ApplicationOwner
