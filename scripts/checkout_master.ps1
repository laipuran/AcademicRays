# Checkout to master branch script
# This script cleans the Flutter project and switches to the master branch

Write-Host "Cleaning Flutter project..." -ForegroundColor Green

try {
    # Change to the Flutter project directory
    Set-Location -Path "academic_rays_fe" -ErrorAction Stop
    
    # Run flutter clean
    Write-Host "Running flutter clean..." -ForegroundColor Yellow
    flutter clean
    
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter clean failed with exit code $LASTEXITCODE"
    }
    
    # Change back to the root directory
    Set-Location -Path ".." -ErrorAction Stop
    
    Write-Host "Flutter project cleaned successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error during Flutter clean: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Switching to master branch..." -ForegroundColor Green

try {
    # Switch to master branch
    git checkout master
    
    if ($LASTEXITCODE -ne 0) {
        throw "Git checkout failed with exit code $LASTEXITCODE"
    }
    
    Write-Host "Successfully switched to master branch!" -ForegroundColor Green
    
    # Show current branch to verify
    $currentBranch = git branch --show-current
    Write-Host "Current branch: $currentBranch" -ForegroundColor Cyan
}
catch {
    Write-Host "Error switching to master branch: $_" -ForegroundColor Red
    exit 1
}