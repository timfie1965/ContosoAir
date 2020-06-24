Add-PSSnapin -Name Microsoft.SharePoint.PowerShell

function Get-DataTable
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true,ParameterSetName="Individual")]
        [string]$DatabaseName,

        [Parameter(Mandatory=$true,ParameterSetName="Individual")]
        [string]$DatabaseServer,

        [Parameter(Mandatory=$true,ParameterSetName="ConnectionString")]
        [string]$ConnectionString,


        [Parameter(Mandatory=$true,ParameterSetName="Individual")]
        [Parameter(Mandatory=$true,ParameterSetName="ConnectionString")]
        [string]$Query,

        [Parameter(Mandatory=$false,ParameterSetName="Individual")]
        [Parameter(Mandatory=$false,ParameterSetName="ConnectionString")]
        [int]$CommandTimeout=30, # The default is 30 seconds

        [Parameter(Mandatory=$false,ParameterSetName="Individual")]
        [Parameter(Mandatory=$false,ParameterSetName="ConnectionString")]
        [HashTable]$Parameters = @{}
    )

    begin
    {
        if( $PSCmdlet.ParameterSetName -eq "Individual" )
        {
            $ConnectionString = "Data Source=$DatabaseServer;Initial Catalog=$DatabaseName;Integrated Security=True;Enlist=False;Connect Timeout=5"
        }
    }
    process
    {
        try
        {
            $dataSet     = New-Object System.Data.DataSet     
            $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter( $Query, $ConnectionString )
            
            foreach( $Parameter in $Parameters.GetEnumerator() )
            {
                $param = $dataAdapter.SelectCommand.Parameters.AddWithValue( "@$($Parameter.Key)", $Parameter.Value )
            }

            $dataAdapter.Fill($dataSet) | Out-Null
            return $dataSet.Tables[0]
        }
        catch
        {
            throw $_.Exception
        }
        finally
        {
            if($dataSet)
            {
                $dataSet.Dispose()
            }

            if($dataAdapter)
            {
                $dataAdapter.Dispose()
            }
        }
    }
    end
    {
    }
}


$rows = Import-Csv -Path "E:\_temp\csv.csv" -Header "scanner", "query"

$databases = Get-SPContentDatabase

foreach( $row in $rows )
{
    foreach( $database in $databases )
    {
        Get-DataTable -ConnectionString $database.DatabaseConnectionString -Query $row.query | FL *
    }

}