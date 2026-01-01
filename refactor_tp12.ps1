$projectPath = "C:\DEV\Lechgar\DrissLechgarRepo\SeleniumScripts\downloads\TP-12 ( id 204 )\Rest-Benchmark-main"
$modules = @("benchmark-common", "variante-a-jersey", "variante-c-springboot-mvc", "variante-d-springdata-rest")
$newGroup = "com.youssef.benchmark"
$newPathStructure = "com\youssef\benchmark"

# 1. Update Root POM
$rootPom = "$projectPath\pom.xml"
if (Test-Path $rootPom) {
    (Get-Content $rootPom) -replace "<groupId>ma.rest</groupId>", "<groupId>$newGroup</groupId>" `
                           -replace "<artifactId>rest-benchmark-parent</artifactId>", "<artifactId>benchmark-api-suite</artifactId>" | Set-Content $rootPom
}

foreach ($mod in $modules) {
    Write-Host "Processing module: $mod"
    $modPath = "$projectPath\$mod"
    $srcJava = "$modPath\src\main\java"
    
    # 2. Update Module POM
    $modPom = "$modPath\pom.xml"
    if (Test-Path $modPom) {
        (Get-Content $modPom) -replace "<groupId>ma.rest</groupId>", "<groupId>$newGroup</groupId>" `
                              -replace "<artifactId>rest-benchmark-parent</artifactId>", "<artifactId>benchmark-api-suite</artifactId>" | Set-Content $modPom
    }

    # 3. Refactor Directory Structure
    $oldPkgDir = "$srcJava\ma\rest"
    $newPkgDir = "$srcJava\$newPathStructure"
    
    if (Test-Path $oldPkgDir) {
        New-Item -ItemType Directory -Force -Path $newPkgDir | Out-Null
        
        # Move contents
        Get-ChildItem "$oldPkgDir\*" -Recurse | Move-Item -Destination $newPkgDir -Force -ErrorAction SilentlyContinue
        
        # Remove old empty dirs
        Remove-Item "$srcJava\ma" -Recurse -Force -ErrorAction SilentlyContinue
    }

    # 4. Content Replacements (Package, Imports, Class Names)
    $javaFiles = Get-ChildItem -Path $modPath -Recurse -Filter "*.java"
    
    foreach ($file in $javaFiles) {
        $content = Get-Content $file.FullName -Raw
        
        # Package & Imports
        $content = $content -replace "package ma.rest;", "package $newGroup;"
        $content = $content -replace "package ma.rest", "package $newGroup"
        $content = $content -replace "import ma.rest", "import $newGroup"
        
        # Renaming Classes (Common Entities)
        $content = $content -replace "Client", "BenchmarkCustomer"
        $content = $content -replace "Compte", "BenchmarkAccount"
        
        # Variable Names
        $content = $content -replace "compte", "account"
        $content = $content -replace "client", "customer"
        
        Set-Content -Path $file.FullName -Value $content
        
        # Rename Files if they match
        if ($file.Name -eq "Client.java") { Rename-Item $file.FullName "BenchmarkCustomer.java" }
        if ($file.Name -eq "Compte.java") { Rename-Item $file.FullName "BenchmarkAccount.java" }
    }
}

# 5. Create README
$readmeContent = "# API Performance Benchmark Suite

## Overview
A comparative benchmark of different Java REST implementations, refactored by **Youssef Bahaddou**.
Measures implementation overhead and performance differences between frameworks.

## Modules
- **benchmark-common**: Shared Data Models (BenchmarkCustomer, BenchmarkAccount).
- **variante-a-jersey**: JAX-RS (Jersey) Implementation.
- **variante-c-springboot-mvc**: Spring Web MVC Implementation.
- **variante-d-springdata-rest**: Spring Data REST Implementation.

## How to Run
1. Build all modules:
   \`\`\`bash
   mvn clean package
   \`\`\`
2. Deploy desired variant (war or jar).
3. Run JMeter scripts located in \`jmeter/\`.

## Author
Youssef Bahaddou
"
Set-Content -Path "$projectPath\README.md" -Value $readmeContent

Write-Host "TP-12 Refactoring Complete!"
