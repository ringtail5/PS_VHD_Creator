#Asks for the number of disks to be created then creates that
#number of virtual hard drives at the input path.
$NumberOfVHDs = Read-Host "How many drives do you want to create?"
$DriveSize = Read-Host "How big would you like each drive?(include MB/GB/TB)"
$DestinationPath = Read-Host "What is the distination path of the created drives? (c:\dir\dir)"
#Converts the drive size variable to an integer and sizes it based off of the units included in the initial input
$DriveSizeInt = if ($DriveSize -like "*tb")
{
    $DriveSize1 = $DriveSize.TrimEnd("T", "B", "t", "b")
    [int]$DriveSize1 * 1099511627776
}
elseif ($DriveSize -like "*gb")
{
    $DriveSize1 = $DriveSize.TrimEnd("G", "B", "g", "b")
    [int]$DriveSize1 * 1073741824
}
elseif ($DriveSize -like "*mb")
{
    $DriveSize1 = $DriveSize.TrimEnd("M", "B", "m", "b")
    [int]$DriveSize1 * 1048576
}
#Checks if the destination path already exists, advise the user if it does not.
if (Test-Path -Path $DestinationPath )
{
    Write-Host "The path already exists, the new VHD will be added to the specified location."
}
else
{
    Read-Host "The Destination Path does not currently exist. If you do not wish to create the path provided, use Ctrl-C to break out of this program now or press any key to continue."
}
for ($i = 0; $i -lt [int]$NumberOfVHDs; $i++) {
    New-VHD -Path ($DestinationPath + "\VirtualDisk" + $i + ".vhdx") -SizeBytes $DriveSizeInt
}
#Add a portion that automatically adds the drives to a Hyper-V Virtual Machine
#Add a portion that automatically adds the drives to a Hyper-V Virtual Machine
Get-VM * | Sort-Object -Property Name | Format-Table
$continue = Read-Host "Would you like to add these drives to a Hyper-V Virtual Machine (above is a list of available VMs)? y or n"
if ($continue.ToLower() -eq "y")
{
    $VMName = Read-Host "Which VM would you like to add the drives to? (Name)"
    for ($i = 0; $i -lt [int]$NumberOfVHDs; $i++) 
    {
        Get-VM $VMName | Add-VMHardDiskDrive -Path ($DestinationPath + "\VirtualDisk" + $i + ".vhdx") -ControllerType SCSI
    } 
}