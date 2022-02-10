// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

import "./Exchange.sol";
import "solmate/tokens/ERC721.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

error TokenDoesNotExist(uint256 tokenId);
error Unauthorized();

contract Cryptomedia is ERC721 {
    using Counters for Counters.Counter;
    using Strings for uint256;

    // ======== Storage ========
    address public exchange; // exchange token pair address
    address public factory; // cryptomedia factory address
    string public baseURI; // NFT base URI
    Counters.Counter currentTokenId; // Counter keeping track of last minted token id

    // ======== Constructor ========
    constructor(address _factory) ERC721("Verse", "VERSE") {
        factory = _factory;
        currentTokenId.increment();
     }

    // ======== Initializer ========
    function initialize(
        string calldata _name,
        string calldata _symbol,
        string calldata _baseURI,
        address _exchange
    ) external {
        if (msg.sender != factory) revert Unauthorized();
        name = _name;
        symbol = _symbol;
        baseURI = _baseURI;
        exchange = _exchange;
    }

    // ======== Functions ========
    function mint(address _recipient) external {
        if (msg.sender != address(exchange)) revert Unauthorized();
        _mint(_recipient, currentTokenId.current());
        currentTokenId.increment();
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (ownerOf[tokenId] == address(0)) revert TokenDoesNotExist(tokenId);
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
}

