#Define the Class
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
#Create the Window and add Elements (title, size, etc.)
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = 'Virtual Hard Drive Creator'
$mainForm.Width = 600
$mainForm.Height = 250
$mainForm.StartPosition = 'CenterScreen'
$mainForm.AutoSize = $true
#Add OK Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Top = ($mainForm.Height - 33)
$okButton.Left = ($mainForm.Width - 160)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$mainForm.AcceptButton = $okButton
$mainForm.Controls.Add($okButton)
#Add Cancel Button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Top = ($okButton.Top)
$cancelButton.Left = ($okButton.Left + 75)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$mainForm.CancelButton = $cancelButton
$mainForm.Controls.Add($cancelButton)
#Hard Drive Quantity
$groupBox1 = New-Object System.Windows.Forms.GroupBox
$groupBox1.Location = New-Object System.Drawing.Point(5,5)
$groupBox1.Size = New-Object System.Drawing.Size(590,40)
$groupBox1.Text = "Hard Drive Quantity"
$label1 = New-Object System.Windows.Forms.label
$label1.Text = "How many virtual hard drives do you want to create:"
$label1.Location = New-Object System.Drawing.Point(10,20)
$label1.AutoSize = $true
$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(280,15)
$textBox1.Size = New-Object System.Drawing.Size(40,20)
$groupBox1.Controls.AddRange(@($label1,$textBox1))
$mainForm.Controls.Add($groupBox1)
$mainForm.Add_Shown({$textBox1.Select()})
#Hard Drive Size
$groupBox2 = New-Object System.Windows.Forms.GroupBox
$groupBox2.Location = New-Object System.Drawing.Point(5,55)
$groupBox2.Size = New-Object System.Drawing.Size(590,40)
$groupBox2.Text = "Hard Drive Size"
$label2 = New-Object System.Windows.Forms.Label
$label2.Text = "How big do you want your hard drives to be:"
$label2.Location = New-Object System.Drawing.Point(10,20)
$label2.AutoSize = $true
$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = '280,15'
$textBox2.Size = '40,20'
$radioButton1 = New-Object System.Windows.Forms.RadioButton
$radioButton1.Location = '330,16'
$radioButton1.Size = '30,30'
$radioButton1.Checked = $false
$radioButton1.Text = "MB"
$radioButton1.AutoSize = $true
$radioButton2 = New-Object System.Windows.Forms.RadioButton
$radioButton2.Location = '380,16'
$radioButton2.Size = '30,30'
$radioButton2.Checked = $true
$radioButton2.Text = "GB"
$radioButton2.AutoSize = $true
$radioButton3 = New-Object System.Windows.Forms.RadioButton
$radioButton3.Location = '430,16'
$radioButton3.Size = '30,30'
$radioButton3.Checked = $false
$radioButton3.Text = "TB"
$radioButton3.AutoSize = $true
$groupBox2.Controls.AddRange(@($label2,$textBox2,$radioButton1,$radioButton2,$radioButton3))
$mainForm.Controls.Add($groupBox2)
#Destination Path for the new VHDs
$groupBox3 = New-Object System.Windows.Forms.GroupBox
$groupBox3.Location = New-Object System.Drawing.Point(5,105)
$groupBox3.Size = New-Object System.Drawing.Size(590,40)
$groupBox3.Text = "Hard Drive Path"
$label3 = New-Object System.Windows.Forms.Label
$label3.Text = "Where do you want your hard drives to be created:"
$label3.Location = '10,20'
$label3.AutoSize = $true
$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = '280,15'
$textBox3.Size = '240,20'
$button1 = New-Object System.Windows.Forms.Button
$button1.Location = '520,14'
$button1.Size = '22,20'
$button1.Text = "..."
$groupBox3.Controls.AddRange(@($label3,$textBox3,$button1))
$mainForm.Controls.Add($groupBox3)
$button1.Add_Click(
    {
        $shell = New-Object -ComObject Shell.Application
        $selectedfolder = $shell.BrowseForFolder(0, 'Select a folder to proceed', 16, $shell.NameSpace(17).Self.Path).Self.Path
        $textBox3.Text = $selectedfolder
    }
)
#Mount the VHDs to a particular VM
$groupBox4 = New-Object System.Windows.Forms.GroupBox
$groupBox4.Location = New-Object System.Drawing.Point(5,160)
$groupBox4.Size = New-Object System.Drawing.Size(590,40)
$groupBox4.Text = "VM for Drive Mounting"
$label4 = New-Object System.Windows.Forms.Label
$label4.Text = "Which VM do you want to mount the VHDs to:"
$label4.Location = '10,20'
$label4.AutoSize = $true
$comboBox4 = New-Object System.Windows.Forms.ComboBox
$comboBox4.Location = '280,15'
$comboBox4.Size = '240,20'
    # Populate the List
$itemsDisplayedIn_comboBox4 = (Get-VM)
ForEach ($item in $itemsDisplayedIn_comboBox4)
{
    $comboBox4.Items.Add($item.Name)
}
$groupBox4.Controls.AddRange(@($label4,$comboBox4))
$mainForm.Controls.Add($groupBox4)
#Display Window
$result = $mainForm.ShowDialog()
#Create VHDs if OK is clicked
if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
    $NumberOfVHDs = $textBox1.Text
    $DriveSize = $textBox2.Text
    $DestinationPath = $textBox3.Text
    $VMName = $comboBox4.Text
    #Alter side of drive based on radio button selection
        $DriveSizeInt = if ($radioButton3.Checked)
        {
            [int]$DriveSize * 1099511627776
        }
        elseif ($radioButton2.Checked)
        {
            [int]$DriveSize * 1073741824
        }
        elseif ($radioButton1.Checked)
        {
            [int]$DriveSize * 1048576
        }
    #create VHDs in path directed and of the indicated size
    for ($i = 0; $i -lt [int]$NumberOfVHDs; $i++) 
    {
        New-VHD -Path ($DestinationPath + "\" + $VMName + "VHD" + $i + ".vhdx") -SizeBytes $DriveSizeInt
    }
    #mount VHDs to indicated VM
    for ($i = 0; $i -lt [int]$NumberOfVHDs; $i++) 
    {
        Get-VM $VMName | Add-VMHardDiskDrive -Path ($DestinationPath + "\" + $VMName + "VHD" + $i + ".vhdx") -ControllerType SCSI
    } 
    [void][System.Windows.Forms.MessageBox]::SHOW("VHDs have been created at the requested location and mounted to the indicated VM.","Script Completed","OK","Information")
}