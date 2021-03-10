# Prende il contenuto di un file e ne conta la frequenza delle parole
# È possibile specificare un limite inferiore alla frequenza
# È possibile specificare un array di parole da trascurare

function Group-WordsFromFile {

    [CmdletBinding()]
    param (
        [string] $FilePath,
        [string[]] $Exclude = @('di', 'e', 'a')
    )
    
    begin {
        # Do not consider frequencies lower than
        $LowerLimit = 6
    }
    
    process {

        $(Get-Content $FilePath) -split '\W+' |
        Group-Object -NoElement |
        Sort-Object count -Descending |
        Where-Object { ($_.Count -gt $LowerLimit) -and ($_.Name -notin $Exclude) }
    }

}

