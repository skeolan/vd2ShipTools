#Example Usage
# cls; Display-ShipData.ps1 -SourceDirectory "ShipData\Fighters" | where-object { $_.Name -ilike "Arsonist" }
# cls; Display-ShipData.ps1 -SourceDirectory "ShipData" |  format-table

[CmdletBinding()]
param(
    $SourceDirectory = "ShipData"
)

Enum Faction
{
    Beggar    = 1
    Civilian  = 2
    Kind      = 3
    Stubs     = 3
    Outsider  = 4
    Outsider2 = 4
    Reborn    = 5
    MU        = 6
    RockGuys  = 6
    Pride     = 7
    ThePride  = 7
    TSF       = 8
    Player    = 9
}

Enum ShipClass
{
    Fighter_Drone = 1
    Drone         = 1
    Fighter       = 2
    Gunship       = 3
    Corvette      = 4
    Frigate       = 5
    Destroyer     = 6
    Cruiser       = 7
    Carrier       = 8
    Dreadnaught   = 9
    Transport     = 10
    Mining        = 11
    Repair        = 12
    Shuttle       = 13
    Capture       = 14
    ShipCapture   = 15
    Ship_Capture  = 15
    Builder       = 16
}

Enum ShipClassSize
{
    Light
    Medium
    Heavy
}

function Get-Attr()
{
    param(
        $ship,
        $attrName
    )
    
    #return
    $ship.$attrName.attr1
}

function Get-NestedAttr()
{
    param(
        $ship,
        $groupName,
        $attrName
    )
    
    #return
    $ship.$groupName.$attrName.attr1
}

function Get-CaptureResistance()
{
    param(
        $Class,
        $Faction
    )

    #Return
    "TODO"
}

function Get-WikiTableCode()
{
    param(
        $shipData
    )
    
    $template = "{{Ship|title1 = $($shipData[1])|image1 = $($shipData[1]).png|row1 = $($shipData[2])|row2 = $($shipData[3])|row3 = $($shipData[4])|row4 = $($shipData[5])|row5 = $($shipData[6])|row6 = $($shipData[7])|row7 = $($shipData[8])|row8 = $($shipData[9]) seconds|row9 = $($shipData[10])|row10 = $($shipData[11])|row11 = $($shipData[12])|row12 = $($shipData[13])|row13 = $($shipData[14])|row14 = $($shipData[15])|row15 = $($shipData[16])|row16 = $($shipData[17])|row17 = $($shipData[18])|row18 = $($shipData[19])|row19 = $($shipData[20])}}"
    
    #return
    $template
}

function Get-WikiDescriptionText()
{
    param(
        $shipData
    )
    
    $description = "''"+[string]::Join("''`n''", $ship.DescriptionText.attr1)+"''"
    $description = $description -replace "\[colour='FFFFFFFF'\]", "}}" 
    $description = $description -replace "\[colour='FFFFFF00'\]", "{{color|#FFFF00|" # Yellow
    $description = $description -replace "\[colour='FFFF0000'\]", "{{color|#FF0000|" # Red
    $description = $description -replace "'' ''", "" # Blank lines
    
    #return
    """$description"""
}

function display-ship()
{
    param(
        $ship
    )
    $hash = [Ordered]@{
        "Faction"               = [Faction]::(Get-Attr $ship "faction")
        "Name"                  = Get-Attr $ship "name"
        "Class"                 = [ShipClass]::(Get-Attr $ship "shipClass")
        "Class Size"            = [ShipClassSize]::(Get-Attr $ship "shipClassSize")
        "Base Credit Cost"      = [int](Get-Attr $ship "creditCost")
        "ShipHp"                = [int](Get-Attr $ship "health")
        "Base Shield Gen"       = [int](Get-Attr $ship "shieldHealth")
        "Armor Rating"          = [int](Get-Attr $ship "armor") 
        "Cruise Speed"          = [int](Get-Attr $ship "cruiseSpeed")
        "Time till Cruise"      = [double](Get-Attr $ship "timeTillCruise")
        "Yaw Max"               = [int](Get-Attr $ship "yaw")
        "Pitch Max"             = [int](Get-Attr $ship "pitch")
        "Roll Max"              = [int](Get-Attr $ship "roll")
        "Afterburner"           = if([int](Get-NestedAttr $ship "afterburner" "multiplier") -gt 0) { "Installed"} else {"No"}
        "Ab Cap"                = [double](Get-NestedAttr $ship "afterburner" "capacity")
        "Ab Recharge"           = [double](Get-NestedAttr $ship "afterburner" "recharge")
        "AB Rating"             = [double](Get-NestedAttr $ship "afterburner" "multiplier")
        "Capture Resistance"    = Get-CaptureResistance -Class [ShipClass]::(Get-Attr $ship "shipClass") -Faction [Faction]::(Get-Attr $ship "faction")
        "Primary Upgrades"      = [Math]::Max([int](Get-NestedAttr $ship "upgrades" "primaryUpgradeCapacity"), 1)
        "Secondary Upgrades"    = 0
        "Active Upgrades"       = [Math]::Max([int](Get-NestedAttr $ship "upgrades" "activeUpgradeCapacity"), 1)
        "Mission Rank Required" = [int](Get-Attr $ship "missionRankRequired")
        "WikiTableCode"         = ""
        "DescriptionText"       = ""
        "WikiPageCode"          = ""
    }
    $shipData = new-object PSObject -Property $hash
    $shipData.WikiTableCode = Get-WikiTableCode -shipData $hash
    $shipData.DescriptionText = Get-WikiDescriptionText -shipData $ship
    $shipData.WikiPageCode = Create-ShipWikiPage -ship $shipData
    
    #return
    $shipData
}

function Create-ShipWikiPage()
{
    param(
        $ship
    )
$ShipWikiData = @"
$($ship.WikiTableCode)

Ingame Description: $($ship.DescriptionText)

== Usage and tactics ==
* wip

== List of upgrades ==

* wip

== Trivia ==
* wip

"@

#return
$ShipWikiData

}

# Main
$ShipFileList = (Get-ChildItem $SourceDirectory -Recurse -Attributes !Directory).FullName 

$ShipDataSet = @()

foreach ($shipFile in $ShipFileList)
{ 
    $rawShipFileContent = (get-content $shipFile) -replace "<\?.*\?>", ""
    
    $shipData = [xml]("<ship>" + $rawShipFileContent + "`n</ship>")
    
    $ShipDataSet += display-ship -ship $shipData.ship
} 

#Return
$ShipDataSet | where-object { $_.Faction -ne [Faction]::Outsider } | sort-object -Property `
    @{Expression = {$_.Class}; Descending = $false}, 
    @{Expression = {$_.'Class Size'}; Descending = $false}, 
    @{Expression = {$_.Speed}; Descending = $true}