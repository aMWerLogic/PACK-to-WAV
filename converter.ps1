param([string]$InputPath=".\TEST1.pack",
      [string]$OutputPath1=".\Extracted",
      [string]$OutputPath2=".\Decoded")
    
try
{
    Add-Type -AssemblyName 'System.Windows.Forms'
    
    Write-Host 'Select directory in wich to perform extraction procedure';
    
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
        .\VGMSTREAM\vgmstream-cli.exe "$($OutputPath1)\$($File)" -o "$($OutputPath2)\$($File)"
    }
    
    Remove-Item -path $OutputPath1 -recurse

}
catch 
{
    Write-Host $_
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');