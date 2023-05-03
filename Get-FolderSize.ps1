Function Get-FolderSize {
    <#
.Synopsis
   Get folder sizes
.DESCRIPTION
   Get the folder sizes and displays the path and the totalsize
.EXAMPLE
   Get-FolderSize -Path D:\osl\Common
.EXAMPLE
   Get-FolderSize -Path D:\osl\Macvol | sort TotalSize -Descending | ft -AutoSize
#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]$Path
    )

    $code = { (‘{0:#,##0.0} GB’ -f ($this / 1GB)) }
    Get-ChildItem -Path $Path | Where-Object { $_.PSIsContainer } |
        ForEach-Object {
        Write-Progress -Activity ’Calculating Total Size for:’ -Status $_.FullName
        $sum = Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue
        $bytes = $sum.Sum

        if ($bytes -eq $null) {
            $bytes = 0
        }

        $result = 1 | Select-Object -Property Path, TotalSize
        $result.Path = $_.FullName
        $result.TotalSize = $bytes |
            Add-Member -MemberType ScriptMethod -Name toString -Value $code -Force -PassThru
        $result
    }
}
