# Verse, the hyperexchange protocol

# Overview

Verse is an autonomous exchange protocol for NFTs. On Verse, anyone can permissionlessly deploy a cryptomedia pair. Each pair consists of an NFT (ERC-721) contract and an ERC-20 contract. The price and supply of the ERC-20 token is governed by a continuous bonding curve, allowing anyone to buy and sell the token with instant liquidity. At any time, holders of the ERC-20 token who own at least 1 token can redeem the underlying NFT in the ERC-721 contract. When an owner redeems an ERC-20 token, that token is transferred and locked in the ERC-721 contract and the redeemer is minted an NFT. 

Thus, Verse enables a new mechanism for NFT exchanges which better mimic social behaviors than the traditional auction model. As more people demand the NFT, the price programmatically increases, and as demand falls, the price decreases. Enabling autonomous exchanges around NFTs can better mirror social behaviors around buying and selling and enable more people to participate in ownership of digital assets.


# Cryptomedia Pair

The cornerstone of the protocol is the `PairFactory` contract. The `PairFactory` is a factory contract which handles deployment of cryptomedia pairs as minimal clone proxies delegating functionality to corresponding logic contracts. Each pair consists of a `Cryptomedia` contract (an ERC-721 NFT contract) and an `Exchange` contract (an ERC-20 contract). The `create` function deploys the pair.

# Cryptomedia Contract

Each `Cryptomedia` contract deployed is an ERC-721 contract. The tokenURI for each NFT minted through this contract is identical. Minting functionality of NFTs is managed exclusively by the paired `Exchange` contract.

# Exchange Contract
Each `Exchange` contract deployed is an ERC-20 contract. This contract has a built-in autonomous exchange governing the price and supply of the underlying token through the use of a bonding curve. Anyone can buy and sell tokens from this contract with instant liquidity, meaning that the contract will mint and burn tokens on-demand, respectively. The bonding curve is based on a power function, and so the price of the token increases as supply increases, and the price decreases as supply decreases.

Anyone who owns >= 1 atomic token for this contract can call the `redeem` function. This function makes a call to the paired ERC-721 contract. Upon the token owner calling this function, the contract transfers 1 token from the caller to the paired ERC-721 contract. In exchange, the ERC-721 contract mints and transfers an NFT to the caller. In effect, the redeemed ERC-20 token is now locked in the ERC-721 contract. This has the effect of maintaining some base price level for the NFT, as the redeemed token can never be burned and subsequently decrease the token's price. 

Additionally, upon deployment, the pair creator can specify a "creator share". The creator share represents a royalty fee on each transaction that occurs through the contract. By specifying a share percentage, the creator can be perpetually compensated for trades that happen with the token. 

# Summary + Vision
The ability to embed an autonomous exchange within an NFT has massive implications. Notably, one can now effectively program supply and demand for any digital asset. We saw nascent experiments with this behavior in projects like Unisocks and Saint Fame. Now, what if anyone could enable this mechanism and create an "internet-native stock"? 

Imagine the Yeezys of the future being exchanged on the Verse protocol. This would enable people to participate in the financial upside of the asset by buying any fractional quantity of the underlying token. And those who want the asset can redeem their tokens at any time. The protocol mirrors social drivers of price and demand, and enables every digital asset to also be its own market. You can also imagine the protocol used for new social media primitives. What if only holders of a specific NFT could post to a certain website? As the demand to be included on this website increased and decreasd, the price for the NFT would automatically increase and decrease. With future auxillary protocol additions like staking-to-vote, one could envision Verse being used to create new forms of curation and content markets.

Verse is called the "hyperexchange" because it is a hyperstructure that enables every digital "thing" to have an autonomous exchange. The implications for this new mechanism are far-reaching, and I hope to work with creative people in this space to experiment with the possibiliies. 

# Stuff to do

These contracts are tested using Foundry. Thus far I've created a few test cases but the next step is to create a more robust fuzzing test suite to check against different scenarios.