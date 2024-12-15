## Assemblies and modules ##
Add-Type -AssemblyName System.Windows.Forms

## Script globals ##
$global:pixels = [Object[]]::new(64)    # Array of picture box elements - this determines size of array
$global:columns = 8                     # Number of columns, should be a multiple of $global:pixels.count
$global:currentColor = "#FF0000"        # Initial background color of pixels

## Script local functions ##

# exportCode
# Exports the current pixels grid to a C-style array 
function exportCode {
    # C-style arrays start with brace
    Write-Host -NoNewline "{"

    # Iterate thru the pixels array and write the value for each pixel
    for ( $index = 0 ; $index -lt $global:pixels.count ; $index++ ) {
        # Add a newline every 'columns' column
        if ($index -ne 0 -and $index -lt $global:pixels.count) {
            if ( (($index%$global:columns)) -eq 0 ) { Write-Host "" } 
        }

        # Get the background color of the pixel's picturebox and write the tuple
        $exportColor = $pixels[$index].BackColor
        Write-Host -NoNewline "{"; Write-Host -NoNewline $exportColor.R; Write-Host -NoNewline ","
        Write-Host -NoNewline $exportColor.G; Write-Host -NoNewline ","
        Write-Host -NoNewline $exportColor.B; Write-Host -NoNewline "}"

        # Add a comma between tuples
        if ($index -lt ($global:pixels.count-1)) { Write-Host -NoNewline ","}        
    }  
    
    # Add the closing brace
    Write-Host "}"  
}

# importCode
# Imports a BMP file to the pixel grid
function importCode {
    # Create an open file dialog to grab the file path    
    $imagePath = New-Object System.Windows.Forms.OpenFileDialog
    $imagePath.ShowDialog()

    # Store the BMP while working
    $previewBmp = [System.Drawing.Bitmap]::new($imagePath.FileName)

    # Start in the upper-right corner of the bitmap, moving backwards (left)
    $myx = $previewBmp.Width - 1
    $myy = 0
    $rowForward = $false

    # Show the image in the preview picture box
    #$previewPic.Image =

    # Iterate thru the array, keep track of BMP coords in myx and myy
    for ( $index = 0 ; $index -lt ($global:pixels.Count) ; $index++ ) {     
        if ($index -ne 0) { 
            if ( (($index%$global:columns)) -eq 0 )  {   # Index evenly divisible by number of columns?
                # Yes - We're at the end of a row, invert direction, set myx appropriately 
                if ($rowForward) { 
                    $myx = $previewBmp.Width - 1
                    $rowForward = $false
                }
                else {
                    $myx = 0 
                    $rowForward = $true
                } 
               
                $myy++           
            } 
        }

#        Write-Host " $myx $myy "
#        Write-Host $previewBmp.GetPixel($myx,$myy)

        # Set the BackColor of the pictureBox to the BMP's pixel color
        $global:pixels[$index].BackColor = $previewBmp.GetPixel($myx,$myy)

        # Increment x counter based on direction of traversal 
        if ($rowForward) { $myx++} else { $myx-- }         
    }
}

## Main procedure ##

# Create the windows form object
$myform = New-Object System.Windows.Forms.Form
$myform.Text = "Pixel Editor"
$myform.Size = New-Object System.Drawing.Size(520,620)  # This should probably be dynamic based on $global.pixels.count

$offset = -40+(($global:columns-2) * 80)    # X coordinate on form (form coordinate)
$rowForward = $false                        # Direction of row traversal
$row = 10                                   # Y coordinate on form (form coordinate)

# Iterate thru the pixels array, creating a pictureBox
# control on the form for each pixel.  The background
# color of each pictureBox represents the corresponding
# pixel's color
for ( $index = 0 ; $index -lt $global:pixels.count ; $index++ )
{
    # Do end of row stuff except for first pixel
    if ($index -ne 0){ 
        if ( (($index%$global:columns)) -eq 0 )   # Index evenly divisible by number of colums?
        {   
            # Yes - end of row.  Invert traversal direction, reset offset
            if ($rowForward) 
            { 
                $offset = -40+(($global:columns-2) * 80 )  # X max
                $rowForward = $false    # Switch to moving left
            }
            else
            {
                $offset = 20 # X Min
                $rowForward = $true  # Switch to moving right
            } 
           
            $row += 60  # Move to next row       
        } 
    }

    # Create the Windows Forms pictureBox object for this pixel and add to form
    $pixels[$index] = New-Object System.Windows.Forms.PictureBox
    $pixels[$index].Location = New-Object System.Drawing.Point($offset, $row)
    $pixels[$index].Size = New-Object System.Drawing.Size(50,50)
    $pixels[$index].Name = $index
    $pixels[$index].BackColor = "#000000"
    $pixels[$index].BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $pixels[$index].Add_Click( { $args[0].BackColor = $global:currentColor; write-host $args[0].Name } ) 
    $myform.Controls.Add($pixels[$index])

    # Move to next pixel (left or right, x)
    if ($rowForward) { $offset += 60 } else { $offset -= 60 }

}

# Create additional controls
$row+= 80  # Move down a little

# Color picker box
$colorBox = New-Object System.Windows.Forms.PictureBox
$colorBox.Location = New-Object System.Drawing.Point(20, $row)
$colorBox.Size = New-Object System.Drawing.Size(50,50)
$colorBox.BackColor = $currentColor
$colorBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$colorBox.Add_Click( {
     $colorPick = New-Object System.Windows.Forms.ColorDialog  # create a system color picker dialog
     $colorPick.ShowDialog()
     $global:currentColor = $colorPick.Color    # Set the current color to whatever was picked
                                                # This does not check if OK or cancel is clicked
     $args[0].BackColor = $global:currentColor  # Set background of the control that was clicked to the currentColor
})
$myform.Controls.Add($colorBox)

# Export to code button
$exportBtn = New-Object System.Windows.Forms.Button
$exportBtn.Text = "Export code..."
$exportBtn.Location = New-Object System.Drawing.Point(80, $row)
$exportBtn.Width = 90
$exportBtn.Height = 30
$exportBtn.Add_Click( { exportCode })
$myform.Controls.Add($exportBtn)

# Preview pictureBox (used during imports and maybe exports)
$previewPic = New-Object System.Windows.Forms.PictureBox
$previewPic.Size = New-Object System.Drawing.Size(8,8)
$previewPic.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$previewPic.Location = New-Object System.Drawing.Point(180, $row)
$myform.Controls.Add($previewPic)

# Import from BMP button
$importBtn = New-Object System.Windows.Forms.Button
$importBtn.Text = "import bmp..."
$importBtn.Location = New-Object System.Drawing.Point(240, $row)
$importBtn.Width = 90
$importBtn.Height = 30
$importBtn.Add_Click( { importCode })
$myform.Controls.Add($importBtn)

# Show the completed form
$myform.ShowDialog()

# This script will remain running until the form is closed.