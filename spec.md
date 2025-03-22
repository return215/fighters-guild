# Program Specification

A multipage app in Vite + TS.

Hosted on GitHub Pages at <https://fg.return215.xyz>.

Has `.nojekyll` to prevent automatic Jekyll from running.

Data is saved to a Supabase PostgreSQL database.

## Functionality

The page should be available to the public, with ONLY login avaliable to the site for administrators. Registrations are handled in case-by-case basis by the administrators.

The public only has viewing access to the site, the administrator has all access, including editing of data and adding new contracts to the site.

## Data Models

### Discord User

```ts
interface DiscordUser {
  displayName?: string
  id?: number
  username: string
  aliases: string[]
}
```

### Player

```ts
interface Player extends DiscordUser {
  inGameName: string
  ipSpent: number
  payout: number
}
```

### Contract

```ts
interface Contract {
  clientFaction?: string
  attackerFaction: string
  defenderFaction?: string
  price: number
  rate: number
  createdAt: Date
  completedAt?: Date
  status: 'bidding' | 'canceled' | 'waiting' | 'active' | 'completed'
  message: string
  auctionDuration: number
  auctionExtOnBid: number
  startingPrice: number
}
```

The status means:

- `bidding`: contract is open for bidding
- `canceled`: contract is canceled as nobody bids
- `waiting`: contract is waiting for the attacker to initiate the attack
- `active`: contract is active, currently in battle
- `completed`: contract is completed, battle ended

## Page Structure

### Index

File name: index.html

Provides jump points. Shows most recent non-canceled contract, and based on status:

- Bidding: show expected end of bidding time, show attacker
- Waiting: show expected end of waiting time, hide winner and defender (as there is none), show attacker
- Active: show expected end of active time, hide winner, show attacker and defender
- Completed: show time of completion

Also provide list of previous contracts in reverse chronological order at [List of Contracts](#list-of-contracts).

### Contract Page

File name: contract.html

Shows all details of the contract.

### List of Contracts

File name: contracts.html

Shows list of contracts in reverse chronological order. Each entry has a link to the contract page.

### Auction Starter

File name: auction.html

List of Faction Users on Discord:

| Display name       | Discord ID          | Username                 |
| ------------------ | ------------------- | ------------------------ |
| MindTech Institute | 1046737715128967179 | @MindTech Institute#3856 |
| Cybernetics Inc.   | 1049991291796205650 | @Cybernetics Inc.#0970   |
| Protectores Silva  | 1049992354624438374 | @Protectores Silva#8965  |
| Delta Collective   | 1049991937622560839 | @Delta Collective#3789   |
| Band of Brothers   | 1260603147768823829 | Band of Brothers#7561    |
| Cloudy Operatives  | 1193585899859083274 | @Cloudy Operatives#5529  |

Message is provided and will be appended to output.

The following are customizable:

- Starting price: default 10
- Offer period: default 24 hours
- Extension on bid: default 120 minutes
- Rate: default 50.000 (50k) IP

Result: a Discord command

```ts
`/auction_offer starting_price:${startingPrice} offer_period:${auctionDuration} extension_on_bid:${auctionExtOnBid} channel:Auction House (default)  anonymous:True bidding_policy:Each bid increases the price by 10% limit_to_factions:True description:${message} (Fighters Guild services; ${offerPeriod} hours + ${auctionExtOnBid} minute extension; price per ${Math.floor(rate/100)/10}k IP)`
```

Check winner: a message is posted on DM, copy that here and check for `<${discordId}>`. Add a button to save this winner and final price and rate to localStorage/database.

```ts
`You've sold \`${message} (Fighters Guild services; ${auctionDuration} hours + ${auctionExtOnBid} minute extension; price per ${Math.floor(rate/100)/10}k IP)\` (custom offer) for **${price}G** https://discord.com/channels/562910943848169472/1105092028011913318/1338064241143451668 to <@${id}>!`
```

Saved in localStorage/database into the [contracts](#contract) table.

Template message of auction end:

### Payout

Filename: payout.html

Has a field for total IP spent by FG.

Has an editable table for each player, rows can be added and deleted, each field in player can be edited directly. Payout is calculated automatically.

Payout is calculated as such:

```ts
function calculatePayout(price: number, ip: number, rate: number) {
  return Math.round(price*ip/rate)
}
```

Additionally, allow parsing of text to fields. This can be seen in the [roleplay forums](https://discord.com/channels/562910943848169472/1046018753504231434)

Field 1 (Factions)

```txt
`----------------------------------------`
`  1. Protectores Silva     27,432,052 IP`
`  2. Cybernetics Inc.       6,724,134 IP`
`  3. Fighters Guild         3,358,450 IP`
`  4. MindTech Institute     2,070,891 IP`
`  5. Band of Brothers       1,807,839 IP`
`  6. Delta Collective       1,733,561 IP`
`----------------------------------------`
```

```ts
function makeReMatchFaction(tag: string): RegExp {
  const reString = `\s+\d+\. \[${tag}\] (.+?)\s+(\d{1,3}(?:,\d{3})*) IP`
  return new RegExp(RegExp.escape(reString))
}

const reMatchFactionFg = makeReMatchFaction("Fighters Guild")
```

Field 2 (Players)

```txt
`-------------------------------------`
`  1. [PS] Nex           16,441,343 IP`
`  2. [PS] BPS           10,912,134 IP`
`  3. [CI] LostNFound     1,658,272 IP`
`  4. [CI] makinef        1,278,250 IP`
`  5. [FG] AlexxDev       1,123,000 IP`
`  6. [CI] Mindless91     1,091,250 IP`
`  7. [MT] ivzave         1,074,505 IP`
`  8. [CI] Happypig37     1,022,940 IP`
`  9. [BB] I N K            957,824 IP`
` 10. [CI] admw2            872,630 IP`
`-------------------------------------`
` 11. [FG] revalx           856,620 IP`
` 12. [FG] Belle            766,510 IP`
` 13. [DC] aliurmir         738,933 IP`
` 14. [CI] Exantos          687,792 IP`
` 15. [FG] KingTIMMY        591,320 IP`
` 16. [DC] 10funtov         412,126 IP`
` 17. [BB] Macmep           375,000 IP`
` 18. [MT] Untamed          374,170 IP`
` 19. [BB] Unnamed          293,000 IP`
` 20. [DC] Lark             252,370 IP`
`-------------------------------------`
` 21. [MT] DinoSaurex       204,422 IP`
` 22. [MT] Menkar 829       196,781 IP`
` 23. [DC] regulus          186,132 IP`
` 24. [DC] DaniilVolk       144,000 IP`
` 25. [BB] AJOJ666          140,000 IP`
` 26. [MT] Ebu Hohlov        91,260 IP`
` 27. [MT] MyR               88,353 IP`
` 28. [CI] gonjaman19        88,000 IP`
` 29. [PS] Gleban            49,241 IP`
` 30. [MT] OnlyIF            41,400 IP`
`-------------------------------------`
` 31. [BB] Ebasher           38,015 IP`
` 32. [PS] poolyk            29,334 IP`
` 33. [CI] GreenOtter        25,000 IP`
` 34. [FG] Nev               21,000 IP`
` 35. [BB] T                  4,000 IP`
`-------------------------------------`
```

```ts
function makeReMatchPlayer(tag: string): RegExp {
  const reString = `\s+\d+\. \[${tag}\] (.+?)\s+(\d{1,3}(?:,\d{3})*) IP`
  return new RegExp(RegExp.escape(reString))
}

const reMatchPlayerInFg = makeReMatchPlayer("FG")
// // above is equivalent to:
// const reMatchPlayerInFG: RegExp = /\s+\d+\. \[FG\] (.+?)\s+(\d{1,3}(?:,\d{3})*) IP/
```

### Payout Invoice

Shows multiple format: text to be sent to Discord by FG, HTML with commands to copy by the client faction
