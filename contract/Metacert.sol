// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Metacert is ERC721A, Ownable {
    using Strings for uint256;
    using ECDSA for bytes32;
    

    uint256 constant public MAX_SUPPLY = 100000;
    uint256 constant public MAX_TX_LIMIT = 20;


    // this could change
    uint256 public publicPrice = 0 ether;

    bool public isPublicSale; 
    bool public isURIFrozen;
    bool public revealed;

    string private baseURI;
    
    string public unrevealedURI;
    string public baseExtension = ".json";

    uint private reserved;

    constructor() ERC721A("Metacert", "MC") {

    }

    function mint(uint256 amount) external payable {
        require(isPublicSale, "Public Sale Inactive");
        require(amount > 0, "Number of tokens should be more than 0");
        require(amount <= MAX_TX_LIMIT, "Mint Overflow");
        require(totalSupply() + amount <= MAX_SUPPLY, "Sold Out");
        require(publicPrice * amount <= msg.value, "Insufficient Funds");

        _safeMint(msg.sender, amount);
    }

    function setUnrevealedURI(string calldata _unrevealedURI) external onlyOwner {
        unrevealedURI = _unrevealedURI;
    }

    function reveal() external onlyOwner {
        require(!isURIFrozen, "URI is Frozen");
        revealed = !revealed;
    }

    function setBaseExtension(string calldata _newBaseExtension) external onlyOwner {
        require(!isURIFrozen, "URI is Frozen");
        baseExtension = _newBaseExtension;
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        require(!isURIFrozen, "URI is Frozen");
        baseURI = newURI;
    }

    function togglePublicSale() external onlyOwner {
        isPublicSale = !isPublicSale;
    }

    function freezeURI() external onlyOwner {
        isURIFrozen = true;
    }

    function withdraw() external onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    // view functions
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        if(revealed == false) {
            return unrevealedURI;
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    // private & internal functions
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

}


