@echo off
echo Generating OAuth token for Anypoint Exchange...

curl -X POST "https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token" ^
     -H "Content-Type: application/json" ^
     -d "{\"client_id\": \"3f17ee390b8840a9ae90dad9fc1671c7\", \"client_secret\": \"477B5651a1cc4983930352b8b9975453\", \"grant_type\": \"client_credentials\"}" ^
     > token_response.json

echo.
echo Token response saved to token_response.json
echo.

if exist token_response.json (
    echo Token generated successfully!
    type token_response.json
) else (
    echo Failed to generate token.
)
