#Set Variables
$SAC_Files = "$env:USERPROFILE\documents\Steam Account Changer\"
$SAC_Usernames = "$env:USERPROFILE\documents\Steam Account Changer\usernames.txt"
$readme = "$env:USERPROFILE\documents\Steam Account Changer\readme.txt"

#--------------------------------------------------------------------------------------------
# Generate first time run files if required
Try
{
Get-Item -Path $SAC_Usernames -ErrorAction Stop
Get-Item -Path $readme
}
Catch
{
New-Item -ItemType directory -Path $SAC_Files
New-Item -ItemType file -Path $SAC_Usernames
New-Item -ItemType file -Path $readme
Set-Content $readme 'Welcome to my Steam Account Changer!

Below are the instructions for use. If you ever need to refer to these instructions again, click the "i" button on the main window.

Instructions for use;
1. Configure usernames using instructions for the editor below
2. Select desired username
3. Click "Login"
4. If this is the first time logging in, enter password and login. You will not have to do this again.

Editor Instructions;
1. Click "Editor"
2. Enter username to add or select username to delete
3. Click "Add User" or "Remove User"
4. Repeat as many times as needed
5. Close the editor or click "Finish"
'
Start-Process notepad.exe $readme
}

#--------------------------------------------------------------------------------------------

function switcher
{
    Stop-Process -Name steam
    $env:username = $Usernames.Text
    cmd.exe /C reg add "HKCU\Software\Valve\Steam" /v AutoLoginUser /t REG_SZ /d %username% /f
    cmd.exe /C reg add "HKCU\Software\Valve\Steam" /v RememberPassword /t REG_DWORD /d 1 /f
    start steam://open/main
}

#<<<<<<<<<<<<<<<<<<<< MAIN FORM START >>>>>>>>>>>>>>>>>>>>

# Create Base Form
Add-Type -Assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='SAC'
$main_form.Width = 0
$main_form.Height = 0
$main_form.AutoSize = $true

# Add 'Username' Label
$Label = New-Object System.Windows.Forms.Label
$Label.Text = 'Username'
$Label.Location = $Location + "0,10"
$Label.AutoSize = $true
$main_form.Controls.Add($Label)

# Add Username Selector
$Usernames = New-Object System.Windows.Forms.ComboBox
$Usernames.Width = 120
$Usernames.DropDownStyle = 'DropDownList'
$txtusers = Get-Content -Path $SAC_Usernames
ForEach ($user in $txtusers)
{
$Usernames.Items.Add($user);
}
$Usernames.Location = New-Object System.Drawing.Point(60,10)
$main_form.Controls.Add($Usernames)

# Add Login Button
$LoginButton = New-Object System.Windows.Forms.Button
$LoginButton.Location = New-Object System.Drawing.Point(5,40)
$LoginButton.Size = New-Object System.Drawing.Size(100,23)
$LoginButton.Text = "Login"
$main_form.Controls.Add($LoginButton)
$LoginButton.Add_Click({switcher})

# Add Readme Button
$Readme_Button = New-Object System.Windows.Forms.Button
$Readme_Button.Location = New-Object System.Drawing.Point(187,9)
$Readme_Button.Size = New-Object System.Drawing.Size(23,23)
$Readme_Button.Text = "i"
$main_form.Controls.Add($Readme_Button)
$Readme_Button.Add_Click(
{
Start-Process notepad.exe $readme
}
)
#<<<<<<<<<<<<<<<<<<<< MAIN FORM END >>>>>>>>>>>>>>>>>>>>

#<<<<<<<<<<<<<<<<<<<< EDITOR FORM START >>>>>>>>>>>>>>>>>>>>
# Create Editor Form
Add-Type -Assembly System.Windows.Forms
$Editor = New-Object System.Windows.Forms.Form
$Editor.Text ='Editor'
$Editor.Width = 0
$Editor.Height = 0
$Editor.AutoSize = $true

# Add 'Username' Label
$Editor_Label = New-Object System.Windows.Forms.Label
$Editor_Label.Text = 'Username'
$Editor_Label.Location = New-Object System.Drawing.Point(0,10)
$Editor_Label.AutoSize = $true
$Editor.Controls.Add($Editor_Label)

# Add Username Input Box
$Editor_UsernameBox = New-Object System.Windows.Forms.ComboBox
$Editor_UsernameBox.Width = 150
$txtusers = Get-Content -Path $SAC_Usernames
ForEach ($user in $txtusers)
{
$Editor_UsernameBox.Items.Add($user);
}
$Editor_UsernameBox.Location = New-Object System.Drawing.Point(60,10)
$Editor.Controls.Add($Editor_UsernameBox)

# Add 'Add user' button
$Editor_Add = New-Object System.Windows.Forms.Button
$Editor_Add.Location = New-Object System.Drawing.Point(5,40)
$Editor_Add.Size = New-Object System.Drawing.Size(100,23)
$Editor_Add.Text = "Add User"
$Editor.Controls.Add($Editor_Add)
$Editor_Add.Add_Click(
{
Add-Content -Path $SAC_Usernames -Value "$($Editor_UsernameBox.Text)"
$txtusers = Get-Content -Path $SAC_Usernames
$Editor_UsernameBox.Items.Clear()
$Usernames.Items.Clear()
ForEach ($user in $txtusers)
{
$Editor_UsernameBox.Items.Add($user);
$Usernames.Items.Add($user);
}
}
)

# Add 'Finish' button
$Editor_Finish = New-Object System.Windows.Forms.Button
$Editor_Finish.Location = New-Object System.Drawing.Point(5,65)
$Editor_Finish.Size = New-Object System.Drawing.Size(205,23)
$Editor_Finish.Text = "Finish"
$Editor.Controls.Add($Editor_Finish)
$Editor_Finish.Add_Click(
{
$Editor.Close()
$txtusers = Get-Content -Path $SAC_Usernames
$Editor_UsernameBox.Items.Clear()
$Usernames.Items.Clear()
ForEach ($user in $txtusers)
{
$Editor_UsernameBox.Items.Add($user);
$Usernames.Items.Add($user);
}
}
)

# Add 'Remove user' button
$Editor_Remove = New-Object System.Windows.Forms.Button
$Editor_Remove.Location = New-Object System.Drawing.Point(110,40)
$Editor_Remove.Size = New-Object System.Drawing.Size(100,23)
$Editor_Remove.Text = "Remove User"
$Editor.Controls.Add($Editor_Remove)
$Editor_Remove.Add_Click(
{
(Get-Content -Path $SAC_Usernames) | Where-Object { $_ -ne $Editor_UsernameBox.Text } | Set-Content $SAC_Usernames
Set-Content -Path $SAC_Usernames -Value (Get-Content $SAC_Usernames | Select-String -Pattern "`n" -NotMatch)
$txtusers = Get-Content -Path $SAC_Usernames
$Editor_UsernameBox.Items.Clear()
$Usernames.Items.Clear()
ForEach ($user in $txtusers)
{
$Editor_UsernameBox.Items.Add($user);
$Usernames.Items.Add($user);
}
$Editor_UsernameBox.ResetText()
}
)

# Add Editor Button
$EditorButton = New-Object System.Windows.Forms.Button
$EditorButton.Location = New-Object System.Drawing.Point(110,40)
$EditorButton.Size = New-Object System.Drawing.Size(100,23)
$EditorButton.Text = "Editor"
$main_form.Controls.Add($EditorButton)
$EditorButton.Add_Click(
{
$Editor.ShowDialog()
}
)
#<<<<<<<<<<<<<<<<<<<< EDITOR FORM END >>>>>>>>>>>>>>>>>>>>

$main_form.ShowDialog()