param([string]$InputPath=".\TEST1.pack",
      [string]$OutputPath1=".\Extracted",
      [string]$OutputPath2=".\Decoded",
      [string]$Duration='30')
    
function Length-to-seconds{
    param ( [string]$Length )

    $hours = "$($Length[0])$($Length[1])"
    $minutes = "$($Length[3])$($Length[4])"
    $seconds = "$($Length[6])$($Length[7])"
    $TotalSeconds = [int]$hours * 3600 + [int]$minutes * 60 + [int]$seconds
    return $TotalSeconds
}

try
{
    Add-Type -AssemblyName 'System.Windows.Forms'

    Write-Host 'Select directory with files to decompress';

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) 
    {
        $InputPath = $dialog.SelectedPath
        Write-Host "Directory selected is $InputPath"
    }

    $Files = Get-ChildItem $InputPath
    ForEach ($File in $Files)
    {
        $Ext = [System.IO.Path]::GetExtension($File)
        if($Ext -eq ".pack" -Or $Ext -eq ".pck" -Or $Ext -eq ".BNK")
        {
            try 
            {
                .\QBMS\quickbms.exe -F "*.wav" -K ".\wavescan.bms" "$($InputPath)\$($File)" $OutputPath1
            }
            catch 
            {
                Write-Host $_
            }
        }
    }

    if (-Not (Test-Path $OutputPath2)) 
    {
        New-Item -Path ".\" -Name "Decoded" -ItemType Directory
    }

    $ExtractedFiles =  Get-ChildItem $OutputPath1
    ForEach ($File in $ExtractedFiles)
    {
        #TODO: add bit rate flag
        .\VGMSTREAM\vgmstream-cli.exe "$($OutputPath1)\$($File)" -o "$($OutputPath2)\$($File)"
        $cpath = [System.Environment]::CurrentDirectory
        $path = "$($cpath)\Decoded\$($File)"
        $shell = New-Object -COMObject Shell.Application
        $folder = Split-Path $path
        $file = Split-Path $path -Leaf
        $shellfolder = $shell.Namespace($folder)
        $shellfile = $shellfolder.ParseName($file)
        $Time = $shellfolder.GetDetailsOf($shellfile, 27); #Windows 10
        $Seconds = Length-to-seconds -Length $Time
        if ($Seconds -lt $Duration)
        {
            Remove-Item -path "$($OutputPath2)\$($File)"
        }
    }
    Write-Host "$($OutputPath2)\$($File)"
    Remove-Item -path $OutputPath1 -recurse

}
catch 
{
    Write-Host $_
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');