# vd2ShipTools
Scripts for generating PSObject and Wikicode representations of ship data from Void Destroyer 2 [http://www.voiddestroyer.com]

# Example Usage
```powershell
cls
Display-ShipData.ps1 -SourceDirectory "ShipData\Fighters" | where-object { $_.Name -ilike "Hornet" }
Display-ShipData.ps1 -SourceDirectory "ShipData" |  format-table
# TODO: Example of producing wiki-text file output per ship
```

