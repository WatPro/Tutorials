$dir="TargetDirA"
New-Item -Path "." -Name "$dir" -ItemType "directory" -Force
New-Item -ItemType "file" -Path "./$dir/TargetFile1.txt", "./$dir/TargetFile2.txt" -Value "value" -Force
New-Item -ItemType "file" -Path "./$dir/NonTargetFile1.txt", "./$dir/NonTargetFile2.txt" -Force
$dir="TargetDirB" 
New-Item -Path "." -Name "$dir" -ItemType "directory" -Force
New-Item -ItemType "file" -Path "./$dir/NonTargetFile1.txt", "./$dir/NonTargetFile2.txt" -Force
$dir="TargetDirC" 
New-Item -Path "." -Name "$dir" -ItemType "directory" -Force
New-Item -ItemType "file" -Path "./$dir/TargetFile1.txt", "./$dir/TargetFile2.txt" -Value "value" -Force
New-Item -ItemType "file" -Path "./$dir/NonTargetFile1.txt", "./$dir/NonTargetFile2.txt" -Force
$dir="TargetDirD" 
New-Item -Path "." -Name "$dir" -ItemType "directory" -Force
$dir="NonTargetDirA"
New-Item -Path "." -Name "$dir" -ItemType "directory" -Force
New-Item -ItemType "file" -Path "./$dir/NonTargetFile1.txt", "./$dir/NonTargetFile2.txt" -Force
 
