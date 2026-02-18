# BegaBonk Contracts

This directory contains the Solidity smart contracts for the BegaBonk game.

## Contract Overview

### Begabonk

The main game contract implementing a survivor-style blockchain game with ZK proof verification.

**Contract Name:** `Begabonk`  
**License:** MIT  
**Solidity Version:** ^0.8.22

## Features

### Player Assets
- **Gold** - Primary currency for purchases
- **Diamonds** - Premium currency for purchases
- **Weapons** - Player weapons that can be upgraded
- **Skins** - Character skins that can be collected and upgraded

### Game Mechanics
- **Start Game** - Begin a new game session
- **Game Over** - End game session and record score (kills, time)
- **ReLive** - Continue playing after death (placeholder)

### Shop System
- **Buy/Upgrade Weapons** - Purchase new weapons or upgrade existing ones
- **Buy/Upgrade Skins** - Purchase new skins or upgrade existing ones

### Lottery System
- **Request Lottery** - Spend tokens for a chance to win gold, diamonds, weapons, or skins

### Leaderboard
- **Top 10 Players** - Track best players by kills
- **Chain Hash Support** - Supports both native EOA and Universal Accounts (Push Chain)

### Integrations
- **IUltraVerifier** - ZK proof verification for game results
- **IUEAFactory** - Universal Account integration (Push Chain at `0x00000000000000000000000000000000000000eA`)

## Getting Started

### Build
```bash
npm run build
# or
yarn build
```

### Deploy
```bash
npm run deploy
# or
yarn deploy
```

### Release
```bash
npm run release
# or
yarn release
```

## Contract Functions

### Owner Functions
- `initWeaponAndSkinData()` - Initialize weapon and skin prices
- `initLotteryList()` - Initialize lottery prize pool
- `testWeaponSkin()` - Grant test player items and currency

### Player Functions
- `startGame()` - Start a new game
- `gameOver(uint time, uint kills)` - End game and record score
- `reLive()` - Continue playing (placeholder)
- `buyOrUpgradeWeapon(uint id)` - Buy or upgrade weapon
- `buyOrUpgradeSkin(uint id)` - Buy or upgrade skin
- `requestLottery()` - Enter lottery
- `mintGold()` - Purchase gold with native tokens

### View Functions
- `getPlayerAllWeaponInfo(address player)` - Get player's weapons and levels
- `getPlayerAllSkinInfo(address player)` - Get player's skins and levels
- `getPlayerAllAssets(address player)` - Get player's gold and diamonds
- `getPlayerLastLotteryResult(address player)` - Get player's latest lottery result
- `getTopListInfo()` - Get leaderboard information
