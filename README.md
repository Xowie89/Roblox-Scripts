# 🎮 Roblox Scripts Collection

A collection of automation and utility scripts for various Roblox games, featuring game-specific exploits and a universal command interface.

## 📋 Table of Contents

- [🚀 Features](#-features)
- [🎯 Supported Games](#-supported-games)
- [📖 Usage](#-usage)
- [🛠️ Installation](#️-installation)
- [📁 Script Descriptions](#-script-descriptions)
- [⚠️ Disclaimer](#️-disclaimer)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [💬 Discord](#-discord)

## 🚀 Features

- **Universal Hub**: Automatic game detection and script loading
- **Game-Specific Automation**: Tailored scripts for different Roblox games
- **Advanced Command UI**: Comprehensive player manipulation and utility tools
- **ESP & Aimbot**: Visual enhancements and targeting systems
- **Anti-AFK**: Prevents automatic disconnection
- **Cross-Game Compatibility**: Works across multiple supported games

## 🎯 Supported Games

| Game | Place ID | Script Features |
|------|----------|----------------|
| **Anime Training Simulator** | `7114796110` | Protected automation features |
| **Hospital Tycoon** | `7050008107` | Protected automation features |
| **Factory Simulator** | `6769764667` | Protected automation features |
| **Mall Tycoon** | `5736409216` | Cash collection, auto-building, rebirth automation |
| **Item Factory** | `7280506312`, `8384895168` | Protected automation features |

## 📖 Usage

### Quick Start

1. **Load the Universal Hub**:
   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Xowie89/Roblox-Scripts/main/Hub.lua"))()
   ```

2. **Individual Game Scripts**:
   ```lua
   -- Mall Tycoon
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Xowie89/Roblox-Scripts/main/Mall%20Tycoon.lua"))()
   
   -- Anime Training Simulator
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Xowie89/Roblox-Scripts/main/Anime%20Training%20Simulator.lua"))()
   ```

3. **Command UI** (Universal utility script):
   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Xowie89/Roblox-Scripts/main/CommandUI.lua"))()
   ```

## 🛠️ Installation

### Method 1: Executor Console
1. Open your Roblox executor
2. Paste the desired script URL into the console
3. Execute the script

### Method 2: Auto-Execute
1. Save the script files to your executor's autoexec folder
2. Join a supported Roblox game
3. Scripts will load automatically

## 📁 Script Descriptions

### 🔧 Hub.lua
- **Purpose**: Universal launcher and game detector
- **Features**: 
  - Automatic game detection by Place ID
  - Loads appropriate scripts for supported games
  - Error notifications for unsupported games

### 🎮 CommandUI.lua
- **Purpose**: Comprehensive player utility and manipulation tool
- **Features**:
  - **Player Controls**: Fly, noclip, spin, teleportation
  - **ESP Systems**: Box ESP, tracer ESP, body highlighting
  - **Aimbot**: Customizable targeting with FOV circle
  - **Teleportation**: Click teleport, player targeting, looped teleport
  - **Character Manipulation**: Bang, headsit, facesit animations
  - **Lighting Controls**: Fullbright, fog removal, time control
  - **Server Utilities**: Server hopping, rejoin functionality
  - **Settings**: Persistent configuration saving

### 🏢 Mall Tycoon.lua
- **Purpose**: Automation script for Mall Tycoon gameplay
- **Features**:
  - Auto cash collection
  - Automatic building purchases
  - Smart store selection based on profitability
  - Automatic setpiece selection
  - Rebirth automation
  - Discord integration

### 🥷 Protected Scripts
The following scripts are protected by MoonSecV2:
- `Anime Training Simulator.lua`
- `Factory Simulator [OVERHAUL].lua`
- `Hospital Tycoon.lua`
- `Item Factory.lua`

These scripts contain advanced automation features but are obfuscated for security.

## ⚠️ Disclaimer

> **Important**: These scripts are for educational purposes only. Using exploits in Roblox games may violate the game's Terms of Service and could result in account termination. Use at your own risk.

- Scripts are provided "as-is" without warranty
- The author is not responsible for any consequences of using these scripts
- Always test scripts in private servers first
- Respect other players and avoid disrupting gameplay

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Contribution Guidelines
- Follow Lua coding standards
- Test all changes thoroughly
- Update documentation for new features
- Respect the existing code structure

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License - Copyright (c) 2023 Xowie89
```

## 💬 Discord

Join our Discord community for support, updates, and discussions:

**Discord Server**: `https://discord.gg/WbqreSvspk`

### Discord Features
- Script support and troubleshooting
- Feature requests and suggestions
- Community discussions
- Early access to new scripts
- Direct contact with developers

---

## 🔧 Technical Details

### Requirements
- Compatible Roblox executor (Synapse X recommended)
- Internet connection for script loading
- Supported Roblox game

### Configuration
Most scripts include configurable settings:
- Speed adjustments
- Toggle options for different features
- Keybind customization
- Auto-save functionality

### Performance
- Scripts are optimized for minimal impact
- Memory-efficient design
- Automatic cleanup on game leave
- Background processing for smooth gameplay

---

<div align="center">

**⭐ Star this repository if you found it helpful!**

Made with ❤️ by [Xowie89](https://github.com/Xowie89)

</div>