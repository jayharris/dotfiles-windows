# Update Chrome & Canary's DevTools to a custom stylesheet
# Uses: https://github.com/mauricecruz/chrome-devtools-zerodarkmatrix-theme
# Canary
Invoke-WebRequest "https://raw.github.com/mauricecruz/chrome-devtools-zerodarkmatrix-theme/master/Custom.css" -OutFile "$env:Home\AppData\Local\Google\Chrome SxS\User Data\Default\User StyleSheets\Custom.css"
# Chrome
Invoke-WebRequest "https://raw.github.com/mauricecruz/chrome-devtools-zerodarkmatrix-theme/master/Custom-Stable.css" -OutFile "$env:Home\AppData\Local\Google\Chrome\User Data\Default\User StyleSheets\Custom.css"

