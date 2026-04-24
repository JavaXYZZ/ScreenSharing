⚙️ What it does:

• Launches multiple PowerShell scripts from remote GitHub sources
• Runs system utility modules (services, directories, and environment checks)
• Includes tools that scan for unusual or suspicious system configurations
• Can analyze system folders like recent files and temporary directories
• Performs integrity-style checks on areas like services and prefetch data (depending on the module)
• Includes tools that may detect duplicate or alternate account usage (based on external script logic)

🌐 How it works:

Runs PowerShell with execution policy bypass (session-only)
Opens new command instances for each module
Pulls and executes scripts directly from online repositories
Each module runs independently and may perform different checks

📊 Analytics (optional):

This tool sends a simple usage ping (timestamp only) to a Discord webhook when launched, used only to track how often the tool is run. No personal files or system data are collected by the launcher itself.
