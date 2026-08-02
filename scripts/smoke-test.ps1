param(
    [string]$BaseUrl = $(if ($env:API_BASE_URL) { $env:API_BASE_URL } else { "http://localhost:8080" }),
    [int]$TimeoutSeconds = $(if ($env:SMOKE_TEST_TIMEOUT_SECONDS) { [int]$env:SMOKE_TEST_TIMEOUT_SECONDS } else { 60 })
)

$ErrorActionPreference = "Stop"
$startTime = Get-Date

function Write-SmokeLog {
    param([string]$Message)
    Write-Host "[smoke-test] $Message"
}

function Fail-SmokeTest {
    param([string]$Message)
    Write-Error "[smoke-test] ERROR: $Message"
    exit 1
}

function Invoke-SmokeEndpoint {
    param(
        [string]$Path,
        [int]$ExpectedStatusCode = 200
    )

    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl$Path" -UseBasicParsing
    }
    catch {
        Fail-SmokeTest "$Path failed: $($_.Exception.Message)"
    }

    if ($response.StatusCode -ne $ExpectedStatusCode) {
        Fail-SmokeTest "Expected $ExpectedStatusCode from $Path, got $($response.StatusCode)."
    }

    Write-SmokeLog "$Path returned $($response.StatusCode)."
}

Write-SmokeLog "Using API base URL: $BaseUrl"
Write-SmokeLog "Waiting for readiness for up to ${TimeoutSeconds}s..."

while ($true) {
    try {
        Invoke-WebRequest -Uri "$BaseUrl/health/ready" -UseBasicParsing | Out-Null
        Write-SmokeLog "API is ready."
        break
    }
    catch {
        $elapsed = ((Get-Date) - $startTime).TotalSeconds
        if ($elapsed -ge $TimeoutSeconds) {
            Fail-SmokeTest "API did not become ready within ${TimeoutSeconds}s."
        }

        Start-Sleep -Seconds 2
    }
}

Invoke-SmokeEndpoint "/health/live"
Invoke-SmokeEndpoint "/health/ready"
Invoke-SmokeEndpoint "/api/vehicles"

Write-SmokeLog "Smoke test completed successfully."
