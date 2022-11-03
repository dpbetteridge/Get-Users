$DESKTOP = [environment]::GetFolderPath("Desktop")

$TODAY = (Get-Date).ToString("yyyy-dd-M")

$DIR = "$DESKTOP\$TODAY\"

$ADMINS = net localgroup administrators
$ADMINS = $ADMINS[6..($ADMINS.count-3)]

$USERS = net localgroup users
$USERS = $USERS[6..($USERS.count-3)]

if (Test-Path $DIR) {
    Remove-Item $DIR -Force -Recurse}

New-Item $DIR -ItemType directory

function Get-Users {
    PROCESS {
        $DATA = net users                                                            # Runs the NET command to determine local user accounts
        $DATA = $DATA[4..($DATA.count-3)]                                            # Removes superfluous leading and following lines
        foreach ($LINE in $DATA) {                                                   # Iterates through all lines
            $LINE = $LINE -replace '\s+', ','                                        # Replaces all whitespaces with a comma
            $LINE = $LINE -replace '.$'                                              # Removes the trailing comma
            $LINE = $LINE -split ','                                                 # Splits each line on the comma
            foreach ($LINE2 in $LINE) {
                if ($ADMINS.Contains($LINE2)) {
                    $Admin = "X"
                } else {
                    $admin = "-"
                }
                if ($USERS.Contains($LINE2)) {
                    $User = "X"
                } else {
                    $User = "-"
                }
                $PROPERTIES = @{
                    Username = $LINE2
                    Admin = $Admin
                    User = $User
                }
            New-Object -TypeName PSObject -Property $PROPERTIES            
            }
        }
    }
}

Get-Users Select-Object -Property User | ForEach-Object {
    $_ | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $env:COMPUTERNAME -PassThru | Add-Member -MemberType NoteProperty -Name Date -Value $TODAY -PassThru } | Select-Object PsComputerName,Date,Username,Admin,User | Export-Csv $DIR$env:COMPUTERNAME"_Users.csv" -NoTypeInformation