<# 
.SYNOPSIS
    Builds a Docker image and pushes it to a Docker registry.
.PARAMETER ImageName
  The name of the Docker image.
.PARAMETER DockerFilePath
  The Path to the Dockerfile.
.PARAMETER ImageTag
  The Tag of the Docker image.
.PARAMETER AWSRegion
  The AWS region.
#>
function New-DockerImageBuildAndPush {
  param (
      [string]$ImageName="ecs-container",
      [string]$DockerFilePath="./ecs-container/Dockerfile",
      [string]$ImageTag="latest",  # latest is an anti-pattern, but this is just an POC
      [string]$AWSRegion="us-east-1"
  )
  $env:DOCKER_CONFIG="$(Get-Location)/docker-config"
  $TaggedImage = "$ImageName`:$ImageTag"
  $ECRRegistry = $(aws sts get-caller-identity --query Account --output text) + ".dkr.ecr.$AWSRegion.amazonaws.com"
  
  Push-Location $(Split-Path $DockerFilePath -Parent)

  Write-Host "Building Docker image $ImageName via $(Get-Location)/Dockerfile"
  docker build . -t $TaggedImage
  
  Pop-Location

  Write-Host "Tagging Docker image $ImageName with remote tag "$ECRRegistry/$TaggedImage""
  docker tag $TaggedImage "$ECRRegistry/$TaggedImage"

  Write-Host "Pushing image"
  docker push  "$ECRRegistry/$TaggedImage"
}