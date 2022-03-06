/// Luxury rap, the Hermés of verses
/// Sophisticated ignorance, write my curses in cursive
/// I get it custom, you a customer
/// You ain't accustomed to going through customs, you ain't been nowhere, huh?

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.11;

import "./Exchange.sol";
import "solmate/tokens/ERC721.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";


contract Cryptomedia is ERC721 {
    using Counters for Counters.Counter;
    using Strings for uint256;

    // ======== Storage ========
    address public exchange; // exchange token pair address
    address public immutable factory; // pair factory address
    string public baseURI; // NFT base URI
    Counters.Counter currentTokenId; // Counter keeping track of last minted token id

    // ======== Constructor ========
    constructor(address _factory) ERC721("Verse", "VERSE") {
        factory = _factory;
     }

    // ======== Initializer ========
    function initialize(
        string calldata _name,
        string calldata _symbol,
        string calldata _baseURI,
        address _exchange
    ) external {
        require(msg.sender == factory, "UNAUTHORIZED");
        name = _name;
        symbol = _symbol;
        baseURI = _baseURI;
        exchange = _exchange;
        currentTokenId.increment();
    }

    // ======== Modifier ========
    /**
    * @notice Authorize exchange contract to call functions
    */
    modifier onlyExchange() {
        require(msg.sender == exchange, "UNAUTHORIZED");
        _;
    }

    // ======== Functions ========
    /**
    * @notice Mint NFT for recipient redeeming 1 exchange token
    */
    function mint(address _recipient) external onlyExchange {
        _mint(_recipient, currentTokenId.current());
        currentTokenId.increment();
    }

    /**
    * @notice Return tokenURI for NFT
    */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(ownerOf[tokenId] != address(0), "TOKEN_DOES_NOT_EXIST"); 
        return bytes(baseURI).length > 0 ? baseURI : "";
    }
}

