param([string]$InputPath="default",
      [string]$Duration='0')
    
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
    $cpath = $pwd;
    if($InputPath -eq "default")
    {
        Write-Host 'Select directory with files to decompress';

        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) 
        {
            $InputPath = $dialog.SelectedPath
            Write-Host "Directory selected is $InputPath"
        }
    }
    if (-Not (Test-Path ".\Extracted")) 
    {
        New-Item -Path ".\" -Name "Extracted" -ItemType Directory -Force
    }
    $Files = Get-ChildItem $InputPath
    ForEach ($File in $Files)
    {
        $Ext = [System.IO.Path]::GetExtension($File)
        if($Ext -eq ".pack" -Or $Ext -eq ".pck" -Or $Ext -eq ".BNK")
        {
            try 
            {
                .\QBMS\quickbms.exe -F "*.wav" -K ".\wavescan.bms" "$($InputPath)\$($File)" ".\Extracted"
            }
            catch 
            {
                Write-Host $_
            }
        }
    }

    if (-Not (Test-Path ".\Decoded")) 
    {
        New-Item -Path ".\" -Name "Decoded" -ItemType Directory -Force
    }


    $ExtractedFiles =  Get-ChildItem ".\Extracted"
    $path = "$($cpath)\Decoded\$($ExtractedFiles[0])"
    $shell = New-Object -COMObject Shell.Application
    $folder = Split-Path $path
    $shellfolder = $shell.Namespace($folder)
    ForEach ($File in $ExtractedFiles)
    {
        .\VGMSTREAM\vgmstream-cli.exe ".\Extracted\$($File)" -o ".\Decoded\$($File)"
        $path = "$($cpath)\Decoded\$($File)"
        $file = Split-Path $path -Leaf
        $shellfile = $shellfolder.ParseName($file)
        $Time = $shellfolder.GetDetailsOf($shellfile, 27); #Windows 10
        $Seconds = Length-to-seconds -Length $Time
        if ($Seconds -lt $Duration)
        {
            Remove-Item -path ".\Decoded\$($File)"
        }
    }
    Write-Host ".\Decoded\$($File)"
    Remove-Item -path ".\Extracted" -recurse

}
catch 
{
    Write-Host $_
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');